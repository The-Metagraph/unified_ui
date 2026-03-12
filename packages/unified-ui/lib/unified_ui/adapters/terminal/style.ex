defmodule UnifiedUi.Adapters.Terminal.Style do
  @moduledoc """
  Style conversion utilities for Terminal renderer.

  Converts UnifiedIUR.Style to TermUI.Renderer.Style.

  ## Color Mapping

  UnifiedUi uses atom colors that map directly to TermUI colors:
  * `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:white`
  * `:bright_black`, `:bright_red`, `:bright_green`, etc.

  ## Attribute Mapping

  Text attributes map 1:1:
  * `:bold` - Bold text
  * `:underline` - Underlined text
  * `:reverse` - Reverse video (fg/bg swap)
  * `:blink` - Blinking text

  ## Examples

      iex> convert_style(%Style{fg: :cyan})
      %TermUI.Renderer.Style{fg: :cyan}

      iex> convert_style(%Style{fg: :red, attrs: [:bold]})
      %TermUI.Renderer.Style{fg: :red, attrs: [:bold]}

  """

  alias UnifiedIUR.Style

  @type termui_style :: term()

  @doc """
  Converts an IUR Style to a TermUI Style.

  ## Parameters

  * `iur_style` - The IUR Style struct to convert

  ## Returns

  A TermUI.Renderer.Style struct or nil if no style.

  ## Examples

      iex> convert_style(%Style{fg: :cyan})
      %TermUI.Renderer.Style{fg: :cyan}

      iex> convert_style(nil)
      nil

  """
  @spec convert_style(Style.t() | nil) :: termui_style() | nil
  def convert_style(nil), do: nil

  def convert_style(%Style{} = iur_style) do
    # Build TermUI style by mapping IUR style properties
    build_termui_style(iur_style)
  end

  # Private helpers

  defp build_termui_style(iur_style) do
    # Start with empty TermUI style
    style = TermUI.Renderer.Style.new()

    # Map foreground color
    style =
      if iur_style.fg do
        TermUI.Renderer.Style.fg(style, iur_style.fg)
      else
        style
      end

    # Map background color
    style =
      if iur_style.bg do
        TermUI.Renderer.Style.bg(style, iur_style.bg)
      else
        style
      end

    # Map text attributes
    if iur_style.attrs do
      Enum.reduce(iur_style.attrs, style, fn attr, acc_style ->
        add_attr(acc_style, attr)
      end)
    else
      style
    end
  end

  defp add_attr(style, :bold), do: TermUI.Renderer.Style.bold(style)
  defp add_attr(style, :underline), do: TermUI.Renderer.Style.underline(style)
  defp add_attr(style, :reverse), do: TermUI.Renderer.Style.reverse(style)
  defp add_attr(style, :blink), do: TermUI.Renderer.Style.blink(style)
  defp add_attr(style, :dim), do: TermUI.Renderer.Style.dim(style)
  defp add_attr(style, :italic), do: TermUI.Renderer.Style.italic(style)
  defp add_attr(style, :strikethrough), do: TermUI.Renderer.Style.strikethrough(style)
  defp add_attr(style, {:font_weight, :bold}), do: TermUI.Renderer.Style.bold(style)
  defp add_attr(style, {:font_weight, :bolder}), do: TermUI.Renderer.Style.bold(style)

  defp add_attr(style, {:font_weight, value}) when is_integer(value) and value >= 600,
    do: TermUI.Renderer.Style.bold(style)

  defp add_attr(style, {:font_weight, :lighter}), do: TermUI.Renderer.Style.dim(style)
  defp add_attr(style, {:font_weight, :normal}), do: style
  defp add_attr(style, _attr), do: style

  @doc """
  Merges multiple styles into a single TermUI style.

  Later styles override earlier styles for conflicting properties.

  ## Parameters

  * `styles` - List of IUR Style structs or nil values

  ## Returns

  A TermUI.Renderer.Style struct.

  ## Examples

      iex> merge_styles([%Style{fg: :red}, %Style{bg: :blue}])
      %TermUI.Renderer.Style{fg: :red, bg: :blue}

  """
  @spec merge_styles([Style.t() | nil]) :: termui_style()
  def merge_styles(styles) when is_list(styles) do
    styles
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(TermUI.Renderer.Style.new(), fn style, acc ->
      converted = convert_style(style)
      merge_termui_styles(acc, converted)
    end)
  end

  defp merge_termui_styles(nil, right), do: right
  defp merge_termui_styles(left, nil), do: left

  defp merge_termui_styles(left, right) do
    # TermUI.Style should have a merge function or we can manually merge
    # For now, let's manually merge the known properties
    base = left || TermUI.Renderer.Style.new()

    base
    |> maybe_merge_fg(right)
    |> maybe_merge_bg(right)
    |> maybe_merge_attrs(right)
  end

  defp maybe_merge_fg(acc, style) do
    if style && Map.get(style, :fg) do
      TermUI.Renderer.Style.fg(acc, style.fg)
    else
      acc
    end
  end

  defp maybe_merge_bg(acc, style) do
    if style && Map.get(style, :bg) do
      TermUI.Renderer.Style.bg(acc, style.bg)
    else
      acc
    end
  end

  defp maybe_merge_attrs(acc, style) do
    if style && Map.get(style, :attrs) do
      Enum.reduce(style.attrs, acc, fn attr, acc_style ->
        add_attr(acc_style, attr) || acc_style
      end)
    else
      acc
    end
  end
end
