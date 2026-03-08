defmodule WebUi.Iur.Interpreter do
  @moduledoc """
  Interprets canonical Unified-IUR layout trees into deterministic WebUi runtime descriptors.
  """

  alias WebUi.Events.ElmBindings
  alias WebUi.Iur.Dependency
  alias WebUi.TypedError

  @layout_kinds MapSet.new(["vbox", "hbox"])

  @widget_aliases %{
    "text" => "label",
    "textinput" => "text_input",
    "text_input" => "text_input",
    "button" => "button",
    "label" => "label",
    "gauge" => "gauge",
    "sparkline" => "sparkline",
    "bar_chart" => "bar_chart",
    "line_chart" => "line_chart",
    "table" => "table",
    "menu" => "menu",
    "context_menu" => "context_menu",
    "tabs" => "tabs",
    "tree_view" => "tree_view"
  }

  @signal_fields_by_widget %{
    "button" => [:on_click],
    "text_input" => [:on_change, :on_submit]
  }

  @spec interpret(map() | struct(), keyword()) :: {:ok, map()} | {:error, TypedError.t()}
  def interpret(spec, opts \\ []) when is_list(opts) do
    correlation_id = Keyword.get(opts, :correlation_id, "iur")

    with {:ok, normalized_root, widgets, signals} <- normalize_node(spec, [], correlation_id),
         {:ok, events} <- build_events(signals, correlation_id) do
      {:ok,
       %{
         root: normalized_root,
         widgets: widgets,
         signals: signals,
         events: events
       }}
    end
  end

  defp normalize_node(spec, path, correlation_id) do
    with {:ok, normalized_map} <- normalize_node_input(spec, correlation_id),
         {:ok, kind} <- infer_kind(normalized_map, correlation_id),
         {:ok, id} <- infer_id(normalized_map, kind, path, correlation_id) do
      if MapSet.member?(@layout_kinds, kind) do
        normalize_layout_node(normalized_map, kind, id, path, correlation_id)
      else
        normalize_widget_node(normalized_map, kind, id, correlation_id)
      end
    end
  end

  defp normalize_layout_node(node, kind, id, path, correlation_id) do
    children = fetch_any(node, :children, [])

    if is_list(children) do
      {children_nodes, widgets, signals} =
        children
        |> Enum.with_index()
        |> Enum.reduce({[], [], []}, fn {child, index}, {acc_nodes, acc_widgets, acc_signals} ->
          case normalize_node(child, path ++ [index], correlation_id) do
            {:ok, child_node, child_widgets, child_signals} ->
              {
                acc_nodes ++ [child_node],
                acc_widgets ++ child_widgets,
                acc_signals ++ child_signals
              }

            {:error, %TypedError{} = error} ->
              throw({:normalize_error, error})
          end
        end)

      {:ok,
       %{
         type: :layout,
         kind: kind,
         id: id,
         props: layout_props(node),
         children: children_nodes
       }, widgets, signals}
    else
      {:error,
       TypedError.new(
         "iur.interpreter.invalid_children",
         "validation",
         false,
         %{kind: kind, id: id, reason: "children must be a list"},
         correlation_id
       )}
    end
  catch
    {:normalize_error, %TypedError{} = error} -> {:error, error}
  end

  defp normalize_widget_node(node, kind, id, _correlation_id) do
    widget_kind = Map.get(@widget_aliases, kind, kind)

    signals =
      @signal_fields_by_widget
      |> Map.get(widget_kind, [])
      |> Enum.reduce([], fn field, acc ->
        case fetch_any(node, field) do
          nil ->
            acc

          signal ->
            acc ++
              [
                %{
                  widget_id: id,
                  widget_kind: widget_kind,
                  source_field: field |> Atom.to_string(),
                  signal: normalize_signal(signal)
                }
              ]
        end
      end)

    {:ok,
     %{
       type: :widget,
       kind: widget_kind,
       id: id,
       props: widget_props(node)
     }, [widget_descriptor(id, widget_kind)], signals}
  end

  defp normalize_node_input(spec, correlation_id) do
    with {:ok, normalized_map} <- normalize_spec_map(spec, correlation_id),
         :ok <- Dependency.validate_schema_markers(normalized_map, correlation_id) do
      {:ok, normalized_map}
    end
  end

  defp normalize_spec_map(%_{} = spec, correlation_id) do
    if Dependency.canonical_iur_struct?(spec) do
      normalize_canonical_struct(spec, correlation_id)
    else
      {:ok, normalize_map(spec)}
    end
  end

  defp normalize_spec_map(spec, _correlation_id), do: {:ok, normalize_map(spec)}

  defp normalize_canonical_struct(spec, correlation_id) when is_struct(spec) do
    try do
      metadata = UnifiedIUR.Element.metadata(spec)
      children = UnifiedIUR.Element.children(spec)

      normalized_map =
        metadata
        |> normalize_map()
        |> Map.put(:children, children)
        |> Map.put(:__struct__, spec.__struct__)

      {:ok, normalized_map}
    rescue
      Protocol.UndefinedError ->
        {:error,
         TypedError.new(
           "iur.interpreter.unsupported_canonical_struct",
           "validation",
           false,
           %{struct: inspect(spec.__struct__)},
           correlation_id
         )}
    end
  end

  defp build_events(signals, correlation_id) when is_list(signals) do
    signals
    |> Enum.reduce_while({:ok, []}, fn signal_binding, {:ok, acc} ->
      case build_event(signal_binding) do
        {:ok, event} ->
          {:cont, {:ok, acc ++ [event]}}

        {:error, %TypedError{} = error} ->
          {:halt,
           {:error,
            TypedError.new(
              "iur.interpreter.signal_mapping_failed",
              "validation",
              false,
              %{
                source_field: Map.get(signal_binding, :source_field),
                widget_id: Map.get(signal_binding, :widget_id),
                widget_kind: Map.get(signal_binding, :widget_kind),
                reason: error.error_code
              },
              correlation_id
            )}}
      end
    end)
  end

  defp build_event(%{
         source_field: "on_click",
         widget_id: widget_id,
         widget_kind: widget_kind,
         signal: signal_payload
       })
       when is_binary(widget_id) and is_binary(widget_kind) and is_map(signal_payload) do
    ElmBindings.on_click(widget_id, widget_kind, signal_payload)
  end

  defp build_event(%{
         source_field: "on_change",
         widget_id: widget_id,
         widget_kind: widget_kind,
         signal: signal_payload
       })
       when is_binary(widget_id) and is_binary(widget_kind) and is_map(signal_payload) do
    value = fetch_string(signal_payload, :value) || "__iur_input_value__"
    data = Map.delete(signal_payload, :value) |> Map.delete("value")

    ElmBindings.on_input(widget_id, widget_kind, value, data)
  end

  defp build_event(%{
         source_field: "on_submit",
         widget_id: widget_id,
         widget_kind: widget_kind,
         signal: signal_payload
       })
       when is_binary(widget_id) and is_binary(widget_kind) and is_map(signal_payload) do
    ElmBindings.on_submit(widget_id, widget_kind, signal_payload)
  end

  defp build_event(_signal_binding) do
    {:error,
     TypedError.new(
       "iur.interpreter.unsupported_signal_binding",
       "validation",
       false,
       %{}
     )}
  end

  defp normalize_map(%_{} = struct), do: struct |> Map.from_struct() |> normalize_map()

  defp normalize_map(map) when is_map(map) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      normalized_key =
        case key do
          atom when is_atom(atom) -> atom
          binary when is_binary(binary) -> safe_atom(binary)
          other -> other
        end

      Map.put(acc, normalized_key, value)
    end)
  end

  defp normalize_map(_), do: %{}

  defp infer_kind(node, correlation_id) when is_map(node) do
    kind =
      fetch_any(node, :type)
      |> normalize_kind_from_value()
      |> case do
        nil -> infer_kind_from_struct_name(fetch_any(node, :__struct__))
        value -> value
      end

    if is_binary(kind) and kind != "" do
      {:ok, kind}
    else
      {:error,
       TypedError.new(
         "iur.interpreter.unknown_element_type",
         "validation",
         false,
         %{node: inspect(node)},
         correlation_id
       )}
    end
  end

  defp infer_id(node, kind, path, correlation_id)
       when is_map(node) and is_binary(kind) and is_list(path) do
    explicit_id = fetch_any(node, :id)

    case normalize_id_value(explicit_id) do
      nil ->
        {:ok, generated_id(kind, path)}

      id when is_binary(id) and id != "" ->
        {:ok, id}

      _ ->
        {:error,
         TypedError.new(
           "iur.interpreter.invalid_id",
           "validation",
           false,
           %{kind: kind, id: explicit_id},
           correlation_id
         )}
    end
  end

  defp layout_props(node) when is_map(node) do
    %{
      spacing: fetch_any(node, :spacing, 0),
      align_items: fetch_any(node, :align_items),
      justify_content: fetch_any(node, :justify_content),
      padding: fetch_any(node, :padding),
      visible: fetch_any(node, :visible, true)
    }
  end

  defp widget_props(node) when is_map(node) do
    node
    |> Map.drop([:__struct__, :type, :children, :on_click, :on_change, :on_submit])
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case key do
        :id -> acc
        _ -> Map.put(acc, key, value)
      end
    end)
  end

  defp widget_descriptor(id, widget_kind) when is_binary(id) and is_binary(widget_kind) do
    %{
      widget_id: id,
      widget_kind: widget_kind
    }
  end

  defp normalize_signal(signal) when is_atom(signal), do: %{action: Atom.to_string(signal)}
  defp normalize_signal(signal) when is_binary(signal), do: %{action: signal}

  defp normalize_signal({action, payload}) when is_atom(action) and is_map(payload) do
    Map.put_new(payload, :action, Atom.to_string(action))
  end

  defp normalize_signal(map) when is_map(map), do: normalize_map(map)
  defp normalize_signal(other), do: %{value: other}

  defp normalize_kind_from_value(nil), do: nil

  defp normalize_kind_from_value(value) when is_atom(value) and not is_nil(value),
    do: value |> Atom.to_string() |> normalize_kind_token()

  defp normalize_kind_from_value(value) when is_binary(value), do: normalize_kind_token(value)
  defp normalize_kind_from_value(_value), do: nil

  defp normalize_kind_token(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> String.replace("-", "_")
  end

  defp infer_kind_from_struct_name(nil), do: nil

  defp infer_kind_from_struct_name(module) when is_atom(module) and not is_nil(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> case do
      nil -> nil
      name -> name |> Macro.underscore() |> normalize_kind_token()
    end
  end

  defp infer_kind_from_struct_name(_module), do: nil

  defp normalize_id_value(nil), do: nil
  defp normalize_id_value(value) when is_atom(value), do: Atom.to_string(value)

  defp normalize_id_value(value) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_id_value(value), do: to_string(value)

  defp generated_id(kind, []) when is_binary(kind), do: "#{kind}_root"

  defp generated_id(kind, path) when is_binary(kind) and is_list(path) do
    suffix =
      path
      |> Enum.map(&Integer.to_string/1)
      |> Enum.join("_")

    "#{kind}_#{suffix}"
  end

  defp fetch_any(map, key, default \\ nil) when is_map(map) and is_atom(key) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp fetch_string(map, key) when is_map(map) do
    case fetch_any(map, key) do
      value when is_binary(value) -> value
      _ -> nil
    end
  end

  defp safe_atom(binary) when is_binary(binary) do
    try do
      String.to_existing_atom(binary)
    rescue
      ArgumentError -> binary
    end
  end
end
