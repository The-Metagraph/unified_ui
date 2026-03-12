defmodule UnifiedUi.Adapters.Web.Style do
  @moduledoc """
  Style conversion utilities for Web renderer.

  Converts UnifiedIUR.Style to CSS inline style strings.

  ## Color Mapping

  UnifiedUi uses atom colors that map to CSS color names:
  * `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:white`
  * CSS also supports hex, rgb, hsl, and named colors

  ## Attribute Mapping

  Text attributes map to CSS properties:
  * `:bold` - `font-weight: bold`
  * `:underline` - `text-decoration: underline`
  * `:italic` - `font-style: italic`
  * `:strikethrough` - `text-decoration: line-through`

  ## Examples

      iex> to_css(%Style{fg: :cyan})
      "color: cyan"

      iex> to_css(%Style{fg: :red, attrs: [:bold]})
      "font-weight: bold; color: red"

  """

  alias UnifiedIUR.Style

  @type css_string :: String.t()

  @doc """
  Converts an IUR Style to a CSS inline style string.

  ## Parameters

  * `iur_style` - The IUR Style struct to convert

  ## Returns

  A CSS inline style string, or nil if no style.

  ## Examples

      iex> to_css(%Style{fg: :cyan})
      "color: cyan"

      iex> to_css(%Style{fg: :red, attrs: [:bold]})
      "font-weight: bold; color: red"

      iex> to_css(nil)
      ""

  """
  @spec to_css(Style.t() | nil) :: css_string()
  def to_css(nil), do: ""

  def to_css(%Style{} = iur_style) do
    []
    |> maybe_add_css("color", color_to_css(iur_style.fg))
    |> maybe_add_css("background-color", color_to_css(iur_style.bg))
    |> maybe_add_css("padding", pixel_value(iur_style.padding))
    |> maybe_add_css("margin", pixel_value(iur_style.margin))
    |> maybe_add_css("width", size_to_css(iur_style.width))
    |> maybe_add_css("height", size_to_css(iur_style.height))
    |> maybe_add_align_css(iur_style.align)
    |> add_attrs_css(iur_style.attrs)
    |> Enum.reverse()
    |> Enum.join("; ")
  end

  @doc """
  Extends existing CSS string with IUR style properties.

  ## Parameters

  * `css` - Existing CSS string
  * `iur_style` - The IUR Style struct to add

  ## Returns

  Extended CSS string with additional style properties.

  ## Examples

      iex> add_to_css("color: red", %Style{bg: :blue})
      "color: red; background-color: blue"

  """
  @spec add_to_css(css_string(), Style.t() | nil) :: css_string()
  def add_to_css(css, nil), do: css
  def add_to_css("", %Style{} = iur_style), do: to_css(iur_style)

  def add_to_css(css, %Style{} = iur_style) do
    additional_css = to_css(iur_style)
    if additional_css == "", do: css, else: "#{css}; #{additional_css}"
  end

  # Private helpers

  defp maybe_add_css(css_parts, _property, nil), do: css_parts
  defp maybe_add_css(css_parts, property, value), do: ["#{property}: #{value}" | css_parts]

  defp maybe_add_align_css(css_parts, :left), do: ["text-align: left" | css_parts]
  defp maybe_add_align_css(css_parts, :center), do: ["text-align: center" | css_parts]
  defp maybe_add_align_css(css_parts, :right), do: ["text-align: right" | css_parts]
  defp maybe_add_align_css(css_parts, :start), do: ["text-align: start" | css_parts]
  defp maybe_add_align_css(css_parts, :end), do: ["text-align: end" | css_parts]
  defp maybe_add_align_css(css_parts, :top), do: ["vertical-align: top" | css_parts]
  defp maybe_add_align_css(css_parts, :bottom), do: ["vertical-align: bottom" | css_parts]
  defp maybe_add_align_css(css_parts, :stretch), do: ["align-items: stretch" | css_parts]
  defp maybe_add_align_css(css_parts, _align), do: css_parts

  defp add_attrs_css(css_parts, attrs) when is_list(attrs) do
    Enum.reduce(attrs, css_parts, fn attr, acc -> add_attr_css(acc, attr) end)
  end

  defp add_attrs_css(css_parts, _attrs), do: css_parts

  # Add text/extended attributes as CSS
  defp add_attr_css(css_parts, :bold), do: ["font-weight: bold" | css_parts]
  defp add_attr_css(css_parts, :underline), do: ["text-decoration: underline" | css_parts]
  defp add_attr_css(css_parts, :italic), do: ["font-style: italic" | css_parts]
  defp add_attr_css(css_parts, :strikethrough), do: ["text-decoration: line-through" | css_parts]
  defp add_attr_css(css_parts, :dim), do: ["opacity: 0.7" | css_parts]
  defp add_attr_css(css_parts, :reverse), do: css_parts
  defp add_attr_css(css_parts, :blink), do: css_parts

  defp add_attr_css(css_parts, {:spacing, value}) do
    maybe_add_css(css_parts, "gap", pixel_value(value))
  end

  defp add_attr_css(css_parts, {:font_family, value})
       when is_binary(value) and byte_size(value) > 0 do
    maybe_add_css(css_parts, "font-family", value)
  end

  defp add_attr_css(css_parts, {:font_size, value}) do
    maybe_add_css(css_parts, "font-size", font_size_to_css(value))
  end

  defp add_attr_css(css_parts, {:font_weight, value}) do
    maybe_add_css(css_parts, "font-weight", font_weight_to_css(value))
  end

  defp add_attr_css(css_parts, {:border, value}) do
    maybe_add_css(css_parts, "border", border_to_css(value))
  end

  defp add_attr_css(css_parts, {:border_width, value}) do
    maybe_add_css(css_parts, "border-width", pixel_value(value))
  end

  defp add_attr_css(css_parts, {:border_color, value}) do
    maybe_add_css(css_parts, "border-color", color_to_css(value))
  end

  defp add_attr_css(css_parts, {:border_style, value}) do
    maybe_add_css(css_parts, "border-style", border_style_to_css(value))
  end

  defp add_attr_css(css_parts, _), do: css_parts

  defp pixel_value(value) when is_integer(value) and value >= 0, do: "#{value}px"
  defp pixel_value(_value), do: nil

  defp size_to_css(value) when is_integer(value) and value >= 0, do: "#{value}px"
  defp size_to_css(:fill), do: "100%"
  defp size_to_css(:auto), do: "auto"
  defp size_to_css(_value), do: nil

  defp font_size_to_css(value) when is_integer(value) and value > 0, do: "#{value}px"
  defp font_size_to_css(value) when is_binary(value) and byte_size(value) > 0, do: value
  defp font_size_to_css(_value), do: nil

  defp font_weight_to_css(value) when value in [:normal, :bold, :bolder, :lighter],
    do: Atom.to_string(value)

  defp font_weight_to_css(value) when is_integer(value) and value >= 100 and value <= 900,
    do: Integer.to_string(value)

  defp font_weight_to_css(_value), do: nil

  defp border_to_css(value) when is_binary(value) and byte_size(value) > 0, do: value

  defp border_to_css(value) when is_integer(value) and value >= 0,
    do: "#{value}px solid currentColor"

  defp border_to_css(value) when is_map(value) do
    width =
      value
      |> map_get(:width)
      |> pixel_value()

    style =
      value
      |> map_get(:style)
      |> border_style_to_css()

    color =
      value
      |> map_get(:color)
      |> color_to_css()

    case Enum.reject([width, style, color], &is_nil/1) do
      [] -> nil
      parts -> Enum.join(parts, " ")
    end
  end

  defp border_to_css(value) when is_list(value) do
    if Keyword.keyword?(value) do
      value
      |> Enum.into(%{})
      |> border_to_css()
    else
      nil
    end
  end

  defp border_to_css(_value), do: nil

  defp border_style_to_css(value) when value in [:none, :solid, :dashed, :dotted, :double],
    do: Atom.to_string(value)

  defp border_style_to_css(_value), do: nil

  # Convert IUR color to CSS color value
  defp color_to_css(nil), do: nil
  defp color_to_css(color) when is_atom(color), do: Atom.to_string(color)
  defp color_to_css(color) when is_binary(color) and byte_size(color) > 0, do: color

  defp color_to_css({r, g, b}) when is_integer(r) and is_integer(g) and is_integer(b),
    do: "rgb(#{r}, #{g}, #{b})"

  defp color_to_css({r, g, b, a})
       when is_integer(r) and is_integer(g) and is_integer(b) and is_integer(a),
       do: "rgba(#{r}, #{g}, #{b}, #{a / 255})"

  defp color_to_css(_color), do: nil

  defp map_get(map, key) when is_map(map),
    do: Map.get(map, key) || Map.get(map, Atom.to_string(key))

  @doc """
  Merges multiple styles into a single CSS string.

  Later styles override earlier styles for conflicting properties.

  ## Parameters

  * `styles` - List of IUR Style structs or nil values

  ## Returns

  A CSS inline style string.

  ## Examples

      iex> merge_styles([%Style{fg: :red}, %Style{bg: :blue}])
      "color: red; background-color: blue"

  """
  @spec merge_styles([Style.t() | nil]) :: css_string()
  def merge_styles(styles) when is_list(styles) do
    styles
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce("", fn style, acc_css ->
      add_to_css(acc_css, style)
    end)
  end
end
