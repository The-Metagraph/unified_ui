defmodule LiveUi.Style.Compiler do
  @moduledoc """
  Maps normalized style metadata into stable CSS tokens and inline CSS.
  """

  @spec compile(map()) :: [String.t()]
  def compile(styles) when is_map(styles) do
    styles
    |> Enum.flat_map(fn
      {key, value} when key in [:class, "class"] and is_binary(value) ->
        value |> String.split(~r/\s+/, trim: true)

      {key, value} when key in [:variant, "variant"] and is_binary(value) ->
        ["variant-#{value}"]

      {key, value} when key in [:tone, "tone"] and is_binary(value) ->
        ["tone-#{value}"]

      {key, value} when key in [:gap, "gap"] ->
        ["gap-#{value}"]

      {key, value} when key in [:fg, "fg"] ->
        ["fg-#{normalize_token(value)}"]

      {key, value} when key in [:bg, "bg"] ->
        ["bg-#{normalize_token(value)}"]

      {key, value} when key in [:align, "align"] ->
        ["align-#{normalize_token(value)}"]

      {key, value} when key in [:attrs, "attrs"] and is_list(value) ->
        Enum.map(value, fn attr -> "attr-#{normalize_token(attr)}" end)

      _other ->
        []
    end)
    |> Enum.uniq()
  end

  def compile(_styles), do: []

  @spec inline(map()) :: String.t() | nil
  def inline(styles) when is_map(styles) do
    styles
    |> Enum.reduce([], fn
      {key, value}, acc when key in [:padding, "padding"] ->
        maybe_css(acc, "padding", px(value))

      {key, value}, acc when key in [:margin, "margin"] ->
        maybe_css(acc, "margin", px(value))

      {key, value}, acc when key in [:width, "width"] ->
        maybe_css(acc, "width", size(value))

      {key, value}, acc when key in [:height, "height"] ->
        maybe_css(acc, "height", size(value))

      {key, value}, acc when key in [:fg, "fg"] ->
        maybe_css(acc, "color", color(value))

      {key, value}, acc when key in [:bg, "bg"] ->
        maybe_css(acc, "background-color", color(value))

      _other, acc ->
        acc
    end)
    |> Enum.reverse()
    |> case do
      [] -> nil
      css -> Enum.join(css, "; ")
    end
  end

  def inline(_styles), do: nil

  defp maybe_css(acc, _property, nil), do: acc
  defp maybe_css(acc, property, value), do: ["#{property}: #{value}" | acc]

  defp normalize_token(value) when is_binary(value),
    do: value |> String.downcase() |> String.replace(~r/[^a-z0-9_\-]+/u, "-")

  defp normalize_token(value) when is_atom(value),
    do: value |> Atom.to_string() |> normalize_token()

  defp normalize_token(value), do: value |> to_string() |> normalize_token()

  defp px(value) when is_integer(value), do: "#{value}px"
  defp px(_value), do: nil

  defp size(:fill), do: "100%"
  defp size("fill"), do: "100%"
  defp size(:auto), do: "auto"
  defp size("auto"), do: "auto"
  defp size(value) when is_integer(value), do: "#{value}px"
  defp size(_value), do: nil

  defp color({r, g, b}) when is_integer(r) and is_integer(g) and is_integer(b),
    do: "rgb(#{r}, #{g}, #{b})"

  defp color(value) when is_binary(value), do: value
  defp color(value) when is_atom(value), do: Atom.to_string(value)
  defp color(_value), do: nil
end
