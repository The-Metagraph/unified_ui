defmodule TerminalUi.Renderer.Mapper do
  @moduledoc """
  Canonical-to-native widget mapper for `terminal_ui`.
  """

  alias TerminalUi.Renderer.Error
  alias UnifiedIUR.{Binding, Element, Interaction}
  alias UnifiedIUR.Element.Child

  @spec map(Element.t(), keyword()) :: {:ok, TerminalUi.Widget.t()} | {:error, Error.t()}
  def map(element, opts \\ [])

  def map(%Element{id: nil} = element, _opts) do
    {:error, Error.new(:missing_canonical_identity, %{kind: element.kind, type: element.type})}
  end

  def map(%Element{} = element, _opts) do
    with :ok <- validate_attachments(element) do
      do_map(element)
    end
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:text, "text"] do
    {:ok,
     TerminalUi.Widgets.text(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:label, "label"] do
    {:ok,
     TerminalUi.Widgets.label(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:icon, "icon"] do
    {:ok,
     TerminalUi.Widgets.icon(
       element.id,
       first_present(
         [group_attr(element, :icon, :name), attr(element, :icon), attr(element, :name)],
         :unknown
       ),
       Keyword.merge(
         base_opts(element),
         fallback_text:
           first_present(
             [group_attr(element, :icon, :fallback_text), attr(element, :fallback_text)],
             "[icon]"
           )
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:image, "image"] do
    {:ok,
     TerminalUi.Widgets.image(
       element.id,
       first_present(
         [group_attr(element, :image, :source), attr(element, :source), attr(element, :src)],
         ""
       ),
       Keyword.merge(
         base_opts(element),
         alt: first_present([group_attr(element, :image, :alt_text), attr(element, :alt)], ""),
         degradation: :placeholder
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:button, "button"] do
    {:ok,
     TerminalUi.Widgets.button(
       element.id,
       content_text(element, "Button"),
       Keyword.merge(base_opts(element), on_press: interaction_payload(element, :click))
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:link, "link"] do
    {:ok,
     TerminalUi.Widgets.link(
       element.id,
       content_text(element, "Link"),
       first_present(
         [group_attr(element, :link, :target), attr(element, :href), attr(element, :target)],
         "#"
       ),
       Keyword.merge(base_opts(element), on_follow: interaction_payload(element, :click))
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:separator, "separator"] do
    {:ok,
     TerminalUi.Widgets.separator(
       element.id,
       Keyword.merge(
         base_opts(element),
         orientation:
           first_present(
             [group_attr(element, :separator, :orientation), attr(element, :orientation)],
             :horizontal
           )
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:spacer, "spacer"] do
    {:ok,
     TerminalUi.Widgets.spacer(
       element.id,
       Keyword.merge(base_opts(element),
         size: first_present([group_attr(element, :spacer, :size), attr(element, :size)], :md)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:text_input, "text_input", :numeric_input, "numeric_input"] do
    {:ok,
     TerminalUi.Widgets.text_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)], ""),
         binding: binding_name(element),
         placeholder:
           first_present(
             [group_attr(element, :input, :placeholder), attr(element, :placeholder)],
             ""
           ),
         on_change: interaction_payload(element, :change),
         on_submit: interaction_payload(element, :submit)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:toggle, "toggle"] do
    {:ok,
     TerminalUi.Widgets.toggle(
       element.id,
       content_text(element, label_text(element, "Toggle")),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_toggle: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:checkbox, "checkbox"] do
    {:ok,
     TerminalUi.Widgets.checkbox(
       element.id,
       label_text(element, "Checkbox"),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:radio_group, "radio_group"] do
    {:ok,
     TerminalUi.Widgets.radio_group(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:select, "select"] do
    {:ok,
     TerminalUi.Widgets.select(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:menu, "menu"] do
    {:ok,
     TerminalUi.Widgets.menu(
       element.id,
       first_present([group_attr(element, :navigation, :items), attr(element, :items)], []),
       Keyword.merge(
         base_opts(element),
         current:
           first_present([group_attr(element, :navigation, :active_item), binding_value(element)]),
         binding: binding_name(element),
         on_navigate: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:tabs, "tabs"] do
    {:ok,
     TerminalUi.Widgets.tabs(
       element.id,
       first_present([group_attr(element, :navigation, :items), attr(element, :items)], []),
       Keyword.merge(
         base_opts(element),
         current:
           first_present([group_attr(element, :navigation, :active_item), binding_value(element)]),
         binding: binding_name(element),
         on_navigate: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:list, "list"] do
    {:ok,
     TerminalUi.Widgets.list(
       element.id,
       first_present([group_attr(element, :list, :items), attr(element, :items)], []),
       Keyword.merge(
         base_opts(element),
         current: first_present([attr(element, :current), binding_value(element)]),
         binding: binding_name(element),
         on_navigate: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:table, "table"] do
    {:ok,
     TerminalUi.Widgets.table(
       element.id,
       first_present([group_attr(element, :table, :columns), attr(element, :columns)], []),
       first_present([group_attr(element, :table, :rows), attr(element, :rows)], []),
       Keyword.merge(
         base_opts(element),
         dense:
           first_present([group_attr(element, :table, :dense?), attr(element, :dense?)], false),
         selection_mode:
           first_present(
             [group_attr(element, :table, :selection_mode), attr(element, :selection_mode)],
             :single
           ),
         sort_key: sorting_attr(element, :key),
         sort_direction: sorting_attr(element, :direction),
         binding: binding_name(element),
         on_select: interaction_payload(element, :selection),
         on_sort: interaction_payload(element, :command),
         on_filter: interaction_payload(element, :change),
         on_paginate: interaction_payload(element, :navigation)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:tree_view, "tree_view"] do
    {:ok,
     TerminalUi.Widgets.tree_view(
       element.id,
       first_present([group_attr(element, :tree, :nodes), attr(element, :nodes)], []),
       Keyword.merge(
         base_opts(element),
         selection_mode:
           first_present(
             [group_attr(element, :tree, :selection_mode), attr(element, :selection_mode)],
             :single
           ),
         query: first_present([group_attr(element, :tree, :query), attr(element, :query)]),
         binding: binding_name(element),
         on_select: interaction_payload(element, :selection),
         on_expand: interaction_payload(element, :navigation),
         on_filter: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:status, "status"] do
    {:ok,
     TerminalUi.Widgets.status(
       element.id,
       first_present([group_attr(element, :feedback, :text), attr(element, :text)], "Status"),
       Keyword.merge(
         base_opts(element),
         severity:
           first_present(
             [group_attr(element, :feedback, :severity), attr(element, :severity)],
             :info
           ),
         status:
           first_present([group_attr(element, :feedback, :status), attr(element, :status)], :idle)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:progress, "progress"] do
    {:ok,
     TerminalUi.Widgets.progress(
       element.id,
       Keyword.merge(
         base_opts(element),
         current:
           first_present([group_attr(element, :progress, :current), attr(element, :current)]),
         total: first_present([group_attr(element, :progress, :total), attr(element, :total)]),
         indeterminate:
           first_present(
             [group_attr(element, :progress, :indeterminate?), attr(element, :indeterminate?)],
             false
           ),
         label: first_present([group_attr(element, :progress, :label), attr(element, :label)]),
         severity:
           first_present([group_attr(element, :feedback, :severity), attr(element, :severity)]),
         binding: binding_name(element)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:gauge, "gauge"] do
    {:ok,
     TerminalUi.Widgets.gauge(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([group_attr(element, :gauge, :value), attr(element, :value)]),
         min: first_present([group_attr(element, :gauge, :min), attr(element, :min)], 0),
         max: first_present([group_attr(element, :gauge, :max), attr(element, :max)], 100),
         label: first_present([group_attr(element, :gauge, :label), attr(element, :label)]),
         severity:
           first_present([group_attr(element, :feedback, :severity), attr(element, :severity)]),
         binding: binding_name(element)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:inline_feedback, "inline_feedback"] do
    {:ok,
     TerminalUi.Widgets.status(
       element.id,
       first_present(
         [
           group_attr(element, :feedback, :message),
           group_attr(element, :feedback, :title),
           attr(element, :message)
         ],
         "Feedback"
       ),
       Keyword.merge(
         base_opts(element),
         severity:
           first_present(
             [group_attr(element, :feedback, :severity), attr(element, :severity)],
             :info
           ),
         status:
           first_present([group_attr(element, :feedback, :status), attr(element, :status)], :idle)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:markdown_viewer, "markdown_viewer"] do
    {:ok,
     TerminalUi.Widgets.markdown_viewer(
       element.id,
       first_present(
         [
           group_attr(element, :document, :source),
           attr(element, :source),
           attr(element, :content)
         ],
         ""
       ),
       Keyword.merge(
         base_opts(element),
         mode:
           first_present([group_attr(element, :document, :mode), attr(element, :mode)], :rendered),
         anchors:
           first_present([group_attr(element, :document, :anchors), attr(element, :anchors)], [])
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:sparkline, "sparkline"] do
    series =
      element
      |> chart_series()
      |> List.first()
      |> case do
        %{values: values} -> values
        %{"values" => values} -> values
        _other -> []
      end

    {:ok, TerminalUi.Widgets.sparkline(element.id, series, base_opts(element))}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:bar_chart, "bar_chart"] do
    {:ok,
     TerminalUi.Widgets.bar_chart(
       element.id,
       chart_series(element),
       Keyword.merge(base_opts(element),
         axes: first_present([group_attr(element, :chart, :axes), attr(element, :axes)], %{})
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:line_chart, "line_chart"] do
    {:ok,
     TerminalUi.Widgets.line_chart(
       element.id,
       chart_series(element),
       Keyword.merge(base_opts(element),
         axes: first_present([group_attr(element, :chart, :axes), attr(element, :axes)], %{})
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:canvas, "canvas"] do
    {:ok,
     TerminalUi.Widgets.canvas(
       element.id,
       first_present([group_attr(element, :canvas, :operations), attr(element, :operations)], []),
       Keyword.merge(
         base_opts(element),
         width: first_present([group_attr(element, :canvas, :width), attr(element, :width)]),
         height: first_present([group_attr(element, :canvas, :height), attr(element, :height)]),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:stream_widget, "stream_widget"] do
    {:ok,
     TerminalUi.Widgets.stream_widget(
       element.id,
       first_present([group_attr(element, :stream, :entries), attr(element, :entries)], []),
       Keyword.merge(
         base_opts(element),
         ordering:
           first_present(
             [group_attr(element, :stream, :ordering), attr(element, :ordering)],
             :append_only
           ),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:log_viewer, "log_viewer"] do
    {:ok,
     TerminalUi.Widgets.log_viewer(
       element.id,
       first_present([group_attr(element, :logs, :entries), attr(element, :entries)], []),
       Keyword.merge(
         base_opts(element),
         query: first_present([group_attr(element, :logs, :query), attr(element, :query)]),
         binding: binding_name(element),
         on_filter: interaction_payload(element, :change),
         on_paginate: interaction_payload(element, :navigation)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:cluster_dashboard, "cluster_dashboard"] do
    {:ok,
     TerminalUi.Widgets.cluster_dashboard(
       element.id,
       first_present([group_attr(element, :cluster, :nodes), attr(element, :nodes)], []),
       Keyword.merge(
         base_opts(element),
         summary:
           first_present([group_attr(element, :cluster, :summary), attr(element, :summary)], %{}),
         severity:
           first_present([group_attr(element, :cluster, :severity), attr(element, :severity)])
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:command_palette, "command_palette"] do
    {:ok,
     TerminalUi.Widgets.command_palette(
       element.id,
       first_present(
         [group_attr(element, :command_palette, :commands), attr(element, :commands)],
         []
       ),
       Keyword.merge(
         base_opts(element),
         query:
           first_present([group_attr(element, :command_palette, :query), attr(element, :query)]),
         current:
           first_present([
             group_attr(element, :command_palette, :active_command),
             attr(element, :active_command)
           ]),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         on_command: interaction_payload(element, :command),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:process_monitor, "process_monitor"] do
    {:ok,
     TerminalUi.Widgets.process_monitor(
       element.id,
       first_present([group_attr(element, :monitor, :processes), attr(element, :processes)], []),
       Keyword.merge(
         base_opts(element),
         sort_by:
           first_present([group_attr(element, :monitor, :sort_by), attr(element, :sort_by)]),
         binding: binding_name(element),
         on_sort: interaction_payload(element, :command),
         on_filter: interaction_payload(element, :change),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:supervision_tree_viewer, "supervision_tree_viewer"] do
    {:ok,
     TerminalUi.Widgets.tree_view(
       element.id,
       first_present([group_attr(element, :inspection, :nodes), attr(element, :nodes)], []),
       Keyword.merge(
         base_opts(element),
         expanded:
           first_present(
             [group_attr(element, :inspection, :expanded?), attr(element, :expanded?)],
             true
           ),
         on_expand: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:content, "content"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok, TerminalUi.Widgets.container(element.id, children, base_opts(element))}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:column, "column"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.column(
         element.id,
         children,
         Keyword.merge(base_opts(element), gap: layout_attr(element, :gap, :sm))
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:row, "row"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.row(
         element.id,
         children,
         Keyword.merge(base_opts(element), gap: layout_attr(element, :gap, :sm))
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:stack, "stack"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.stack(
         element.id,
         children,
         Keyword.merge(base_opts(element), gap: layout_attr(element, :gap, :sm))
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:grid, "grid"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.column(
         element.id,
         children,
         Keyword.merge(
           base_opts(element),
           gap: layout_attr(element, :gap, :sm),
           degradation: :linearized_grid
         )
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element)
       when kind in [:viewport, "viewport", :scroll_region, "scroll_region"] do
    with {:ok, content} <- map_required_child(element, [:content, :default]) do
      {:ok,
       TerminalUi.Layout.viewport(
         element.id,
         content,
         Keyword.merge(
           base_opts(element),
           axis: viewport_axis(element),
           offset: viewport_offset(element),
           size: viewport_size(element),
           bounded:
             first_present([group_attr(element, :viewport, :clip?), attr(element, :clip?)], true),
           on_scroll: interaction_payload(element, :navigation)
         )
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element)
       when kind in [:split_pane, "split_pane"] do
    with {:ok, primary} <- map_required_child(element, [:primary]),
         {:ok, secondary} <- map_required_child(element, [:secondary]) do
      {:ok,
       TerminalUi.Layout.split_pane(
         element.id,
         primary,
         secondary,
         Keyword.merge(
           base_opts(element),
           axis: split_direction(element),
           ratio:
             first_present([group_attr(element, :split, :ratio), attr(element, :ratio)], 0.5),
           resizable:
             first_present(
               [group_attr(element, :split, :resizable?), attr(element, :resizable?)],
               true
             ),
           on_resize: interaction_payload(element, :change)
         )
       )}
    end
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:scroll_bar, "scroll_bar"] do
    {:ok,
     TerminalUi.Widgets.progress(
       element.id,
       Keyword.merge(
         base_opts(element),
         current: scroll_position(element),
         total:
           first_present(
             [group_attr(element, :scroll_bar, :content_size), attr(element, :content_size)],
             100
           ),
         label: "Scroll",
         degradation: :scroll_indicator
       )
     )}
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:box, "box"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.container(
         element.id,
         children,
         Keyword.merge(base_opts(element), border: :single, padding: attr(element, :padding))
       )}
    end
  end

  defp do_map(%Element{type: :layer, kind: kind} = element) when kind in [:overlay, "overlay"] do
    with {:ok, base} <- map_required_child(element, [:base]),
         {:ok, overlays} <-
           map_children(children_for_slots(element, [:overlay, :dialog, :alert, :content])) do
      {:ok,
       TerminalUi.Layer.overlay(
         element.id,
         base,
         overlays,
         Keyword.merge(
           base_opts(element),
           on_close: interaction_payload(element, :close),
           on_focus: interaction_payload(element, :focus)
         )
       )}
    end
  end

  defp do_map(%Element{type: :layer, kind: kind} = element) when kind in [:dialog, "dialog"] do
    with {:ok, content} <- map_required_child(element, [:content, :default]) do
      {:ok,
       TerminalUi.Widgets.dialog(
         element.id,
         [content],
         Keyword.merge(
           base_opts(element),
           label:
             first_present([
               group_attr(element, :dialog, :title),
               label_text(element, nil),
               to_string(element.id)
             ]),
           open: true,
           on_close: interaction_payload(element, :close),
           on_dismiss: interaction_payload(element, :close)
         )
       )}
    end
  end

  defp do_map(%Element{type: :layer, kind: kind} = element) when kind in [:toast, "toast"] do
    with {:ok, content} <- map_required_child(element, [:content, :default]) do
      {:ok,
       TerminalUi.Widgets.toast(
         element.id,
         widget_text(content, "Toast"),
         Keyword.merge(
           base_opts(element),
           severity:
             first_present(
               [group_attr(element, :toast, :severity), attr(element, :severity)],
               :info
             ),
           timeout_ms:
             first_present(
               [group_attr(element, :toast, :duration_ms), attr(element, :duration_ms)],
               5_000
             ),
           on_close: interaction_payload(element, :close)
         )
       )}
    end
  end

  defp do_map(%Element{type: :layer, kind: kind} = element)
       when kind in [:alert_dialog, "alert_dialog"] do
    with {:ok, content} <- map_required_child(element, [:content, :default]) do
      {:ok,
       TerminalUi.Widgets.alert_dialog(
         element.id,
         widget_text(content, "Alert"),
         [content],
         Keyword.merge(
           base_opts(element),
           severity:
             first_present(
               [group_attr(element, :alert_dialog, :severity), attr(element, :severity)],
               :warning
             ),
           on_close: interaction_payload(element, :close),
           on_dismiss: interaction_payload(element, :close)
         )
       )}
    end
  end

  defp do_map(%Element{type: :layer, kind: kind} = element)
       when kind in [:context_menu, "context_menu"] do
    {:ok,
     TerminalUi.Layer.context_menu(
       element.id,
       TerminalUi.Widgets.text(
         "#{element.id}-anchor",
         context_anchor_label(element)
       ),
       context_menu_items(element),
       Keyword.merge(
         base_opts(element),
         on_select: interaction_payload(element, :selection),
         on_close: interaction_payload(element, :close)
       )
     )}
  end

  defp do_map(%Element{type: :layer, kind: kind} = element)
       when kind in [:absolute, "absolute"] do
    with {:ok, content} <- map_required_child(element, [:content, :default]) do
      {:ok,
       TerminalUi.Layer.absolute(
         element.id,
         content,
         Keyword.merge(
           base_opts(element),
           x: first_present([group_attr(element, :absolute, :x), attr(element, :x)], 0),
           y: first_present([group_attr(element, :absolute, :y), attr(element, :y)], 0),
           z:
             first_present(
               [
                 group_attr(element, :absolute, :z),
                 group_attr(element, :absolute, :z_index),
                 attr(element, :z)
               ],
               0
             )
         )
       )}
    end
  end

  defp do_map(%Element{} = element) do
    {:error,
     Error.new(:unsupported_canonical_construct, %{
       kind: element.kind,
       type: element.type,
       id: element.id
     })}
  end

  defp map_children(children) do
    children
    |> Enum.reduce_while({:ok, []}, fn child, {:ok, acc} ->
      case map(child) do
        {:ok, widget} -> {:cont, {:ok, acc ++ [widget]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp map_required_child(%Element{} = element, slots) do
    case first_child_in_slots(element, slots) do
      nil ->
        {:error,
         Error.new(:unsupported_canonical_construct, %{
           kind: element.kind,
           type: element.type,
           id: element.id,
           missing_slots: List.wrap(slots)
         })}

      child ->
        map(child)
    end
  end

  defp default_children(%Element{} = element) do
    element.children
    |> Enum.filter(&Child.present?/1)
    |> Enum.map(& &1.element)
  end

  defp children_for_slots(%Element{} = element, slots) do
    slots
    |> List.wrap()
    |> Enum.flat_map(fn slot ->
      element.children
      |> Enum.filter(&(Child.present?(&1) and &1.slot == slot))
      |> Enum.map(& &1.element)
    end)
  end

  defp first_child_in_slots(%Element{} = element, slots) do
    element
    |> children_for_slots(slots)
    |> List.first()
  end

  defp validate_attachments(%Element{} = element) do
    with :ok <- validate_bindings(element),
         :ok <- validate_interactions(element) do
      :ok
    end
  end

  defp validate_bindings(%Element{} = element) do
    case Map.get(element.attributes, :bindings) do
      nil ->
        :ok

      bindings when is_list(bindings) ->
        if Enum.all?(bindings, &match?(%Binding{}, &1)) do
          :ok
        else
          {:error, Error.new(:invalid_canonical_bindings, %{id: element.id, kind: element.kind})}
        end

      _other ->
        {:error, Error.new(:invalid_canonical_bindings, %{id: element.id, kind: element.kind})}
    end
  end

  defp validate_interactions(%Element{} = element) do
    case Map.get(element.attributes, :interactions) do
      nil ->
        :ok

      interactions when is_list(interactions) ->
        if Enum.all?(interactions, &match?(%Interaction{}, &1)) do
          :ok
        else
          {:error,
           Error.new(:invalid_canonical_interactions, %{id: element.id, kind: element.kind})}
        end

      _other ->
        {:error,
         Error.new(:invalid_canonical_interactions, %{id: element.id, kind: element.kind})}
    end
  end

  defp base_opts(element) do
    []
    |> maybe_put(:label, label_text(element, nil))
    |> maybe_put(:description, description(element))
    |> maybe_put(:disabled, state_attr(element, :disabled?))
  end

  defp binding_name(element) do
    case first_binding(element) do
      %Binding{name: name} when not is_nil(name) -> name
      %Binding{path: path} when is_list(path) and path != [] -> List.last(path)
      _other -> nil
    end
  end

  defp binding_value(element) do
    case first_binding(element) do
      %Binding{value: nil, default: default} -> default
      %Binding{value: value} -> value
      _other -> nil
    end
  end

  defp first_binding(element) do
    element.attributes
    |> Map.get(:bindings, [])
    |> List.wrap()
    |> List.first()
  end

  defp interaction_payload(element, family) do
    element.attributes
    |> Map.get(:interactions, [])
    |> List.wrap()
    |> Enum.find(&(&1.family == family))
    |> case do
      nil ->
        nil

      %Interaction{} = interaction ->
        %{}
        |> maybe_put(:intent, interaction.intent)
        |> maybe_put(:binding, Map.get(interaction.target, :binding))
        |> maybe_put(:command, Map.get(interaction.payload, :command))
        |> maybe_put(:value, Map.get(interaction.payload, :value))
        |> maybe_put(:selection, Map.get(interaction.payload, :selection))
    end
  end

  defp content_text(element, default) do
    first_present(
      [group_attr(element, :content, :text), attr(element, :text), attr(element, :content)],
      default
    )
  end

  defp label_text(element, default) do
    first_present(
      [group_attr(element, :label, :text), attr(element, :label_text), attr(element, :label)],
      default
    )
  end

  defp description(%Element{} = element) do
    Map.get(element.metadata || %{}, :description)
  end

  defp state_attr(element, key) do
    group_attr(element, :state, key)
  end

  defp layout_attr(element, key, default) do
    first_present([group_attr(element, :layout, key), attr(element, key)], default)
  end

  defp sorting_attr(element, key) do
    case group_attr(element, :table, :sorting) do
      values when is_map(values) -> Map.get(values, key, Map.get(values, Atom.to_string(key)))
      _other -> nil
    end
  end

  defp chart_series(element) do
    first_present([group_attr(element, :chart, :series), attr(element, :series)], [])
  end

  defp viewport_axis(element) do
    first_present([group_attr(element, :viewport, :axis), attr(element, :axis)], :vertical)
  end

  defp viewport_offset(element) do
    case first_present([group_attr(element, :viewport, :offset), attr(element, :offset)], 0) do
      %{y: y} when is_integer(y) -> y
      %{"y" => y} when is_integer(y) -> y
      {_x, y} when is_integer(y) -> y
      offset when is_integer(offset) -> offset
      _other -> 0
    end
  end

  defp viewport_size(element) do
    first_present([
      group_attr(element, :viewport, :height),
      attr(element, :height),
      group_attr(element, :viewport, :width),
      attr(element, :width)
    ])
  end

  defp split_direction(element) do
    first_present(
      [group_attr(element, :split, :direction), attr(element, :direction)],
      :horizontal
    )
  end

  defp scroll_position(element) do
    case first_present([group_attr(element, :scroll_bar, :position), attr(element, :position)], 0) do
      %{start: start_pos} -> start_pos
      %{"start" => start_pos} -> start_pos
      {start_pos, _end_pos} -> start_pos
      value -> value
    end
  end

  defp context_menu_items(element) do
    element
    |> first_child_in_slots([:menu, :content, :default])
    |> case do
      nil -> []
      child -> first_present([group_attr(child, :navigation, :items), attr(child, :items)], [])
    end
  end

  defp context_anchor_label(element) do
    case group_attr(element, :context_menu, :anchor) do
      %{} = anchor ->
        Map.get(anchor, :target_id, Map.get(anchor, "target_id", "Context"))
        |> to_string()

      _other ->
        "Context"
    end
  end

  defp widget_text(widget, default) do
    first_present(
      [
        Map.get(widget.attributes, :text),
        Map.get(widget.attributes, :content),
        Map.get(widget.attributes, :message),
        Map.get(widget.attributes, :label),
        Map.get(widget.metadata, :label)
      ],
      default
    )
  end

  defp group_attr(%Element{} = element, group, key) do
    case Map.get(element.attributes, group) do
      nil -> nil
      values when is_map(values) -> Map.get(values, key, Map.get(values, Atom.to_string(key)))
      _other -> nil
    end
  end

  defp attr(%Element{} = element, key) do
    Map.get(element.attributes, key, Map.get(element.attributes, Atom.to_string(key)))
  end

  defp first_present(values, default \\ nil) do
    Enum.find(values, default, &(not is_nil(&1)))
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value) when is_list(opts), do: Keyword.put(opts, key, value)
  defp maybe_put(opts, key, value) when is_map(opts), do: Map.put(opts, key, value)
end
