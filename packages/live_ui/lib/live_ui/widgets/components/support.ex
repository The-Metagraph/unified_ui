defmodule LiveUi.Widgets.Components.Support do
  @moduledoc false

  alias LiveUi.BrowserAttrs

  @spec component_attrs(map(), atom(), atom(), map() | keyword()) :: map()
  def component_attrs(assigns, kind, family, extra \\ %{}) do
    base =
      %{}
      |> put_attr("data-live-ui-widget", kind)
      |> put_attr("data-live-ui-component-family", family)
      |> put_attr("data-live-ui-tone", Map.get(assigns, :tone))
      |> put_attr("data-live-ui-variant", Map.get(assigns, :variant))
      |> put_attr("data-live-ui-state", Map.get(assigns, :state))
      |> BrowserAttrs.merge(extra)

    BrowserAttrs.merge(Map.get(assigns, :rest, %{}), base)
  end

  @spec fetch(map() | keyword() | nil, atom(), term()) :: term()
  def fetch(source, key, default \\ nil)
  def fetch(nil, _key, default), do: default

  def fetch(source, key, default) when is_list(source) do
    source
    |> Map.new()
    |> fetch(key, default)
  end

  def fetch(source, key, default) when is_map(source) do
    Map.get(source, key, Map.get(source, Atom.to_string(key), default))
  end

  def text(value, default \\ "")
  def text(nil, default), do: default
  def text(value, _default), do: to_string(value)

  def atom_name(value, default \\ "")
  def atom_name(nil, default), do: default

  def atom_name(value, _default) do
    value
    |> to_string()
    |> String.replace("_", "-")
  end

  def numeric(nil, default), do: default
  def numeric(value, _default) when is_number(value), do: value

  def numeric(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _other -> default
    end
  end

  def numeric(_value, default), do: default

  def percentage(current, minimum, maximum) do
    current = numeric(current, 0)
    minimum = numeric(minimum, 0)
    maximum = numeric(maximum, 100)
    range = max(maximum - minimum, 1)

    ((current - minimum) / range * 100)
    |> max(0)
    |> min(100)
  end

  def selected?(option, active_value) do
    fetch(option, :selected?, false) || fetch(option, :selected, false) ||
      fetch(option, :value) == active_value
  end

  def disabled?(value), do: fetch(value, :disabled?, fetch(value, :disabled, false))

  def attrs(source) do
    case fetch(source, :attrs, %{}) do
      attrs when is_map(attrs) -> attrs
      attrs when is_list(attrs) -> Map.new(attrs)
      _other -> %{}
    end
  end

  def label(value, default \\ "") do
    fetch(value, :label, fetch(value, :title, fetch(value, :value, default)))
    |> text(default)
  end

  def id_value(value, default) do
    value
    |> fetch(:id, fetch(value, :value, default))
    |> text(default)
  end

  defp put_attr(attrs, _key, nil), do: attrs
  defp put_attr(attrs, _key, ""), do: attrs
  defp put_attr(attrs, key, value), do: Map.put(attrs, key, to_string(value))
end
