defmodule UnifiedUi.Compiler.Pipeline do
  @moduledoc """
  Compiler passes and lowering helpers for deterministic `UnifiedUi` to
  `UnifiedIUR` compilation.
  """

  alias Spark.Dsl.Extension

  alias UnifiedIUR.{
    Container,
    Element,
    Forms,
    Interaction,
    Layout,
    Metadata,
    Style,
    Theme,
    Widgets
  }

  alias UnifiedIUR.Binding, as: IURBinding
  alias UnifiedUi.Compiler.Result
  alias UnifiedUi.Dsl.Node
  alias UnifiedUi.{Signal, Signals}

  @type context :: %{
          module: module(),
          identity: map(),
          composition: map(),
          default_theme: atom() | String.t() | nil,
          top_level_nodes: [Node.t()],
          node_by_id: %{optional(atom()) => Node.t()},
          authored_themes: [UnifiedUi.Theme.t()],
          compiled_themes: [Theme.t()],
          compiled_theme_by_id: %{optional(atom()) => Theme.t()},
          binding_by_id: %{optional(atom()) => UnifiedIUR.Binding.t()},
          interaction_by_id: %{optional(atom()) => UnifiedIUR.Interaction.t()},
          authored_ids: [atom()]
        }

  @spec run(module(), keyword() | map()) :: Result.t()
  def run(module, _opts \\ []) when is_atom(module) do
    context = build_context(module)
    compiled_themes = compile_themes(context.authored_themes)
    compiled_theme_by_id = Map.new(compiled_themes, &{&1.id, &1})
    compiled_bindings = compile_bindings(Signals.bindings(module))
    binding_by_id = Map.new(compiled_bindings, &{&1.name, &1})
    compiled_interactions = compile_interactions(Signals.interactions(module), binding_by_id)
    interaction_by_id = Map.new(compiled_interactions, &{interaction_identifier(&1), &1})

    context =
      context
      |> Map.put(:compiled_themes, compiled_themes)
      |> Map.put(:compiled_theme_by_id, compiled_theme_by_id)
      |> Map.put(:binding_by_id, binding_by_id)
      |> Map.put(:interaction_by_id, interaction_by_id)

    iur =
      Element.new(:composite, context.composition.mode,
        id: context.composition.root,
        metadata: root_metadata(context),
        attributes: root_attributes(context, compiled_bindings, compiled_interactions),
        children:
          Enum.map(context.top_level_nodes, fn node ->
            Element.Child.new(:default, lower_node(node, context, MapSet.new()))
          end)
      )

    %Result{
      module: module,
      identity: context.identity,
      composition: context.composition,
      iur: iur,
      themes: compiled_themes,
      default_theme: context.default_theme,
      bindings: compiled_bindings,
      interactions: compiled_interactions,
      trace: %{
        authored_ids: context.authored_ids,
        binding_by_id: binding_by_id,
        interaction_by_id: interaction_by_id,
        theme_by_id: compiled_theme_by_id
      }
    }
  end

  defp build_context(module) do
    top_level_nodes = Extension.get_entities(module, [:composition])
    authored_themes = UnifiedUi.Theme.themes(module)

    %{
      module: module,
      identity: %{
        id: Extension.get_opt(module, [:identity], :id, nil),
        title: Extension.get_opt(module, [:identity], :title, nil),
        description: Extension.get_opt(module, [:identity], :description, nil),
        authored_ref: Extension.get_opt(module, [:identity], :authored_ref, nil),
        tags: Extension.get_opt(module, [:identity], :tags, [])
      },
      composition: %{
        root: Extension.get_opt(module, [:composition], :root, nil),
        mode: Extension.get_opt(module, [:composition], :mode, :screen),
        summary: Extension.get_opt(module, [:composition], :summary, nil),
        default_slot: Extension.get_opt(module, [:composition], :default_slot, nil)
      },
      default_theme: Extension.get_opt(module, [:themes], :default_theme, nil),
      top_level_nodes: top_level_nodes,
      node_by_id: top_level_nodes |> flatten_nodes() |> Map.new(&{&1.id, &1}),
      authored_themes: authored_themes,
      compiled_themes: [],
      compiled_theme_by_id: %{},
      binding_by_id: %{},
      interaction_by_id: %{},
      authored_ids: top_level_nodes |> flatten_nodes() |> Enum.map(& &1.id) |> Enum.sort()
    }
  end

  defp root_metadata(context) do
    Metadata.new(%{
      authored_ref: context.identity.authored_ref,
      description: context.identity.description || context.composition.summary,
      tags: context.identity.tags,
      annotations: %{
        module: context.module,
        identity_id: context.identity.id,
        title: context.identity.title,
        mode: context.composition.mode
      }
    })
  end

  defp root_attributes(context, compiled_bindings, compiled_interactions) do
    %{
      compiled: %{
        module: context.module,
        identity_id: context.identity.id,
        title: context.identity.title,
        mode: context.composition.mode,
        default_slot: context.composition.default_slot,
        summary: context.composition.summary
      }
    }
    |> maybe_put(:theme, root_theme_attachment(context))
    |> maybe_put(:bindings, if(compiled_bindings == [], do: nil, else: compiled_bindings))
    |> maybe_put(
      :interactions,
      if(compiled_interactions == [], do: nil, else: compiled_interactions)
    )
  end

  defp root_theme_attachment(%{default_theme: nil}), do: nil

  defp root_theme_attachment(context) do
    %{
      id: context.default_theme,
      component: context.composition.mode
    }
  end

  defp compile_themes(themes) do
    Enum.map(themes, &compile_theme/1)
  end

  defp compile_theme(theme) do
    components =
      theme
      |> UnifiedUi.Theme.component_styles()
      |> Enum.reduce(%{}, fn component_style, acc ->
        style = lower_style(component_style.style)

        Map.update(
          acc,
          component_style.component,
          component_bucket(component_style, style),
          fn bucket ->
            Map.merge(bucket, component_bucket(component_style, style))
          end
        )
      end)

    Theme.new(%{
      id: theme.id,
      palette:
        theme
        |> UnifiedUi.Theme.palette_colors()
        |> Map.new(&{&1.id, &1.color}),
      roles:
        theme
        |> UnifiedUi.Theme.semantic_roles()
        |> Map.new(fn role ->
          {role.id, lower_theme_role_value(role.value)}
        end),
      tokens:
        theme
        |> UnifiedUi.Theme.tokens()
        |> Map.new(fn token ->
          {[token.id], lower_theme_token_value(token.value)}
        end),
      components: components,
      extra: %{
        authored_ref: theme.authored_ref,
        description: theme.description,
        summary: theme.summary,
        extends: theme.extends,
        inherit?: theme.inherit?
      }
    })
  end

  defp component_bucket(component_style, style) do
    cond do
      component_style.variant ->
        %{variants: %{component_style.variant => style}}

      component_style.state ->
        %{states: %{component_style.state => style}}

      true ->
        %{default: style}
    end
  end

  defp lower_theme_role_value(value) do
    cond do
      UnifiedUi.Style.role_reference?(value) ->
        nil

      token_reference?(value) ->
        UnifiedIUR.Token.new(value)

      true ->
        UnifiedIUR.Style.Color.new(value)
    end
  end

  defp lower_theme_token_value(%UnifiedUi.Style{} = style), do: lower_style(style)
  defp lower_theme_token_value(style) when is_map(style) or is_list(style), do: lower_style(style)
  defp lower_theme_token_value(value), do: value

  defp compile_bindings(bindings) do
    Enum.map(bindings, &compile_binding/1)
  end

  defp compile_binding(binding) do
    binding = UnifiedUi.Binding.new(binding)

    IURBinding.new(%{
      name: binding.id,
      path: binding.path,
      scope: binding.scope,
      default: binding.default,
      format: binding.format,
      source: binding.source,
      collection?: binding.collection?,
      depends_on: Enum.map(binding.depends_on, &compiled_binding_ref/1),
      derived: binding.derived,
      metadata: %{
        summary: binding.summary,
        authored_id: binding.id
      }
    })
  end

  defp compile_interactions(interactions, binding_by_id) do
    Enum.map(interactions, &compile_interaction(&1, binding_by_id))
  end

  defp compile_interaction(interaction, binding_by_id) do
    interaction = Signal.new(interaction)

    Interaction.new(%{
      family: interaction.family,
      intent: interaction.intent,
      source: normalize_map(interaction.source_context),
      target: compile_payload_map(interaction.target_intent, binding_by_id),
      payload: compile_payload_map(interaction.payload_mapping, binding_by_id),
      metadata: %{
        summary: interaction.summary,
        authored_id: interaction.id,
        binding_refs:
          Enum.map(interaction.binding_refs, &compile_binding_ref_value(&1, binding_by_id))
      }
    })
  end

  defp interaction_identifier(interaction) do
    interaction.metadata[:authored_id] || interaction.intent
  end

  defp lower_node(node, context, visited) do
    if MapSet.member?(visited, node.id) do
      Element.new(:composite, :reference_cycle,
        id: "cycle:#{node.id}",
        metadata:
          Metadata.new(%{
            description: "Reference cycle placeholder for #{inspect(node.id)}",
            annotations: %{ref: node.id}
          })
      )
    else
      visited = MapSet.put(visited, node.id)
      attachments = node_attachments(node, context)

      case node.kind do
        :content ->
          Container.content(
            lower_children(node, context, visited),
            common_opts(node, attachments)
          )

        :box ->
          Container.box(lower_children(node, context, visited), common_opts(node, attachments))

        :row ->
          Layout.row(lower_children(node, context, visited), common_opts(node, attachments))

        :column ->
          Layout.column(lower_children(node, context, visited), common_opts(node, attachments))

        :grid ->
          Layout.grid(
            lower_children(node, context, visited),
            common_opts(node, attachments, [:columns, :rows, :gap, :align, :justify])
          )

        :stack ->
          Layout.stack(
            lower_children(node, context, visited),
            common_opts(node, attachments, [:align])
          )

        :form_builder ->
          Forms.form_builder(
            lower_children(node, context, visited),
            common_opts(node, attachments, [:submit_intent])
          )

        :field_group ->
          Forms.field_group(
            lower_children(node, context, visited),
            common_opts(node, attachments, [:legend])
          )

        :field ->
          lower_field(node, context, visited, attachments)

        :text ->
          Widgets.Foundational.text(node.value || "", common_opts(node, attachments))

        :label ->
          Widgets.Foundational.label(node.value || "", common_opts(node, attachments, [:target]))

        :icon ->
          Widgets.Foundational.icon(
            node.name,
            common_opts(node, attachments, [:set, :fallback_text])
          )

        :image ->
          Widgets.Foundational.image(
            node.source || "",
            common_opts(node, attachments, [:alt_text, :media_type, :fit])
          )

        :button ->
          Widgets.Foundational.button(node.label || "", common_opts(node, attachments))

        :link ->
          Widgets.Foundational.link(
            node.label || "",
            node.target || "",
            common_opts(node, attachments, [:external?])
          )

        :separator ->
          Widgets.Foundational.separator(
            common_opts(node, attachments, [:orientation, :decorative?])
          )

        :spacer ->
          Widgets.Foundational.spacer(common_opts(node, attachments, [:size, :grow]))

        :text_input ->
          Widgets.Input.text_input(
            common_opts(node, attachments, [:placeholder, :value_path, :default_value])
          )

        :toggle ->
          Widgets.Input.toggle(
            common_opts(node, attachments, [:label, :value_path, :default_value])
          )

        :select ->
          Widgets.Input.select(
            normalize_keyword_items(node.options),
            common_opts(node, attachments, [:label, :value_path, :default_value, :multiple?])
          )

        :menu ->
          Widgets.Navigation.menu(
            normalize_keyword_items(node.options),
            common_opts(node, attachments, [:active_item, :orientation])
          )

        :tabs ->
          Widgets.Navigation.tabs(
            normalize_keyword_items(node.options),
            common_opts(node, attachments, [:active_item, :orientation])
          )

        :command_palette ->
          Widgets.Advanced.command_palette(
            normalize_keyword_items(node.options),
            common_opts(node, attachments, [:label])
          )

        :table ->
          Widgets.Data.table(
            normalize_table_columns(node.table_columns),
            normalize_table_rows(node.table_rows),
            common_opts(node, attachments, [:empty_state])
          )

        :tree_view ->
          Widgets.Data.tree_view(
            normalize_list(node.tree_nodes),
            common_opts(node, attachments, [:expanded?, :empty_state])
          )

        :markdown_viewer ->
          Widgets.Advanced.markdown_viewer(node.source || "", common_opts(node, attachments))

        :log_viewer ->
          Widgets.Advanced.log_viewer(
            normalize_list(node.log_entries),
            common_opts(node, attachments, [:wrap?, :show_timestamps?])
          )

        :gauge ->
          Widgets.Feedback.gauge(
            common_opts(node, attachments,
              current: node.current,
              min: node.minimum,
              max: node.maximum,
              severity: node.severity
            )
          )

        :sparkline ->
          UnifiedIUR.Canvas.sparkline(
            normalize_number_points(node.points),
            common_opts(node, attachments)
          )

        :bar_chart ->
          UnifiedIUR.Canvas.bar_chart(
            normalize_series(node.series),
            common_opts(node, attachments, x_label: node.x_label, y_label: node.y_label)
          )

        :line_chart ->
          UnifiedIUR.Canvas.line_chart(
            normalize_series(node.series),
            common_opts(node, attachments, x_label: node.x_label, y_label: node.y_label)
          )

        :stream_widget ->
          Widgets.Advanced.stream_widget(
            normalize_list(node.entries),
            common_opts(node, attachments, [:ordering, :severity_field, :timestamp_field])
          )

        :process_monitor ->
          Widgets.Advanced.process_monitor(
            normalize_list(node.processes),
            common_opts(node, attachments, [:sort_by, :severity])
          )

        :cluster_dashboard ->
          Widgets.Advanced.cluster_dashboard(
            normalize_list(node.cluster_nodes),
            common_opts(node, attachments,
              summary: normalize_map(node.metrics),
              severity: node.severity
            )
          )

        :supervision_tree_viewer ->
          Widgets.Advanced.supervision_tree_viewer(
            normalize_list(node.topology),
            common_opts(node, attachments, [:expanded?])
          )

        :dialog ->
          generic_element(:layer, :dialog, node, attachments, %{
            dialog: %{
              title: node.title,
              content_ref: node.content_ref,
              trigger_ref: node.trigger_ref,
              visible?: node.visible?,
              modal?: node.modal?,
              confirm_intent: node.confirm_intent,
              dismiss_intent: node.dismiss_intent
            }
          })

        :alert_dialog ->
          generic_element(:layer, :alert_dialog, node, attachments, %{
            alert_dialog: %{
              title: node.title,
              message: node.message,
              trigger_ref: node.trigger_ref,
              visible?: node.visible?,
              confirm_intent: node.confirm_intent,
              dismiss_intent: node.dismiss_intent,
              severity: node.severity
            }
          })

        :toast ->
          generic_element(:layer, :toast, node, attachments, %{
            toast: %{
              title: node.title,
              message: node.message,
              trigger_ref: node.trigger_ref,
              visible?: node.visible?,
              placement: node.placement,
              severity: node.severity
            }
          })

        :context_menu ->
          generic_element(:layer, :context_menu, node, attachments, %{
            context_menu: %{
              options: normalize_keyword_items(node.options),
              target_ref: node.target_ref,
              trigger_ref: node.trigger_ref,
              placement: node.placement,
              visible?: node.visible?
            }
          })

        :overlay ->
          generic_element(:layer, :overlay, node, attachments, %{
            overlay: %{
              base_ref: node.base_ref,
              layer_refs: node.layer_refs,
              background_fill: node.background_fill
            }
          })

        :absolute ->
          generic_element(:layer, :absolute, node, attachments, %{
            absolute: %{
              content_ref: node.content_ref,
              target_ref: node.target_ref,
              x: node.x,
              y: node.y,
              z_index: node.z_index
            }
          })

        :viewport ->
          generic_element(:layout, :viewport, node, attachments, %{
            viewport: %{
              content_ref: node.content_ref,
              width: node.width,
              height: node.height,
              offset: node.offset,
              clip?: node.clip?
            }
          })

        :scroll_region ->
          generic_element(:layout, :scroll_region, node, attachments, %{
            scroll_region: %{
              content_ref: node.content_ref,
              height: node.height,
              offset: node.offset,
              clip?: node.clip?
            }
          })

        :scroll_bar ->
          generic_element(:widget, :scroll_bar, node, attachments, %{
            scroll_bar: %{
              target_ref: node.target_ref,
              position: node.position,
              viewport_size: node.viewport_size,
              content_size: node.content_size,
              orientation: node.orientation
            }
          })

        :split_pane ->
          generic_element(:layout, :split_pane, node, attachments, %{
            split: %{
              primary_ref: node.primary_ref,
              secondary_ref: node.secondary_ref,
              ratio: node.ratio,
              orientation: node.orientation,
              divider_size: node.divider_size,
              divider_style: node.divider_style
            }
          })

        :canvas ->
          UnifiedIUR.Canvas.surface(
            normalize_list(node.operations),
            common_opts(node, attachments, [:width, :height])
          )

        other ->
          generic_element(element_type(node.family), other, node, attachments, %{
            authored: %{
              family: node.family,
              summary: node.summary
            }
          })
      end
    end
  end

  defp lower_field(node, context, visited, attachments) do
    control =
      case node.children do
        [child | _rest] -> lower_node(child, context, visited)
        [] -> Element.new(:widget, :empty_field_control, id: "#{node.id}-control")
      end

    Forms.field(
      control,
      common_opts(node, attachments,
        name: node.field_name,
        label: node.label,
        help: node.help,
        path: node.value_path,
        default: node.default_value
      )
    )
  end

  defp lower_children(node, context, visited) do
    Enum.map(node.children, fn child ->
      Element.Child.new(:default, lower_node(child, context, visited))
    end)
  end

  defp node_attachments(node, context) do
    bindings = compile_node_bindings(node, context)
    interactions = compile_node_interactions(node, context)

    %{
      style: lower_style(node.style),
      theme: compile_theme_attachment(node, context),
      bindings: if(bindings == [], do: nil, else: bindings),
      interactions: if(interactions == [], do: nil, else: interactions)
    }
  end

  defp compile_node_bindings(node, context) do
    explicit =
      node.binding_refs
      |> List.wrap()
      |> Enum.map(&Map.get(context.binding_by_id, &1))
      |> Enum.reject(&is_nil/1)

    fallback =
      case {node.value_path, node.field_name || node.id} do
        {nil, _name} ->
          []

        {path, name} ->
          [
            IURBinding.new(%{
              name: name,
              path: List.wrap(path),
              default: node.default_value,
              metadata: %{source: :authored_node}
            })
          ]
      end

    explicit ++ fallback
  end

  defp compile_node_interactions(node, context) do
    explicit =
      node.interaction_refs
      |> List.wrap()
      |> Enum.map(&Map.get(context.interaction_by_id, &1))
      |> Enum.reject(&is_nil/1)

    fallback =
      []
      |> maybe_prepend(default_action_interaction(node))
      |> maybe_prepend(default_submit_interaction(node))

    explicit ++ Enum.reverse(fallback)
  end

  defp default_action_interaction(%Node{action_intent: nil}), do: nil

  defp default_action_interaction(node) do
    Interaction.click(
      intent: node.action_intent,
      element_id: node.id,
      phase: :authored_default
    )
  end

  defp default_submit_interaction(%Node{submit_intent: nil}), do: nil

  defp default_submit_interaction(node) do
    Interaction.submit(
      intent: node.submit_intent,
      element_id: node.id,
      phase: :authored_default
    )
  end

  defp compile_theme_attachment(node, context) do
    theme_id = node.theme_ref || context.default_theme

    if is_nil(theme_id) do
      nil
    else
      %{
        id: theme_id,
        component: node.kind,
        variant: node.variant,
        source_style_refs: node.style_refs
      }
    end
  end

  defp common_opts(node, attachments, extra \\ []) do
    extra =
      cond do
        is_list(extra) -> Enum.into(extra, %{}, fn key -> {key, Map.get(node, key)} end)
        is_map(extra) -> Map.new(extra)
        true -> %{}
      end

    %{
      id: node.id,
      description: node.summary || node.description,
      authored_ref: node.authored_ref,
      tags: node.tags,
      style: attachments.style,
      theme: attachments.theme,
      bindings: attachments.bindings,
      interactions: attachments.interactions
    }
    |> Map.merge(extra)
    |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
    |> Map.new()
  end

  defp generic_element(type, kind, node, attachments, attribute_groups) do
    Element.new(type, kind,
      id: node.id,
      metadata:
        Metadata.new(%{
          authored_ref: node.authored_ref,
          description: node.summary || node.description,
          tags: node.tags,
          annotations: %{
            source_family: node.family
          }
        }),
      attributes:
        attribute_groups
        |> Enum.reject(fn {_key, value} -> value in [%{}, nil] end)
        |> Map.new(fn {key, value} -> {key, compact_map(value)} end)
        |> maybe_put(:style, attachments.style)
        |> maybe_put(:theme, attachments.theme)
        |> maybe_put(:bindings, attachments.bindings)
        |> maybe_put(:interactions, attachments.interactions),
      children: []
    )
  end

  defp lower_style(nil), do: nil

  defp lower_style(style) do
    style = UnifiedUi.Style.new(style)

    lowered =
      Style.new(%{
        foreground: lower_color(style.foreground),
        background: lower_color(style.background),
        border_color: lower_color(style.border_color),
        text: style.typography,
        spacing: style.spacing,
        sizing: style.sizing,
        alignment: style.alignment,
        visibility: style.visibility,
        border: style.border,
        emphasis: style.emphasis,
        state_variants:
          Map.new(style.state_variants, fn {key, variant} ->
            {key, lower_style(variant)}
          end),
        extra:
          %{}
          |> maybe_put(:variant, style.variant)
          |> maybe_put(:tone, style.tone)
          |> maybe_put(:component, style.component)
      })

    if lowered == %Style{}, do: nil, else: lowered
  end

  defp lower_color(nil), do: nil

  defp lower_color(value) do
    cond do
      UnifiedUi.Style.role_reference?(value) -> nil
      token_reference?(value) -> nil
      true -> UnifiedIUR.Style.Color.new(value)
    end
  end

  defp compile_payload_map(values, binding_by_id) when is_map(values) do
    Map.new(values, fn {key, value} ->
      {key, compile_named_payload_value(key, value, binding_by_id)}
    end)
  end

  defp compile_payload_map(values, _binding_by_id) when values in [nil, []], do: %{}

  defp compile_payload_map(values, binding_by_id) when is_list(values) do
    values
    |> Enum.into(%{})
    |> compile_payload_map(binding_by_id)
  end

  defp compile_payload_value(value, binding_by_id) when is_map(value) do
    cond do
      UnifiedUi.Binding.reference?(value) ->
        compile_binding_ref_value(value, binding_by_id)

      true ->
        Map.new(value, fn {key, nested} -> {key, compile_payload_value(nested, binding_by_id)} end)
    end
  end

  defp compile_payload_value(value, binding_by_id) when is_list(value) do
    if Keyword.keyword?(value) do
      value
      |> Enum.into(%{})
      |> compile_payload_value(binding_by_id)
    else
      Enum.map(value, &compile_payload_value(&1, binding_by_id))
    end
  end

  defp compile_payload_value(value, _binding_by_id), do: value

  defp compile_named_payload_value(key, value, binding_by_id)
       when key in [:binding, "binding"] and (is_atom(value) or is_binary(value)) do
    case Map.get(binding_by_id, value) do
      nil -> value
      _binding -> compile_binding_ref_value(value, binding_by_id)
    end
  end

  defp compile_named_payload_value(_key, value, binding_by_id) do
    compile_payload_value(value, binding_by_id)
  end

  defp compile_binding_ref_value(ref, binding_by_id) do
    ref = UnifiedUi.Binding.new(%{depends_on: [ref]}).depends_on |> List.first()

    case Map.get(binding_by_id, ref.id) do
      nil ->
        %{kind: :binding_ref, id: ref.id}

      binding ->
        %{
          kind: :binding_ref,
          id: ref.id,
          name: binding.name,
          path: binding.path,
          scope: binding.scope
        }
    end
  end

  defp compiled_binding_ref(ref) do
    ref = UnifiedUi.Binding.new(%{depends_on: [ref]}).depends_on |> List.first()
    IURBinding.reference([ref.id])
  end

  defp normalize_keyword_items(items) when is_list(items) do
    Enum.map(items, fn
      {id, label} ->
        %{id: id, label: label, value: id}

      %{} = item ->
        normalize_map(item)
    end)
  end

  defp normalize_table_columns(columns) when is_list(columns) do
    Enum.map(columns, fn
      {id, label} -> %{id: id, label: label}
      %{} = column -> normalize_map(column)
    end)
  end

  defp normalize_table_rows(rows) when is_list(rows) do
    Enum.with_index(rows, fn row, index ->
      row = normalize_map(row)

      %{
        id: Map.get(row, :id, Map.get(row, "id", "row-#{index}")),
        cells:
          row
          |> Enum.reject(fn {key, _value} -> key in [:id, "id"] end)
          |> Enum.map(fn {_key, value} -> value end)
      }
    end)
  end

  defp normalize_series(series) when is_list(series) do
    Enum.map(series, &normalize_map/1)
  end

  defp normalize_number_points(points) when is_list(points), do: points
  defp normalize_number_points(_other), do: []

  defp normalize_list(nil), do: []
  defp normalize_list(list) when is_list(list), do: Enum.map(list, &normalize_map/1)

  defp element_type(:layout), do: :layout
  defp element_type(:forms), do: :composite
  defp element_type(:overlay), do: :layer
  defp element_type(:display), do: :layout
  defp element_type(:canvas), do: :widget
  defp element_type(_family), do: :widget

  defp flatten_nodes(nodes) when is_list(nodes) do
    Enum.flat_map(nodes, fn %Node{children: children} = node ->
      [node | flatten_nodes(children)]
    end)
  end

  defp token_reference?(%{kind: :token_ref, path: path}) when is_list(path), do: true
  defp token_reference?(%{"kind" => :token_ref, "path" => path}) when is_list(path), do: true
  defp token_reference?(_other), do: false

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp compact_map(map) when is_map(map) do
    map
    |> Enum.reject(fn {_key, value} -> value in [nil, [], %{}] end)
    |> Map.new()
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp maybe_prepend(list, nil), do: list
  defp maybe_prepend(list, value), do: [value | list]
end
