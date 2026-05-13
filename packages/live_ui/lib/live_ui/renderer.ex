defmodule LiveUi.Renderer do
  @moduledoc """
  Package-facing entrypoint for canonical `UnifiedIUR` rendering.
  """

  use Phoenix.Component

  alias LiveUi.Style, as: NativeStyle
  alias UnifiedIUR.{Binding, Element, Interaction}
  alias UnifiedIUR.Element.Child

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:consume_canonical_iur, :reuse_native_widgets, :preserve_runtime_continuity]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :alert_dialog,
      :bar_chart,
      :box,
      :button,
      :canvas,
      :checkbox,
      :cluster_dashboard,
      :column,
      :command_palette,
      :content,
      :context_menu,
      :date_input,
      :dialog,
      :disclosure,
      :event_callout,
      :field,
      :field_group,
      :file_input,
      :form_builder,
      :gauge,
      :grid,
      :host_form_shell,
      :icon,
      :image,
      :inline_feedback,
      :kicker,
      :label,
      :line_chart,
      :link,
      :list,
      :list_item_multi_column,
      :log_viewer,
      :markdown_viewer,
      :menu,
      :meter_thin,
      :numeric_input,
      :overlay,
      :pick_list,
      :pipeline_stepper_horizontal,
      :presence_dot,
      :process_monitor,
      :progress,
      :radio_group,
      :redline_inline,
      :repeated_collection,
      :row,
      :scroll_bar,
      :select,
      :separator,
      :segmented_button_group,
      :segmented_progress_bar,
      :sparkline,
      :spacer,
      :split_pane,
      :status,
      :stream_widget,
      :sticky_header,
      :slide_over_panel,
      :supervision_tree_viewer,
      :table,
      :tabs,
      :text,
      :text_input,
      :time_input,
      :toast,
      :toggle,
      :tree_view,
      :viewport,
      :workflow_stage_list_vertical,
      :avatar,
      :artifact_row,
      :chat_composer,
      :code_block_syntax_highlighted
    ]
  end

  attr(:element, :any, required: true)
  attr(:runtime_state, :any, default: nil)
  attr(:event_target, :any, default: nil)

  def render(%{element: %Element{kind: :text}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Text.component
      id={element_id(@element, "text")}
      content={content_text(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :label}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Label.component
      id={element_id(@element, "label")}
      for={label_for(@element)}
      content={content_text(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :icon}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Icon.component
      id={element_id(@element, "icon")}
      name={string_value(get_in(@element.attributes, [:icon, :name]), "icon")}
      set={string_optional(get_in(@element.attributes, [:icon, :set]))}
      fallback_text={string_optional(get_in(@element.attributes, [:icon, :fallback_text]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :image}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Image.component
      id={element_id(@element, "image")}
      src={string_value(get_in(@element.attributes, [:image, :source]), "")}
      alt={string_value(get_in(@element.attributes, [:image, :alt_text]), "")}
      fit={string_optional(get_in(@element.attributes, [:image, :fit]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :button}} = assigns) do
    interaction_attrs = interaction_event_attrs(assigns.element, Map.get(assigns, :event_target))

    assigns =
      assign(assigns, :interaction_attrs, interaction_attrs)
      |> assign(
        :style_attrs,
        merge_global_attrs(style_rest(assigns.element), interaction_attrs)
      )

    ~H"""
    <LiveUi.Widgets.Button.component
      id={element_id(@element, "button")}
      label={content_text(@element)}
      disabled={state_boolean(@element, :disabled?)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :link}} = assigns) do
    assigns =
      assign(
        assigns,
        :interaction_attrs,
        interaction_event_attrs(assigns.element, Map.get(assigns, :event_target))
      )

    ~H"""
    <LiveUi.Widgets.Link.component
      id={element_id(@element, "link")}
      label={content_text(@element)}
      href={string_value(get_in(@element.attributes, [:link, :target]), "#")}
      external={state_boolean(@element, [:link, :external?])}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@interaction_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :separator}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Separator.component
      id={element_id(@element, "separator")}
      orientation={string_value(get_in(@element.attributes, [:separator, :orientation]), "horizontal")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :spacer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Spacer.component
      id={element_id(@element, "spacer")}
      size={string_value(get_in(@element.attributes, [:spacer, :size]), "md")}
      grow={integer_value(get_in(@element.attributes, [:spacer, :grow]), 0)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :content}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Content.component
      id={element_id(@element, "content")}
      role={string_value(get_in(@element.attributes, [:container, :role]), "content")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.Content.component>
    """
  end

  def render(%{element: %Element{kind: :box}} = assigns) do
    accessibility_attrs = accessibility_attrs(assigns.element)

    assigns =
      assign(assigns, :accessibility_attrs, accessibility_attrs)
      |> assign(
        :style_attrs,
        merge_global_attrs(style_rest(assigns.element), accessibility_attrs)
      )

    ~H"""
    <LiveUi.Widgets.Box.component
      id={element_id(@element, "box")}
      padding={string_optional(get_in(@element.attributes, [:container, :padding]))}
      border={string_optional(get_in(@element.attributes, [:container, :border]))}
      background={string_optional(get_in(@element.attributes, [:container, :background]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.Box.component>
    """
  end

  def render(%{element: %Element{kind: :row}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Layout.Row.component
      id={element_id(@element, "row")}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      padding={string_optional(get_in(@element.attributes, [:layout, :padding]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      width={string_optional(get_in(@element.attributes, [:layout, :width]))}
      height={string_optional(get_in(@element.attributes, [:layout, :height]))}
      min_width={string_optional(get_in(@element.attributes, [:layout, :min_width]))}
      min_height={string_optional(get_in(@element.attributes, [:layout, :min_height]))}
      max_width={string_optional(get_in(@element.attributes, [:layout, :max_width]))}
      max_height={string_optional(get_in(@element.attributes, [:layout, :max_height]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- layout_children(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Layout.Row.component>
    """
  end

  def render(%{element: %Element{kind: :column}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Layout.Column.component
      id={element_id(@element, "column")}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      padding={string_optional(get_in(@element.attributes, [:layout, :padding]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      width={string_optional(get_in(@element.attributes, [:layout, :width]))}
      height={string_optional(get_in(@element.attributes, [:layout, :height]))}
      min_width={string_optional(get_in(@element.attributes, [:layout, :min_width]))}
      min_height={string_optional(get_in(@element.attributes, [:layout, :min_height]))}
      max_width={string_optional(get_in(@element.attributes, [:layout, :max_width]))}
      max_height={string_optional(get_in(@element.attributes, [:layout, :max_height]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- layout_children(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Layout.Column.component>
    """
  end

  def render(%{element: %Element{kind: :grid}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Layout.Grid.component
      id={element_id(@element, "grid")}
      columns={integer_optional(get_in(@element.attributes, [:layout, :columns]))}
      rows={integer_optional(get_in(@element.attributes, [:layout, :rows]))}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      padding={string_optional(get_in(@element.attributes, [:layout, :padding]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      width={string_optional(get_in(@element.attributes, [:layout, :width]))}
      height={string_optional(get_in(@element.attributes, [:layout, :height]))}
      min_width={string_optional(get_in(@element.attributes, [:layout, :min_width]))}
      min_height={string_optional(get_in(@element.attributes, [:layout, :min_height]))}
      max_width={string_optional(get_in(@element.attributes, [:layout, :max_width]))}
      max_height={string_optional(get_in(@element.attributes, [:layout, :max_height]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- layout_children(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Layout.Grid.component>
    """
  end

  def render(%{element: %Element{kind: :form_builder}} = assigns) do
    assigns =
      assign(
        assigns,
        :form_interaction_attrs,
        form_interaction_attrs(assigns.element, Map.get(assigns, :event_target))
      )

    ~H"""
    <LiveUi.Forms.FormBuilder.component
      id={element_id(@element, "form-builder")}
      autocomplete={boolean_default(get_in(@element.attributes, [:form, :autocomplete?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@form_interaction_attrs}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Forms.FormBuilder.component>
    """
  end

  def render(%{element: %Element{kind: :host_form_shell}} = assigns) do
    assigns =
      assign(
        assigns,
        :form_interaction_attrs,
        form_interaction_attrs(assigns.element, Map.get(assigns, :event_target))
      )

    ~H"""
    <LiveUi.Forms.HostFormShell.component
      id={element_id(@element, "host-form-shell")}
      owner={string_value(get_in(@element.attributes, [:form_shell, :owner]), "host")}
      lifecycle={string_value(get_in(@element.attributes, [:form_shell, :lifecycle]), "host_owned")}
      submit_intent={string_optional(get_in(@element.attributes, [:form, :submit_intent]))}
      validation_summary={string_optional(get_in(@element.attributes, [:validation, :summary]))}
      action_placement={string_value(get_in(@element.attributes, [:form_shell, :action_placement]), "footer")}
      autocomplete={boolean_default(get_in(@element.attributes, [:form, :autocomplete?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@form_interaction_attrs}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Forms.HostFormShell.component>
    """
  end

  def render(%{element: %Element{kind: :field_group}} = assigns) do
    ~H"""
    <LiveUi.Forms.FieldGroup.component
      id={element_id(@element, "field-group")}
      legend={string_optional(get_in(@element.attributes, [:group, :legend]))}
      description={string_optional(get_in(@element.attributes, [:group, :description]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Forms.FieldGroup.component>
    """
  end

  def render(%{element: %Element{kind: :field}} = assigns) do
    ~H"""
    <LiveUi.Forms.Field.component
      id={element_id(@element, "field")}
      name={string_optional(get_in(@element.attributes, [:field, :name]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    >
      <:label :for={child <- child_elements(@element, :label)}>
        <.render element={child} event_target={@event_target} />
      </:label>
      <:control :for={child <- child_elements(@element, :control)}>
        <.render element={child} event_target={@event_target} />
      </:control>
      <:help :for={child <- child_elements(@element, :help)}>
        <.render element={child} event_target={@event_target} />
      </:help>
    </LiveUi.Forms.Field.component>
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:text_input, :numeric_input, :date_input, :time_input, :file_input] do
    assigns =
      assign(assigns, :change_interaction, primary_change_interaction(assigns.element))
      |> assign(:style_attrs, style_rest(assigns.element))

    ~H"""
    <%= if @change_interaction && @event_target do %>
      <form
        id={interaction_form_id(@element, "input")}
        data-live-ui-interaction-form="true"
        phx-input="canonical_interaction"
        phx-change="canonical_interaction"
        phx-target={@event_target}
      >
        <input type="hidden" name="interaction" value={encode_interaction(@change_interaction)} />
        <input type="hidden" name="element_id" value={element_id(@element, "element")} />
        <input type="hidden" name="widget" value={to_string(@element.kind)} />
        <LiveUi.Widgets.TextInput.component
          id={element_id(@element, "input")}
          name={binding_name(@element)}
          value={binding_value(@element)}
          placeholder={string_optional(get_in(@element.attributes, [:input, :placeholder]))}
          input_type={input_type(@element.kind)}
          tone={style_tone(@element)}
          variant={theme_variant(@element)}
          state={style_state(@element)}
          class={style_class(@element)}
          {@style_attrs}
        />
      </form>
    <% else %>
      <LiveUi.Widgets.TextInput.component
        id={element_id(@element, "input")}
        name={binding_name(@element)}
        value={binding_value(@element)}
        placeholder={string_optional(get_in(@element.attributes, [:input, :placeholder]))}
        input_type={input_type(@element.kind)}
        tone={style_tone(@element)}
        variant={theme_variant(@element)}
        state={style_state(@element)}
        class={style_class(@element)}
        {@style_attrs}
      />
    <% end %>
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:toggle, :checkbox] do
    assigns =
      assign(assigns, :change_interaction, primary_control_interaction(assigns.element))

    ~H"""
    <%= if @change_interaction && @event_target do %>
      <form
        id={interaction_form_id(@element, "toggle")}
        data-live-ui-interaction-form="true"
        phx-change="canonical_interaction"
        phx-target={@event_target}
      >
        <input type="hidden" name="interaction" value={encode_interaction(@change_interaction)} />
        <input type="hidden" name="element_id" value={element_id(@element, "element")} />
        <input type="hidden" name="widget" value={to_string(@element.kind)} />
        <LiveUi.Widgets.Toggle.component
          id={element_id(@element, "toggle")}
          name={binding_name(@element)}
          checked={boolean_default(binding_value(@element), false)}
          tone={style_tone(@element)}
          variant={theme_variant(@element)}
          state={style_state(@element)}
          class={style_class(@element)}
        />
      </form>
    <% else %>
      <LiveUi.Widgets.Toggle.component
        id={element_id(@element, "toggle")}
        name={binding_name(@element)}
        checked={boolean_default(binding_value(@element), false)}
        tone={style_tone(@element)}
        variant={theme_variant(@element)}
        state={style_state(@element)}
        class={style_class(@element)}
      />
    <% end %>
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:select, :pick_list, :radio_group] do
    assigns =
      assign(assigns, :change_interaction, primary_control_interaction(assigns.element))

    ~H"""
    <%= if @change_interaction && @event_target do %>
      <form
        id={interaction_form_id(@element, "select")}
        data-live-ui-interaction-form="true"
        phx-change="canonical_interaction"
        phx-target={@event_target}
      >
        <input type="hidden" name="interaction" value={encode_interaction(@change_interaction)} />
        <input type="hidden" name="element_id" value={element_id(@element, "element")} />
        <input type="hidden" name="widget" value={to_string(@element.kind)} />
        <LiveUi.Widgets.Select.component
          id={element_id(@element, "select")}
          name={binding_name(@element)}
          options={selection_options(@element)}
          multiple={selection_multiple?(@element, @element.kind)}
          tone={style_tone(@element)}
          variant={theme_variant(@element)}
          state={style_state(@element)}
          class={style_class(@element)}
        />
      </form>
    <% else %>
      <LiveUi.Widgets.Select.component
        id={element_id(@element, "select")}
        name={binding_name(@element)}
        options={selection_options(@element)}
        multiple={selection_multiple?(@element, @element.kind)}
        tone={style_tone(@element)}
        variant={theme_variant(@element)}
        state={style_state(@element)}
        class={style_class(@element)}
      />
    <% end %>
    """
  end

  def render(%{element: %Element{kind: :menu}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Menu.component
      id={element_id(@element, "menu")}
      items={navigation_items(@element, @event_target)}
      active_item={string_optional(get_in(@element.attributes, [:navigation, :active_item]))}
      orientation={string_value(get_in(@element.attributes, [:navigation, :orientation]), "vertical")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :tabs}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Tabs.component
      id={element_id(@element, "tabs")}
      items={navigation_items(@element, @event_target)}
      active_item={string_optional(get_in(@element.attributes, [:navigation, :active_item]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :command_palette}} = assigns) do
    assigns =
      assigns
      |> assign(
        :input_attrs,
        direct_change_interaction_attrs(assigns.element, Map.get(assigns, :event_target))
      )
      |> assign(
        :palette_items,
        command_palette_items(assigns.element, Map.get(assigns, :event_target))
      )

    ~H"""
    <LiveUi.Widgets.CommandPalette.component
      id={element_id(@element, "command-palette")}
      query={string_optional(get_in(@element.attributes, [:command_palette, :query]))}
      items={@palette_items}
      input_attrs={@input_attrs}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :list}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.List.component
      id={element_id(@element, "list")}
      items={list_items(@element, @event_target)}
      ordered={boolean_default(get_in(@element.attributes, [:list, :ordered?]), false)}
      selection_mode={string_value(get_in(@element.attributes, [:list, :selection_mode]), "single")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :disclosure}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Disclosure.component
      id={element_id(@element, "disclosure")}
      label={string_value(get_in(@element.attributes, [:disclosure, :label]), "")}
      open={boolean_default(get_in(@element.attributes, [:disclosure, :open?]), false)}
      content_label={string_optional(get_in(@element.attributes, [:disclosure, :content_label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :kicker}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Kicker.component
      id={element_id(@element, "kicker")}
      value={string_value(get_in(@element.attributes, [:kicker, :value]), "")}
      icon={string_optional(get_in(@element.attributes, [:kicker, :icon]))}
      role={string_value(get_in(@element.attributes, [:kicker, :role]), "eyebrow")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :avatar}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Avatar.component
      id={element_id(@element, "avatar")}
      label={string_value(get_in(@element.attributes, [:avatar, :label]), "")}
      initials={string_optional(get_in(@element.attributes, [:avatar, :initials]))}
      src={string_optional(get_in(@element.attributes, [:avatar, :source]))}
      status={string_optional(get_in(@element.attributes, [:avatar, :status]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :presence_dot}} = assigns) do
    ~H"""
    <LiveUi.Widgets.PresenceDot.component
      id={element_id(@element, "presence-dot")}
      status={string_value(get_in(@element.attributes, [:presence, :status]), "unknown")}
      label={string_optional(get_in(@element.attributes, [:presence, :label]))}
      pulse={boolean_default(get_in(@element.attributes, [:presence, :pulse?]), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :segmented_button_group}} = assigns) do
    assigns =
      assign(
        assigns,
        :interaction_attrs,
        interaction_event_attrs(assigns.element, Map.get(assigns, :event_target))
      )

    ~H"""
    <LiveUi.Widgets.SegmentedButtonGroup.component
      id={element_id(@element, "segmented-button-group")}
      items={get_in(@element.attributes, [:segments, :items]) || []}
      active_item={get_in(@element.attributes, [:segments, :active_item])}
      selection_mode={string_value(get_in(@element.attributes, [:segments, :selection_mode]), "single")}
      orientation={string_value(get_in(@element.attributes, [:segments, :orientation]), "horizontal")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@interaction_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :list_item_multi_column}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ListItemMultiColumn.component
      id={element_id(@element, "list-item-multi-column")}
      label={string_optional(get_in(@element.attributes, [:list_item, :label]))}
      columns={get_in(@element.attributes, [:list_item, :columns]) || []}
      value={get_in(@element.attributes, [:list_item, :value])}
      status={string_optional(get_in(@element.attributes, [:list_item, :status]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :artifact_row}} = assigns) do
    interaction_attrs = interaction_event_attrs(assigns.element, Map.get(assigns, :event_target))

    assigns =
      assign(
        assigns,
        :style_attrs,
        merge_global_attrs(style_rest(assigns.element), interaction_attrs)
      )

    ~H"""
    <LiveUi.Widgets.ArtifactRow.component
      id={element_id(@element, "artifact-row")}
      title={string_value(get_in(@element.attributes, [:artifact, :title]), "")}
      artifact={get_in(@element.attributes, [:artifact, :value])}
      status={string_optional(get_in(@element.attributes, [:artifact, :status]))}
      timestamp={string_optional(get_in(@element.attributes, [:artifact, :timestamp]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :sticky_header}} = assigns) do
    ~H"""
    <LiveUi.Widgets.StickyHeader.component
      id={element_id(@element, "sticky-header")}
      title={string_value(get_in(@element.attributes, [:sticky_header, :title]), "")}
      stuck={boolean_default(get_in(@element.attributes, [:sticky_header, :stuck?]), false)}
      elevation={string_optional(get_in(@element.attributes, [:sticky_header, :elevation]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :pipeline_stepper_horizontal}} = assigns) do
    ~H"""
    <LiveUi.Widgets.PipelineStepperHorizontal.component
      id={element_id(@element, "pipeline-stepper-horizontal")}
      steps={get_in(@element.attributes, [:workflow, :steps]) || []}
      active_item={get_in(@element.attributes, [:workflow, :active_item])}
      status={string_optional(get_in(@element.attributes, [:workflow, :status]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :segmented_progress_bar}} = assigns) do
    ~H"""
    <LiveUi.Widgets.SegmentedProgressBar.component
      id={element_id(@element, "segmented-progress-bar")}
      segments={get_in(@element.attributes, [:progress, :segments]) || []}
      current={integer_value(get_in(@element.attributes, [:progress, :current]), 0)}
      maximum={integer_value(get_in(@element.attributes, [:progress, :maximum]), 100)}
      label={string_optional(get_in(@element.attributes, [:progress, :label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :workflow_stage_list_vertical}} = assigns) do
    ~H"""
    <LiveUi.Widgets.WorkflowStageListVertical.component
      id={element_id(@element, "workflow-stage-list-vertical")}
      stages={get_in(@element.attributes, [:workflow, :stages]) || []}
      active_item={get_in(@element.attributes, [:workflow, :active_item])}
      status={string_optional(get_in(@element.attributes, [:workflow, :status]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :meter_thin}} = assigns) do
    ~H"""
    <LiveUi.Widgets.MeterThin.component
      id={element_id(@element, "meter-thin")}
      current={integer_value(get_in(@element.attributes, [:meter, :current]), 0)}
      minimum={integer_value(get_in(@element.attributes, [:meter, :minimum]), 0)}
      maximum={integer_value(get_in(@element.attributes, [:meter, :maximum]), 100)}
      label={string_optional(get_in(@element.attributes, [:meter, :label]))}
      severity={string_optional(get_in(@element.attributes, [:meter, :severity]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :slide_over_panel}} = assigns) do
    ~H"""
    <LiveUi.Widgets.SlideOverPanel.component
      id={element_id(@element, "slide-over-panel")}
      title={string_optional(get_in(@element.attributes, [:panel, :title]))}
      placement={placement_value(get_in(@element.attributes, [:panel, :placement]), "end")}
      visible={boolean_default(get_in(@element.attributes, [:panel, :visible?]), false)}
      modal={boolean_default(get_in(@element.attributes, [:panel, :modal?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.SlideOverPanel.component>
    """
  end

  def render(%{element: %Element{kind: :event_callout}} = assigns) do
    ~H"""
    <LiveUi.Widgets.EventCallout.component
      id={element_id(@element, "event-callout")}
      title={string_optional(get_in(@element.attributes, [:callout, :title]))}
      message={string_value(get_in(@element.attributes, [:callout, :message]), "")}
      severity={string_value(get_in(@element.attributes, [:callout, :severity]), "info")}
      timestamp={string_optional(get_in(@element.attributes, [:callout, :timestamp]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :redline_inline}} = assigns) do
    ~H"""
    <LiveUi.Widgets.RedlineInline.component
      id={element_id(@element, "redline-inline")}
      before_text={string_value(get_in(@element.attributes, [:redline, :before_text]), "")}
      after_text={string_value(get_in(@element.attributes, [:redline, :after_text]), "")}
      label={string_optional(get_in(@element.attributes, [:redline, :label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :code_block_syntax_highlighted}} = assigns) do
    ~H"""
    <LiveUi.Widgets.CodeBlockSyntaxHighlighted.component
      id={element_id(@element, "code-block-syntax-highlighted")}
      code={string_value(get_in(@element.attributes, [:code_block, :code]), "")}
      language={string_optional(get_in(@element.attributes, [:code_block, :language]))}
      label={string_optional(get_in(@element.attributes, [:code_block, :label]))}
      wrap={boolean_default(get_in(@element.attributes, [:code_block, :wrap?]), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :chat_composer}} = assigns) do
    assigns =
      assign(
        assigns,
        :form_interaction_attrs,
        form_interaction_attrs(assigns.element, Map.get(assigns, :event_target))
      )

    ~H"""
    <LiveUi.Widgets.ChatComposer.component
      id={element_id(@element, "chat-composer")}
      placeholder={string_optional(get_in(@element.attributes, [:composer, :placeholder]))}
      submit_intent={string_optional(get_in(@element.attributes, [:composer, :submit_intent]))}
      actions={get_in(@element.attributes, [:composer, :actions]) || []}
      multiline={boolean_default(get_in(@element.attributes, [:composer, :multiline?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@form_interaction_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :repeated_collection}} = assigns) do
    assigns =
      assigns
      |> assign(:collection_rows, collection_rows(assigns.element))
      |> assign(:empty_children, child_elements(assigns.element, :empty_state))

    ~H"""
    <section
      id={element_id(@element, "repeated-collection")}
      data-live-ui-widget="repeated-collection"
      data-live-ui-item-alias={string_optional(get_in(@element.attributes, [:collection, :item_alias]))}
      data-live-ui-index-alias={string_optional(get_in(@element.attributes, [:collection, :index_alias]))}
      data-live-ui-key-path={key_path_text(get_in(@element.attributes, [:collection, :key_path]))}
      data-live-ui-tone={style_tone(@element)}
      data-live-ui-variant={theme_variant(@element)}
      data-live-ui-state={style_state(@element)}
      class={style_class(@element)}
    >
      <%= if @collection_rows == [] do %>
        <div data-live-ui-collection-slot="empty">
          <%= for child <- @empty_children do %>
            <.render element={child} event_target={@event_target} />
          <% end %>
        </div>
      <% else %>
        <div
          :for={row <- @collection_rows}
          data-live-ui-collection-row={row.key}
          data-live-ui-row-index={row.index}
        >
          <.render element={row.element} event_target={@event_target} />
        </div>
      <% end %>
    </section>
    """
  end

  def render(%{element: %Element{kind: :table}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Table.component
      id={element_id(@element, "table")}
      columns={get_in(@element.attributes, [:table, :columns]) || []}
      rows={table_rows(@element, @event_target)}
      dense={boolean_default(get_in(@element.attributes, [:table, :dense?]), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :tree_view}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.TreeView.component
      id={element_id(@element, "tree-view")}
      nodes={tree_nodes(@element, @event_target)}
      selection_mode={string_value(get_in(@element.attributes, [:tree, :selection_mode]), "single")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :status}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Status.component
      id={element_id(@element, "status")}
      text={string_value(get_in(@element.attributes, [:feedback, :text]), "")}
      severity={string_value(get_in(@element.attributes, [:feedback, :severity]), "info")}
      status={string_value(get_in(@element.attributes, [:feedback, :status]), "idle")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :progress}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Progress.component
      id={element_id(@element, "progress")}
      current={integer_value(get_in(@element.attributes, [:progress, :current]), 0)}
      total={integer_value(get_in(@element.attributes, [:progress, :total]), 100)}
      indeterminate={boolean_default(get_in(@element.attributes, [:progress, :indeterminate?]), false)}
      label={string_optional(get_in(@element.attributes, [:progress, :label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :gauge}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Gauge.component
      id={element_id(@element, "gauge")}
      value={integer_value(get_in(@element.attributes, [:gauge, :value]), 0)}
      min={integer_value(get_in(@element.attributes, [:gauge, :min]), 0)}
      max={integer_value(get_in(@element.attributes, [:gauge, :max]), 100)}
      label={string_optional(get_in(@element.attributes, [:gauge, :label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :inline_feedback}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.InlineFeedback.component
      id={element_id(@element, "inline-feedback")}
      message={string_value(get_in(@element.attributes, [:feedback, :message]), "")}
      title={string_optional(get_in(@element.attributes, [:feedback, :title]))}
      severity={string_value(get_in(@element.attributes, [:feedback, :severity]), "info")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :markdown_viewer}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.MarkdownViewer.component
      id={element_id(@element, "markdown-viewer")}
      source={string_value(get_in(@element.attributes, [:document, :source]), "")}
      mode={string_value(get_in(@element.attributes, [:document, :mode]), "rendered")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :log_viewer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.LogViewer.component
      id={element_id(@element, "log-viewer")}
      entries={get_in(@element.attributes, [:logs, :entries]) || []}
      wrap={boolean_default(get_in(@element.attributes, [:logs, :wrap?]), true)}
      show_timestamps={boolean_default(get_in(@element.attributes, [:logs, :show_timestamps?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :stream_widget}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.StreamWidget.component
      id={element_id(@element, "stream-widget")}
      entries={get_in(@element.attributes, [:stream, :entries]) || []}
      ordering={string_value(get_in(@element.attributes, [:stream, :ordering]), "append_only")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :process_monitor}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ProcessMonitor.component
      id={element_id(@element, "process-monitor")}
      processes={get_in(@element.attributes, [:monitor, :processes]) || []}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :cluster_dashboard}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.ClusterDashboard.component
      id={element_id(@element, "cluster-dashboard")}
      nodes={get_in(@element.attributes, [:cluster, :nodes]) || []}
      summary={get_in(@element.attributes, [:cluster, :summary]) || %{}}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :supervision_tree_viewer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.SupervisionTreeViewer.component
      id={element_id(@element, "supervision-tree-viewer")}
      nodes={get_in(@element.attributes, [:inspection, :nodes]) || []}
      expanded={boolean_default(get_in(@element.attributes, [:inspection, :expanded?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :sparkline}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Sparkline.component
      id={element_id(@element, "sparkline")}
      series={chart_values(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :bar_chart}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.BarChart.component
      id={element_id(@element, "bar-chart")}
      series={get_in(@element.attributes, [:chart, :series]) || []}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :line_chart}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.LineChart.component
      id={element_id(@element, "line-chart")}
      series={get_in(@element.attributes, [:chart, :series]) || []}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(%{element: %Element{kind: :dialog}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Dialog.component
      id={element_id(@element, "dialog")}
      title={string_optional(get_in(@element.attributes, [:dialog, :title]))}
      modal={boolean_default(get_in(@element.attributes, [:dialog, :modal?]), true)}
      dismissible={boolean_default(get_in(@element.attributes, [:dialog, :dismissible?]), true)}
      size={string_value(get_in(@element.attributes, [:dialog, :size]), "md")}
      background_fill={string_value(get_in(@element.attributes, [:dialog, :background_fill]), "scrim")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.Dialog.component>
    """
  end

  def render(%{element: %Element{kind: :alert_dialog}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.AlertDialog.component
      id={element_id(@element, "alert-dialog")}
      title={string_optional(get_in(@element.attributes, [:alert_dialog, :title]))}
      severity={string_value(get_in(@element.attributes, [:alert_dialog, :severity]), "warning")}
      requires_confirmation={boolean_default(get_in(@element.attributes, [:alert_dialog, :requires_confirmation?]), true)}
      background_fill={string_value(get_in(@element.attributes, [:alert_dialog, :background_fill]), "scrim")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.AlertDialog.component>
    """
  end

  def render(%{element: %Element{kind: :toast}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Toast.component
      id={element_id(@element, "toast")}
      placement={placement_value(get_in(@element.attributes, [:toast, :placement]), "top-end")}
      duration_ms={integer_value(get_in(@element.attributes, [:toast, :duration_ms]), 5000)}
      severity={string_value(get_in(@element.attributes, [:toast, :severity]), "info")}
      transient={boolean_default(get_in(@element.attributes, [:toast, :transient?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.Toast.component>
    """
  end

  def render(%{element: %Element{kind: :context_menu}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ContextMenu.component
      id={element_id(@element, "context-menu")}
      items={context_menu_items(@element, @event_target)}
      placement={placement_value(get_in(@element.attributes, [:context_menu, :placement]), "bottom-start")}
      anchor={get_in(@element.attributes, [:context_menu, :anchor]) || %{}}
      active_item={string_optional(get_in(@element.attributes, [:context_menu, :active_item]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :overlay}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.OverlaySurface.component
      id={element_id(@element, "overlay-surface")}
      mode={string_value(get_in(@element.attributes, [:overlay, :mode]), "stacked")}
      background_fill={string_value(get_in(@element.attributes, [:overlay, :background_fill]), "transparent")}
      dismissible={boolean_default(get_in(@element.attributes, [:overlay, :dismissible?]), false)}
      focus_scope={string_optional(get_in(@element.attributes, [:overlay, :focus_scope]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <:base :for={child <- child_elements(@element, :base)}>
        <.render element={child} event_target={@event_target} />
      </:base>
      <:overlay :for={child <- overlay_children(@element)}>
        <.render element={child} event_target={@event_target} />
      </:overlay>
    </LiveUi.Widgets.OverlaySurface.component>
    """
  end

  def render(%{element: %Element{kind: :viewport}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Viewport.component
      id={element_id(@element, "viewport")}
      axis={string_value(get_in(@element.attributes, [:viewport, :axis]), "vertical")}
      offset_x={integer_value(get_in(@element.attributes, [:viewport, :offset, :x]), 0)}
      offset_y={integer_value(get_in(@element.attributes, [:viewport, :offset, :y]), 0)}
      clip={boolean_default(get_in(@element.attributes, [:viewport, :clip?]), true)}
      scrollbars={string_value(get_in(@element.attributes, [:viewport, :scrollbars]), "auto")}
      width={string_optional(get_in(@element.attributes, [:viewport, :width]))}
      height={string_optional(get_in(@element.attributes, [:viewport, :height]))}
      sync_group={string_optional(get_in(@element.attributes, [:viewport, :sync_group]))}
      independent_scroll={boolean_default(get_in(@element.attributes, [:viewport, :independent_scroll?]), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} event_target={@event_target} />
      <% end %>
    </LiveUi.Widgets.Viewport.component>
    """
  end

  def render(%{element: %Element{kind: :scroll_bar}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ScrollBar.component
      id={element_id(@element, "scroll-bar")}
      orientation={string_value(get_in(@element.attributes, [:scroll_bar, :orientation]), "vertical")}
      position_start={float_value(get_in(@element.attributes, [:scroll_bar, :position, :start]), 0.0)}
      position_end={float_value(get_in(@element.attributes, [:scroll_bar, :position, :end]), 0.0)}
      viewport_size={integer_optional(get_in(@element.attributes, [:scroll_bar, :viewport_size]))}
      content_size={integer_optional(get_in(@element.attributes, [:scroll_bar, :content_size]))}
      viewport_ref={string_optional(get_in(@element.attributes, [:scroll_bar, :viewport_ref]))}
      sync_group={string_optional(get_in(@element.attributes, [:scroll_bar, :sync_group]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :split_pane}} = assigns) do
    ~H"""
    <LiveUi.Widgets.SplitPane.component
      id={element_id(@element, "split-pane")}
      direction={string_value(get_in(@element.attributes, [:split, :direction]), "horizontal")}
      ratio={float_value(get_in(@element.attributes, [:split, :ratio]), 0.5)}
      resizable={boolean_default(get_in(@element.attributes, [:split, :resizable?]), true)}
      min_primary={integer_optional(get_in(@element.attributes, [:split, :min_primary]))}
      min_secondary={integer_optional(get_in(@element.attributes, [:split, :min_secondary]))}
      divider_size={integer_optional(get_in(@element.attributes, [:split, :divider, :size]))}
      sync_scroll={string_optional(get_in(@element.attributes, [:split, :sync_scroll]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
    >
      <:primary :for={child <- child_elements(@element, :primary)}>
        <.render element={child} event_target={@event_target} />
      </:primary>
      <:secondary :for={child <- child_elements(@element, :secondary)}>
        <.render element={child} event_target={@event_target} />
      </:secondary>
    </LiveUi.Widgets.SplitPane.component>
    """
  end

  def render(%{element: %Element{kind: :canvas}} = assigns) do
    assigns = assign(assigns, :style_attrs, style_rest(assigns.element))

    ~H"""
    <LiveUi.Widgets.Canvas.component
      id={element_id(@element, "canvas")}
      operations={get_in(@element.attributes, [:canvas, :operations]) || []}
      width={integer_optional(get_in(@element.attributes, [:canvas, :width]))}
      height={integer_optional(get_in(@element.attributes, [:canvas, :height]))}
      unit={string_value(get_in(@element.attributes, [:canvas, :unit]), "cell")}
      background={string_optional(get_in(@element.attributes, [:canvas, :background]))}
      clip={boolean_default(get_in(@element.attributes, [:canvas, :clip?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
      state={style_state(@element)}
      class={style_class(@element)}
      {@style_attrs}
    />
    """
  end

  def render(assigns) do
    ~H"""
    <div id={element_id(@element, "unsupported")} data-live-ui-widget="unsupported" data-live-ui-kind={to_string(@element.kind)}>
      Unsupported canonical kind: <%= inspect(@element.kind) %>
    </div>
    """
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__

  defp child_elements(%Element{} = element, slot \\ :default) do
    element
    |> Element.children_for_slot(slot)
    |> Enum.map(& &1.element)
    |> Enum.reject(&is_nil/1)
  end

  defp layout_children(%Element{} = element) do
    element.children
    |> Enum.map(& &1.element)
    |> Enum.reject(&is_nil/1)
  end

  defp overlay_children(%Element{} = element) do
    element.children
    |> Enum.reject(&(&1.slot == :base))
    |> Enum.map(& &1.element)
    |> Enum.reject(&is_nil/1)
  end

  defp binding_name(%Element{} = element) do
    element
    |> primary_binding()
    |> case do
      %Binding{name: nil, path: [segment | _]} -> to_string(segment)
      %Binding{name: name} when not is_nil(name) -> to_string(name)
      _ -> element_id(element, "binding")
    end
  end

  defp binding_value(%Element{} = element) do
    case primary_binding(element) do
      %Binding{value: nil, default: default} -> default
      %Binding{value: value} -> value
      _ -> nil
    end
  end

  defp primary_binding(%Element{} = element) do
    element.attributes
    |> Map.get(:bindings, [])
    |> List.wrap()
    |> List.first()
  end

  defp primary_interaction(%Element{} = element, family) do
    element.attributes
    |> Map.get(:interactions, [])
    |> List.wrap()
    |> Enum.find(&match?(%Interaction{family: ^family}, &1))
  end

  defp interaction_event_attrs(%Element{} = element, event_target) do
    case {primary_action_interaction(element), event_target} do
      {%Interaction{} = interaction, target} when not is_nil(target) ->
        [
          {:"phx-click", "canonical_interaction"},
          {:"phx-target", target},
          {:"phx-value-interaction", encode_interaction(interaction)},
          {:"phx-value-element_id", element_id(element, "element")},
          {:"phx-value-widget", to_string(element.kind)}
        ]

      _ ->
        []
    end
  end

  defp primary_change_interaction(%Element{} = element) do
    primary_interaction(element, :change)
  end

  defp direct_change_interaction_attrs(%Element{} = element, event_target) do
    case {primary_change_interaction(element), event_target} do
      {%Interaction{} = interaction, target} when not is_nil(target) ->
        %{
          :"phx-input" => "canonical_change_interaction",
          :"phx-change" => "canonical_change_interaction",
          :"phx-target" => target,
          :"phx-value-change-interaction" => encode_interaction(interaction),
          :"phx-value-element_id" => element_id(element, Atom.to_string(element.kind)),
          :"phx-value-widget" => Atom.to_string(element.kind)
        }

      _ ->
        %{}
    end
  end

  defp encode_interaction(%Interaction{} = interaction) do
    interaction
    |> :erlang.term_to_binary()
    |> Base.url_encode64(padding: false)
  end

  defp selection_options(%Element{} = element) do
    element.attributes
    |> get_in([:selection, :options])
    |> List.wrap()
    |> Enum.map(fn option ->
      %{
        id: Map.get(option, :id) || Map.get(option, "id"),
        value: Map.get(option, :value) || Map.get(option, "value"),
        label: Map.get(option, :label) || Map.get(option, "label"),
        disabled: Map.get(option, :disabled?) || Map.get(option, "disabled?"),
        selected: Map.get(option, :selected?) || Map.get(option, "selected?")
      }
    end)
  end

  defp selection_multiple?(%Element{} = element, kind) do
    case kind do
      :radio_group -> false
      _ -> boolean_default(get_in(element.attributes, [:selection, :multiple?]), false)
    end
  end

  defp list_items(%Element{} = element, event_target) do
    element
    |> get_in([Access.key(:attributes), :list, :items])
    |> List.wrap()
    |> Enum.map(&normalize_list_item(&1, element, event_target))
  end

  defp navigation_items(%Element{} = element, event_target) do
    element
    |> get_in([Access.key(:attributes), :navigation, :items])
    |> List.wrap()
    |> Enum.map(&normalize_navigation_item(&1, element, event_target))
  end

  defp command_palette_items(%Element{} = element, event_target) do
    active_command = get_in(element.attributes, [:command_palette, :active_command])

    element
    |> get_in([Access.key(:attributes), :command_palette, :commands])
    |> List.wrap()
    |> Enum.map(fn command ->
      command = Map.new(command)
      command_id = Map.get(command, :id) || Map.get(command, "id")

      command
      |> Map.put(:active, command_id == active_command)
      |> maybe_put_item_attrs(collection_item_attrs(element, event_target, command_id))
    end)
  end

  defp context_menu_items(%Element{} = element, event_target) do
    element
    |> child_elements(:menu)
    |> List.first()
    |> case do
      %Element{} = menu ->
        menu
        |> get_in([Access.key(:attributes), :navigation, :items])
        |> List.wrap()
        |> Enum.map(&normalize_navigation_item(&1, element, event_target))

      _ ->
        []
    end
  end

  defp table_rows(%Element{} = element, event_target) do
    element
    |> get_in([Access.key(:attributes), :table, :rows])
    |> List.wrap()
    |> Enum.map(&normalize_table_row(&1, element, event_target))
  end

  defp tree_nodes(%Element{} = element, event_target) do
    element
    |> get_in([Access.key(:attributes), :tree, :nodes])
    |> List.wrap()
    |> Enum.map(&normalize_tree_node(&1, element, event_target))
  end

  defp chart_values(%Element{} = element) do
    case get_in(element.attributes, [:chart, :series]) || [] do
      [series | _] -> Map.get(series, :values) || Map.get(series, "values") || []
      _ -> []
    end
  end

  defp collection_rows(%Element{} = element) do
    template = element |> child_elements(:template) |> List.first()
    source = get_in(element.attributes, [:collection, :source])
    item_alias = get_in(element.attributes, [:collection, :item_alias]) || :item
    index_alias = get_in(element.attributes, [:collection, :index_alias]) || :index
    key_path = get_in(element.attributes, [:collection, :key_path]) || []

    case {template, collection_source_items(source)} do
      {%Element{} = template, items} when is_list(items) ->
        items
        |> Enum.with_index()
        |> Enum.map(fn {item, index} ->
          key = collection_row_key(item, key_path, index)

          %{
            key: key,
            index: index,
            item: item,
            element:
              resolve_row_scope(template, %{
                item: item,
                index: index,
                item_alias: item_alias,
                index_alias: index_alias,
                key: key
              })
          }
        end)

      _other ->
        []
    end
  end

  defp collection_source_items(%Binding{value: value}) when is_list(value), do: value
  defp collection_source_items(_source), do: []

  defp collection_row_key(item, key_path, index) do
    case value_at_path(item, key_path) do
      nil -> Integer.to_string(index)
      value -> to_string(value)
    end
  end

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

  defp resolve_row_scope(values, context) when is_list(values) do
    Enum.map(values, &resolve_row_scope(&1, context))
  end

  defp resolve_row_scope(values, context) when is_map(values) do
    Map.new(values, fn {key, value} -> {key, resolve_row_scope(value, context)} end)
  end

  defp resolve_row_scope(value, _context), do: value

  defp row_scoped_id(nil, key), do: "row-template-#{key}"
  defp row_scoped_id(id, key), do: "#{id}-#{key}"

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

  defp fetch_path_segment(current, segment) when is_map(current) do
    cond do
      Map.has_key?(current, segment) -> {:ok, Map.fetch!(current, segment)}
      Map.has_key?(current, to_string(segment)) -> {:ok, Map.fetch!(current, to_string(segment))}
      true -> :error
    end
  end

  defp fetch_path_segment(_current, _segment), do: :error

  defp key_path_text(path) when is_list(path) do
    path
    |> Enum.map(&to_string/1)
    |> Enum.join(".")
  end

  defp key_path_text(nil), do: ""
  defp key_path_text(path), do: to_string(path)

  defp theme_variant(%Element{} = element), do: element |> style_profile() |> Map.get(:variant)
  defp style_tone(%Element{} = element), do: element |> style_profile() |> Map.get(:tone)
  defp style_state(%Element{} = element), do: element |> style_profile() |> Map.get(:state)
  defp style_class(%Element{} = element), do: element |> style_profile() |> Map.get(:class)

  defp style_rest(%Element{} = element),
    do: element |> style_profile() |> NativeStyle.to_assigns() |> Map.get(:rest, %{})

  defp style_profile(%Element{} = element) do
    NativeStyle.from_element(element)
  end

  defp merge_global_attrs(left, right) do
    normalize_global_attrs(left)
    |> Map.merge(normalize_global_attrs(right), fn
      "style", left_value, right_value -> merge_inline_styles(left_value, right_value)
      _key, _left_value, right_value -> right_value
    end)
  end

  defp normalize_global_attrs(attrs) when is_list(attrs) do
    Map.new(attrs, fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  defp normalize_global_attrs(attrs) when is_map(attrs) do
    Map.new(attrs, fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  defp normalize_global_attrs(_other), do: %{}

  defp merge_inline_styles(left, right) do
    [left, right]
    |> Enum.map(&normalize_optional_style/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("; ")
    |> normalize_optional_style()
  end

  defp normalize_optional_style(nil), do: nil
  defp normalize_optional_style(""), do: nil
  defp normalize_optional_style(value), do: value |> to_string() |> String.trim()

  defp accessibility_attrs(%Element{} = element) do
    accessibility = Map.get(element.attributes, :accessibility, %{})

    []
    |> maybe_attr(:role, accessibility[:role] || accessibility["role"])
    |> maybe_attr(:"aria-label", accessibility[:label] || accessibility["label"])
    |> maybe_attr(
      :"aria-labelledby",
      accessibility[:labelled_by] || accessibility["labelled_by"]
    )
    |> maybe_attr(
      :"aria-describedby",
      accessibility[:described_by] || accessibility["described_by"]
    )
    |> maybe_attr(:"aria-live", accessibility[:live] || accessibility["live"])
    |> maybe_attr(:"aria-atomic", boolean_attr(accessibility[:atomic] || accessibility["atomic"]))
  end

  defp content_text(%Element{} = element) do
    string_value(get_in(element.attributes, [:content, :text]), "")
  end

  defp label_for(%Element{} = element) do
    string_optional(get_in(element.attributes, [:label, :for]))
  end

  defp input_type(:text_input), do: "text"
  defp input_type(:numeric_input), do: "number"
  defp input_type(:date_input), do: "date"
  defp input_type(:time_input), do: "time"
  defp input_type(:file_input), do: "file"

  defp element_id(%Element{id: nil}, fallback), do: fallback
  defp element_id(%Element{id: id}, _fallback), do: to_string(id)

  defp string_value(nil, default), do: default
  defp string_value(value, _default), do: to_string(value)

  defp string_optional(nil), do: nil
  defp string_optional(value), do: to_string(value)

  defp boolean_attr(true), do: "true"
  defp boolean_attr(false), do: "false"
  defp boolean_attr(nil), do: nil

  defp placement_value(nil, default), do: default

  defp placement_value(value, _default) do
    value
    |> to_string()
    |> String.replace("_", "-")
  end

  defp integer_optional(nil), do: nil
  defp integer_optional(value) when is_integer(value), do: value
  defp integer_optional(value) when is_float(value), do: trunc(value)
  defp integer_optional(value) when is_binary(value), do: String.to_integer(value)

  defp integer_value(nil, default), do: default
  defp integer_value(value, _default) when is_integer(value), do: value
  defp integer_value(value, _default) when is_float(value), do: trunc(value)
  defp integer_value(value, _default) when is_binary(value), do: String.to_integer(value)

  defp float_value(nil, default), do: default
  defp float_value(value, _default) when is_float(value), do: value
  defp float_value(value, _default) when is_integer(value), do: value / 1

  defp float_value(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _ -> default
    end
  end

  defp boolean_default(nil, default), do: default
  defp boolean_default(value, _default) when is_boolean(value), do: value
  defp boolean_default("true", _default), do: true
  defp boolean_default("false", _default), do: false
  defp boolean_default(value, _default), do: value

  defp state_boolean(%Element{} = element, path) when is_list(path) do
    boolean_default(get_in(element.attributes, path), false)
  end

  defp state_boolean(%Element{} = element, key) do
    boolean_default(get_in(element.attributes, [:state, key]), false)
  end

  defp form_interaction_attrs(%Element{} = element, event_target) do
    case event_target do
      target when is_binary(target) ->
        %{}
        |> maybe_merge_form_interaction(
          primary_control_interaction(element),
          element,
          target,
          :"phx-change",
          "canonical_change_interaction",
          :"phx-value-change-interaction"
        )
        |> maybe_merge_form_interaction(
          primary_submit_interaction(element),
          element,
          target,
          :"phx-submit",
          "canonical_submit_interaction",
          :"phx-value-submit-interaction"
        )

      _other ->
        %{}
    end
  end

  defp maybe_merge_form_interaction(
         attrs,
         %Interaction{} = interaction,
         %Element{} = element,
         target,
         event_attr,
         event_name,
         value_attr
       ) do
    Map.merge(attrs, %{
      event_attr => event_name,
      :"phx-target" => target,
      value_attr => encode_interaction(interaction),
      :"phx-value-widget" => Atom.to_string(element.kind),
      :"phx-value-element_id" => element_id(element, Atom.to_string(element.kind))
    })
  end

  defp maybe_merge_form_interaction(
         attrs,
         nil,
         _element,
         _target,
         _event_attr,
         _event_name,
         _value_attr
       ),
       do: attrs

  defp maybe_attr(attrs, _key, nil), do: attrs
  defp maybe_attr(attrs, _key, ""), do: attrs
  defp maybe_attr(attrs, key, value), do: [{key, value} | attrs]

  defp primary_action_interaction(%Element{} = element) do
    primary_interaction(element, :click) ||
      primary_interaction(element, :navigation) ||
      primary_interaction(element, :command)
  end

  defp primary_collection_interaction(%Element{} = element) do
    primary_interaction(element, :selection) ||
      primary_interaction(element, :click) ||
      primary_interaction(element, :navigation) ||
      primary_interaction(element, :command)
  end

  defp collection_item_attrs(%Element{} = element, event_target, item_id) do
    case {primary_collection_interaction(element), event_target, item_id} do
      {%Interaction{} = interaction, target, id} when not is_nil(target) and not is_nil(id) ->
        %{
          :"phx-click" => "canonical_interaction",
          :"phx-target" => target,
          :"phx-value-interaction" => encode_interaction(interaction),
          :"phx-value-element_id" => element_id(element, Atom.to_string(element.kind)),
          :"phx-value-widget" => Atom.to_string(element.kind),
          :"phx-value-item_id" => to_string(id)
        }

      _ ->
        %{}
    end
  end

  defp normalize_navigation_item(item, source_element, event_target) do
    item = Map.new(item)
    item_id = Map.get(item, :id) || Map.get(item, "id")

    item
    |> Map.put(:disabled, Map.get(item, :disabled, Map.get(item, :disabled?)))
    |> Map.put(:active, Map.get(item, :active, Map.get(item, :active?)))
    |> maybe_put_item_attrs(collection_item_attrs(source_element, event_target, item_id))
  end

  defp normalize_list_item(item, source_element, event_target) do
    item = Map.new(item)
    item_id = Map.get(item, :id) || Map.get(item, "id")

    item
    |> Map.put(:selected, Map.get(item, :selected, Map.get(item, :selected?)))
    |> maybe_put_item_attrs(collection_item_attrs(source_element, event_target, item_id))
  end

  defp normalize_table_row(row, source_element, event_target) do
    row = Map.new(row)
    row_id = Map.get(row, :id) || Map.get(row, "id")

    row
    |> Map.put(:selected, Map.get(row, :selected, Map.get(row, :selected?)))
    |> maybe_put_item_attrs(collection_item_attrs(source_element, event_target, row_id))
  end

  defp normalize_tree_node(node, source_element, event_target) do
    node = Map.new(node)
    node_id = Map.get(node, :id) || Map.get(node, "id")

    children =
      node
      |> Map.get(:children, Map.get(node, "children", []))
      |> List.wrap()
      |> Enum.map(&normalize_tree_node(&1, source_element, event_target))

    node
    |> Map.put(:selected, Map.get(node, :selected, Map.get(node, :selected?)))
    |> Map.put(:expanded, Map.get(node, :expanded, Map.get(node, :expanded?)))
    |> Map.put(:children, children)
    |> maybe_put_item_attrs(collection_item_attrs(source_element, event_target, node_id))
  end

  defp maybe_put_item_attrs(item, attrs) when attrs == %{}, do: item

  defp maybe_put_item_attrs(item, attrs) do
    Map.update(item, :attrs, attrs, &Map.merge(Map.new(&1), attrs))
  end

  defp primary_control_interaction(%Element{} = element) do
    primary_interaction(element, :change) || primary_interaction(element, :selection)
  end

  defp primary_submit_interaction(%Element{} = element) do
    primary_interaction(element, :submit)
  end

  defp interaction_form_id(%Element{} = element, widget_name) when is_binary(widget_name) do
    "#{element_id(element, widget_name)}-interaction-form"
  end
end
