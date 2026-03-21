defmodule WebUi.Renderer.Canonical do
  @moduledoc """
  Deterministic canonical-to-native widget mapping for the `web_ui` scaffold.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias WebUi.Renderer.Error
  alias WebUi.Widgets

  @spec render(Element.t(), keyword()) :: {:ok, WebUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, _opts \\ []) do
    do_render(element)
  end

  defp do_render(%Element{id: nil} = element), do: {:error, Error.missing_identity(element)}

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:text, "text"] do
    {:ok,
     Widgets.text(element.id, attr(element, :content, inspect(element.id)), base_opts(element))}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:label, "label"] do
    {:ok,
     Widgets.label(
       element.id,
       attr(element, :content, inspect(element.id)),
       Keyword.merge(base_opts(element),
         for: attr(element, :for),
         relationship: attr(element, :relationship, :label)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:icon, "icon"] do
    {:ok,
     Widgets.icon(
       element.id,
       attr(element, :name, attr(element, :icon, :unknown)),
       Keyword.merge(base_opts(element),
         set: attr(element, :set),
         fallback_text: attr(element, :fallback_text)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:image, "image"] do
    {:ok,
     Widgets.image(
       element.id,
       attr(element, :src, attr(element, :source, "")),
       Keyword.merge(base_opts(element),
         alt: attr(element, :alt, ""),
         fit: attr(element, :fit, :cover)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:button, "button"] do
    {:ok,
     Widgets.button(
       element.id,
       attr(element, :label, attr(element, :content, "Button")),
       base_opts(element)
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:link, "link"] do
    {:ok,
     Widgets.link(
       element.id,
       attr(element, :label, attr(element, :content, "Link")),
       attr(element, :href, "#"),
       Keyword.merge(base_opts(element), external: attr(element, :external, false))
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:separator, "separator"] do
    {:ok,
     Widgets.separator(
       element.id,
       Keyword.merge(base_opts(element),
         orientation: attr(element, :orientation, :horizontal),
         decorative: attr(element, :decorative, true)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:spacer, "spacer"] do
    {:ok,
     Widgets.spacer(
       element.id,
       Keyword.merge(base_opts(element),
         size: attr(element, :size, :md),
         grow: attr(element, :grow, 0)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:content, "content"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.content(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           role: attr(element, :role, :content),
           presentation: attr(element, :presentation, :body)
         )
       )}
    end
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:text_input, "text_input"] do
    {:ok,
     Widgets.text_input(
       element.id,
       Keyword.merge(base_opts(element),
         name: attr(element, :name),
         value: attr(element, :value, ""),
         placeholder: attr(element, :placeholder),
         multiline: attr(element, :multiline, false),
         input_mode: attr(element, :input_mode, :text)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:checkbox, "checkbox"] do
    {:ok,
     Widgets.checkbox(
       element.id,
       attr(element, :label, "Checkbox"),
       Keyword.merge(base_opts(element),
         name: attr(element, :name),
         checked: attr(element, :checked, attr(element, :value, false))
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:select, "select"] do
    {:ok,
     Widgets.select(
       element.id,
       attr(element, :options, []),
       Keyword.merge(base_opts(element),
         name: attr(element, :name),
         value: attr(element, :value),
         multiple: attr(element, :multiple, false)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:menu, "menu"] do
    {:ok,
     Widgets.menu(
       element.id,
       attr(element, :items, []),
       Keyword.merge(base_opts(element),
         active_item: attr(element, :active_item),
         orientation: attr(element, :orientation, :vertical)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:tabs, "tabs"] do
    {:ok,
     Widgets.tabs(
       element.id,
       attr(element, :items, []),
       Keyword.merge(base_opts(element),
         active_item: attr(element, :active_item),
         orientation: attr(element, :orientation, :horizontal)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:table, "table"] do
    sorting = map_attr(element, :sorting)
    pagination = map_attr(element, :pagination)

    {:ok,
     Widgets.table(
       element.id,
       attr(element, :columns, []),
       attr(element, :rows, []),
       Keyword.merge(base_opts(element),
         dense: attr(element, :dense, false),
         selection_mode: attr(element, :selection_mode, :single),
         sort_key: attr(element, :sort_key, map_get(sorting, :key)),
         sort_direction: attr(element, :sort_direction, map_get(sorting, :direction)),
         filters: attr(element, :filters, []),
         page: attr(element, :page, map_get(pagination, :page)),
         page_size: attr(element, :page_size, map_get(pagination, :page_size)),
         total_entries: attr(element, :total_entries, map_get(pagination, :total_entries))
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:tree_view, "tree_view"] do
    {:ok,
     Widgets.tree_view(
       element.id,
       attr(element, :nodes, []),
       Keyword.merge(base_opts(element),
         selection_mode: attr(element, :selection_mode, :single),
         filters: attr(element, :filters, []),
         query: attr(element, :query),
         expand_all: attr(element, :expand_all, false)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:markdown_viewer, "markdown_viewer"] do
    {:ok,
     Widgets.markdown_viewer(
       element.id,
       attr(element, :source, attr(element, :content, "")),
       Keyword.merge(base_opts(element),
         mode: attr(element, :mode, :rendered),
         anchors: attr(element, :anchors, [])
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:log_viewer, "log_viewer"] do
    pagination = map_attr(element, :pagination)

    {:ok,
     Widgets.log_viewer(
       element.id,
       attr(element, :entries, []),
       Keyword.merge(base_opts(element),
         wrap: attr(element, :wrap, true),
         show_timestamps: attr(element, :show_timestamps, true),
         follow: attr(element, :follow, false),
         filters: attr(element, :filters, []),
         page: attr(element, :page, map_get(pagination, :page)),
         page_size: attr(element, :page_size, map_get(pagination, :page_size)),
         total_entries: attr(element, :total_entries, map_get(pagination, :total_entries))
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:status, "status"] do
    {:ok,
     Widgets.status(
       element.id,
       attr(element, :text, attr(element, :content, "")),
       Keyword.merge(base_opts(element),
         severity: attr(element, :severity, :info),
         status: attr(element, :status, :idle),
         icon: attr(element, :icon)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:progress, "progress"] do
    {:ok,
     Widgets.progress(
       element.id,
       Keyword.merge(base_opts(element),
         current: attr(element, :current),
         total: attr(element, :total),
         indeterminate: attr(element, :indeterminate, false),
         label: attr(element, :label),
         severity: attr(element, :severity),
         status: attr(element, :status)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:inline_feedback, "inline_feedback"] do
    {:ok,
     Widgets.inline_feedback(
       element.id,
       attr(element, :message, attr(element, :content, "")),
       Keyword.merge(base_opts(element),
         title: attr(element, :title),
         severity: attr(element, :severity, :info),
         status: attr(element, :status)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:gauge, "gauge"] do
    {:ok,
     Widgets.gauge(
       element.id,
       Keyword.merge(base_opts(element),
         value: attr(element, :value),
         min: attr(element, :min, 0),
         max: attr(element, :max, 100),
         label: attr(element, :label),
         severity: attr(element, :severity),
         status: attr(element, :status)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:sparkline, "sparkline"] do
    series = attr(element, :series, [])

    {:ok,
     Widgets.sparkline(
       element.id,
       sparkline_values(series),
       Keyword.merge(base_opts(element),
         series_id: sparkline_series_id(series),
         axes: attr(element, :axes, %{}),
         legend: attr(element, :legend, %{}),
         scale: attr(element, :scale, %{})
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:bar_chart, "bar_chart"] do
    {:ok,
     Widgets.bar_chart(
       element.id,
       attr(element, :series, []),
       Keyword.merge(base_opts(element),
         axes: attr(element, :axes, %{}),
         legend: attr(element, :legend, %{}),
         scale: attr(element, :scale, %{})
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:line_chart, "line_chart"] do
    {:ok,
     Widgets.line_chart(
       element.id,
       attr(element, :series, []),
       Keyword.merge(base_opts(element),
         axes: attr(element, :axes, %{}),
         legend: attr(element, :legend, %{}),
         scale: attr(element, :scale, %{})
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:canvas, "canvas"] do
    {:ok,
     Widgets.canvas(
       element.id,
       attr(element, :operations, []),
       Keyword.merge(base_opts(element),
         width: attr(element, :width),
         height: attr(element, :height),
         unit: attr(element, :unit, :cell),
         background: attr(element, :background),
         clip: attr(element, :clip, true)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:stream_widget, "stream_widget"] do
    {:ok,
     Widgets.stream_widget(
       element.id,
       attr(element, :entries, []),
       Keyword.merge(base_opts(element),
         ordering: attr(element, :ordering, :append_only),
         severity_field: attr(element, :severity_field),
         timestamp_field: attr(element, :timestamp_field)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:process_monitor, "process_monitor"] do
    {:ok,
     Widgets.process_monitor(
       element.id,
       attr(element, :processes, []),
       Keyword.merge(base_opts(element),
         sort_by: attr(element, :sort_by),
         severity: attr(element, :severity)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:cluster_dashboard, "cluster_dashboard"] do
    {:ok,
     Widgets.cluster_dashboard(
       element.id,
       attr(element, :nodes, []),
       Keyword.merge(base_opts(element),
         summary: attr(element, :summary, %{}),
         severity: attr(element, :severity)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:command_palette, "command_palette"] do
    {:ok,
     Widgets.command_palette(
       element.id,
       attr(element, :commands, []),
       Keyword.merge(base_opts(element),
         query: attr(element, :query),
         active_command: attr(element, :active_command),
         placeholder: attr(element, :placeholder)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:supervision_tree_viewer, "supervision_tree_viewer"] do
    {:ok,
     Widgets.supervision_tree_viewer(
       element.id,
       attr(element, :nodes, []),
       Keyword.merge(base_opts(element),
         expanded: attr(element, :expanded, true),
         show_restarts: attr(element, :show_restarts, true)
       )
     )}
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and kind in [:row, "row"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.row(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           gap: attr(element, :gap),
           align: attr(element, :align),
           justify: attr(element, :justify)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and kind in [:column, "column", :container, "container"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.column(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           gap: attr(element, :gap),
           align: attr(element, :align),
           justify: attr(element, :justify)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and kind in [:stack, "stack"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.stack(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           direction: attr(element, :direction, :column),
           gap: attr(element, :gap)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and kind in [:viewport, "viewport"] do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Widgets.viewport(
         element.id,
         content,
         Keyword.merge(base_opts(element),
           axis: attr(element, :axis, :vertical),
           offset: attr(element, :offset, 0),
           clip: attr(element, :clip, true),
           scrollbars: attr(element, :scrollbars, :auto),
           width: attr(element, :width),
           height: attr(element, :height),
           sync_group: attr(element, :sync_group),
           independent_scroll: attr(element, :independent_scroll, false)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:widget, :layout, "widget", "layout"] and kind in [:scroll_bar, "scroll_bar"] do
    {:ok,
     Widgets.scroll_bar(
       element.id,
       Keyword.merge(base_opts(element),
         orientation: attr(element, :orientation, :vertical),
         position: attr(element, :position, 0),
         viewport_size: attr(element, :viewport_size),
         content_size: attr(element, :content_size),
         viewport_ref: attr(element, :viewport_ref),
         sync_group: attr(element, :sync_group)
       )
     )}
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and kind in [:split_pane, "split_pane"] do
    with {:ok, primary} <- required_slot_child(element, :primary),
         {:ok, secondary} <- required_slot_child(element, :secondary) do
      {:ok,
       Widgets.split_pane(
         element.id,
         primary,
         secondary,
         Keyword.merge(base_opts(element),
           direction: attr(element, :direction, :horizontal),
           ratio: attr(element, :ratio, 0.5),
           resizable: attr(element, :resizable, true),
           min_primary: attr(element, :min_primary),
           min_secondary: attr(element, :min_secondary),
           primary_size: attr(element, :primary_size),
           secondary_size: attr(element, :secondary_size),
           divider: attr(element, :divider, %{}),
           divider_size: map_get(map_attr(element, :divider), :size),
           divider_style: map_get(map_attr(element, :divider), :style),
           sync_scroll: attr(element, :sync_scroll, false)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and
              kind in [:form, "form", :form_builder, "form_builder"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.form(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           mode: attr(element, :mode, :grouped),
           autocomplete: attr(element, :autocomplete, true)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:field_group, "field_group"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.field_group(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           legend: attr(element, :legend),
           group_description: attr(element, :description),
           collapsible: attr(element, :collapsible, false)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:field, "field"] do
    with {:ok, control} <- required_slot_child(element, :control) do
      {:ok,
       Widgets.field(
         element.id,
         control,
         Keyword.merge(base_opts(element),
           name: attr(element, :name),
           control_id: attr(element, :control_id),
           label: optional_slot_child(element, :label),
           help: optional_slot_child(element, :help)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layer, :widget, "layer", "widget"] and kind in [:overlay, "overlay"] do
    with {:ok, base} <- required_slot_child(element, :base),
         {:ok, layers} <- required_layer_children(element) do
      {:ok,
       Widgets.overlay(
         element.id,
         base,
         layers,
         Keyword.merge(base_opts(element),
           mode: attr(element, :mode, :stacked),
           background_fill: attr(element, :background_fill, :transparent),
           dismissible: attr(element, :dismissible, true),
           focus_scope: attr(element, :focus_scope),
           z_order: attr(element, :z_order, :overlay)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layer, :widget, "layer", "widget"] and kind in [:dialog, "dialog"] do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Widgets.dialog(
         element.id,
         content,
         Keyword.merge(base_opts(element),
           title: attr(element, :title),
           modal: attr(element, :modal, true),
           dismissible: attr(element, :dismissible, true),
           size: attr(element, :size, :md),
           background_fill: attr(element, :background_fill, :scrim),
           focus_scope: attr(element, :focus_scope, :dialog)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layer, :widget, "layer", "widget"] and kind in [:toast, "toast"] do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Widgets.toast(
         element.id,
         content,
         Keyword.merge(base_opts(element),
           placement: attr(element, :placement, :top_end),
           duration_ms: attr(element, :duration_ms, 5_000),
           severity: attr(element, :severity, :info),
           transient: attr(element, :transient, true)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layer, :widget, "layer", "widget"] and
              kind in [:alert_dialog, "alert_dialog"] do
    with {:ok, content} <- required_slot_child(element, :content) do
      {:ok,
       Widgets.alert_dialog(
         element.id,
         content,
         Keyword.merge(base_opts(element),
           title: attr(element, :title),
           severity: attr(element, :severity, :warning),
           requires_confirmation: attr(element, :requires_confirmation, true),
           background_fill: attr(element, :background_fill, :scrim),
           focus_scope: attr(element, :focus_scope, :alert_dialog)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layer, :widget, "layer", "widget"] and
              kind in [:context_menu, "context_menu"] do
    {:ok,
     Widgets.context_menu(
       element.id,
       attr(element, :items, []),
       Keyword.merge(base_opts(element),
         anchor: attr(element, :anchor, %{}),
         placement: attr(element, :placement, :bottom_start),
         dismissible: attr(element, :dismissible, true),
         background_fill: attr(element, :background_fill, :none)
       )
     )}
  end

  defp do_render(%Element{} = element) do
    {:error, Error.unsupported_kind(element, WebUi.Renderer.supported_kinds())}
  end

  defp base_opts(%Element{} = element) do
    [
      description: element.metadata && element.metadata.description,
      tags: element.metadata && Map.get(element.metadata, :tags),
      annotations: element.metadata && Map.get(element.metadata, :annotations),
      state: attr(element, :state, %{}),
      styles: attr(element, :styles, %{}),
      events: attr(element, :events, %{}),
      style_hooks: attr(element, :style_hooks, []),
      metadata: %{
        canonical_source: %{
          id: element.id,
          type: element.type,
          kind: element.kind
        }
      }
    ]
    |> Enum.reject(fn {_key, value} -> value in [nil, %{}, []] end)
  end

  defp default_children(%Element{} = element) do
    element.children
    |> Enum.filter(fn
      %Child{slot: slot} -> slot in [:default, "default"]
      %Element{} -> true
    end)
  end

  defp map_children(children) do
    children
    |> Enum.reduce_while({:ok, []}, fn child, {:ok, acc} ->
      case render_child(child) do
        {:ok, widget} -> {:cont, {:ok, [widget | acc]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, widgets} -> {:ok, Enum.reverse(widgets)}
      error -> error
    end
  end

  defp required_slot_child(%Element{} = element, slot) do
    case slot_child(element, slot) do
      {:ok, nil} -> {:error, Error.missing_required_slot(element, slot)}
      {:ok, widget} -> {:ok, widget}
      {:error, error} -> {:error, error}
    end
  end

  defp required_layer_children(%Element{} = element) do
    layers =
      element.children
      |> Enum.filter(fn
        %Child{slot: slot} -> slot in [:layers, "layers"]
        _other -> false
      end)

    layers =
      if layers == [] do
        Enum.filter(element.children, fn
          %Child{slot: slot} -> slot not in [:base, "base"]
          _other -> false
        end)
      else
        layers
      end

    case layers do
      [] -> {:error, Error.missing_required_slot(element, :layers)}
      children -> map_children(children)
    end
  end

  defp optional_slot_child(%Element{} = element, slot) do
    case slot_child(element, slot) do
      {:ok, widget} -> widget
      {:error, _error} -> nil
    end
  end

  defp slot_child(%Element{} = element, slot) do
    element.children
    |> Enum.find(fn
      %Child{slot: child_slot} -> child_slot == slot or child_slot == Atom.to_string(slot)
      _other -> false
    end)
    |> case do
      %Child{element: %Element{} = child} ->
        do_render(child)

      %Element{} = child ->
        do_render(child)

      _other ->
        {:ok, nil}
    end
  end

  defp render_child(%Child{element: %Element{} = element}), do: do_render(element)
  defp render_child(%Element{} = element), do: do_render(element)

  defp sparkline_values(series) when is_list(series) do
    case List.first(series) do
      %{values: values} when is_list(values) -> values
      %{"values" => values} when is_list(values) -> values
      first when is_number(first) -> series
      _other -> []
    end
  end

  defp sparkline_values(_series), do: []

  defp sparkline_series_id(series) when is_list(series) do
    case List.first(series) do
      %{id: id} -> id
      %{"id" => id} -> id
      _other -> :primary
    end
  end

  defp sparkline_series_id(_series), do: :primary

  defp map_attr(%Element{} = element, key) do
    element
    |> attr(key, %{})
    |> normalize_map()
  end

  defp map_get(map, key, default \\ nil) when is_map(map) do
    cond do
      Map.has_key?(map, key) -> Map.get(map, key)
      Map.has_key?(map, Atom.to_string(key)) -> Map.get(map, Atom.to_string(key))
      true -> default
    end
  end

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp attr(%Element{attributes: attrs}, key, default \\ nil) do
    cond do
      Map.has_key?(attrs, key) -> Map.get(attrs, key)
      Map.has_key?(attrs, Atom.to_string(key)) -> Map.get(attrs, Atom.to_string(key))
      true -> default
    end
  end
end
