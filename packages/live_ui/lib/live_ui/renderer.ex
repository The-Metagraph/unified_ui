defmodule LiveUi.Renderer do
  @moduledoc """
  Package-facing entrypoint for canonical `UnifiedIUR` rendering.
  """

  use Phoenix.Component

  alias UnifiedIUR.{Binding, Element, Style}
  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:consume_canonical_iur, :reuse_native_widgets, :preserve_runtime_continuity]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :box,
      :button,
      :checkbox,
      :column,
      :content,
      :field,
      :field_group,
      :form_builder,
      :grid,
      :icon,
      :image,
      :label,
      :link,
      :menu,
      :numeric_input,
      :pick_list,
      :radio_group,
      :row,
      :select,
      :separator,
      :spacer,
      :tabs,
      :text,
      :text_input,
      :time_input,
      :date_input,
      :file_input,
      :toggle
    ]
  end

  attr(:element, :any, required: true)

  def render(%{element: %Element{kind: :text}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Text.render
      id={element_id(@element, "text")}
      content={content_text(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :label}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Label.render
      id={element_id(@element, "label")}
      for={label_for(@element)}
      content={content_text(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :icon}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Icon.render
      id={element_id(@element, "icon")}
      name={string_value(get_in(@element.attributes, [:icon, :name]), "icon")}
      set={string_optional(get_in(@element.attributes, [:icon, :set]))}
      fallback_text={string_optional(get_in(@element.attributes, [:icon, :fallback_text]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :image}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Image.render
      id={element_id(@element, "image")}
      src={string_value(get_in(@element.attributes, [:image, :source]), "")}
      alt={string_value(get_in(@element.attributes, [:image, :alt_text]), "")}
      fit={string_optional(get_in(@element.attributes, [:image, :fit]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :button}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Button.render
      id={element_id(@element, "button")}
      label={content_text(@element)}
      disabled={state_boolean(@element, :disabled?)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :link}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Link.render
      id={element_id(@element, "link")}
      label={content_text(@element)}
      href={string_value(get_in(@element.attributes, [:link, :target]), "#")}
      external={state_boolean(@element, [:link, :external?])}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :separator}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Separator.render
      id={element_id(@element, "separator")}
      orientation={string_value(get_in(@element.attributes, [:separator, :orientation]), "horizontal")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :spacer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Spacer.render
      id={element_id(@element, "spacer")}
      size={string_value(get_in(@element.attributes, [:spacer, :size]), "md")}
      grow={integer_value(get_in(@element.attributes, [:spacer, :grow]), 0)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :content}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Content.render
      id={element_id(@element, "content")}
      role={string_value(get_in(@element.attributes, [:container, :role]), "content")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Content.render>
    """
  end

  def render(%{element: %Element{kind: :box}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Box.render
      id={element_id(@element, "box")}
      padding={string_optional(get_in(@element.attributes, [:container, :padding]))}
      border={string_optional(get_in(@element.attributes, [:container, :border]))}
      background={string_optional(get_in(@element.attributes, [:container, :background]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Box.render>
    """
  end

  def render(%{element: %Element{kind: :row}} = assigns) do
    ~H"""
    <LiveUi.Layout.Row.render
      id={element_id(@element, "row")}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Layout.Row.render>
    """
  end

  def render(%{element: %Element{kind: :column}} = assigns) do
    ~H"""
    <LiveUi.Layout.Column.render
      id={element_id(@element, "column")}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Layout.Column.render>
    """
  end

  def render(%{element: %Element{kind: :grid}} = assigns) do
    ~H"""
    <LiveUi.Layout.Grid.render
      id={element_id(@element, "grid")}
      columns={integer_optional(get_in(@element.attributes, [:layout, :columns]))}
      rows={integer_optional(get_in(@element.attributes, [:layout, :rows]))}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Layout.Grid.render>
    """
  end

  def render(%{element: %Element{kind: :form_builder}} = assigns) do
    ~H"""
    <LiveUi.Forms.FormBuilder.render
      id={element_id(@element, "form-builder")}
      autocomplete={boolean_default(get_in(@element.attributes, [:form, :autocomplete?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Forms.FormBuilder.render>
    """
  end

  def render(%{element: %Element{kind: :field_group}} = assigns) do
    ~H"""
    <LiveUi.Forms.FieldGroup.render
      id={element_id(@element, "field-group")}
      legend={string_optional(get_in(@element.attributes, [:group, :legend]))}
      description={string_optional(get_in(@element.attributes, [:group, :description]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Forms.FieldGroup.render>
    """
  end

  def render(%{element: %Element{kind: :field}} = assigns) do
    ~H"""
    <LiveUi.Forms.Field.render
      id={element_id(@element, "field")}
      name={string_optional(get_in(@element.attributes, [:field, :name]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <:label :for={child <- child_elements(@element, :label)}>
        <.render element={child} />
      </:label>
      <:control :for={child <- child_elements(@element, :control)}>
        <.render element={child} />
      </:control>
      <:help :for={child <- child_elements(@element, :help)}>
        <.render element={child} />
      </:help>
    </LiveUi.Forms.Field.render>
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:text_input, :numeric_input, :date_input, :time_input, :file_input] do
    ~H"""
    <LiveUi.Widgets.TextInput.render
      id={element_id(@element, "input")}
      name={binding_name(@element)}
      value={binding_value(@element)}
      placeholder={string_optional(get_in(@element.attributes, [:input, :placeholder]))}
      input_type={input_type(@element.kind)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:toggle, :checkbox] do
    ~H"""
    <LiveUi.Widgets.Toggle.render
      id={element_id(@element, "toggle")}
      name={binding_name(@element)}
      checked={boolean_default(binding_value(@element), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:select, :pick_list, :radio_group] do
    ~H"""
    <LiveUi.Widgets.Select.render
      id={element_id(@element, "select")}
      name={binding_name(@element)}
      options={selection_options(@element)}
      multiple={selection_multiple?(@element, @element.kind)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :menu}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Menu.render
      id={element_id(@element, "menu")}
      items={navigation_items(@element)}
      active_item={string_optional(get_in(@element.attributes, [:navigation, :active_item]))}
      orientation={string_value(get_in(@element.attributes, [:navigation, :orientation]), "vertical")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :tabs}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Tabs.render
      id={element_id(@element, "tabs")}
      items={navigation_items(@element)}
      active_item={string_optional(get_in(@element.attributes, [:navigation, :active_item]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
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

  defp navigation_items(%Element{} = element) do
    get_in(element.attributes, [:navigation, :items]) || []
  end

  defp theme_variant(%Element{} = element) do
    element.attributes
    |> Map.get(:theme)
    |> case do
      %{variant: variant} -> string_optional(variant)
      %{"variant" => variant} -> string_optional(variant)
      _ -> nil
    end
  end

  defp style_tone(%Element{} = element) do
    case Map.get(element.attributes, :style) do
      %Style{emphasis: emphasis} ->
        string_optional(Map.get(emphasis, :tone) || Map.get(emphasis, "tone"))

      %{emphasis: emphasis} when is_map(emphasis) ->
        string_optional(Map.get(emphasis, :tone) || Map.get(emphasis, "tone"))

      _ ->
        nil
    end
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

  defp integer_optional(nil), do: nil
  defp integer_optional(value) when is_integer(value), do: value
  defp integer_optional(value) when is_binary(value), do: String.to_integer(value)

  defp integer_value(nil, default), do: default
  defp integer_value(value, _default) when is_integer(value), do: value
  defp integer_value(value, _default) when is_binary(value), do: String.to_integer(value)

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
end
