defmodule UnifiedIUR.Validate do
  @moduledoc """
  Canonical validation helpers for normalized `UnifiedIUR` values.
  """

  alias UnifiedIUR.{Binding, Element, Interaction, Metadata, Style}
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Validate.Error

  @runtime_local_prefixes [
    "DesktopUi",
    "LiveUi",
    "ElmUi",
    "UnifiedUi",
    "Phoenix.LiveView",
    "Jido.Signal"
  ]

  @guidance_by_code %{
    invalid_element: %{
      construct_family: :core_model,
      guidance:
        "Validate values through UnifiedIUR.Normalize and ensure the root is a UnifiedIUR.Element."
    },
    missing_type: %{
      construct_family: :core_model,
      guidance:
        "Create elements through package constructors so canonical type values stay explicit."
    },
    missing_kind: %{
      construct_family: :core_model,
      guidance:
        "Use a known canonical kind from UnifiedIUR.Core, Widgets, Layout, Layer, Forms, or Canvas."
    },
    invalid_metadata: %{
      construct_family: :core_model,
      guidance:
        "Attach metadata through UnifiedIUR.Metadata so description, tags, and annotations stay portable."
    },
    invalid_children: %{
      construct_family: :display_systems,
      guidance: "Represent children as UnifiedIUR.Element.Child values with stable slot names."
    },
    invalid_child: %{
      construct_family: :display_systems,
      guidance:
        "Wrap nested elements with UnifiedIUR.Element.Child.new/2 or package constructors that do so for you."
    },
    invalid_style_attachment: %{
      construct_family: :theming,
      guidance: "Attach styles as UnifiedIUR.Style structs and keep style references portable."
    },
    invalid_theme_attachment: %{
      construct_family: :theming,
      guidance:
        "Attach themes as canonical maps or token references rather than runtime-local theme structs."
    },
    invalid_interaction_attachment: %{
      construct_family: :interactions,
      guidance: "Populate :interactions with UnifiedIUR.Interaction structs only."
    },
    invalid_interactions_attachment: %{
      construct_family: :interactions,
      guidance: "Keep the :interactions attachment as a list of UnifiedIUR.Interaction structs."
    },
    invalid_binding_attachment: %{
      construct_family: :interactions,
      guidance: "Populate :bindings with UnifiedIUR.Binding structs only."
    },
    invalid_bindings_attachment: %{
      construct_family: :interactions,
      guidance: "Keep the :bindings attachment as a list of UnifiedIUR.Binding structs."
    },
    invalid_interaction_scope: %{
      construct_family: :interactions,
      guidance:
        "Represent interaction_scope as a canonical map describing portable routing context."
    },
    missing_required_widget_field: %{
      construct_family: :widgets,
      guidance:
        "Populate the required canonical fields for this widget kind before exporting or rendering."
    },
    invalid_widget_state: %{
      construct_family: :widgets,
      guidance:
        "Normalize promoted widget state into stable canonical values and supported state combinations."
    },
    unsupported_opaque_payload: %{
      construct_family: :widgets,
      guidance:
        "Represent widget payloads with plain canonical values rather than callbacks, process handles, ports, or references."
    },
    invalid_collection_source: %{
      construct_family: :collection,
      guidance:
        "Represent repeated collection sources as list-oriented canonical bindings, not resource relationships or runtime callbacks."
    },
    missing_collection_template: %{
      construct_family: :collection,
      guidance:
        "Attach exactly one canonical child template in the :template slot for repeated collection rendering."
    },
    duplicate_collection_key: %{
      construct_family: :collection,
      guidance:
        "Use a stable key path that resolves to unique values for detectable static collection data."
    },
    invalid_row_scope_binding: %{
      construct_family: :collection,
      guidance:
        "Keep row-scope bindings inside the repeated template and reference only the declared item or index aliases."
    },
    runtime_local_escape_hatch: %{
      construct_family: :interoperability,
      guidance:
        "Keep runtime-native structs out of canonical IUR and translate them at runtime-library boundaries."
    }
  }

  @promoted_widget_kinds [
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot,
    :segmented_button_group,
    :list_item_multi_column,
    :artifact_row,
    :sticky_header,
    :pipeline_stepper_horizontal,
    :segmented_progress_bar,
    :workflow_stage_list_vertical,
    :meter_thin,
    :slide_over_panel,
    :event_callout,
    :redline_inline,
    :code_block_syntax_highlighted,
    :chat_composer,
    :host_form_shell
  ]

  @required_widget_fields %{
    disclosure: [[:disclosure, :label]],
    kicker: [[:kicker, :value]],
    avatar: [[:avatar, :label]],
    presence_dot: [[:presence, :status]],
    segmented_button_group: [[:segments, :items]],
    list_item_multi_column: [[:list_item, :columns]],
    artifact_row: [[:artifact, :value], [:artifact, :title]],
    sticky_header: [[:sticky_header, :title]],
    pipeline_stepper_horizontal: [[:workflow, :steps]],
    segmented_progress_bar: [[:progress, :segments]],
    workflow_stage_list_vertical: [[:workflow, :stages]],
    meter_thin: [[:meter, :current]],
    slide_over_panel: [[:panel, :placement]],
    event_callout: [[:callout, :message]],
    redline_inline: [[:redline, :before_text], [:redline, :after_text]],
    code_block_syntax_highlighted: [[:code_block, :code]],
    chat_composer: [[:composer]],
    host_form_shell: [[:form_shell, :owner], [:form_shell, :lifecycle]]
  }

  @spec element(Element.t()) :: :ok | {:error, [Error.t()]}
  def element(%Element{} = element) do
    errors =
      []
      |> Kernel.++(validate_element_shape(element))
      |> Kernel.++(validate_metadata(element.metadata))
      |> Kernel.++(validate_attachments(element.attributes))
      |> Kernel.++(validate_promoted_widget(element))
      |> Kernel.++(validate_repeated_collection(element))
      |> Kernel.++(validate_runtime_local_values(element.attributes, [:attributes]))
      |> Kernel.++(validate_children(element.children))

    if errors == [], do: :ok, else: {:error, errors}
  end

  def element(other) do
    {:error,
     [
       Error.new(
         :invalid_element,
         "validation expects a canonical UnifiedIUR.Element struct",
         details: %{value: inspect(other)}
       )
     ]}
  end

  defp validate_element_shape(%Element{type: type, kind: kind}) do
    []
    |> maybe_add(
      is_nil(type),
      Error.new(:missing_type, "element type is required", path: [:type])
    )
    |> maybe_add(
      is_nil(kind),
      Error.new(:missing_kind, "element kind is required", path: [:kind])
    )
  end

  defp validate_metadata(%Metadata{}), do: []

  defp validate_metadata(other) do
    [
      Error.new(
        :invalid_metadata,
        "element metadata must be a UnifiedIUR.Metadata struct",
        path: [:metadata],
        details: %{value: inspect(other)}
      )
    ]
  end

  @spec diagnostics(Element.t() | map() | keyword()) :: map()
  def diagnostics(input) do
    case UnifiedIUR.Normalize.element(input) do
      {:ok, element} ->
        case element(element) do
          :ok ->
            %{
              valid?: true,
              identity: %{id: element.id, type: element.type, kind: element.kind},
              errors: [],
              construct_families: []
            }

          {:error, errors} ->
            %{
              valid?: false,
              identity: %{id: element.id, type: element.type, kind: element.kind},
              errors: Enum.map(errors, &diagnostic_entry/1),
              construct_families:
                errors
                |> Enum.map(&guidance_for_error/1)
                |> Enum.map(& &1.construct_family)
                |> Enum.uniq()
                |> Enum.sort()
            }
        end

      {:error, errors} ->
        %{
          valid?: false,
          identity: nil,
          errors: Enum.map(errors, &diagnostic_entry/1),
          construct_families:
            errors
            |> Enum.map(&guidance_for_error/1)
            |> Enum.map(& &1.construct_family)
            |> Enum.uniq()
            |> Enum.sort()
        }
    end
  end

  @spec guidance_for_error(Error.t() | atom()) :: %{
          construct_family: atom(),
          guidance: String.t()
        }
  def guidance_for_error(%Error{code: code}), do: guidance_for_error(code)

  def guidance_for_error(code) when is_atom(code) do
    Map.get(@guidance_by_code, code, %{
      construct_family: :unknown,
      guidance:
        "Review the canonical construct family and normalize the value before export or validation."
    })
  end

  defp validate_children(children) when is_list(children) do
    Enum.flat_map(Enum.with_index(children), fn {child, index} ->
      validate_child(child, [:children, index])
    end)
  end

  defp validate_children(other) do
    [
      Error.new(
        :invalid_children,
        "element children must be a list",
        path: [:children],
        details: %{value: inspect(other)}
      )
    ]
  end

  defp validate_child(%Child{slot: slot, element: nil}, _path)
       when is_atom(slot) or is_binary(slot),
       do: []

  defp validate_child(%Child{slot: slot, element: %Element{} = element}, path)
       when is_atom(slot) or is_binary(slot) do
    case element(element) do
      :ok -> []
      {:error, errors} -> Enum.map(errors, &prepend_path(&1, path))
    end
  end

  defp validate_child(%Child{}, path) do
    [
      Error.new(:invalid_child, "child slot must be an atom or string", path: path)
    ]
  end

  defp validate_child(other, path) do
    [
      Error.new(
        :invalid_child,
        "children must be UnifiedIUR.Element.Child structs",
        path: path,
        details: %{value: inspect(other)}
      )
    ]
  end

  defp validate_attachments(attributes) when is_map(attributes) do
    []
    |> validate_style(attributes)
    |> validate_theme(attributes)
    |> validate_interactions(attributes)
    |> validate_bindings(attributes)
    |> validate_interaction_scope(attributes)
  end

  defp validate_attachments(_other), do: []

  defp validate_style(errors, %{style: %Style{}}), do: errors

  defp validate_style(errors, %{style: style}) do
    errors ++
      [
        Error.new(
          :invalid_style_attachment,
          "style attachment must be a UnifiedIUR.Style struct",
          path: [:attributes, :style],
          details: %{value: inspect(style)}
        )
      ]
  end

  defp validate_style(errors, _attributes), do: errors

  defp validate_theme(errors, %{theme: theme}) when is_map(theme), do: errors

  defp validate_theme(errors, %{theme: theme}) do
    errors ++
      [
        Error.new(
          :invalid_theme_attachment,
          "theme attachment must be a map",
          path: [:attributes, :theme],
          details: %{value: inspect(theme)}
        )
      ]
  end

  defp validate_theme(errors, _attributes), do: errors

  defp validate_interactions(errors, %{interactions: interactions}) when is_list(interactions) do
    interaction_errors =
      interactions
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {%Interaction{}, _index} ->
          []

        {interaction, index} ->
          [
            Error.new(
              :invalid_interaction_attachment,
              "interactions attachment must contain UnifiedIUR.Interaction structs",
              path: [:attributes, :interactions, index],
              details: %{value: inspect(interaction)}
            )
          ]
      end)

    errors ++ interaction_errors
  end

  defp validate_interactions(errors, %{interactions: value}) do
    errors ++
      [
        Error.new(
          :invalid_interactions_attachment,
          "interactions attachment must be a list",
          path: [:attributes, :interactions],
          details: %{value: inspect(value)}
        )
      ]
  end

  defp validate_interactions(errors, _attributes), do: errors

  defp validate_bindings(errors, %{bindings: bindings}) when is_list(bindings) do
    binding_errors =
      bindings
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {%Binding{}, _index} ->
          []

        {binding, index} ->
          [
            Error.new(
              :invalid_binding_attachment,
              "bindings attachment must contain UnifiedIUR.Binding structs",
              path: [:attributes, :bindings, index],
              details: %{value: inspect(binding)}
            )
          ]
      end)

    errors ++ binding_errors
  end

  defp validate_bindings(errors, %{bindings: value}) do
    errors ++
      [
        Error.new(
          :invalid_bindings_attachment,
          "bindings attachment must be a list",
          path: [:attributes, :bindings],
          details: %{value: inspect(value)}
        )
      ]
  end

  defp validate_bindings(errors, _attributes), do: errors

  defp validate_interaction_scope(errors, %{interaction_scope: scope}) when is_map(scope),
    do: errors

  defp validate_interaction_scope(errors, %{interaction_scope: scope}) do
    errors ++
      [
        Error.new(
          :invalid_interaction_scope,
          "interaction_scope attachment must be a map",
          path: [:attributes, :interaction_scope],
          details: %{value: inspect(scope)}
        )
      ]
  end

  defp validate_interaction_scope(errors, _attributes), do: errors

  defp validate_promoted_widget(%Element{kind: kind, attributes: attributes})
       when kind in @promoted_widget_kinds do
    []
    |> Kernel.++(validate_required_widget_fields(kind, attributes))
    |> Kernel.++(validate_widget_state(kind, attributes))
    |> Kernel.++(validate_opaque_widget_payloads(attributes, [:attributes]))
  end

  defp validate_promoted_widget(%Element{}), do: []

  defp validate_required_widget_fields(kind, attributes) do
    @required_widget_fields
    |> Map.get(kind, [])
    |> Enum.flat_map(fn path ->
      if present_field?(attributes, path) do
        []
      else
        [
          Error.new(
            :missing_required_widget_field,
            "promoted widget #{inspect(kind)} is missing required field #{format_path(path)}",
            path: [:attributes | path],
            details: %{kind: kind, field: path}
          )
        ]
      end
    end)
  end

  defp validate_widget_state(:segmented_button_group, attributes) do
    segments = Map.get(attributes, :segments, %{})

    []
    |> maybe_invalid_value(
      Map.get(segments, :items),
      &is_list/1,
      "segmented_button_group items must be a deterministic list",
      [:attributes, :segments, :items]
    )
    |> maybe_invalid_member(
      Map.get(segments, :selection_mode),
      [:single, :multiple, :none],
      [:attributes, :segments, :selection_mode]
    )
    |> maybe_invalid_member(
      Map.get(segments, :orientation),
      [:horizontal, :vertical],
      [:attributes, :segments, :orientation]
    )
    |> maybe_add(
      Map.get(segments, :selection_mode) == :none and not is_nil(Map.get(segments, :active_item)),
      Error.new(
        :invalid_widget_state,
        "segmented_button_group cannot define active_item when selection_mode is :none",
        path: [:attributes, :segments, :active_item],
        details: %{selection_mode: :none}
      )
    )
  end

  defp validate_widget_state(:pipeline_stepper_horizontal, attributes) do
    workflow = Map.get(attributes, :workflow, %{})

    maybe_invalid_value(
      [],
      Map.get(workflow, :steps),
      &is_list/1,
      "pipeline_stepper_horizontal steps must be a deterministic list",
      [:attributes, :workflow, :steps]
    )
  end

  defp validate_widget_state(:workflow_stage_list_vertical, attributes) do
    workflow = Map.get(attributes, :workflow, %{})

    maybe_invalid_value(
      [],
      Map.get(workflow, :stages),
      &is_list/1,
      "workflow_stage_list_vertical stages must be a deterministic list",
      [:attributes, :workflow, :stages]
    )
  end

  defp validate_widget_state(:segmented_progress_bar, attributes) do
    progress = Map.get(attributes, :progress, %{})
    current = Map.get(progress, :current)
    maximum = Map.get(progress, :maximum)

    []
    |> maybe_invalid_value(
      Map.get(progress, :segments),
      &is_list/1,
      "segmented_progress_bar segments must be a deterministic list",
      [:attributes, :progress, :segments]
    )
    |> maybe_invalid_number_order(
      current,
      maximum,
      "segmented_progress_bar current cannot be greater than maximum",
      [:attributes, :progress, :current]
    )
  end

  defp validate_widget_state(:meter_thin, attributes) do
    meter = Map.get(attributes, :meter, %{})
    current = Map.get(meter, :current)
    minimum = Map.get(meter, :minimum)
    maximum = Map.get(meter, :maximum)

    []
    |> maybe_invalid_number_order(
      minimum,
      current,
      "meter_thin current cannot be less than minimum",
      [:attributes, :meter, :current]
    )
    |> maybe_invalid_number_order(
      current,
      maximum,
      "meter_thin current cannot be greater than maximum",
      [:attributes, :meter, :current]
    )
  end

  defp validate_widget_state(:slide_over_panel, attributes) do
    panel = Map.get(attributes, :panel, %{})

    maybe_invalid_member(
      [],
      Map.get(panel, :placement),
      [:start, :end, :top, :bottom],
      [:attributes, :panel, :placement]
    )
  end

  defp validate_widget_state(:host_form_shell, attributes) do
    form_shell = Map.get(attributes, :form_shell, %{})

    []
    |> maybe_invalid_member(Map.get(form_shell, :owner), [:host], [
      :attributes,
      :form_shell,
      :owner
    ])
    |> maybe_invalid_member(
      Map.get(form_shell, :lifecycle),
      [:host_owned],
      [:attributes, :form_shell, :lifecycle]
    )
  end

  defp validate_widget_state(_kind, _attributes), do: []

  defp validate_opaque_widget_payloads(value, path) when is_function(value) or is_pid(value) do
    [
      Error.new(
        :unsupported_opaque_payload,
        "promoted widget payloads must not contain opaque runtime values",
        path: path,
        details: %{value: inspect(value)}
      )
    ]
  end

  defp validate_opaque_widget_payloads(value, path) when is_port(value) or is_reference(value) do
    [
      Error.new(
        :unsupported_opaque_payload,
        "promoted widget payloads must not contain opaque runtime values",
        path: path,
        details: %{value: inspect(value)}
      )
    ]
  end

  defp validate_opaque_widget_payloads(%Element{}, _path), do: []
  defp validate_opaque_widget_payloads(%Child{}, _path), do: []

  defp validate_opaque_widget_payloads(%_{} = struct, path) do
    struct
    |> Map.from_struct()
    |> validate_opaque_widget_payloads(path)
  end

  defp validate_opaque_widget_payloads(value, path) when is_list(value) do
    value
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} ->
      validate_opaque_widget_payloads(item, path ++ [index])
    end)
  end

  defp validate_opaque_widget_payloads(value, path) when is_map(value) do
    Enum.flat_map(value, fn {key, nested_value} ->
      validate_opaque_widget_payloads(nested_value, path ++ [key])
    end)
  end

  defp validate_opaque_widget_payloads(_value, _path), do: []

  defp validate_repeated_collection(%Element{kind: :repeated_collection} = element) do
    collection = Map.get(element.attributes, :collection, %{})
    source = Map.get(collection, :source)
    key_path = Map.get(collection, :key_path, [])
    item_alias = Map.get(collection, :item_alias)
    index_alias = Map.get(collection, :index_alias)

    []
    |> Kernel.++(validate_collection_source(source))
    |> Kernel.++(validate_collection_key_path(key_path))
    |> Kernel.++(validate_collection_template(element.children))
    |> Kernel.++(validate_detectable_collection_keys(source, key_path))
    |> Kernel.++(validate_row_scope_bindings(element, [item_alias, index_alias]))
    |> Kernel.++(validate_opaque_widget_payloads(element.attributes, [:attributes]))
  end

  defp validate_repeated_collection(%Element{}), do: []

  defp validate_collection_source(nil) do
    [
      Error.new(
        :invalid_collection_source,
        "repeated_collection source is required",
        path: [:attributes, :collection, :source]
      )
    ]
  end

  defp validate_collection_source(%Binding{} = source) do
    []
    |> maybe_add(
      not source.collection?,
      Error.new(
        :invalid_collection_source,
        "repeated_collection source binding must be marked collection?: true",
        path: [:attributes, :collection, :source],
        details: %{source: inspect(source)}
      )
    )
    |> maybe_add(
      source.path == [] and is_nil(source.name) and is_nil(source.value),
      Error.new(
        :invalid_collection_source,
        "repeated_collection source must define a binding name, path, or static value",
        path: [:attributes, :collection, :source],
        details: %{source: inspect(source)}
      )
    )
    |> Kernel.++(validate_resource_relationship_source(source))
  end

  defp validate_collection_source(source) do
    [
      Error.new(
        :invalid_collection_source,
        "repeated_collection source must be a UnifiedIUR.Binding struct",
        path: [:attributes, :collection, :source],
        details: %{value: inspect(source)}
      )
    ]
  end

  defp validate_collection_key_path([]) do
    [
      Error.new(
        :invalid_collection_source,
        "repeated_collection key_path is required for stable child identity",
        path: [:attributes, :collection, :key_path]
      )
    ]
  end

  defp validate_collection_key_path(path) when is_list(path), do: []

  defp validate_collection_key_path(path) do
    [
      Error.new(
        :invalid_collection_source,
        "repeated_collection key_path must be a list of path segments",
        path: [:attributes, :collection, :key_path],
        details: %{value: inspect(path)}
      )
    ]
  end

  defp validate_collection_template(children) do
    template_children = Enum.filter(children, &(&1.slot == :template and not is_nil(&1.element)))

    cond do
      template_children == [] ->
        [
          Error.new(
            :missing_collection_template,
            "repeated_collection requires one child template",
            path: [:children]
          )
        ]

      length(template_children) > 1 ->
        [
          Error.new(
            :missing_collection_template,
            "repeated_collection supports exactly one child template",
            path: [:children],
            details: %{template_count: length(template_children)}
          )
        ]

      true ->
        []
    end
  end

  defp validate_detectable_collection_keys(%Binding{value: values}, key_path)
       when is_list(values) and is_list(key_path) and key_path != [] do
    keys =
      Enum.map(values, fn item ->
        fetch_path(normalize_collection_item(item), key_path)
      end)

    missing_key_indexes =
      keys
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {nil, index} -> [index]
        {_key, _index} -> []
      end)

    duplicate_keys =
      keys
      |> Enum.reject(&is_nil/1)
      |> Enum.frequencies()
      |> Enum.flat_map(fn
        {_key, 1} -> []
        {key, _count} -> [key]
      end)

    []
    |> maybe_add(
      missing_key_indexes != [],
      Error.new(
        :invalid_collection_source,
        "repeated_collection key_path must resolve for each detectable source item",
        path: [:attributes, :collection, :source, :value],
        details: %{missing_key_indexes: missing_key_indexes}
      )
    )
    |> maybe_add(
      duplicate_keys != [],
      Error.new(
        :duplicate_collection_key,
        "repeated_collection key_path resolved duplicate static keys",
        path: [:attributes, :collection, :key_path],
        details: %{duplicate_keys: duplicate_keys}
      )
    )
  end

  defp validate_detectable_collection_keys(_source, _key_path), do: []

  defp validate_row_scope_bindings(%Element{} = collection, aliases) do
    aliases = aliases |> Enum.reject(&is_nil/1) |> Enum.uniq()

    collection
    |> collect_row_scope_bindings()
    |> Enum.flat_map(fn {binding, path} ->
      row_alias = binding |> row_scope_alias() |> List.wrap() |> List.first()

      []
      |> maybe_add(
        is_nil(row_alias),
        Error.new(
          :invalid_row_scope_binding,
          "row-scope binding must declare an item or index alias in its scope",
          path: path,
          details: %{binding: inspect(binding)}
        )
      )
      |> maybe_add(
        not is_nil(row_alias) and row_alias not in aliases,
        Error.new(
          :invalid_row_scope_binding,
          "row-scope binding references an alias that is not available in this collection",
          path: path,
          details: %{alias: row_alias, available_aliases: aliases}
        )
      )
      |> maybe_add(
        row_scope_requires_renderer?(binding),
        Error.new(
          :invalid_row_scope_binding,
          "row-scope binding must not require renderer-local evaluation",
          path: path,
          details: %{binding: inspect(binding)}
        )
      )
    end)
  end

  defp collect_row_scope_bindings(%Element{} = element) do
    child_bindings =
      element.children
      |> Enum.with_index()
      |> Enum.flat_map(fn {child, index} ->
        case child.element do
          nil ->
            []

          %Element{} = child_element ->
            collect_row_scope_bindings(child_element, [:children, index])
        end
      end)

    collect_row_scope_bindings(element.attributes, [:attributes]) ++ child_bindings
  end

  defp collect_row_scope_bindings(%Binding{source: :row_scope} = binding, path),
    do: [{binding, path}]

  defp collect_row_scope_bindings(%Binding{} = _binding, _path), do: []

  defp collect_row_scope_bindings(%Interaction{} = interaction, path) do
    interaction
    |> Map.from_struct()
    |> collect_row_scope_bindings(path)
  end

  defp collect_row_scope_bindings(%_{} = struct, path) do
    struct
    |> Map.from_struct()
    |> collect_row_scope_bindings(path)
  end

  defp collect_row_scope_bindings(value, path) when is_list(value) do
    value
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} -> collect_row_scope_bindings(item, path ++ [index]) end)
  end

  defp collect_row_scope_bindings(value, path) when is_map(value) do
    Enum.flat_map(value, fn {key, nested_value} ->
      collect_row_scope_bindings(nested_value, path ++ [key])
    end)
  end

  defp collect_row_scope_bindings(_value, _path), do: []

  defp row_scope_alias(%Binding{scope: [row_alias | _]}), do: row_alias
  defp row_scope_alias(%Binding{metadata: %{row_alias: row_alias}}), do: row_alias
  defp row_scope_alias(%Binding{}), do: nil

  defp row_scope_requires_renderer?(%Binding{} = binding) do
    binding.source in [:renderer_callback, :runtime_callback] or
      Map.has_key?(binding.metadata, :callback) or
      Map.has_key?(binding.metadata, :renderer_callback)
  end

  defp validate_resource_relationship_source(%Binding{} = source) do
    []
    |> maybe_add(
      source.source in [:ash, :ash_relationship, :resource, "ash", "ash_relationship", "resource"],
      Error.new(
        :invalid_collection_source,
        "repeated_collection source must not reference Ash resources or relationships",
        path: [:attributes, :collection, :source, :source],
        details: %{source: source.source}
      )
    )
    |> maybe_add(
      resource_relationship_metadata?(source.metadata),
      Error.new(
        :invalid_collection_source,
        "repeated_collection source metadata must not contain resource relationship references",
        path: [:attributes, :collection, :source, :metadata],
        details: %{metadata: source.metadata}
      )
    )
  end

  defp resource_relationship_metadata?(metadata) when is_map(metadata) do
    Enum.any?([:relationship, :resource, :ash_relationship, :ash_resource], fn key ->
      Map.has_key?(metadata, key) or Map.has_key?(metadata, Atom.to_string(key))
    end)
  end

  defp resource_relationship_metadata?(_metadata), do: false

  defp normalize_collection_item(item) when is_list(item) do
    if Keyword.keyword?(item), do: Enum.into(item, %{}), else: item
  end

  defp normalize_collection_item(item), do: item

  defp validate_runtime_local_values(value, path) when is_list(value) do
    value
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} -> validate_runtime_local_values(item, path ++ [index]) end)
  end

  defp validate_runtime_local_values(%Element{} = element, path) do
    case element(element) do
      :ok -> []
      {:error, errors} -> Enum.map(errors, &prepend_path(&1, path))
    end
  end

  defp validate_runtime_local_values(%Child{} = child, path) do
    validate_child(child, path)
  end

  defp validate_runtime_local_values(%_{} = struct, path) do
    module = struct.__struct__

    cond do
      runtime_local_struct?(module) ->
        [
          Error.new(
            :runtime_local_escape_hatch,
            "runtime-local structs are not allowed in canonical IUR values",
            path: path,
            details: %{module: inspect(module)}
          )
        ]

      true ->
        struct
        |> Map.from_struct()
        |> validate_runtime_local_values(path)
    end
  end

  defp validate_runtime_local_values(map, path) when is_map(map) do
    Enum.flat_map(map, fn {key, value} -> validate_runtime_local_values(value, path ++ [key]) end)
  end

  defp validate_runtime_local_values(_value, _path), do: []

  defp runtime_local_struct?(module) do
    parts = Module.split(module)
    name = Enum.join(parts, ".")

    Enum.any?(@runtime_local_prefixes, fn prefix ->
      String.starts_with?(name, prefix) or prefix_in_parts?(parts, String.split(prefix, "."))
    end)
  end

  defp prefix_in_parts?(parts, prefix_parts) do
    parts
    |> Enum.chunk_every(length(prefix_parts), 1, :discard)
    |> Enum.any?(&(&1 == prefix_parts))
  end

  defp present_field?(attributes, path) do
    case fetch_path(attributes, path) do
      nil -> false
      %{} = value -> map_size(value) > 0
      [] -> false
      _value -> true
    end
  end

  defp fetch_path(value, []) do
    value
  end

  defp fetch_path(map, [key | rest]) when is_map(map) do
    map
    |> Map.get(key, Map.get(map, Atom.to_string(key)))
    |> fetch_path(rest)
  end

  defp fetch_path(_value, _path), do: nil

  defp format_path(path) do
    path
    |> Enum.map(&to_string/1)
    |> Enum.join(".")
  end

  defp maybe_invalid_value(errors, nil, _predicate, _message, _path), do: errors

  defp maybe_invalid_value(errors, value, predicate, message, path) do
    if predicate.(value) do
      errors
    else
      errors ++
        [
          Error.new(
            :invalid_widget_state,
            message,
            path: path,
            details: %{value: inspect(value)}
          )
        ]
    end
  end

  defp maybe_invalid_member(errors, nil, _allowed, _path), do: errors

  defp maybe_invalid_member(errors, value, allowed, path) do
    if value in allowed do
      errors
    else
      errors ++
        [
          Error.new(
            :invalid_widget_state,
            "promoted widget state #{inspect(value)} is not supported",
            path: path,
            details: %{allowed: allowed, value: value}
          )
        ]
    end
  end

  defp maybe_invalid_number_order(errors, nil, _right, _message, _path), do: errors
  defp maybe_invalid_number_order(errors, _left, nil, _message, _path), do: errors

  defp maybe_invalid_number_order(errors, left, right, message, path)
       when is_number(left) and is_number(right) do
    if left <= right do
      errors
    else
      errors ++
        [
          Error.new(
            :invalid_widget_state,
            message,
            path: path,
            details: %{left: left, right: right}
          )
        ]
    end
  end

  defp maybe_invalid_number_order(errors, _left, _right, _message, _path), do: errors

  defp maybe_add(errors, true, error), do: errors ++ [error]
  defp maybe_add(errors, false, _error), do: errors

  defp prepend_path(%Error{} = error, prefix) do
    %{error | path: prefix ++ error.path}
  end

  defp diagnostic_entry(%Error{} = error) do
    guidance = guidance_for_error(error)

    %{
      code: error.code,
      message: Error.format(error),
      path: error.path,
      details: error.details,
      construct_family: guidance.construct_family,
      guidance: guidance.guidance
    }
  end
end
