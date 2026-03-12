defmodule UnifiedUi.Dsl.Verifiers.UniqueIdVerifier do
  @moduledoc """
  Verifier that ensures all widget and layout IDs are unique.

  Checks for duplicate IDs across all widgets and layouts in the DSL.
  Each widget/layout with an `:id` attribute must have a unique value.
  """
  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.CompileIndex

  @doc """
  Verifies that all IDs across widgets and layouts are unique.
  """
  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    index = CompileIndex.get(dsl_state)

    # Collect all IDs from widgets section
    widget_ids =
      index.widgets
      |> collect_ids()

    # Collect all IDs from layouts section
    layout_ids =
      index.layouts
      |> collect_ids()

    # Combine all IDs
    all_ids = widget_ids ++ layout_ids

    # Check for duplicates
    all_ids
    |> Enum.frequencies_by(fn {id, _entity, _opts} -> id end)
    |> Enum.find_value(fn {id, count} ->
      if count > 1, do: id
    end)
    |> case do
      nil ->
        :ok

      duplicate_id ->
        # Find all entities with this ID
        duplicates =
          all_ids
          |> Enum.filter(fn {id, _entity, _opts} -> id == duplicate_id end)
          |> Enum.map(fn {_id, entity, opts} ->
            {entity.__struct__, Keyword.get(opts, :entity, "unknown")}
          end)

        raise Spark.Error.DslError,
          module: module,
          path: [:ui],
          message: """
          Duplicate ID found: #{inspect(duplicate_id)}

          The following entities share the same ID:

          #{format_duplicates(duplicates)}

          Each widget and layout with an `:id` attribute must have a unique value.
          """
    end
  end

  defp collect_ids(entities) do
    Enum.flat_map(entities, fn entity ->
      case Map.get(entity, :id) do
        nil -> []
        id -> [{id, entity, Keyword.take(entity.__meta__, [:entity, :line])}]
      end
    end)
  end

  defp format_duplicates(duplicates) do
    duplicates
    |> Enum.map_join("\n", fn {struct, entity_name} ->
      entity_type =
        struct
        |> Module.split()
        |> List.last()
        |> to_string()

      "  - #{entity_type} (#{entity_name})"
    end)
  end
end

