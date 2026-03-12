defmodule UnifiedIUR.Style do
  @moduledoc """
  Platform-agnostic style representation for UI elements.

  The Style struct contains visual attributes that can be applied
  to widgets and layouts. These attributes are intentionally
  platform-agnostic, allowing renderers to interpret them
  appropriately for their target platform.

  ## Style Attributes

  * `fg` - Foreground color (atom like `:blue`, RGB tuple, or hex string)
  * `bg` - Background color (atom like `:white`, RGB tuple, or hex string)
  * `attrs` - List of text attributes (`:bold`, `:italic`, `:underline`, `:reverse`)
  * `padding` - Internal spacing around content (integer)
  * `margin` - External spacing around the element (integer)
  * `width` - Width constraint (integer, `:auto`, or `:fill`)
  * `height` - Height constraint (integer, `:auto`, or `:fill`)
  * `align` - Content alignment (`:left`, `:center`, `:right`, `:top`, `:bottom`, `:start`, `:end`, `:stretch`)

  ## Color Representation

  Colors can be specified in three formats:

  * **Named colors**: `:red`, `:blue`, `:green`, `:yellow`, `:cyan`, `:magenta`, `:white`, `:black`
  * **RGB tuples**: `{255, 128, 0}` for orange
  * **Hex strings**: `"#FF8000"` for orange

  ## Text Attributes

  The `attrs` field accepts a list of text attributes:
  * `:bold` - Bold/bright text
  * `:italic` - Italic text (platform dependent)
  * `:underline` - Underlined text
  * `:reverse` - Reverse video (swapped fg/bg)

  ## Examples

  Create a simple style:

      iex> UnifiedIUR.Style.new(fg: :blue, bg: :white)
      %UnifiedIUR.Style{fg: :blue, bg: :white, attrs: [], padding: nil, ...}

  Create a style with text attributes:

      iex> UnifiedIUR.Style.new(fg: :red, attrs: [:bold, :underline])
      %UnifiedIUR.Style{fg: :red, attrs: [:bold, :underline], ...}

  Merge two styles (later values override earlier):

      iex> base = UnifiedIUR.Style.new(fg: :blue, padding: 2)
      iex> override = UnifiedIUR.Style.new(fg: :red, margin: 1)
      iex> UnifiedIUR.Style.merge(base, override)
      %UnifiedIUR.Style{fg: :red, padding: 2, margin: 1, bg: nil, ...}

  ## Platform Rendering

  Each renderer interprets these attributes appropriately:

  * **Terminal**: ANSI color codes and text attributes
  * **Desktop**: Native widget properties or CSS styles
  * **Web**: CSS properties (color, background-color, font-weight, etc.)
  """

  defstruct [
    :fg,
    :bg,
    attrs: [],
    padding: nil,
    margin: nil,
    width: nil,
    height: nil,
    align: nil
  ]

  @type color :: atom() | {integer(), integer(), integer()} | String.t()
  @type text_attr :: :bold | :italic | :underline | :reverse
  @type size :: integer() | :auto | :fill
  @type alignment :: :left | :center | :right | :top | :bottom | :start | :end | :stretch

  @type t :: %__MODULE__{
          fg: color() | nil,
          bg: color() | nil,
          attrs: [text_attr()],
          padding: integer() | nil,
          margin: integer() | nil,
          width: size() | nil,
          height: size() | nil,
          align: alignment() | nil
        }

  @doc """
  Creates a new Style struct from the given keyword list.

  ## Examples

      iex> Style.new(fg: :blue, bg: :white, attrs: [:bold])
      %Style{fg: :blue, bg: :white, attrs: [:bold]}
  """
  @spec new(keyword()) :: t()
  def new(attrs \\ []) do
    struct!(__MODULE__, attrs)
  end

  @doc """
  Merges two styles, with values from `style2` taking precedence.

  The `attrs` lists are concatenated (deduplicated). All other
  fields are simply overridden by the second style if present.

  If either style is `nil`, the other is returned as-is.

  ## Examples

      iex> base = Style.new(fg: :blue, padding: 2, attrs: [:bold])
      iex> override = Style.new(fg: :red, margin: 1, attrs: [:underline])
      iex> Style.merge(base, override)
      %Style{fg: :red, padding: 2, margin: 1, attrs: [:bold, :underline]}
  """
  @spec merge(t() | nil, t() | nil) :: t()
  def merge(nil, nil), do: new()
  def merge(nil, style2), do: style2
  def merge(style1, nil), do: style1

  def merge(style1, style2) do
    merged_attrs =
      (style1.attrs ++ style2.attrs)
      |> Enum.uniq()

    %__MODULE__{
      fg: style2.fg || style1.fg,
      bg: style2.bg || style1.bg,
      attrs: merged_attrs,
      padding: style2.padding || style1.padding,
      margin: style2.margin || style1.margin,
      width: style2.width || style1.width,
      height: style2.height || style1.height,
      align: style2.align || style1.align
    }
  end

  @doc """
  Merges a list of styles, applying them in order (later styles override earlier ones).

  ## Examples

      iex> styles = [Style.new(fg: :blue), Style.new(bg: :white), Style.new(fg: :red)]
      iex> Style.merge_many(styles)
      %Style{fg: :red, bg: :white}
  """
  @spec merge_many([t() | nil]) :: t()
  def merge_many(styles) when is_list(styles) do
    Enum.reduce(styles, new(), fn
      nil, acc -> acc
      style, acc -> merge(acc, style)
    end)
  end
end
