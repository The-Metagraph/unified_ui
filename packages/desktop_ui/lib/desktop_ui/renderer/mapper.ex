defmodule DesktopUi.Renderer.Mapper do
  @moduledoc """
  Canonical-to-native widget mapper for `desktop_ui`.
  """

  alias DesktopUi.Renderer.Error
  alias DesktopUi.Widget
  alias UnifiedIUR.{Binding, Interaction}
  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child

  @spec map(Element.t(), keyword()) :: {:ok, Widget.t()} | {:error, Error.t()}
  def map(element, opts \\ [])

  def map(%Element{id: nil} = element, _opts) do
    {:error, Error.new(:missing_canonical_identity, %{kind: element.kind, type: element.type})}
  end

  # Handle screen elements - extract the default child and render that
  def map(%Element{type: :composite, kind: :screen, children: children}, opts) do
    case Enum.find(children, fn %Child{slot: slot} -> slot == :default end) do
      nil ->
        {:error, Error.new(:empty_screen, %{id: "screen"})}

      %Child{element: %Element{} = child_element} ->
        map(child_element, opts)

      %Child{element: nil} ->
        {:error, Error.new(:screen_empty_content, %{id: "screen"})}
    end
  end

  def map(%Element{type: type, kind: kind} = element, _opts)
      when type in [:composite, "composite"] and
             kind in [:repeated_collection, "repeated_collection"] do
    with :ok <- validate_bindings(element) do
      map_element(element)
    end
  end

  def map(%Element{} = element, _opts) do
    with :ok <- validate_bindings(element),
         {:ok, slot_children} <- map_children(element.children),
         {:ok, widget} <- map_element(element) do
      {:ok, attach_slot_children(widget, slot_children)}
    end
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:scroll_bar, "scroll_bar"] do
    {:ok,
     DesktopUi.Layout.scroll_bar(
       element.id,
       Keyword.merge(
         base_opts(element),
         orientation: first_present([attr(element, :orientation)], :vertical),
         value: first_present([attr(element, :value), binding_value(element)], 0),
         min: attr(element, :min),
         max: attr(element, :max),
         page_size: attr(element, :page_size),
         thickness: attr(element, :thickness),
         on_scroll: interaction_payload(element, :change),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:text, "text"] do
    {:ok,
     DesktopUi.Widgets.text(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:label, "label"] do
    {:ok,
     DesktopUi.Widgets.label(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:icon, "icon"] do
    {:ok,
     DesktopUi.Widgets.icon(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:image, "image"] do
    {:ok,
     DesktopUi.Widgets.image(
       element.id,
       first_present(
         [group_attr(element, :image, :source), attr(element, :source), attr(element, :src)],
         ""
       ),
       Keyword.merge(
         base_opts(element),
         alt: first_present([group_attr(element, :image, :alt_text), attr(element, :alt)], "")
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:separator, "separator"] do
    {:ok,
     DesktopUi.Widgets.separator(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:spacer, "spacer"] do
    {:ok,
     DesktopUi.Widgets.spacer(
       element.id,
       Keyword.merge(base_opts(element),
         size: first_present([group_attr(element, :spacer, :size), attr(element, :size)], :md)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:badge, "badge"] do
    {:ok,
     DesktopUi.Widgets.badge(
       element.id,
       content_text(element, to_string(element.id)),
       Keyword.merge(
         base_opts(element),
         size: first_present([group_attr(element, :badge, :size), attr(element, :size)], :md),
         variant:
           first_present(
             [group_attr(element, :badge, :variant), attr(element, :variant)],
             :default
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:hero, "hero"] do
    {:ok,
     DesktopUi.Widgets.hero(
       element.id,
       first_present(
         [group_attr(element, :hero, :headline), attr(element, :headline), label_text(element)],
         "Hero"
       ),
       Keyword.merge(
         base_opts(element),
         subheadline:
           first_present([group_attr(element, :hero, :subheadline), attr(element, :subheadline)]),
         image: first_present([group_attr(element, :hero, :image), attr(element, :image)]),
         actions:
           first_present([group_attr(element, :hero, :actions), attr(element, :actions)], [])
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:button, "button"] do
    {:ok,
     DesktopUi.Widgets.button(
       element.id,
       content_text(element, "Button"),
       Keyword.merge(base_opts(element),
         on_click: interaction_payload(element, :click),
         intent: interaction_intent(element, :click)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:toggle, "toggle"] do
    {:ok,
     DesktopUi.Widgets.toggle(
       element.id,
       label_text(element, "Toggle"),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         intent: interaction_intent(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:link, "link"] do
    {:ok,
     DesktopUi.Widgets.link(
       element.id,
       label_text(element, "Link"),
       first_present(
         [group_attr(element, :link, :target), attr(element, :href), attr(element, :target)],
         "#"
       ),
       Keyword.merge(base_opts(element),
         on_follow: interaction_payload(element, :click),
         intent: interaction_intent(element, :click)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:command, "command"] do
    {:ok,
     DesktopUi.Widgets.command(
       element.id,
       label_text(element, "Command"),
       Keyword.merge(
         base_opts(element),
         shortcut:
           first_present([attr(element, :shortcut), group_attr(element, :command, :shortcut)]),
         on_press: interaction_payload(element, :command),
         intent: interaction_intent(element, :command)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:text_input, "text_input"] do
    {:ok,
     DesktopUi.Widgets.text_input(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:numeric_input, "numeric_input"] do
    {:ok,
     DesktopUi.Widgets.numeric_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)], 0),
         binding: binding_name(element),
         min: attr(element, :min),
         max: attr(element, :max),
         step: first_present([attr(element, :step), group_attr(element, :input, :step)], 1),
         placeholder:
           first_present(
             [attr(element, :placeholder), group_attr(element, :input, :placeholder)],
             ""
           ),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:slider, "slider"] do
    {:ok,
     DesktopUi.Widgets.slider(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)], 0),
         binding: binding_name(element),
         min: attr(element, :min),
         max: attr(element, :max),
         step: first_present([attr(element, :step), group_attr(element, :input, :step)], 1),
         show_value:
           first_present(
             [attr(element, :show_value), group_attr(element, :input, :show_value)],
             true
           ),
         orientation:
           first_present(
             [attr(element, :orientation), group_attr(element, :input, :orientation)],
             :horizontal
           ),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:date_input, "date_input"] do
    {:ok,
     DesktopUi.Widgets.date_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         min: attr(element, :min),
         max: attr(element, :max),
         placeholder:
           first_present(
             [attr(element, :placeholder), group_attr(element, :input, :placeholder)],
             "YYYY-MM-DD"
           ),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:time_input, "time_input"] do
    {:ok,
     DesktopUi.Widgets.time_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         format:
           first_present([attr(element, :format), group_attr(element, :input, :format)], :"24h"),
         placeholder:
           first_present(
             [attr(element, :placeholder), group_attr(element, :input, :placeholder)],
             "HH:MM"
           ),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:file_input, "file_input"] do
    {:ok,
     DesktopUi.Widgets.file_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         accept: first_present([attr(element, :accept), group_attr(element, :input, :accept)]),
         multiple:
           first_present(
             [attr(element, :multiple), group_attr(element, :input, :multiple)],
             false
           ),
         placeholder:
           first_present(
             [attr(element, :placeholder), group_attr(element, :input, :placeholder)],
             "Choose file..."
           ),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:pick_list, "pick_list"] do
    {:ok,
     DesktopUi.Widgets.pick_list(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         searchable:
           first_present(
             [attr(element, :searchable), group_attr(element, :selection, :searchable)],
             true
           ),
         multiple:
           first_present(
             [attr(element, :multiple), group_attr(element, :selection, :multiple)],
             false
           ),
         placeholder:
           first_present(
             [attr(element, :placeholder), group_attr(element, :selection, :placeholder)],
             "Select..."
           ),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:checkbox, "checkbox"] do
    {:ok,
     DesktopUi.Widgets.checkbox(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:radio_group, "radio_group"] do
    {:ok,
     DesktopUi.Widgets.radio_group(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:select, "select"] do
    {:ok,
     DesktopUi.Widgets.select(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:tabs, "tabs"] do
    {:ok, map_navigation(:tabs, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:menu, "menu"] do
    {:ok, map_navigation(:menu, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:breadcrumbs, "breadcrumbs"] do
    {:ok, map_navigation(:breadcrumbs, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:list, "list"] do
    {:ok, map_navigation(:list, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:content, "content"] do
    {:ok, DesktopUi.Widgets.content(element.id, [], base_opts(element))}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:disclosure, "disclosure"] do
    {:ok,
     DesktopUi.Widgets.disclosure(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:kicker, "kicker"] do
    {:ok,
     DesktopUi.Widgets.kicker(
       element.id,
       first_present([group_attr(element, :kicker, :value), content_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         icon: group_attr(element, :kicker, :icon),
         role: group_attr(element, :kicker, :role),
         summary: group_attr(element, :kicker, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:avatar, "avatar"] do
    {:ok,
     DesktopUi.Widgets.avatar(
       element.id,
       first_present([group_attr(element, :avatar, :label), label_text(element)], ""),
       Keyword.merge(base_opts(element),
         initials: group_attr(element, :avatar, :initials),
         source: first_present([group_attr(element, :avatar, :source), attr(element, :source)]),
         status: group_attr(element, :avatar, :status),
         summary: group_attr(element, :avatar, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:presence_dot, "presence_dot"] do
    {:ok,
     DesktopUi.Widgets.presence_dot(
       element.id,
       first_present([group_attr(element, :presence, :status), attr(element, :status)], :unknown),
       Keyword.merge(base_opts(element),
         label: first_present([group_attr(element, :presence, :label), label_text(element)]),
         pulse: group_attr(element, :presence, :pulse?),
         summary: group_attr(element, :presence, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:segmented_button_group, "segmented_button_group"] do
    {:ok,
     DesktopUi.Widgets.segmented_button_group(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:list_item_multi_column, "list_item_multi_column"] do
    {:ok,
     DesktopUi.Widgets.list_item_multi_column(
       element.id,
       first_present([group_attr(element, :list_item, :columns), attr(element, :columns)], []),
       Keyword.merge(base_opts(element),
         label: first_present([group_attr(element, :list_item, :label), label_text(element)]),
         value: group_attr(element, :list_item, :value),
         status: group_attr(element, :list_item, :status),
         summary: group_attr(element, :list_item, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:artifact_row, "artifact_row"] do
    {:ok,
     DesktopUi.Widgets.artifact_row(
       element.id,
       first_present([group_attr(element, :artifact, :value), attr(element, :value)], %{}),
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:sticky_header, "sticky_header"] do
    {:ok,
     DesktopUi.Widgets.sticky_header(
       element.id,
       first_present(
         [group_attr(element, :sticky_header, :title), content_text(element, nil)],
         ""
       ),
       Keyword.merge(base_opts(element),
         stuck: group_attr(element, :sticky_header, :stuck?),
         elevation: group_attr(element, :sticky_header, :elevation),
         summary: group_attr(element, :sticky_header, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:pipeline_stepper_horizontal, "pipeline_stepper_horizontal"] do
    {:ok,
     DesktopUi.Widgets.pipeline_stepper_horizontal(
       element.id,
       first_present([group_attr(element, :workflow, :steps), attr(element, :steps)], []),
       Keyword.merge(base_opts(element),
         active_item: group_attr(element, :workflow, :active_item),
         status: group_attr(element, :workflow, :status),
         summary: group_attr(element, :workflow, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:segmented_progress_bar, "segmented_progress_bar"] do
    {:ok,
     DesktopUi.Widgets.segmented_progress_bar(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:workflow_stage_list_vertical, "workflow_stage_list_vertical"] do
    {:ok,
     DesktopUi.Widgets.workflow_stage_list_vertical(
       element.id,
       first_present([group_attr(element, :workflow, :stages), attr(element, :stages)], []),
       Keyword.merge(base_opts(element),
         active_item: group_attr(element, :workflow, :active_item),
         status: group_attr(element, :workflow, :status),
         summary: group_attr(element, :workflow, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:meter_thin, "meter_thin"] do
    {:ok,
     DesktopUi.Widgets.meter_thin(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:slide_over_panel, "slide_over_panel"] do
    {:ok,
     DesktopUi.Widgets.slide_over_panel(
       element.id,
       [],
       Keyword.merge(base_opts(element),
         title: first_present([group_attr(element, :panel, :title), label_text(element)]),
         placement: group_attr(element, :panel, :placement),
         visible: group_attr(element, :panel, :visible?),
         modal: group_attr(element, :panel, :modal?),
         summary: group_attr(element, :panel, :summary),
         on_open: interaction_payload(element, :open),
         on_close: interaction_payload(element, :close)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:event_callout, "event_callout"] do
    {:ok,
     DesktopUi.Widgets.event_callout(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:redline_inline, "redline_inline"] do
    {:ok,
     DesktopUi.Widgets.redline_inline(
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

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:code_block_syntax_highlighted, "code_block_syntax_highlighted"] do
    {:ok,
     DesktopUi.Widgets.code_block_syntax_highlighted(
       element.id,
       first_present([group_attr(element, :code_block, :code), content_text(element, nil)], ""),
       Keyword.merge(base_opts(element),
         language: group_attr(element, :code_block, :language),
         label: group_attr(element, :code_block, :label),
         wrap: group_attr(element, :code_block, :wrap?),
         summary: group_attr(element, :code_block, :summary)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:chat_composer, "chat_composer"] do
    {:ok,
     DesktopUi.Widgets.chat_composer(
       element.id,
       Keyword.merge(base_opts(element),
         placeholder: group_attr(element, :composer, :placeholder),
         submit_intent: group_attr(element, :composer, :submit_intent),
         actions: group_attr(element, :composer, :actions) || [],
         multiline: group_attr(element, :composer, :multiline?),
         summary: group_attr(element, :composer, :summary),
         on_submit: interaction_payload(element, :submit),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:host_form_shell, "host_form_shell"] do
    {:ok,
     DesktopUi.Widgets.host_form_shell(
       element.id,
       [],
       Keyword.merge(base_opts(element),
         owner: group_attr(element, :form_shell, :owner),
         lifecycle: group_attr(element, :form_shell, :lifecycle),
         action_placement: group_attr(element, :form_shell, :action_placement),
         mode: group_attr(element, :form, :mode),
         submit_intent: group_attr(element, :form, :submit_intent),
         autocomplete: group_attr(element, :form, :autocomplete?),
         validation_summary: group_attr(element, :validation, :summary),
         validation_status: group_attr(element, :validation, :status),
         validation_errors: group_attr(element, :validation, :errors),
         on_submit: interaction_payload(element, :submit),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and
              kind in [:repeated_collection, "repeated_collection"] do
    with {:ok, rows} <- collection_rows(element),
         {:ok, empty_state} <- collection_empty_state(element, rows) do
      {:ok,
       DesktopUi.Widgets.repeated_collection(
         element.id,
         Enum.map(rows, & &1.widget),
         Keyword.merge(base_opts(element),
           item_alias: group_attr(element, :collection, :item_alias) || :item,
           index_alias: group_attr(element, :collection, :index_alias) || :index,
           key_path: group_attr(element, :collection, :key_path) || [],
           row_metadata: Enum.map(rows, &Map.drop(&1, [:widget])),
           empty_state: empty_state
         )
       )}
    end
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:window, "window"] do
    {:ok,
     DesktopUi.Widgets.window(
       element.id,
       first_present([attr(element, :title), label_text(element)], "Window"),
       [],
       base_opts(element)
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:table, "table"] do
    {:ok,
     DesktopUi.Widgets.table(
       element.id,
       first_present([attr(element, :columns), group_attr(element, :data, :columns)], []),
       first_present([attr(element, :rows), group_attr(element, :data, :rows)], []),
       Keyword.merge(
         base_opts(element),
         selection_binding: binding_name(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         sort_key:
           first_present([attr(element, :sort_key), group_attr(element, :data, :sort_key)]),
         on_select: interaction_payload(element, :selection),
         on_sort: interaction_payload(element, :sort),
         on_filter: interaction_payload(element, :filter)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:tree_view, "tree_view"] do
    {:ok,
     DesktopUi.Widgets.tree_view(
       element.id,
       first_present([attr(element, :nodes), group_attr(element, :data, :nodes)], []),
       Keyword.merge(
         base_opts(element),
         selection_binding: binding_name(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         on_select: interaction_payload(element, :selection),
         on_expand: interaction_payload(element, :expand)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:stat, "stat"] do
    {:ok,
     DesktopUi.Widgets.stat(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         label:
           first_present([
             attr(element, :label),
             group_attr(element, :stat, :label),
             label_text(element)
           ]),
         unit: first_present([attr(element, :unit), group_attr(element, :stat, :unit)]),
         trend: first_present([attr(element, :trend), group_attr(element, :stat, :trend)]),
         previous_value:
           first_present([
             attr(element, :previous_value),
             group_attr(element, :stat, :previous_value)
           ]),
         size: first_present([attr(element, :size), group_attr(element, :stat, :size)], :md),
         variant:
           first_present(
             [attr(element, :variant), group_attr(element, :stat, :variant)],
             :default
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:key_value, "key_value"] do
    {:ok,
     DesktopUi.Widgets.key_value(
       element.id,
       Keyword.merge(
         base_opts(element),
         key: first_present([attr(element, :key), group_attr(element, :key_value, :key)]),
         value: first_present([attr(element, :value), binding_value(element)]),
         align:
           first_present([attr(element, :align), group_attr(element, :key_value, :align)], :left),
         size: first_present([attr(element, :size), group_attr(element, :key_value, :size)], :md),
         variant:
           first_present(
             [attr(element, :variant), group_attr(element, :key_value, :variant)],
             :default
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:info_list, "info_list"] do
    {:ok,
     DesktopUi.Widgets.info_list(
       element.id,
       first_present([attr(element, :items), group_attr(element, :data, :items)], []),
       Keyword.merge(
         base_opts(element),
         size: first_present([attr(element, :size), group_attr(element, :info_list, :size)], :md),
         variant:
           first_present(
             [attr(element, :variant), group_attr(element, :info_list, :variant)],
             :default
           ),
         show_icons:
           first_present(
             [attr(element, :show_icons), group_attr(element, :info_list, :show_icons)],
             true
           ),
         compact:
           first_present(
             [attr(element, :compact), group_attr(element, :info_list, :compact)],
             false
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:inspector, "inspector"] do
    {:ok,
     DesktopUi.Widgets.inspector(
       element.id,
       first_present([attr(element, :subject), group_attr(element, :data, :subject)], %{}),
       Keyword.merge(
         base_opts(element),
         sections:
           first_present([attr(element, :sections), group_attr(element, :data, :sections)], []),
         on_expand: interaction_payload(element, :expand),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:markdown_viewer, "markdown_viewer"] do
    {:ok,
     DesktopUi.Widgets.markdown_viewer(
       element.id,
       first_present([attr(element, :source), attr(element, :content)], ""),
       Keyword.merge(
         base_opts(element),
         anchors: first_present([attr(element, :anchors)], []),
         mode: first_present([attr(element, :mode)], :rendered),
         on_navigate: interaction_payload(element, :navigation)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:dialog, "dialog"] do
    {:ok,
     DesktopUi.Widgets.dialog(
       element.id,
       first_present([attr(element, :title), label_text(element)], "Dialog"),
       [],
       Keyword.merge(
         base_opts(element),
         open: first_present([attr(element, :open)], true),
         on_close: interaction_payload(element, :close)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:toast, "toast"] do
    {:ok,
     DesktopUi.Widgets.toast(
       element.id,
       content_text(element, "Toast"),
       Keyword.merge(
         base_opts(element),
         timeout_ms: first_present([attr(element, :timeout_ms)], 3_000),
         on_close: interaction_payload(element, :close)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:inline_feedback, "inline_feedback"] do
    {:ok,
     DesktopUi.Widgets.inline_feedback(
       element.id,
       Keyword.merge(
         base_opts(element),
         message:
           first_present([attr(element, :message), attr(element, :content), label_text(element)]),
         severity:
           first_present(
             [attr(element, :severity), group_attr(element, :feedback, :severity)],
             :info
           ),
         placement:
           first_present(
             [attr(element, :placement), group_attr(element, :feedback, :placement)],
             :bottom
           ),
         dismissible:
           first_present(
             [attr(element, :dismissible), group_attr(element, :feedback, :dismissible)],
             true
           ),
         auto_hide:
           first_present(
             [attr(element, :auto_hide), group_attr(element, :feedback, :auto_hide)],
             true
           ),
         timeout_ms:
           first_present(
             [attr(element, :timeout_ms), group_attr(element, :feedback, :timeout_ms)],
             3_000
           ),
         on_close: interaction_payload(element, :close)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:status, "status"] do
    {:ok,
     DesktopUi.Widgets.status(
       element.id,
       label_text(element, "Status"),
       Keyword.merge(
         base_opts(element),
         status:
           first_present([attr(element, :status), group_attr(element, :status, :state)], :idle),
         severity:
           first_present(
             [attr(element, :severity), group_attr(element, :status, :severity)],
             :info
           ),
         active:
           first_present([attr(element, :active), group_attr(element, :status, :active)], true),
         icon: first_present([attr(element, :icon), group_attr(element, :status, :icon)])
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:progress, "progress"] do
    {:ok,
     DesktopUi.Widgets.progress(
       element.id,
       Keyword.merge(
         base_opts(element),
         current: first_present([attr(element, :current), binding_value(element)]),
         total: attr(element, :total),
         binding: binding_name(element),
         indeterminate: first_present([attr(element, :indeterminate)], false)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:gauge, "gauge"] do
    {:ok,
     DesktopUi.Widgets.gauge(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)]),
         binding: binding_name(element),
         min: first_present([attr(element, :min)], 0),
         max: first_present([attr(element, :max)], 100),
         label: label_text(element)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:bar_chart, "bar_chart"] do
    {:ok,
     DesktopUi.Widgets.bar_chart(
       element.id,
       first_present([attr(element, :series)], []),
       Keyword.merge(base_opts(element), axes: first_present([attr(element, :axes)], %{}))
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:line_chart, "line_chart"] do
    {:ok,
     DesktopUi.Widgets.line_chart(
       element.id,
       first_present([attr(element, :series)], []),
       Keyword.merge(base_opts(element), axes: first_present([attr(element, :axes)], %{}))
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:sparkline, "sparkline"] do
    {:ok,
     DesktopUi.Widgets.sparkline(
       element.id,
       Keyword.merge(
         base_opts(element),
         data: first_present([attr(element, :data), group_attr(element, :chart, :data)], []),
         min: attr(element, :min),
         max: attr(element, :max),
         color: first_present([attr(element, :color), group_attr(element, :chart, :color)]),
         width: attr(element, :width),
         height: attr(element, :height),
         show_area:
           first_present(
             [attr(element, :show_area), group_attr(element, :chart, :show_area)],
             true
           ),
         show_dots:
           first_present(
             [attr(element, :show_dots), group_attr(element, :chart, :show_dots)],
             false
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:timeline, "timeline"] do
    {:ok,
     DesktopUi.Widgets.timeline(
       element.id,
       first_present([attr(element, :events)], []),
       Keyword.merge(base_opts(element), mode: first_present([attr(element, :mode)], :relative))
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:canvas, "canvas"] do
    {:ok,
     DesktopUi.Widgets.canvas(
       element.id,
       first_present([attr(element, :operations)], []),
       Keyword.merge(
         base_opts(element),
         width: attr(element, :width),
         height: attr(element, :height),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:log_viewer, "log_viewer"] do
    {:ok,
     DesktopUi.Widgets.log_viewer(
       element.id,
       first_present([attr(element, :entries)], []),
       Keyword.merge(
         base_opts(element),
         query_binding: binding_name(element),
         query: attr(element, :query),
         on_filter: interaction_payload(element, :filter)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:cluster_dashboard, "cluster_dashboard"] do
    {:ok,
     DesktopUi.Widgets.cluster_dashboard(
       element.id,
       first_present([attr(element, :nodes)], []),
       Keyword.merge(base_opts(element), summary: first_present([attr(element, :summary)], %{}))
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:command_palette, "command_palette"] do
    {:ok,
     DesktopUi.Widgets.command_palette(
       element.id,
       first_present([attr(element, :commands)], []),
       Keyword.merge(
         base_opts(element),
         query_binding: binding_name(element),
         query: attr(element, :query),
         on_change: interaction_payload(element, :change),
         on_command: interaction_payload(element, :command),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:process_monitor, "process_monitor"] do
    {:ok,
     DesktopUi.Widgets.process_monitor(
       element.id,
       first_present([attr(element, :processes)], []),
       Keyword.merge(
         base_opts(element),
         selection_binding: binding_name(element),
         sort_by: attr(element, :sort_by),
         on_sort: interaction_payload(element, :sort),
         on_filter: interaction_payload(element, :filter),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:stream_widget, "stream_widget"] do
    {:ok,
     DesktopUi.Widgets.stream_widget(
       element.id,
       Keyword.merge(
         base_opts(element),
         entries:
           first_present([attr(element, :entries), group_attr(element, :data, :entries)], []),
         follow:
           first_present([attr(element, :follow), group_attr(element, :stream, :follow)], true),
         filter: first_present([attr(element, :filter), group_attr(element, :stream, :filter)]),
         level: first_present([attr(element, :level), group_attr(element, :stream, :level)]),
         line_limit:
           first_present(
             [attr(element, :line_limit), group_attr(element, :stream, :line_limit)],
             1000
           ),
         streaming:
           first_present(
             [attr(element, :streaming), group_attr(element, :stream, :streaming)],
             true
           ),
         paused:
           first_present([attr(element, :paused), group_attr(element, :stream, :paused)], false),
         on_pause: interaction_payload(element, :pause),
         on_resume: interaction_payload(element, :resume),
         on_clear: interaction_payload(element, :clear),
         on_filter: interaction_payload(element, :filter)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:supervision_tree_viewer, "supervision_tree_viewer"] do
    {:ok,
     DesktopUi.Widgets.supervision_tree_viewer(
       element.id,
       Keyword.merge(
         base_opts(element),
         tree:
           first_present([attr(element, :tree), group_attr(element, :supervision, :tree)], []),
         query: first_present([attr(element, :query), group_attr(element, :supervision, :query)]),
         application:
           first_present([
             attr(element, :application),
             group_attr(element, :supervision, :application)
           ]),
         selection_binding: binding_name(element),
         expanded:
           first_present(
             [attr(element, :expanded), group_attr(element, :supervision, :expanded)],
             []
           ),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         on_select: interaction_payload(element, :selection),
         on_expand: interaction_payload(element, :expand),
         on_collapse: interaction_payload(element, :collapse),
         on_refresh: interaction_payload(element, :refresh)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:window_command, "window_command"] do
    {:ok,
     DesktopUi.Widgets.window_command(
       element.id,
       label_text(element, "Window Command"),
       Keyword.merge(base_opts(element), on_command: interaction_payload(element, :command))
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:column, "column"] do
    {:ok,
     DesktopUi.Widgets.column(
       element.id,
       [],
       Keyword.merge(base_opts(element), gap: first_present([attr(element, :gap)], 16))
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element) when kind in [:row, "row"] do
    {:ok,
     DesktopUi.Widgets.row(
       element.id,
       [],
       Keyword.merge(base_opts(element), gap: first_present([attr(element, :gap)], 12))
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:stack, "stack"] do
    {:ok,
     DesktopUi.Widgets.stack(
       element.id,
       [],
       Keyword.merge(base_opts(element), align: first_present([attr(element, :align)], :stretch))
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:viewport, "viewport"] do
    {:ok,
     DesktopUi.Layout.viewport(
       element.id,
       placeholder_child(element.id, :viewport),
       Keyword.merge(
         base_opts(element),
         axis: first_present([attr(element, :axis)], :vertical),
         offset: first_present([attr(element, :offset)], %{x: 0, y: 0}),
         width: attr(element, :width),
         height: attr(element, :height),
         on_scroll: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:scroll_region, "scroll_region"] do
    {:ok,
     DesktopUi.Layout.scroll_region(
       element.id,
       placeholder_child(element.id, :scroll_region),
       Keyword.merge(
         base_opts(element),
         axis: first_present([attr(element, :axis)], :vertical),
         offset: first_present([attr(element, :offset)], %{x: 0, y: 0}),
         on_scroll: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:split_pane, "split_pane"] do
    {:ok,
     DesktopUi.Layout.split_pane(
       element.id,
       placeholder_child(element.id, :primary),
       placeholder_child(element.id, :secondary),
       Keyword.merge(
         base_opts(element),
         direction: first_present([attr(element, :direction)], :horizontal),
         ratio: first_present([attr(element, :ratio)], 0.5),
         on_resize: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:canvas_surface, "canvas_surface"] do
    {:ok,
     DesktopUi.Layout.canvas_surface(
       element.id,
       [],
       Keyword.merge(base_opts(element),
         width: attr(element, :width),
         height: attr(element, :height)
       )
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:absolute, "absolute"] do
    {:ok,
     DesktopUi.Layout.absolute(
       element.id,
       [],
       Keyword.merge(
         base_opts(element),
         x: first_present([attr(element, :x)], 0),
         y: first_present([attr(element, :y)], 0),
         z_index: first_present([attr(element, :z_index)], 0)
       )
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element) when kind in [:box, "box"] do
    # Extract container attributes from IUR attributes
    container_attrs = attr(element, :container) || %{}

    # Extract layout attributes from IUR attributes
    layout_attrs = attr(element, :layout) || %{}

    {:ok,
     DesktopUi.Layout.box(
       element.id,
       # Children will be added via slot_children
       [],
       Keyword.merge(
         base_opts(element),
         # Container attributes
         padding: Map.get(container_attrs, :padding),
         margin: Map.get(container_attrs, :margin),
         border: Map.get(container_attrs, :border),
         background: Map.get(container_attrs, :background),
         clip?: Map.get(container_attrs, :clip?),
         # Layout attributes
         gap: Map.get(layout_attrs, :gap),
         align: Map.get(layout_attrs, :align),
         justify: Map.get(layout_attrs, :justify),
         width: Map.get(layout_attrs, :width),
         height: Map.get(layout_attrs, :height),
         min_width: Map.get(layout_attrs, :min_width),
         max_width: Map.get(layout_attrs, :max_width),
         min_height: Map.get(layout_attrs, :min_height),
         max_height: Map.get(layout_attrs, :max_height)
       )
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element) when kind in [:grid, "grid"] do
    # Extract layout attributes from IUR attributes
    layout_attrs = attr(element, :layout) || %{}
    container_attrs = attr(element, :container) || %{}

    {:ok,
     DesktopUi.Layout.grid(
       element.id,
       # Children will be added via slot_children
       [],
       Keyword.merge(
         base_opts(element),
         # Grid dimensions
         columns: Map.get(layout_attrs, :columns) || attr(element, :columns),
         rows: Map.get(layout_attrs, :rows) || attr(element, :rows),
         # Spacing
         gap: Map.get(layout_attrs, :gap) || attr(element, :gap),
         column_gap: Map.get(layout_attrs, :column_gap) || attr(element, :column_gap),
         row_gap: Map.get(layout_attrs, :row_gap) || attr(element, :row_gap),
         # Alignment
         align: Map.get(layout_attrs, :align) || attr(element, :align),
         justify: Map.get(layout_attrs, :justify) || attr(element, :justify),
         # Container attributes
         padding: Map.get(container_attrs, :padding) || attr(element, :padding),
         margin: Map.get(container_attrs, :margin) || attr(element, :margin),
         border: Map.get(container_attrs, :border) || attr(element, :border),
         background: Map.get(container_attrs, :background) || attr(element, :background),
         # Sizing
         width: Map.get(layout_attrs, :width) || attr(element, :width),
         height: Map.get(layout_attrs, :height) || attr(element, :height),
         min_width: Map.get(layout_attrs, :min_width) || attr(element, :min_width),
         max_width: Map.get(layout_attrs, :max_width) || attr(element, :max_width),
         min_height: Map.get(layout_attrs, :min_height) || attr(element, :min_height),
         max_height: Map.get(layout_attrs, :max_height) || attr(element, :max_height)
       )
     )}
  end

  defp map_element(%Element{type: :layer, kind: kind} = element)
       when kind in [:overlay, "overlay"] do
    {:ok,
     DesktopUi.Layer.overlay(
       element.id,
       placeholder_child(element.id, :content),
       [],
       Keyword.merge(base_opts(element),
         overlay_role: first_present([metadata_attr(element, :overlay_role)], :overlay)
       )
     )}
  end

  defp map_element(%Element{type: :layer, kind: kind} = element)
       when kind in [:context_menu, "context_menu"] do
    {:ok,
     DesktopUi.Layer.context_menu(
       element.id,
       placeholder_child(element.id, :anchor),
       first_present([attr(element, :items)], []),
       Keyword.merge(base_opts(element), on_select: interaction_payload(element, :selection))
     )}
  end

  defp map_element(%Element{type: :layer, kind: kind} = element)
       when kind in [:popover, "popover"] do
    {:ok,
     DesktopUi.Layer.popover(
       element.id,
       placeholder_child(element.id, :anchor),
       placeholder_child(element.id, :content),
       Keyword.merge(base_opts(element), on_close: interaction_payload(element, :close))
     )}
  end

  defp map_element(%Element{type: :layer, kind: kind} = element)
       when kind in [:multi_window, "multi_window"] do
    {:ok,
     DesktopUi.Layer.multi_window(
       element.id,
       [],
       Keyword.merge(
         base_opts(element),
         window_identity: first_present([metadata_attr(element, :window_identity)], element.id)
       )
     )}
  end

  defp map_element(%Element{} = element) do
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
      {%Child{element: %Element{} = template}, items} when is_list(items) ->
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
      child = ensure_child_id(child, "#{element.id}-empty-state-#{index}")

      case map_child(child) do
        {:ok, widget} -> {:cont, {:ok, acc ++ [widget]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp ensure_child_id(%Child{element: %Element{id: nil} = element} = child, id) do
    %{child | element: %{element | id: id}}
  end

  defp ensure_child_id(child, _id), do: child

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

  defp children_for_slots(%Element{} = element, slots) do
    slots = Enum.map(slots, &to_string/1)

    Enum.filter(element.children, fn
      %Child{slot: slot} -> to_string(slot) in slots
      _other -> false
    end)
  end

  defp map_child(%Child{element: %Element{} = element}), do: map(element)
  defp map_child(%Element{} = element), do: map(element)
  defp map_child(_other), do: {:ok, nil}

  defp map_children(children) do
    children
    |> Enum.reject(&is_nil(&1.element))
    |> Enum.reduce_while({:ok, %{}}, fn %Child{slot: slot, element: element}, {:ok, acc} ->
      case map(element) do
        {:ok, widget} ->
          {:cont, {:ok, Map.update(acc, slot, [widget], fn existing -> existing ++ [widget] end)}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp attach_slot_children(%Widget{} = widget, slot_children) do
    if map_size(slot_children) == 0 do
      widget
    else
      children = slot_children |> Map.values() |> List.flatten()
      %{widget | slot_children: slot_children, slots: Map.keys(slot_children), children: children}
    end
  end

  defp map_navigation(kind, element) do
    items = first_present([group_attr(element, :navigation, :items), attr(element, :items)], [])

    current =
      first_present([
        group_attr(element, :navigation, :active_item),
        attr(element, :current),
        binding_value(element)
      ])

    apply(DesktopUi.Widgets, kind, [
      element.id,
      items,
      Keyword.merge(
        base_opts(element),
        current: current,
        binding: binding_name(element),
        on_navigate: interaction_payload(element, :navigation),
        on_select: interaction_payload(element, :selection)
      )
    ])
  end

  defp validate_bindings(%Element{} = element) do
    bindings = [attr(element, :binding), attr(element, :bindings)] |> Enum.reject(&is_nil/1)

    if Enum.all?(bindings, &valid_binding_attachment?/1) do
      :ok
    else
      {:error, Error.new(:invalid_canonical_bindings, %{kind: element.kind, id: element.id})}
    end
  end

  defp valid_binding_attachment?(%{name: name}) when is_atom(name) or is_binary(name), do: true

  defp valid_binding_attachment?(bindings) when is_list(bindings) do
    Enum.all?(bindings, fn
      %{name: name} -> is_atom(name) or is_binary(name)
      _other -> false
    end)
  end

  defp valid_binding_attachment?(_other), do: false

  defp base_opts(element) do
    [
      styles: normalize_styles(attr(element, :styles)),
      metadata: metadata_opts(element),
      disabled:
        first_present([attr(element, :disabled), metadata_attr(element, :disabled)], false)
    ]
  end

  defp metadata_opts(element) do
    [
      label: label_text(element),
      description: metadata_attr(element, :description),
      variant: first_present([attr(element, :variant), metadata_attr(element, :variant)]),
      shortcut: first_present([attr(element, :shortcut), metadata_attr(element, :shortcut)]),
      focus_group: metadata_attr(element, :focus_group),
      binding_surface: metadata_attr(element, :binding_surface),
      selection_mode: metadata_attr(element, :selection_mode),
      sort_key: metadata_attr(element, :sort_key),
      overlay_role: metadata_attr(element, :overlay_role),
      overlay_lifecycle: metadata_attr(element, :overlay_lifecycle),
      positioning_mode: metadata_attr(element, :positioning_mode),
      interaction_route: metadata_attr(element, :interaction_route),
      window_identity: metadata_attr(element, :window_identity)
    ]
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp binding_name(element) do
    case attr(element, :binding) do
      %{name: name} -> name
      _other -> nil
    end
  end

  defp binding_value(element) do
    case attr(element, :binding) do
      %{value: value} -> value
      _other -> nil
    end
  end

  defp interaction_payload(element, family) do
    case attr(element, :interaction) do
      %{family: ^family} = interaction ->
        interaction

      %{kind: ^family} = interaction ->
        interaction

      %{intent: _intent} = interaction
      when family in [
             :click,
             :change,
             :submit,
             :open,
             :selection,
             :focus,
             :navigation,
             :command,
             :sort,
             :filter,
             :close
           ] ->
        interaction

      _other ->
        case attr(element, :interactions) do
          interactions when is_list(interactions) ->
            Enum.find(interactions, fn
              %{family: ^family} -> true
              %{kind: ^family} -> true
              _ -> false
            end)

          _ ->
            nil
        end
    end
  end

  defp interaction_intent(element, family) do
    case interaction_payload(element, family) do
      %{intent: intent} -> intent
      _other -> family
    end
  end

  defp content_text(element, fallback) do
    first_present([attr(element, :content), attr(element, :text), label_text(element)], fallback)
  end

  defp label_text(element, fallback \\ nil) do
    first_present(
      [
        attr(element, :label),
        metadata_attr(element, :label),
        attr(element, :label_text),
        attr(element, :content)
      ],
      fallback
    )
  end

  defp group_attr(element, group, key) do
    case attr(element, group) do
      %{} = group_map -> Map.get(group_map, key) || Map.get(group_map, to_string(key))
      _other -> nil
    end
  end

  defp metadata_attr(%Element{} = element, key) do
    metadata = element.metadata || %{}
    Map.get(metadata, key) || Map.get(metadata, to_string(key))
  end

  defp attr(%Element{} = element, key) do
    Map.get(element.attributes, key) || Map.get(element.attributes, to_string(key))
  end

  defp first_present(values, fallback \\ nil) do
    Enum.find(values, fallback, &(not is_nil(&1)))
  end

  defp normalize_styles(nil), do: []
  defp normalize_styles(styles) when is_map(styles), do: Map.to_list(styles)
  defp normalize_styles(styles) when is_list(styles), do: styles

  defp placeholder_child(id, role) do
    Widget.new(:spacer, id: "#{id}-#{role}-placeholder")
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
end