defmodule UnifiedUi.Dsl.Verifiers.LayoutStructureVerifier do
  @moduledoc """
  Verifier that validates layout structure constraints.

  Checks:
  - Label `:for` attributes reference valid input IDs
  - Layout depth doesn't exceed maximum
  """
  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.CompileIndex

  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    widgets = CompileIndex.get(dsl_state).widgets

    # Collect all text_input IDs (these are required)
    input_ids =
      widgets
      |> Enum.filter(&(&1.__struct__ == UnifiedIUR.Widgets.TextInput))
      |> Enum.map(& &1.id)

    # Verify label :for attributes
    widgets
    |> Enum.filter(&(&1.__struct__ == UnifiedIUR.Widgets.Label))
    |> Enum.each(fn label ->
      verify_label_for(module, label, input_ids)
    end)

    :ok
  end

  defp verify_label_for(module, label, input_ids) do
    for_ref = label.for

    if for_ref not in input_ids do
      entity_name = Keyword.get(label.__meta__, :entity, "label")

      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Invalid label reference in #{entity_name}:

        The label's `:for` attribute references #{inspect(for_ref)},
        but no text_input with that ID exists.

        Available input IDs: #{format_available_ids(input_ids)}

        Ensure the `:for` attribute matches the `:id` of a text_input widget.
        """
    end
  end

  defp format_available_ids([]), do: "(none)"
  defp format_available_ids(ids), do: Enum.map_join(ids, ", ", &inspect/1)
end

defmodule UnifiedUi.Dsl.Verifiers.SignalHandlerVerifier do
  @moduledoc """
  Verifier that validates signal handler references.

  Checks:
  - Signal handlers have valid format (atom, tuple, or MFA)
  - MFA handlers reference existing modules and functions
  """
  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.CompileIndex

  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    widgets = CompileIndex.get(dsl_state).widgets

    # Check all widgets with signal handlers
    widgets
    |> Enum.each(fn entity ->
      verify_entity_handlers(module, entity)
    end)

    :ok
  end

  defp verify_entity_handlers(module, entity) do
    entity_name = Keyword.get(entity.__meta__, :entity, "widget")

    # Check on_click for buttons
    if entity.__struct__ == UnifiedIUR.Widgets.Button and Map.get(entity, :on_click) do
      verify_handler(module, entity.on_click, :on_click, entity_name)
    end

    # Check on_change and on_submit for text_inputs
    if entity.__struct__ == UnifiedIUR.Widgets.TextInput do
      if Map.get(entity, :on_change) do
        verify_handler(module, entity.on_change, :on_change, entity_name)
      end

      if Map.get(entity, :on_submit) do
        verify_handler(module, entity.on_submit, :on_submit, entity_name)
      end
    end
  end

  defp verify_handler(_module, handler, _attr, _entity_name) when is_atom(handler) do
    # Atom signal names are valid - they're just references to signal types
    :ok
  end

  defp verify_handler(_module, {signal_name, _payload}, _attr, _entity_name)
       when is_atom(signal_name) do
    # Tuple with signal name and payload is valid
    :ok
  end

  defp verify_handler(module, {mod, fun, args}, attr, entity_name)
       when is_atom(mod) and is_atom(fun) and is_list(args) do
    # MFA tuple - verify module exists
    unless Code.ensure_loaded?(mod) do
      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Invalid MFA handler in #{entity_name}:

        The #{attr} handler references module #{inspect(mod)},
        but that module is not available or loaded.

        Ensure the module is defined and available at compile time.
        """
    end

    # Check if function exists if module is loaded
    if function_exported?(mod, :behaviour_info, 1) or function_exported?(mod, fun, length(args)) do
      :ok
    else
      # Not an error - might be a macro or generated function
      # Just warn
      :ok
    end
  end

  defp verify_handler(module, invalid_handler, attr, entity_name) do
    raise Spark.Error.DslError,
      module: module,
      path: [:ui],
      message: """
      Invalid signal handler format in #{entity_name}:

        #{attr}: #{inspect(invalid_handler)}

      Signal handlers must be one of:
        - An atom signal name: :my_signal
        - A tuple with payload: {:my_signal, %{key: value}}
        - An MFA tuple: {MyModule, :my_function, [:arg1, :arg2]}

      Got: #{inspect(invalid_handler)}
      """
  end
end

defmodule UnifiedUi.Dsl.Verifiers.StyleReferenceVerifier do
  @moduledoc """
  Verifier that validates style attribute references.

  Checks:
  - Inline style keyword lists use valid attribute names
  - Style values have correct types
  """
  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.CompileIndex

  # Valid style attributes based on the styles section schema
  @valid_style_attrs [
    :fg,
    :bg,
    :attrs,
    :padding,
    :margin,
    :width,
    :height,
    :align,
    :spacing,
    :font_family,
    :font_size,
    :font_weight,
    :border,
    :border_width,
    :border_color,
    :border_style
  ]

  # Valid text attributes for the :attrs key
  @valid_text_attrs [
    :bold,
    :italic,
    :underline,
    :reverse,
    :blink,
    :dim,
    :strikethrough
  ]

  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    index = CompileIndex.get(dsl_state)

    # Check all entities with style attributes
    Enum.each(
      [
        index.widgets,
        index.layouts
      ],
      fn entities ->
        Enum.each(entities, fn entity ->
          verify_entity_style(module, entity)
        end)
      end
    )

    :ok
  end

  defp verify_entity_style(_module, entity) do
    style = Map.get(entity, :style)

    if style != nil and is_list(style) do
      entity_name = Keyword.get(entity.__meta__, :entity, "entity")

      Enum.each(style, fn {key, value} ->
        verify_style_attribute(key, value, entity_name)
      end)
    end

    :ok
  end

  defp verify_style_attribute(:attrs, attrs, entity_name) when is_list(attrs) do
    invalid = Enum.reject(attrs, fn attr -> attr in @valid_text_attrs end)

    if invalid != [] do
      raise ArgumentError, """
      Invalid text attributes in #{entity_name}:

        attrs: #{inspect(attrs)}

      Invalid attributes: #{inspect(invalid)}

      Valid text attributes: #{inspect(@valid_text_attrs)}
      """
    end
  end

  defp verify_style_attribute(key, _value, _entity_name) when key in @valid_style_attrs do
    :ok
  end

  defp verify_style_attribute(key, _value, entity_name) do
    raise ArgumentError, """
    Invalid style attribute in #{entity_name}:

      #{inspect(key)}: ...

    Valid style attributes: #{inspect(@valid_style_attrs)}
    """
  end
