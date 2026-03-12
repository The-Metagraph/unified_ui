defmodule UnifiedUi.Adapters.Desktop.Style do
  @moduledoc """
  Style conversion utilities for Desktop renderer.

  Converts UnifiedIUR.Style to DesktopUi widget properties.

  ## Color Mapping

  UnifiedUi uses atom colors that map to DesktopUi colors:
  * `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:white`
  * Bright variants: `:bright_black`, `:bright_red`, etc.

  ## Attribute Mapping

  Text attributes are mapped where DesktopUi supports them:
  * `:bold` - Bold text (if font supports it)
  * `:underline` - Underlined text
  * Note: Some terminal attributes may not have desktop equivalents

  ## Examples

      iex> to_props([text: "Hello"], %Style{fg: :cyan})
      [text: "Hello", color: :cyan]

      iex> to_props([text: "Hi"], %Style{fg: :red, attrs: [:bold]})
      [text: "Hi", color: :red, font_style: :bold]

  """

  alias UnifiedIUR.Style

  @type desktop_props :: keyword()

  @doc """
  Converts an IUR Style to DesktopUi widget properties.

  ## Parameters

  * `props` - Existing props keyword list to extend
  * `iur_style` - The IUR Style struct to convert

  ## Returns

  Extended props keyword list with DesktopUi style properties.

  ## Examples

      iex> add_props([text: "Hello"], %Style{fg: :cyan})
      [text: "Hello", color: :cyan]

      iex> add_props([text: "Hi"], nil)
      [text: "Hi"]

  """
  @spec add_props(keyword(), Style.t() | nil) :: keyword()
  def add_props(props, nil), do: props

  def add_props(props, %Style{} = iur_style) do
    # Map IUR style to DesktopUi props
    props
    |> maybe_add_color(iur_style.fg)
    |> maybe_add_background(iur_style.bg)
    |> maybe_add_spacing_prop(:padding, iur_style.padding)
    |> maybe_add_spacing_prop(:margin, iur_style.margin)
    |> maybe_add_size_prop(:width, iur_style.width)
    |> maybe_add_size_prop(:height, iur_style.height)
    |> maybe_add_align(iur_style.align)
    |> maybe_add_style_attrs(iur_style.attrs)
  end

  @doc """
  Converts an IUR Style to DesktopUi widget properties (standalone).

  ## Parameters

  * `iur_style` - The IUR Style struct to convert

  ## Returns

  Props keyword list with DesktopUi style properties.

  ## Examples

      iex> to_props(%Style{fg: :cyan})
      [color: :cyan]

      iex> to_props(nil)
      []

  """
  @spec to_props(Style.t() | nil) :: keyword()
  def to_props(nil), do: []
  def to_props(%Style{} = iur_style), do: add_props([], iur_style)

  # Private helpers

  # Map foreground color to :color prop
  defp maybe_add_color(props, nil), do: props
  defp maybe_add_color(props, color), do: [{:color, color} | props]

  # Map background color to :background prop
  defp maybe_add_background(props, nil), do: props
  defp maybe_add_background(props, color), do: [{:background, color} | props]

  defp maybe_add_spacing_prop(props, _key, nil), do: props

  defp maybe_add_spacing_prop(props, key, value) when is_integer(value),
    do: [{key, value} | props]

  defp maybe_add_spacing_prop(props, _key, _value), do: props

  defp maybe_add_size_prop(props, _key, nil), do: props
  defp maybe_add_size_prop(props, key, value) when is_integer(value), do: [{key, value} | props]
  defp maybe_add_size_prop(props, key, value) when is_atom(value), do: [{key, value} | props]
  defp maybe_add_size_prop(props, _key, _value), do: props

  defp maybe_add_align(props, nil), do: props
  defp maybe_add_align(props, align), do: [{:align, align} | props]

  # Map text/extended attributes
  defp maybe_add_style_attrs(props, attrs) when is_list(attrs) do
    attrs
    |> Enum.reduce(props, fn attr, acc_props ->
      add_style_attr(acc_props, attr)
    end)
  end

  defp maybe_add_style_attrs(props, _attrs), do: props

  # Font attribute mapping
  # DesktopUi style uses :font_style prop for text decoration
  defp add_style_attr(props, :bold), do: [{:font_style, :bold} | props]
  defp add_style_attr(props, :underline), do: [{:font_style, :underline} | props]
  defp add_style_attr(props, :italic), do: [{:font_style, :italic} | props]

  # For attributes that might not have direct DesktopUi support,
  # we still try to map them or ignore gracefully
  defp add_style_attr(props, :reverse), do: props
  defp add_style_attr(props, :blink), do: props
  defp add_style_attr(props, :dim), do: props
  defp add_style_attr(props, :strikethrough), do: props

  defp add_style_attr(props, {:spacing, value}) when is_integer(value),
    do: [{:gap, value} | props]

  defp add_style_attr(props, {:font_family, value})
       when is_binary(value) and byte_size(value) > 0,
       do: [{:font_family, value} | props]

  defp add_style_attr(props, {:font_size, value}) when is_integer(value) and value > 0,
    do: [{:font_size, value} | props]

  defp add_style_attr(props, {:font_size, value}) when is_binary(value) and byte_size(value) > 0,
    do: [{:font_size, value} | props]

  defp add_style_attr(props, {:font_weight, value})
       when value in [:normal, :bold, :bolder, :lighter] or
              (is_integer(value) and value >= 100 and value <= 900),
       do: [{:font_weight, value} | props]

  defp add_style_attr(props, {:border, value}), do: [{:border, value} | props]

  defp add_style_attr(props, {:border_width, value}) when is_integer(value) and value >= 0,
    do: [{:border_width, value} | props]

  defp add_style_attr(props, {:border_color, value}), do: [{:border_color, value} | props]

  defp add_style_attr(props, {:border_style, value})
       when value in [:none, :solid, :dashed, :dotted, :double],
       do: [{:border_style, value} | props]

  defp add_style_attr(props, _), do: props

  @doc """
  Merges multiple styles into a single DesktopUi props list.

  Later styles override earlier styles for conflicting properties.

  ## Parameters

  * `props` - Base props to extend
  * `styles` - List of IUR Style structs or nil values

  ## Returns

  Extended props keyword list with merged style properties.

  ## Examples

      iex> merge_props([text: "Hello"], [%Style{fg: :red}, %Style{bg: :blue}])
      [text: "Hello", background: :blue, color: :red]

  """
  @spec merge_props(keyword(), [Style.t() | nil]) :: keyword()
  def merge_props(props, []), do: props

  def merge_props(props, styles) when is_list(styles) do
    styles
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(props, fn style, acc_props ->
      add_props(acc_props, style)
    end)
  end
end
