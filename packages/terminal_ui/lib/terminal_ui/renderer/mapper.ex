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

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:badge, "badge"] do
    {:ok,
     TerminalUi.Widgets.label(
       element.id,
       content_text(element, "Badge"),
       Keyword.merge(base_opts(element),
         role: :badge,
         degradation: :text_label,
         variant: group_attr(element, :badge, :presentation)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:hero, "hero"] do
    with {:ok, children} <- map_children(default_children(element)) do
      hero_children =
        [
          maybe_terminal_text(element, :eyebrow, group_attr(element, :hero, :eyebrow), :kicker),
          maybe_terminal_text(element, :title, group_attr(element, :hero, :title), :label),
          maybe_terminal_text(element, :message, group_attr(element, :hero, :message), :text)
        ]
        |> Enum.reject(&is_nil/1)

      {:ok,
       TerminalUi.Widgets.container(
         element.id,
         hero_children ++ children,
         Keyword.merge(base_opts(element), degradation: :linearized_hero)
       )}
    end
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
       when kind in [:text_input, "text_input"] do
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

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:numeric_input, "numeric_input"] do
    {:ok,
     TerminalUi.Widgets.numeric_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         placeholder:
           first_present(
             [group_attr(element, :input, :placeholder), attr(element, :placeholder)],
             ""
           ),
         min: first_present([group_attr(element, :input, :min), attr(element, :min)]),
         max: first_present([group_attr(element, :input, :max), attr(element, :max)]),
         step: first_present([group_attr(element, :input, :step), attr(element, :step)], 1),
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

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:pick_list, "pick_list"] do
    {:ok,
     TerminalUi.Widgets.pick_list(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         multiple:
           first_present(
             [group_attr(element, :selection, :multiple?), attr(element, :multiple?)],
             true
           ),
         on_change: interaction_payload(element, :change),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:slider, "slider"] do
    {:ok,
     TerminalUi.Widgets.slider(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)], 0),
         binding: binding_name(element),
         min: first_present([group_attr(element, :input, :min), attr(element, :min)], 0),
         max: first_present([group_attr(element, :input, :max), attr(element, :max)], 100),
         step: first_present([group_attr(element, :input, :step), attr(element, :step)], 1),
         on_change: interaction_payload(element, :change),
         on_focus: interaction_payload(element, :focus)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:date_input, "date_input"] do
    {:ok,
     TerminalUi.Widgets.date_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         min: first_present([group_attr(element, :input, :min), attr(element, :min)]),
         max: first_present([group_attr(element, :input, :max), attr(element, :max)]),
         format:
           first_present([group_attr(element, :input, :format), attr(element, :format)], :iso8601),
         on_change: interaction_payload(element, :change),
         on_submit: interaction_payload(element, :submit)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:time_input, "time_input"] do
    {:ok,
     TerminalUi.Widgets.time_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         min: first_present([group_attr(element, :input, :min), attr(element, :min)]),
         max: first_present([group_attr(element, :input, :max), attr(element, :max)]),
         step: first_present([group_attr(element, :input, :step), attr(element, :step)]),
         format:
           first_present([group_attr(element, :input, :format), attr(element, :format)], :iso8601),
         on_change: interaction_payload(element, :change),
         on_submit: interaction_payload(element, :submit)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:file_input, "file_input"] do
    {:ok,
     TerminalUi.Widgets.file_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         binding: binding_name(element),
         accept: first_present([group_attr(element, :file, :accept), attr(element, :accept)], []),
         multiple:
           first_present(
             [group_attr(element, :file, :multiple?), attr(element, :multiple?)],
             false
           ),
         capture: first_present([group_attr(element, :file, :capture), attr(element, :capture)]),
         on_change: interaction_payload(element, :change),
         on_focus: interaction_payload(element, :focus)
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

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:stat, "stat"] do
    title = group_attr(element, :stat, :title)
    value = group_attr(element, :stat, :value)
    message = group_attr(element, :stat, :message)

    {:ok,
     TerminalUi.Widgets.label(
       element.id,
       [title, value, message]
       |> Enum.reject(&is_nil/1)
       |> Enum.map(&to_string/1)
       |> Enum.join(": "),
       Keyword.merge(base_opts(element), role: :stat, degradation: :text_stat)
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:key_value, "key_value"] do
    label = group_attr(element, :key_value, :label)
    value = group_attr(element, :key_value, :value)

    {:ok,
     TerminalUi.Widgets.label(
       element.id,
       "#{label}: #{value}",
       Keyword.merge(base_opts(element), role: :key_value, degradation: :text_pair)
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:info_list, "info_list"] do
    items =
      element
      |> group_attr(:info_list, :items)
      |> List.wrap()
      |> Enum.map(fn
        %{label: label, value: value} = item ->
          item |> Map.put_new(:id, label) |> Map.put(:label, "#{label}: #{value}")

        %{"label" => label, "value" => value} = item ->
          item |> Map.put_new("id", label) |> Map.put("label", "#{label}: #{value}")

        item ->
          item
      end)

    {:ok,
     TerminalUi.Widgets.list(
       element.id,
       items,
       Keyword.merge(base_opts(element),
         empty_state: group_attr(element, :info_list, :empty_state),
         ordered: group_attr(element, :info_list, :ordered?)
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
       when kind in [:disclosure, "disclosure"] do
    {:ok,
     TerminalUi.Widgets.disclosure(
       element.id,
       first_present([group_attr(element, :disclosure, :label), content_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         open:
           first_present([group_attr(element, :disclosure, :open?), attr(element, :open)], false),
         content_label: group_attr(element, :disclosure, :content_label),
         summary: group_attr(element, :disclosure, :summary),
         on_toggle: interaction_payload(element, :open) || interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:kicker, "kicker"] do
    {:ok,
     TerminalUi.Widgets.kicker(
       element.id,
       first_present([group_attr(element, :kicker, :value), content_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         icon: group_attr(element, :kicker, :icon),
         role: group_attr(element, :kicker, :role),
         summary: group_attr(element, :kicker, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:avatar, "avatar"] do
    {:ok,
     TerminalUi.Widgets.avatar(
       element.id,
       first_present([group_attr(element, :avatar, :label), label_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         initials: group_attr(element, :avatar, :initials),
         source: first_present([group_attr(element, :avatar, :source), attr(element, :source)]),
         status: group_attr(element, :avatar, :status),
         summary: group_attr(element, :avatar, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:presence_dot, "presence_dot"] do
    {:ok,
     TerminalUi.Widgets.presence_dot(
       element.id,
       first_present([group_attr(element, :presence, :status), attr(element, :status)], :unknown),
       Keyword.merge(base_opts(element),
         label: first_present([group_attr(element, :presence, :label), label_text(element, nil)]),
         pulse: group_attr(element, :presence, :pulse?),
         summary: group_attr(element, :presence, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:segmented_button_group, "segmented_button_group"] do
    {:ok,
     TerminalUi.Widgets.segmented_button_group(
       element.id,
       first_present([group_attr(element, :segments, :items), attr(element, :items)], []),
       Keyword.merge(base_opts(element),
         active_item:
           first_present([group_attr(element, :segments, :active_item), binding_value(element)]),
         selection_mode: group_attr(element, :segments, :selection_mode),
         orientation: group_attr(element, :segments, :orientation),
         summary: group_attr(element, :segments, :summary),
         on_select: interaction_payload(element, :selection),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:list_item_multi_column, "list_item_multi_column"] do
    {:ok,
     TerminalUi.Widgets.list_item_multi_column(
       element.id,
       first_present([group_attr(element, :list_item, :columns), attr(element, :columns)], []),
       Keyword.merge(base_opts(element),
         label:
           first_present([group_attr(element, :list_item, :label), label_text(element, nil)]),
         value: group_attr(element, :list_item, :value),
         status: group_attr(element, :list_item, :status),
         summary: group_attr(element, :list_item, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:artifact_row, "artifact_row"] do
    {:ok,
     TerminalUi.Widgets.artifact_row(
       element.id,
       group_attr(element, :artifact, :value),
       first_present([group_attr(element, :artifact, :title), content_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         status: group_attr(element, :artifact, :status),
         timestamp: group_attr(element, :artifact, :timestamp),
         summary: group_attr(element, :artifact, :summary),
         on_click: interaction_payload(element, :click),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:sticky_header, "sticky_header"] do
    {:ok,
     TerminalUi.Widgets.sticky_header(
       element.id,
       first_present(
         [group_attr(element, :sticky_header, :title), content_text(element, nil)],
         ""
       ),
       Keyword.merge(base_opts(element),
         stuck:
           first_present(
             [group_attr(element, :sticky_header, :stuck?), attr(element, :stuck)],
             false
           ),
         elevation: group_attr(element, :sticky_header, :elevation),
         summary: group_attr(element, :sticky_header, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:pipeline_stepper_horizontal, "pipeline_stepper_horizontal"] do
    {:ok,
     TerminalUi.Widgets.pipeline_stepper_horizontal(
       element.id,
       first_present([group_attr(element, :workflow, :steps), attr(element, :steps)], []),
       Keyword.merge(base_opts(element),
         active_item: group_attr(element, :workflow, :active_item),
         status: group_attr(element, :workflow, :status),
         summary: group_attr(element, :workflow, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:segmented_progress_bar, "segmented_progress_bar"] do
    {:ok,
     TerminalUi.Widgets.segmented_progress_bar(
       element.id,
       first_present([group_attr(element, :progress, :segments), attr(element, :segments)], []),
       Keyword.merge(base_opts(element),
         current: group_attr(element, :progress, :current),
         maximum: group_attr(element, :progress, :maximum),
         label: group_attr(element, :progress, :label),
         summary: group_attr(element, :progress, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:workflow_stage_list_vertical, "workflow_stage_list_vertical"] do
    {:ok,
     TerminalUi.Widgets.workflow_stage_list_vertical(
       element.id,
       first_present([group_attr(element, :workflow, :stages), attr(element, :stages)], []),
       Keyword.merge(base_opts(element),
         active_item: group_attr(element, :workflow, :active_item),
         status: group_attr(element, :workflow, :status),
         summary: group_attr(element, :workflow, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:meter_thin, "meter_thin"] do
    {:ok,
     TerminalUi.Widgets.meter_thin(
       element.id,
       first_present([group_attr(element, :meter, :current), attr(element, :current)], 0),
       Keyword.merge(base_opts(element),
         minimum: group_attr(element, :meter, :minimum),
         maximum: group_attr(element, :meter, :maximum),
         label: group_attr(element, :meter, :label),
         severity: group_attr(element, :meter, :severity),
         summary: group_attr(element, :meter, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:slide_over_panel, "slide_over_panel"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.slide_over_panel(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           title: group_attr(element, :panel, :title),
           visible: group_attr(element, :panel, :visible?),
           placement: group_attr(element, :panel, :placement),
           modal: group_attr(element, :panel, :modal?),
           summary: group_attr(element, :panel, :summary),
           on_open: interaction_payload(element, :open),
           on_close: interaction_payload(element, :close)
         )
       )}
    end
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:event_callout, "event_callout"] do
    {:ok,
     TerminalUi.Widgets.event_callout(
       element.id,
       first_present([group_attr(element, :callout, :message), content_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         title: group_attr(element, :callout, :title),
         severity: group_attr(element, :callout, :severity),
         timestamp: group_attr(element, :callout, :timestamp),
         summary: group_attr(element, :callout, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:redline_inline, "redline_inline"] do
    {:ok,
     TerminalUi.Widgets.redline_inline(
       element.id,
       first_present(
         [group_attr(element, :redline, :before_text), attr(element, :before_text)],
         ""
       ),
       first_present(
         [group_attr(element, :redline, :after_text), attr(element, :after_text)],
         ""
       ),
       Keyword.merge(base_opts(element),
         label: group_attr(element, :redline, :label),
         summary: group_attr(element, :redline, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:code_block_syntax_highlighted, "code_block_syntax_highlighted"] do
    {:ok,
     TerminalUi.Widgets.code_block_syntax_highlighted(
       element.id,
       first_present([group_attr(element, :code_block, :code), attr(element, :code)], ""),
       Keyword.merge(base_opts(element),
         language: group_attr(element, :code_block, :language),
         label: group_attr(element, :code_block, :label),
         wrap: group_attr(element, :code_block, :wrap?),
         summary: group_attr(element, :code_block, :summary)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:chat_composer, "chat_composer"] do
    {:ok,
     TerminalUi.Widgets.chat_composer(
       element.id,
       Keyword.merge(base_opts(element),
         placeholder: group_attr(element, :composer, :placeholder),
         submit_intent: group_attr(element, :composer, :submit_intent),
         actions: group_attr(element, :composer, :actions),
         multiline: group_attr(element, :composer, :multiline?),
         summary: group_attr(element, :composer, :summary),
         on_submit: interaction_payload(element, :submit),
         on_change: interaction_payload(element, :change)
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

  defp do_map(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:host_form_shell, "host_form_shell"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.host_form_shell(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           owner: group_attr(element, :form_shell, :owner),
           lifecycle: group_attr(element, :form_shell, :lifecycle),
           action_placement: group_attr(element, :form_shell, :action_placement),
           mode: group_attr(element, :form, :mode),
           submit_intent: group_attr(element, :form, :submit_intent),
           autocomplete: group_attr(element, :form, :autocomplete?),
           validation_summary: group_attr(element, :validation, :summary),
           validation_errors: group_attr(element, :validation, :errors),
           on_submit: interaction_payload(element, :submit),
           on_change: interaction_payload(element, :change)
         )
       )}
    end
  end

  defp do_map(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and
              kind in [:repeated_collection, "repeated_collection"] do
    with {:ok, rows} <- collection_rows(element),
         {:ok, empty_state} <- collection_empty_state(element, rows) do
      {:ok,
       TerminalUi.Widgets.repeated_collection(
         element.id,
         Enum.map(rows, & &1.widget),
         Keyword.merge(base_opts(element),
           item_alias: group_attr(element, :collection, :item_alias),
           index_alias: group_attr(element, :collection, :index_alias),
           key_path: group_attr(element, :collection, :key_path),
           row_metadata: Enum.map(rows, &Map.drop(&1, [:widget])),
           empty_state: empty_state
         )
       )}
    end
  end

  defp do_map(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:form_builder, "form_builder"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.form_builder(
         element.id,
         children,
         Keyword.merge(
           base_opts(element),
           mode:
             first_present([group_attr(element, :form, :mode), attr(element, :mode)], :grouped),
           autocomplete:
             first_present(
               [group_attr(element, :form, :autocomplete?), attr(element, :autocomplete?)],
               true
             ),
           on_submit: interaction_payload(element, :submit)
         )
       )}
    end
  end

  defp do_map(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:field_group, "field_group"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.field_group(
         element.id,
         children,
         Keyword.merge(
           base_opts(element),
           legend: first_present([group_attr(element, :group, :legend), attr(element, :legend)]),
           group_description:
             first_present([
               group_attr(element, :group, :description),
               attr(element, :group_description)
             ]),
           collapsible:
             first_present(
               [group_attr(element, :group, :collapsible?), attr(element, :collapsible?)],
               false
             )
         )
       )}
    end
  end

  defp do_map(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and
              kind in [:field, "field", :form_field, "form_field"] do
    with {:ok, control} <- map_required_child(element, [:control]),
         {:ok, label} <- map_optional_child(element, [:label]),
         {:ok, help} <- map_optional_child(element, [:help]) do
      {:ok,
       TerminalUi.Widgets.field(
         element.id,
         control,
         Keyword.merge(
           base_opts(element),
           name: first_present([group_attr(element, :field, :name), attr(element, :name)]),
           control_id:
             first_present([group_attr(element, :field, :control_id), attr(element, :control_id)]),
           label: label,
           help: help
         )
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

  defp collection_rows(%Element{} = element) do
    template = element |> children_for_slots([:template]) |> List.first()
    source = group_attr(element, :collection, :source)
    item_alias = group_attr(element, :collection, :item_alias) || :item
    index_alias = group_attr(element, :collection, :index_alias) || :index
    key_path = group_attr(element, :collection, :key_path) || []

    case {template, collection_source_items(source)} do
      {%Element{} = template, items} when is_list(items) ->
        row_entries =
          items
          |> Enum.with_index()
          |> Enum.map(fn {item, index} ->
            %{item: item, index: index, key_info: collection_row_key_info(item, key_path, index)}
          end)

        key_counts = Enum.frequencies_by(row_entries, & &1.key_info.key)

        Enum.reduce_while(row_entries, {:ok, []}, fn %{
                                                       item: item,
                                                       index: index,
                                                       key_info: key_info
                                                     },
                                                     {:ok, acc} ->
          resolved_element =
            resolve_row_scope(template, %{
              item: item,
              index: index,
              item_alias: item_alias,
              index_alias: index_alias,
              key: collection_row_render_key(key_info.key, index, key_counts)
            })

          case map(resolved_element) do
            {:ok, widget} ->
              row = %{
                key: key_info.key,
                key_source: key_info.source,
                index: index,
                item: item,
                diagnostics:
                  collection_row_diagnostics(key_info, key_counts) ++
                    unresolved_row_scope_diagnostics(resolved_element),
                widget: widget
              }

              {:cont, {:ok, [row | acc]}}

            {:error, error} ->
              {:halt, {:error, error}}
          end
        end)
        |> case do
          {:ok, rows} -> {:ok, Enum.reverse(rows)}
          error -> error
        end

      _other ->
        {:ok, []}
    end
  end

  defp collection_source_items(%Binding{value: value}) when is_list(value), do: value
  defp collection_source_items(_source), do: []

  defp collection_empty_state(_element, [_row | _rows]), do: {:ok, []}

  defp collection_empty_state(%Element{} = element, []) do
    element
    |> children_for_slots([:empty_state])
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, []}, fn {child, index}, {:ok, acc} ->
      child = ensure_element_id(child, "#{element.id}-empty-state-#{index}")

      case map(child) do
        {:ok, widget} -> {:cont, {:ok, acc ++ [widget]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp ensure_element_id(%Element{id: nil} = element, id), do: %{element | id: id}
  defp ensure_element_id(element, _id), do: element

  defp collection_row_key_info(item, key_path, index) do
    case value_at_path(item, key_path) do
      nil ->
        %{key: Integer.to_string(index), source: :index_fallback, diagnostics: [:missing_key]}

      value ->
        %{key: to_string(value), source: :key_path, diagnostics: []}
    end
  end

  defp collection_row_diagnostics(key_info, key_counts) do
    diagnostics = key_info.diagnostics

    if Map.fetch!(key_counts, key_info.key) > 1 do
      Enum.uniq(diagnostics ++ [:duplicate_key])
    else
      diagnostics
    end
  end

  defp collection_row_render_key(key, index, key_counts) do
    if Map.fetch!(key_counts, key) > 1 do
      "#{key}-#{index}"
    else
      key
    end
  end

  defp unresolved_row_scope_diagnostics(value) do
    case unresolved_row_scope_bindings(value) do
      [] -> []
      _bindings -> [:unresolved_row_scope]
    end
  end

  defp unresolved_row_scope_bindings(%Binding{source: :row_scope} = binding), do: [binding]
  defp unresolved_row_scope_bindings(%Binding{}), do: []

  defp unresolved_row_scope_bindings(%Interaction{} = interaction) do
    unresolved_row_scope_bindings(interaction.source) ++
      unresolved_row_scope_bindings(interaction.target) ++
      unresolved_row_scope_bindings(interaction.payload) ++
      unresolved_row_scope_bindings(interaction.metadata)
  end

  defp unresolved_row_scope_bindings(%Element{} = element) do
    unresolved_row_scope_bindings(element.attributes) ++
      unresolved_row_scope_bindings(element.children)
  end

  defp unresolved_row_scope_bindings(%Child{} = child) do
    unresolved_row_scope_bindings(child.element)
  end

  defp unresolved_row_scope_bindings(values) when is_list(values) do
    Enum.flat_map(values, &unresolved_row_scope_bindings/1)
  end

  defp unresolved_row_scope_bindings(values) when is_map(values) do
    values
    |> Map.values()
    |> Enum.flat_map(&unresolved_row_scope_bindings/1)
  end

  defp unresolved_row_scope_bindings(_value), do: []

  defp resolve_row_scope(%Element{} = element, context) do
    %{
      element
      | id: row_scoped_id(element.id, context.key),
        attributes: resolve_row_scope(element.attributes, context),
        children: Enum.map(element.children, &resolve_row_scope(&1, context))
    }
  end

  defp resolve_row_scope(%Child{} = child, context) do
    %{child | element: resolve_row_scope(child.element, context)}
  end

  defp resolve_row_scope(
         %Binding{source: :row_scope, scope: [scope | _], path: path} = binding,
         context
       ) do
    cond do
      scope == context.item_alias ->
        value_at_path(context.item, path)

      scope == context.index_alias ->
        context.index

      true ->
        binding
    end
  end

  defp resolve_row_scope(%Binding{} = binding, _context), do: binding
  defp resolve_row_scope(nil, _context), do: nil

  defp resolve_row_scope(%Interaction{} = interaction, context) do
    %{
      interaction
      | source: resolve_row_scope(interaction.source, context),
        target: resolve_row_scope(interaction.target, context),
        payload: resolve_row_scope(interaction.payload, context),
        metadata: resolve_row_scope(interaction.metadata, context)
    }
  end

  defp resolve_row_scope(values, context) when is_list(values) do
    Enum.map(values, &resolve_row_scope(&1, context))
  end

  defp resolve_row_scope(values, context) when is_map(values) do
    Map.new(values, fn {key, value} -> {key, resolve_row_scope(value, context)} end)
  end

  defp resolve_row_scope(value, _context), do: value

  defp row_scoped_id(nil, key), do: "row-template-#{key}"
  defp row_scoped_id(id, key), do: "#{id}-#{key}"

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

  defp map_optional_child(%Element{} = element, slots) do
    case first_child_in_slots(element, slots) do
      nil -> {:ok, nil}
      child -> map(child)
    end
  end

  defp default_children(%Element{} = element) do
    element.children
    |> Enum.filter(&Child.present?/1)
    |> Enum.map(& &1.element)
  end

  defp children_for_slots(%Element{} = element, slots) do
    slot_names =
      slots
      |> List.wrap()
      |> Enum.map(&to_string/1)

    element.children
    |> Enum.filter(&(Child.present?(&1) and to_string(&1.slot) in slot_names))
    |> Enum.map(& &1.element)
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
    |> maybe_put(
      :theme,
      first_present([group_attr(element, :style, :theme), attr(element, :theme)])
    )
    |> maybe_put(
      :variant,
      first_present([group_attr(element, :style, :variant), attr(element, :variant)])
    )
    |> maybe_put(
      :semantic_role,
      first_present([group_attr(element, :style, :semantic_role), attr(element, :semantic_role)])
    )
    |> maybe_put(:fg, first_present([group_attr(element, :style, :fg), attr(element, :fg)]))
    |> maybe_put(:bg, first_present([group_attr(element, :style, :bg), attr(element, :bg)]))
    |> maybe_put(
      :attrs,
      first_present([group_attr(element, :style, :attrs), attr(element, :attrs)])
    )
    |> maybe_put(
      :border,
      first_present([group_attr(element, :style, :border), attr(element, :border)])
    )
    |> maybe_put(
      :padding,
      first_present([group_attr(element, :style, :padding), attr(element, :padding)])
    )
    |> maybe_put(
      :theme_tokens,
      first_present([group_attr(element, :style, :theme_tokens), attr(element, :theme_tokens)])
    )
    |> maybe_put(
      :style_refs,
      first_present([group_attr(element, :style, :style_refs), attr(element, :style_refs)])
    )
    |> maybe_put(
      :degradation,
      first_present([group_attr(element, :style, :degradation), attr(element, :degradation)])
    )
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
        |> maybe_put(:mapping, Map.get(interaction.payload, :mapping))
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

  defp maybe_terminal_text(_element, _suffix, nil, _kind), do: nil
  defp maybe_terminal_text(_element, _suffix, "", _kind), do: nil

  defp maybe_terminal_text(element, suffix, value, :kicker) do
    TerminalUi.Widgets.kicker("#{element.id}-#{suffix}", to_string(value))
  end

  defp maybe_terminal_text(element, suffix, value, :label) do
    TerminalUi.Widgets.label("#{element.id}-#{suffix}", to_string(value), role: :heading)
  end

  defp maybe_terminal_text(element, suffix, value, :text) do
    TerminalUi.Widgets.text("#{element.id}-#{suffix}", to_string(value))
  end

  defp value_at_path(value, nil), do: value
  defp value_at_path(value, []), do: value

  defp value_at_path(value, path) do
    Enum.reduce_while(List.wrap(path), value, fn segment, current ->
      case fetch_path_segment(current, segment) do
        {:ok, next} -> {:cont, next}
        :error -> {:halt, nil}
      end
    end)
  end

  defp fetch_path_segment(%{} = map, segment) do
    atom_segment = existing_atom_key(segment)

    cond do
      Map.has_key?(map, segment) ->
        {:ok, Map.fetch!(map, segment)}

      Map.has_key?(map, to_string(segment)) ->
        {:ok, Map.fetch!(map, to_string(segment))}

      is_atom(atom_segment) and Map.has_key?(map, atom_segment) ->
        {:ok, Map.fetch!(map, atom_segment)}

      true ->
        :error
    end
  end

  defp fetch_path_segment(list, index) when is_list(list) and is_integer(index) do
    case Enum.fetch(list, index) do
      {:ok, value} -> {:ok, value}
      :error -> :error
    end
  end

  defp fetch_path_segment(_current, _segment), do: :error

  defp existing_atom_key(segment) when is_binary(segment) do
    String.to_existing_atom(segment)
  rescue
    ArgumentError -> nil
  end

  defp existing_atom_key(_segment), do: nil

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