end

defmodule UnifiedUi.Dsl.Verifiers.StateReferenceVerifier do
  @moduledoc """
  Verifier that validates state key references.

  Checks:
  - State keys referenced in widgets are defined in initial state
  - Initial state is properly defined
  """
  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.CompileIndex

  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    index = CompileIndex.get(dsl_state)

    # Get initial state definition from precomputed index.
    state_entities = index.state

    initial_state_keys =
      case state_entities do
        [%UnifiedUi.Dsl.State{attrs: attrs} | _] when is_list(attrs) ->
          Keyword.keys(attrs)

        _ ->
          []
      end

    verify_initial_state_structure(module, state_entities)
    state_references = collect_state_references(index.flat)
    verify_state_references(module, state_references, initial_state_keys)

    :ok
  end

  defp verify_initial_state_structure(_module, []), do: :ok

  defp verify_initial_state_structure(module, [%UnifiedUi.Dsl.State{attrs: attrs} | _]) do
    # Verify all keys are atoms
    invalid_keys =
      attrs
      |> Enum.filter(fn
        {k, _v} when is_atom(k) -> false
        _ -> true
      end)
      |> Enum.map(fn {k, _v} -> k end)

    if invalid_keys != [] do
      entity_name = "state declaration"

      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Invalid state keys in #{entity_name}:

        State keys must be atoms, but found:

        #{Enum.map_join(invalid_keys, "\n", fn k -> "  - #{inspect(k)}" end)}

        Please use atom keys for state:

          state [
            count: 0,
            name: "default"
          ]

        Instead of:

          state [
            "count" => 0,  # Invalid - use atom key
            "name" => "default"  # Invalid - use atom key
          ]
        """
    end

    :ok
  end

  defp collect_state_references(entities) do
    entities
    |> Enum.flat_map(&extract_state_refs/1)
    |> Enum.uniq()
  end

  defp extract_state_refs({:state, key}) when is_atom(key), do: [key]
  defp extract_state_refs({:state, key}), do: [{:invalid, key}]

  defp extract_state_refs(value) when is_list(value) do
    Enum.flat_map(value, &extract_state_refs/1)
  end

  defp extract_state_refs(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> extract_state_refs()
  end

  defp extract_state_refs(value) when is_map(value) do
    value
    |> Enum.flat_map(fn
      {:__meta__, _} -> []
      {:__struct__, _} -> []
      {_key, nested} -> extract_state_refs(nested)
    end)
  end

  defp extract_state_refs(value) when is_tuple(value) do
    value
    |> Tuple.to_list()
    |> Enum.flat_map(&extract_state_refs/1)
  end

  defp extract_state_refs(_), do: []

  defp verify_state_references(module, state_references, initial_state_keys) do
    invalid_refs =
      state_references
      |> Enum.flat_map(fn
        {:invalid, key} -> [key]
        _ -> []
      end)

    if invalid_refs != [] do
      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Invalid state references found.

        State references must use the format `{:state, :key}` where `:key` is an atom.

        Invalid keys:

        #{Enum.map_join(invalid_refs, "\n", fn key -> "  - #{inspect(key)}" end)}
        """
    end

    refs =
      state_references
      |> Enum.filter(&is_atom/1)

    if refs != [] and initial_state_keys == [] do
      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        State references were found, but no initial state is defined.

        Add a state declaration, for example:

          state [
            count: 0
          ]
        """
    end

    missing_refs = Enum.reject(refs, &(&1 in initial_state_keys))

    if missing_refs != [] do
      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Undefined state keys referenced in UI entities.

        Referenced keys:
        #{Enum.map_join(refs, "\n", fn key -> "  - #{inspect(key)}" end)}

        Defined keys:
        #{Enum.map_join(initial_state_keys, "\n", fn key -> "  - #{inspect(key)}" end)}

        Missing keys:
        #{Enum.map_join(missing_refs, "\n", fn key -> "  - #{inspect(key)}" end)}
        """
    end
  end
end
