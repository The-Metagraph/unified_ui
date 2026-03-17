defmodule WebUi.Server.RenderModel do
  @moduledoc """
  Deterministic server-side render model generation for foundational `web_ui`
  widgets.
  """

  alias WebUi.Widget
  alias WebUi.Widgets

  @spec build(Widget.t()) :: map()
  def build(%Widget{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      component: widget.kind,
      dom: %{
        tag: dom_tag(widget.kind),
        role: dom_role(widget.kind),
        attributes: dom_attributes(widget)
      },
      props: widget.props,
      state: widget.state,
      style_hooks: widget.style_hooks,
      events: widget.events,
      interactions: %{
        interactive?: widget.kind in interactive_kinds() or map_size(widget.events) > 0,
        focusable?: widget.kind in focusable_kinds(),
        editable?: widget.kind in editable_kinds(),
        navigable?: widget.kind in navigable_kinds()
      },
      slots: build_slots(widget.slots),
      diagnostics: %{
        event_names: widget.events |> Map.keys() |> Enum.sort(),
        slot_names: widget.slots |> Map.keys() |> Enum.map(&to_string/1) |> Enum.sort()
      }
    }
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    Widgets.kinds()
  end

  defp build_slots(slots) do
    slots
    |> Enum.sort_by(fn {slot, _children} -> to_string(slot) end)
    |> Enum.map(fn {slot, children} ->
      %{
        name: slot,
        children: children |> normalize_slot_children() |> Enum.map(&build/1)
      }
    end)
  end

  defp normalize_slot_children(nil), do: []
  defp normalize_slot_children(%Widget{} = widget), do: [widget]

  defp normalize_slot_children(children) when is_list(children) do
    case Widgets.normalize_many(children) do
      {:ok, widgets} -> widgets
      {:error, _reason} -> []
    end
  end

  defp dom_tag(:text), do: "span"
  defp dom_tag(:label), do: "label"
  defp dom_tag(:icon), do: "span"
  defp dom_tag(:image), do: "img"
  defp dom_tag(:button), do: "button"
  defp dom_tag(:link), do: "a"
  defp dom_tag(:separator), do: "hr"
  defp dom_tag(:spacer), do: "div"
  defp dom_tag(:content), do: "section"
  defp dom_tag(:text_input), do: "input"
  defp dom_tag(:checkbox), do: "input"
  defp dom_tag(:select), do: "select"
  defp dom_tag(:menu), do: "nav"
  defp dom_tag(:tabs), do: "div"
  defp dom_tag(:row), do: "div"
  defp dom_tag(:column), do: "div"
  defp dom_tag(:form_builder), do: "form"
  defp dom_tag(:field_group), do: "fieldset"
  defp dom_tag(:field), do: "div"
  defp dom_tag(_kind), do: "div"

  defp dom_role(:text), do: "text"
  defp dom_role(:label), do: "label"
  defp dom_role(:button), do: "button"
  defp dom_role(:link), do: "link"
  defp dom_role(:text_input), do: "textbox"
  defp dom_role(:checkbox), do: "checkbox"
  defp dom_role(:select), do: "listbox"
  defp dom_role(:menu), do: "navigation"
  defp dom_role(:tabs), do: "tablist"
  defp dom_role(:row), do: "group"
  defp dom_role(:column), do: "group"
  defp dom_role(:form_builder), do: "form"
  defp dom_role(:field_group), do: "group"
  defp dom_role(:field), do: "group"
  defp dom_role(_kind), do: "presentation"

  defp dom_attributes(%Widget{} = widget) do
    %{
      id: widget.id,
      class_tokens: Enum.map(widget.style_hooks, &to_string/1),
      disabled: Map.get(widget.state, :disabled?, false)
    }
    |> maybe_put(:href, Map.get(widget.props, :href))
    |> maybe_put(:value, Map.get(widget.props, :value))
    |> maybe_put(:name, Map.get(widget.props, :name))
    |> maybe_put(:for, Map.get(widget.props, :for))
    |> maybe_put(:placeholder, Map.get(widget.props, :placeholder))
    |> maybe_put(:orientation, Map.get(widget.props, :orientation))
    |> maybe_put(:active_item, Map.get(widget.props, :active_item))
  end

  defp interactive_kinds do
    [:button, :link, :text_input, :checkbox, :select, :menu, :tabs, :form_builder]
  end

  defp focusable_kinds do
    [:button, :link, :text_input, :checkbox, :select, :menu, :tabs]
  end

  defp editable_kinds do
    [:text_input, :checkbox, :select]
  end

  defp navigable_kinds do
    [:link, :menu, :tabs]
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
