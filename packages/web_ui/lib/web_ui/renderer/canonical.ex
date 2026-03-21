defmodule WebUi.Renderer.Canonical do
  @moduledoc """
  Deterministic canonical-to-native widget mapping for the `web_ui` scaffold.
  """

  alias UnifiedIUR.Element
  alias WebUi.{Widget, Widgets}

  @spec render(Element.t(), keyword()) :: Widget.t()
  def render(%Element{} = element, _opts \\ []) do
    attrs = Map.new(element.attributes)
    id = element.id || "#{element.kind}-node"

    case normalize_kind(element.kind) do
      :text ->
        Widgets.text(id, fetch_attr(attrs, :content, inspect(id)))

      :button ->
        Widgets.button(id, fetch_attr(attrs, :label, fetch_attr(attrs, :content, "Button")))

      :container ->
        Widgets.stack(id, Enum.map(element.children, &render_child/1))

      _other ->
        Widget.new(:text,
          id: id,
          attributes: %{
            content: "unsupported:#{element.kind}",
            canonical_kind: element.kind,
            canonical_type: element.type
          }
        )
    end
  end

  defp render_child(%{element: %Element{} = element}), do: render(element)
  defp render_child(%Element{} = element), do: render(element)

  defp normalize_kind(kind) when kind in [:container, :stack, :column], do: :container
  defp normalize_kind(kind) when kind in ["container", "stack", "column"], do: :container
  defp normalize_kind(kind) when kind in ["text"], do: :text
  defp normalize_kind(kind) when kind in ["button"], do: :button
  defp normalize_kind(kind) when is_binary(kind), do: String.to_atom(kind)
  defp normalize_kind(kind), do: kind

  defp fetch_attr(attrs, key, default) do
    Map.get(attrs, key) || Map.get(attrs, Atom.to_string(key)) || default
  end
end
