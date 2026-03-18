defmodule WebUi.Renderer.Mapper do
  @moduledoc false

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Interaction
  alias WebUi.Renderer.Error

  alias WebUi.Widgets.{
    Data,
    Feedback,
    Forms,
    Foundational,
    Input,
    Layered,
    Layout,
    Navigation,
    Operational,
    Visualization
  }

  @supported_kinds [
    :text,
    :label,
    :icon,
    :image,
    :button,
    :link,
    :separator,
    :spacer,
    :content,
    :text_input,
    :checkbox,
    :select,
    :menu,
    :tabs,
    :row,
    :column,
    :grid,
    :stack,
    :viewport,
    :scroll_bar,
    :split_pane,
    :form_builder,
    :field_group,
    :field,
    :table,
    :tree_view,
    :markdown_viewer,
    :log_viewer,
    :status,
    :progress,
    :inline_feedback,
    :gauge,
    :sparkline,
    :bar_chart,
    :line_chart,
    :canvas,
    :stream_widget,
    :process_monitor,
    :cluster_dashboard,
    :command_palette,
    :supervision_tree_viewer,
    :overlay,
    :dialog,
    :toast,
    :alert_dialog,
    :context_menu
  ]

  @spec supported_kinds() :: [atom()]
  def supported_kinds, do: @supported_kinds

  @spec element(Element.t()) :: {:ok, WebUi.Widget.t()} | {:error, Error.t()}
  def element(%Element{id: nil} = element), do: {:error, Error.missing_identity(element)}

  def element(%Element{type: :widget, kind: :text} = element) do
    {:ok, Foundational.text(content_text(element), base_opts(element))}
  end

  def element(%Element{type: :widget, kind: :label} = element) do
    {:ok,
     Foundational.label(
       content_text(element),
       base_opts(element)
       |> Map.put(:for, get_in(element.attributes, [:label, :for]))
       |> Map.put(:relationship, get_in(element.attributes, [:label, :relationship]))
     )}
  end

  def element(%Element{type: :widget, kind: :icon} = element) do
    {:ok,
     Foundational.icon(
       attribute(element, [:icon, :name]),
       merge_opts(base_opts(element), %{
         set: attribute(element, [:icon, :set]),
         fallback_text: attribute(element, [:icon, :fallback_text])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :image} = element) do
    {:ok,
     Foundational.image(
       attribute(element, [:image, :source]),
       merge_opts(base_opts(element), %{
         alt: attribute(element, [:image, :alt_text]),
         fit: attribute(element, [:image, :fit])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :button} = element) do
    {:ok,
     Foundational.button(
       content_text(element),
       merge_opts(base_opts(element), %{variant: style_variant(element)})
     )}
  end

  def element(%Element{type: :widget, kind: :link} = element) do
    {:ok,
     Foundational.link(
       content_text(element),
       attribute(element, [:link, :target]),
       merge_opts(base_opts(element), %{
         external?: attribute(element, [:link, :external?], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :separator} = element) do
    {:ok,
     Foundational.separator(
       merge_opts(base_opts(element), %{
         orientation: attribute(element, [:separator, :orientation]),
         decorative?: attribute(element, [:separator, :decorative?], true)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :spacer} = element) do
    {:ok,
     Foundational.spacer(
       merge_opts(base_opts(element), %{
         size: attribute(element, [:spacer, :size]),
         grow: attribute(element, [:spacer, :grow], 0),
         min: attribute(element, [:spacer, :min]),
         max: attribute(element, [:spacer, :max])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :content} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Foundational.content(
         children,
         merge_opts(base_opts(element), %{
           role: attribute(element, [:container, :role]),
           presentation: attribute(element, [:container, :presentation])
         })
       )}
    end
  end

  def element(%Element{type: :widget, kind: :text_input} = element) do
    binding = first_binding(element)

    {:ok,
     Input.text_input(
       merge_opts(base_opts(element), %{
         name: Map.get(binding, :name),
         value: Map.get(binding, :value, Map.get(binding, :default, "")),
         placeholder: attribute(element, [:input, :placeholder]),
         multiline?: attribute(element, [:input, :multiline?], false),
         input_mode: attribute(element, [:input, :input_mode], :text)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :checkbox} = element) do
    binding = first_binding(element)

    {:ok,
     Input.checkbox(
       merge_opts(base_opts(element), %{
         name: Map.get(binding, :name),
         value: Map.get(binding, :value, false),
         checked?: Map.get(binding, :value, false),
         label: attribute(element, [:label, :text]),
         checked_value: attribute(element, [:input, :checked_value], true),
         unchecked_value: attribute(element, [:input, :unchecked_value], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :select} = element) do
    binding = first_binding(element)

    {:ok,
     Input.select(
       attribute(element, [:selection, :options], []),
       merge_opts(base_opts(element), %{
         name: Map.get(binding, :name),
         value: Map.get(binding, :value),
         multiple?: attribute(element, [:selection, :multiple?], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :menu} = element) do
    {:ok,
     Navigation.menu(
       attribute(element, [:navigation, :items], []),
       merge_opts(base_opts(element), %{
         active_item: attribute(element, [:navigation, :active_item]),
         orientation: attribute(element, [:navigation, :orientation], :vertical)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :tabs} = element) do
    {:ok,
     Navigation.tabs(
       attribute(element, [:navigation, :items], []),
       merge_opts(base_opts(element), %{
         active_item: attribute(element, [:navigation, :active_item]),
         orientation: attribute(element, [:navigation, :orientation], :horizontal)
       })
     )}
  end

  def element(%Element{type: :layout, kind: :row} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Layout.row(
         children,
         merge_opts(base_opts(element), %{
           gap: attribute(element, [:layout, :gap]),
           align: attribute(element, [:layout, :align]),
           justify: attribute(element, [:layout, :justify])
         })
       )}
    end
  end

  def element(%Element{type: :layout, kind: :column} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Layout.column(
         children,
         merge_opts(base_opts(element), %{
           gap: attribute(element, [:layout, :gap]),
           align: attribute(element, [:layout, :align]),
           justify: attribute(element, [:layout, :justify])
         })
       )}
    end
  end

  def element(%Element{type: :layout, kind: :grid} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Layout.grid(
         children,
         merge_opts(base_opts(element), %{
           columns: attribute(element, [:layout, :columns]),
           rows: attribute(element, [:layout, :rows]),
           auto_flow: attribute(element, [:layout, :auto_flow], :row),
           gap: attribute(element, [:layout, :gap]),
           align: attribute(element, [:layout, :align]),
           justify: attribute(element, [:layout, :justify])
         })
       )}
    end
  end

  def element(%Element{type: :layout, kind: :stack} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Layout.stack(
         children,
         merge_opts(base_opts(element), %{
           stacking: attribute(element, [:layout, :stacking], :overlay),
           align: attribute(element, [:layout, :align]),
           justify: attribute(element, [:layout, :justify])
         })
       )}
    end
  end

  def element(%Element{type: :layout, kind: :viewport} = element) do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Layout.viewport(
         content,
         merge_opts(base_opts(element), %{
           axis: attribute(element, [:viewport, :axis], :vertical),
           offset: attribute(element, [:viewport, :offset], %{x: 0, y: 0}),
           clip?: attribute(element, [:viewport, :clip?], true),
           scrollbars: attribute(element, [:viewport, :scrollbars], :auto),
           width: attribute(element, [:viewport, :width]),
           height: attribute(element, [:viewport, :height]),
           sync_group: attribute(element, [:viewport, :sync_group]),
           independent_scroll?: attribute(element, [:viewport, :independent_scroll?])
         })
       )}
    end
  end

  def element(%Element{type: :widget, kind: :scroll_bar} = element) do
    {:ok,
     Layout.scroll_bar(
       merge_opts(base_opts(element), %{
         orientation: attribute(element, [:scroll_bar, :orientation], :vertical),
         position: attribute(element, [:scroll_bar, :position], %{start: 0, end: 0}),
         viewport_size: attribute(element, [:scroll_bar, :viewport_size]),
         content_size: attribute(element, [:scroll_bar, :content_size]),
         viewport_ref: attribute(element, [:scroll_bar, :viewport_ref]),
         sync_group: attribute(element, [:scroll_bar, :sync_group])
       })
     )}
  end

  def element(%Element{type: :layout, kind: :split_pane} = element) do
    with {:ok, primary} <- required_slot_child(element, :primary),
         {:ok, secondary} <- required_slot_child(element, :secondary) do
      {:ok,
       Layout.split_pane(
         primary,
         secondary,
         merge_opts(base_opts(element), %{
           direction: attribute(element, [:split, :direction], :horizontal),
           ratio: attribute(element, [:split, :ratio], 0.5),
           resizable?: attribute(element, [:split, :resizable?], true),
           min_primary: attribute(element, [:split, :min_primary]),
           min_secondary: attribute(element, [:split, :min_secondary]),
           primary_size: attribute(element, [:split, :primary_size]),
           secondary_size: attribute(element, [:split, :secondary_size]),
           divider: attribute(element, [:split, :divider], %{}),
           divider_size: get_in(element.attributes, [:split, :divider, :size]),
           divider_style: get_in(element.attributes, [:split, :divider, :style]),
           sync_scroll: attribute(element, [:split, :sync_scroll])
         })
       )}
    end
  end

  def element(%Element{type: :composite, kind: :form_builder} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Forms.form_builder(
         children,
         merge_opts(base_opts(element), %{
           mode: attribute(element, [:form, :mode], :grouped),
           autocomplete?: attribute(element, [:form, :autocomplete?], true)
         })
       )}
    end
  end

  def element(%Element{type: :composite, kind: :field_group} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Forms.field_group(
         children,
         merge_opts(base_opts(element), %{
           legend: attribute(element, [:group, :legend]),
           group_description: attribute(element, [:group, :description]),
           collapsible?: attribute(element, [:group, :collapsible?], false)
         })
       )}
    end
  end

  def element(%Element{type: :composite, kind: :field} = element) do
    with {:ok, control} <- required_slot_child(element, :control) do
      {:ok,
       Forms.field(
         control,
         merge_opts(base_opts(element), %{
           name: attribute(element, [:field, :name]),
           control_id: attribute(element, [:field, :control_id]),
           label: optional_slot_child(element, :label),
           help: optional_slot_child(element, :help)
         })
       )}
    end
  end

  def element(%Element{type: :widget, kind: :table} = element) do
    {:ok,
     Data.table(
       attribute(element, [:table, :columns], []),
       attribute(element, [:table, :rows], []),
       merge_opts(base_opts(element), %{
         dense?: attribute(element, [:table, :dense?], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :tree_view} = element) do
    {:ok,
     Data.tree_view(
       attribute(element, [:tree, :nodes], []),
       merge_opts(base_opts(element), %{
         selection_mode: attribute(element, [:tree, :selection_mode], :single)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :markdown_viewer} = element) do
    {:ok,
     Data.markdown_viewer(
       attribute(element, [:document, :source], ""),
       merge_opts(base_opts(element), %{
         mode: attribute(element, [:document, :mode], :rendered),
         anchors: attribute(element, [:document, :anchors], [])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :log_viewer} = element) do
    {:ok,
     Data.log_viewer(
       attribute(element, [:logs, :entries], []),
       merge_opts(base_opts(element), %{
         wrap?: attribute(element, [:logs, :wrap?], true),
         show_timestamps?: attribute(element, [:logs, :show_timestamps?], true)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :status} = element) do
    {:ok,
     Feedback.status(
       attribute(element, [:feedback, :text], ""),
       merge_opts(base_opts(element), %{
         severity: attribute(element, [:feedback, :severity], :info),
         status: attribute(element, [:feedback, :status], :idle)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :progress} = element) do
    {:ok,
     Feedback.progress(
       merge_opts(base_opts(element), %{
         current: attribute(element, [:progress, :current]),
         total: attribute(element, [:progress, :total]),
         indeterminate?: attribute(element, [:progress, :indeterminate?], false),
         label: attribute(element, [:progress, :label]),
         severity: attribute(element, [:feedback, :severity]),
         status: attribute(element, [:feedback, :status])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :inline_feedback} = element) do
    {:ok,
     Feedback.inline_feedback(
       attribute(element, [:feedback, :message], ""),
       merge_opts(base_opts(element), %{
         title: attribute(element, [:feedback, :title]),
         severity: attribute(element, [:feedback, :severity], :info),
         status: attribute(element, [:feedback, :status])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :gauge} = element) do
    {:ok,
     Visualization.gauge(
       merge_opts(base_opts(element), %{
         value: attribute(element, [:gauge, :value]),
         min: attribute(element, [:gauge, :min], 0),
         max: attribute(element, [:gauge, :max], 100),
         label: attribute(element, [:gauge, :label]),
         severity: attribute(element, [:feedback, :severity]),
         status: attribute(element, [:feedback, :status])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :sparkline} = element) do
    series = chart_series(element)

    {:ok,
     Visualization.sparkline(
       series_values(series),
       merge_opts(base_opts(element), %{
         series_id: Map.get(List.first(series) || %{}, :id),
         axes: attribute(element, [:chart, :axes], %{}),
         legend: attribute(element, [:chart, :legend], %{}),
         scale: attribute(element, [:chart, :scale], %{})
       })
     )}
  end

  def element(%Element{type: :widget, kind: :bar_chart} = element) do
    {:ok,
     Visualization.bar_chart(
       chart_series(element),
       merge_opts(base_opts(element), %{
         axes: attribute(element, [:chart, :axes], %{}),
         legend: attribute(element, [:chart, :legend], %{}),
         scale: attribute(element, [:chart, :scale], %{})
       })
     )}
  end

  def element(%Element{type: :widget, kind: :line_chart} = element) do
    {:ok,
     Visualization.line_chart(
       chart_series(element),
       merge_opts(base_opts(element), %{
         axes: attribute(element, [:chart, :axes], %{}),
         legend: attribute(element, [:chart, :legend], %{}),
         scale: attribute(element, [:chart, :scale], %{})
       })
     )}
  end

  def element(%Element{type: :widget, kind: :canvas} = element) do
    {:ok,
     Visualization.canvas(
       attribute(element, [:canvas, :operations], []),
       merge_opts(base_opts(element), %{
         width: attribute(element, [:canvas, :width]),
         height: attribute(element, [:canvas, :height]),
         unit: attribute(element, [:canvas, :unit], :cell),
         background: attribute(element, [:canvas, :background]),
         clip?: attribute(element, [:canvas, :clip?], true)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :stream_widget} = element) do
    {:ok,
     Operational.stream_widget(
       attribute(element, [:stream, :entries], []),
       merge_opts(base_opts(element), %{
         ordering: attribute(element, [:stream, :ordering], :append_only),
         severity_field: attribute(element, [:stream, :severity_field]),
         timestamp_field: attribute(element, [:stream, :timestamp_field])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :process_monitor} = element) do
    {:ok,
     Operational.process_monitor(
       attribute(element, [:monitor, :processes], []),
       merge_opts(base_opts(element), %{
         sort_by: attribute(element, [:monitor, :sort_by]),
         severity: attribute(element, [:monitor, :severity])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :cluster_dashboard} = element) do
    {:ok,
     Operational.cluster_dashboard(
       attribute(element, [:cluster, :nodes], []),
       merge_opts(base_opts(element), %{
         summary: attribute(element, [:cluster, :summary], %{}),
         severity: attribute(element, [:cluster, :severity])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :command_palette} = element) do
    {:ok,
     Operational.command_palette(
       attribute(element, [:command_palette, :commands], []),
       merge_opts(base_opts(element), %{
         query: attribute(element, [:command_palette, :query]),
         active_command: attribute(element, [:command_palette, :active_command]),
         placeholder: attribute(element, [:command_palette, :placeholder])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :supervision_tree_viewer} = element) do
    {:ok,
     Operational.supervision_tree_viewer(
       attribute(element, [:inspection, :nodes], []),
       merge_opts(base_opts(element), %{
         expanded?: attribute(element, [:inspection, :expanded?], true),
         show_restarts?: attribute(element, [:inspection, :show_restarts?], true)
       })
     )}
  end

  def element(%Element{type: :layer, kind: :overlay} = element) do
    with {:ok, base} <- required_slot_child(element, :base),
         {:ok, layers} <- overlay_children(element) do
      {:ok,
       Layered.overlay(
         base,
         layers,
         merge_opts(base_opts(element), %{
           mode: attribute(element, [:overlay, :mode], :stacked),
           background_fill: attribute(element, [:overlay, :background_fill], :transparent),
           dismissible?: attribute(element, [:overlay, :dismissible?]),
           focus_scope: attribute(element, [:overlay, :focus_scope])
         })
       )}
    end
  end

  def element(%Element{type: :layer, kind: :dialog} = element) do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Layered.dialog(
         content,
         merge_opts(base_opts(element), %{
           title: attribute(element, [:dialog, :title]),
           modal?: attribute(element, [:dialog, :modal?], true),
           dismissible?: attribute(element, [:dialog, :dismissible?], true),
           size: attribute(element, [:dialog, :size], :md),
           background_fill: attribute(element, [:dialog, :background_fill], :scrim),
           focus_scope: attribute(element, [:dialog, :focus_scope], :dialog)
         })
       )}
    end
  end

  def element(%Element{type: :layer, kind: :toast} = element) do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Layered.toast(
         content,
         merge_opts(base_opts(element), %{
           placement: attribute(element, [:toast, :placement], :top_end),
           duration_ms: attribute(element, [:toast, :duration_ms], 5000),
           severity: attribute(element, [:toast, :severity], :info),
           transient?: attribute(element, [:toast, :transient?], true)
         })
       )}
    end
  end

  def element(%Element{type: :layer, kind: :alert_dialog} = element) do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Layered.alert_dialog(
         content,
         merge_opts(base_opts(element), %{
           title: attribute(element, [:alert_dialog, :title]),
           severity: attribute(element, [:alert_dialog, :severity], :warning),
           requires_confirmation?:
             attribute(
               element,
               [:alert_dialog, :requires_confirmation?],
               true
             ),
           background_fill: attribute(element, [:alert_dialog, :background_fill], :scrim),
           focus_scope: attribute(element, [:alert_dialog, :focus_scope], :alert_dialog)
         })
       )}
    end
  end

  def element(%Element{type: :layer, kind: :context_menu} = element) do
    with {:ok, menu} <- required_slot_child(element, :menu) do
      {:ok,
       Layered.context_menu(
         menu,
         merge_opts(base_opts(element), %{
           anchor: attribute(element, [:context_menu, :anchor], %{}),
           placement: attribute(element, [:context_menu, :placement], :bottom_start),
           dismissible?: attribute(element, [:context_menu, :dismissible?], true),
           background_fill: attribute(element, [:context_menu, :background_fill], :none)
         })
       )}
    end
  end

  def element(%Element{} = element) do
    {:error, Error.unsupported_kind(element, supported_kinds())}
  end

  defp base_opts(element) do
    %{
      id: element.id,
      description: element.metadata.description,
      tags: element.metadata.tags,
      annotations: element.metadata.annotations,
      style_hooks: style_hooks(element),
      state: canonical_state(element),
      events: canonical_events(element),
      metadata: canonical_metadata(element)
    }
  end

  defp canonical_metadata(element) do
    %{
      canonical_source: %{
        id: element.id,
        type: element.type,
        kind: element.kind
      },
      authored_ref: element.metadata.authored_ref,
      extra: element.metadata.extra,
      attachment_keys:
        element.attributes
        |> Map.keys()
        |> Enum.filter(&(&1 in [:style, :theme, :interactions, :bindings, :interaction_scope]))
        |> Enum.sort()
    }
  end

  defp canonical_state(element) do
    theme_state = get_in(element.attributes, [:theme, :state])

    element.attributes
    |> Map.get(:state, %{})
    |> normalize_map()
    |> maybe_put(:theme_state, theme_state)
  end

  defp canonical_events(element) do
    element.attributes
    |> Map.get(:interactions, [])
    |> Enum.reduce(%{}, fn %Interaction{} = interaction, acc ->
      Map.put(acc, event_name(element.kind, interaction.family), event_value(interaction))
    end)
  end

  defp event_name(kind, :selection) when kind in [:menu, :tabs, :context_menu], do: :navigation
  defp event_name(_kind, :selection), do: :change
  defp event_name(_kind, family), do: family

  defp event_value(%Interaction{} = interaction) do
    suffix = interaction.intent || Map.get(interaction.metadata, :phase) || interaction.family
    "canonical:#{suffix}"
  end

  defp style_hooks(element) do
    refs =
      element.attributes
      |> get_in([:theme, :token_refs])
      |> List.wrap()
      |> Enum.map(&token_ref_to_hook/1)

    refs
    |> maybe_append(style_tone(element))
    |> maybe_append(style_variant(element))
    |> Enum.uniq()
  end

  defp style_tone(element) do
    attribute(element, [:style, :emphasis, :tone])
  end

  defp style_variant(element) do
    attribute(element, [:theme, :variant])
  end

  defp token_ref_to_hook(%{path: path}) when is_list(path),
    do: path |> Enum.map(&to_string/1) |> Enum.join(".")

  defp token_ref_to_hook(value), do: to_string(value)

  defp content_text(element) do
    attribute(element, [:content, :text], "")
  end

  defp first_binding(element) do
    element.attributes
    |> Map.get(:bindings, [])
    |> List.first()
    |> normalize_map()
  end

  defp child_elements(element) do
    element.children
    |> Enum.filter(&Child.present?/1)
    |> Enum.map(& &1.element)
  end

  defp overlay_children(element) do
    element.children
    |> Enum.filter(&(Child.present?(&1) and &1.slot != :base))
    |> Enum.map(& &1.element)
    |> map_children()
  end

  defp required_slot_child(element, slot) do
    case optional_slot_child(element, slot) do
      nil -> {:error, Error.invalid_field(element, slot)}
      widget -> {:ok, widget}
    end
  end

  defp optional_slot_child(element, slot) do
    element
    |> Element.children_for_slot(slot)
    |> Enum.find_value(fn
      %Child{element: nil} -> nil
      %Child{element: child} -> child |> element() |> unwrap_widget()
    end)
  end

  defp chart_series(element) do
    attribute(element, [:chart, :series], [])
  end

  defp series_values(series) do
    series
    |> List.first()
    |> case do
      nil -> []
      item -> Map.get(item, :values, Map.get(item, "values", []))
    end
  end

  defp unwrap_widget({:ok, widget}), do: widget
  defp unwrap_widget({:error, _reason}), do: nil

  defp map_children(children) do
    children
    |> Enum.reduce_while({:ok, []}, fn child, {:ok, acc} ->
      case element(child) do
        {:ok, widget} -> {:cont, {:ok, acc ++ [widget]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp normalize_map(nil), do: %{}
  defp normalize_map(%_{} = struct), do: Map.from_struct(struct)
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp maybe_append(list, nil), do: list
  defp maybe_append(list, value), do: list ++ [value]

  defp merge_opts(base, extras) do
    Map.merge(base, Enum.reject(extras, fn {_key, value} -> is_nil(value) end) |> Map.new())
  end

  defp attribute(%Element{attributes: attributes}, path, default \\ nil) do
    case get_in(attributes, path) do
      nil -> default
      value -> value
    end
  end
end
