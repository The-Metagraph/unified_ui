defmodule UnifiedUi.Dsl.StyleResolver do
  @moduledoc """
  Resolves named styles to IUR.Style structs with inheritance support.

  This module handles the resolution of style references in the DSL to
  actual IUR.Style structs. It supports:
  - Named style references (atoms)
  - Style inheritance via `extends`
  - Merging with inline styles
  - Circular reference detection

  ## Usage

  Resolve a named style:

      iex> StyleResolver.resolve(dsl_state, :header)
      %IUR.Style{fg: :cyan, attrs: [:bold], ...}

  Resolve with inline overrides:

      iex> StyleResolver.resolve(dsl_state, :header, fg: :green)
      %IUR.Style{fg: :green, attrs: [:bold], ...}

  Resolve from a style reference (atom or keyword list):

      iex> StyleResolver.resolve_style_ref(dsl_state, :header)
      %IUR.Style{fg: :cyan, ...}

      iex> StyleResolver.resolve_style_ref(dsl_state, [fg: :red])
      %IUR.Style{fg: :red, ...}

      iex> StyleResolver.resolve_style_ref(dsl_state, [:header, fg: :green])
      %IUR.Style{fg: :green, attrs: [:bold], ...}

  ## Style Inheritance

  When a style extends another, the resolver merges the parent's attributes
  with the child's attributes (child attributes take precedence):

      style :base do
        attributes [fg: :white, bg: :blue, padding: 1]
      end

      style :variant do
        extends :base
        attributes [fg: :yellow]
      end

      # Resolving :variant gives: fg: :yellow, bg: :blue, padding: 1

  """

  alias Spark.Dsl.Transformer
  alias UnifiedIUR.Style
  alias UnifiedUi.Dsl.Style, as: DslStyle
  alias UnifiedUi.Dsl.Theme, as: DslTheme

  @standard_theme_attrs %{
    default: %{
      root: [fg: :black, bg: :white],
      panel: [fg: :black, bg: :white, padding: 1],
      text: [fg: :black],
      muted_text: [fg: :gray],
      accent: [fg: :blue, attrs: [:bold]],
      button: [fg: :white, bg: :blue, attrs: [:bold], padding: 1],
      button_primary: [fg: :white, bg: :blue, attrs: [:bold], padding: 1],
      button_danger: [fg: :white, bg: :red, attrs: [:bold], padding: 1],
      input: [fg: :black, bg: :white]
    },
    dark: %{
      root: [fg: "#f5f5f5", bg: "#111111"],
      panel: [fg: "#f5f5f5", bg: "#1a1a1a", padding: 1],
      text: [fg: "#f5f5f5"],
      muted_text: [fg: "#b0b0b0"],
      accent: [fg: "#66b3ff", attrs: [:bold]],
      button: [fg: "#f5f5f5", bg: "#2d5aa0", attrs: [:bold], padding: 1],
      button_primary: [fg: :white, bg: "#2563eb", attrs: [:bold], padding: 1],
      button_danger: [fg: :white, bg: "#b91c1c", attrs: [:bold], padding: 1],
      input: [fg: "#f5f5f5", bg: "#222222"]
    },
    light: %{
      root: [fg: "#111111", bg: "#ffffff"],
      panel: [fg: "#111111", bg: "#f7f7f7", padding: 1],
      text: [fg: "#111111"],
      muted_text: [fg: "#555555"],
      accent: [fg: "#1d4ed8", attrs: [:bold]],
      button: [fg: :white, bg: "#1d4ed8", attrs: [:bold], padding: 1],
      button_primary: [fg: :white, bg: "#1d4ed8", attrs: [:bold], padding: 1],
      button_danger: [fg: :white, bg: "#dc2626", attrs: [:bold], padding: 1],
      input: [fg: "#111111", bg: "#ffffff"]
    }
  }

  @style_struct_keys [:fg, :bg, :attrs, :padding, :margin, :width, :height, :align]
  @extended_style_keys [
    :spacing,
    :font_family,
    :font_size,
    :font_weight,
    :border,
    :border_width,
    :border_color,
    :border_style
  ]
  @style_keys @style_struct_keys ++ @extended_style_keys

  @doc """
  Resolves a named style to an IUR.Style struct.

  Handles inheritance by recursively resolving parent styles.
  Detects and prevents circular references in style inheritance.

  ## Parameters

  * `dsl_state` - The Spark DSL state
  * `style_name` - The name of the style to resolve (atom)
  * `overrides` - Optional keyword list of attribute overrides

  ## Returns

  An `IUR.Style` struct with merged attributes.

  ## Raises

  Raises `Spark.Error.DslError` if a circular reference is detected.

  ## Examples

      iex> resolve(dsl_state, :header)
      %Style{fg: :cyan, attrs: [:bold], ...}

      iex> resolve(dsl_state, :header, fg: :green)
      %Style{fg: :green, attrs: [:bold], ...}

  """
  @spec resolve(map(), atom(), keyword()) :: Style.t()
  def resolve(dsl_state, style_name, overrides \\ []) when is_atom(style_name) do
    style_entity = find_style(dsl_state, style_name)

    if style_entity do
      resolve_with_inheritance(dsl_state, style_entity, overrides, MapSet.new())
    else
      # Style not found, return empty style with overrides
      new_style(overrides)
    end
  end

  @doc """
  Resolves a style reference to an IUR.Style struct.

  The style reference can be:
  * An atom - named style reference
  * A keyword list - inline styles
  * A list starting with an atom - named style with inline overrides

  ## Parameters

  * `dsl_state` - The Spark DSL state
  * `style_ref` - The style reference to resolve

  ## Returns

  An `IUR.Style` struct or `nil` if style_ref is `nil` or empty list.

  ## Examples

      iex> resolve_style_ref(dsl_state, :header)
      %Style{fg: :cyan, ...}

      iex> resolve_style_ref(dsl_state, [fg: :red])
      %Style{fg: :red, ...}

      iex> resolve_style_ref(dsl_state, [:header, fg: :green])
      %Style{fg: :green, attrs: [:bold], ...}

      iex> resolve_style_ref(dsl_state, nil)
      nil

  """
  @spec resolve_style_ref(map(), atom() | keyword() | list()) :: Style.t() | nil
  def resolve_style_ref(_dsl_state, nil), do: nil
  def resolve_style_ref(_dsl_state, []), do: nil

  def resolve_style_ref(dsl_state, style_name) when is_atom(style_name) do
    resolve(dsl_state, style_name)
  end

  def resolve_style_ref(dsl_state, style_ref) when is_list(style_ref) do
    # Check if this is a list with a named style as first element
    case style_ref do
      [style_name | overrides] when is_atom(style_name) ->
        resolve_or_inline(dsl_state, style_name, overrides)

      _ ->
        # Pure inline styles (keyword list)
        new_style(style_ref)
    end
  end

  @doc """
  Loads a named theme into a map of style tokens to resolved `IUR.Style` structs.

  Theme inheritance is supported via `base_theme`. Local style mappings override
  inherited mappings with the same token.

  Returns an empty map when the theme cannot be found.
  """
  @spec load_theme(map(), atom()) :: %{atom() => Style.t()}
  def load_theme(dsl_state, theme_name) when is_atom(theme_name) do
    case find_theme(dsl_state, theme_name) do
      nil -> load_standard_theme(theme_name)
      theme -> resolve_theme_with_inheritance(dsl_state, theme, MapSet.new())
    end
  end

  # Private functions

  defp resolve_or_inline(dsl_state, style_name, overrides) do
    # Check if this is a valid style name or just inline attributes
    # If the first element is a known style attribute key, treat as pure inline
    if style_name in @style_keys do
      # This is actually inline styles starting with a keyword
      new_style([style_name | overrides])
    else
      # This is a named style reference with overrides
      resolve(dsl_state, style_name, overrides)
    end
  end

  defp find_style(dsl_state, style_name) do
    dsl_state
    |> Transformer.get_entities(:styles)
    |> Enum.find(fn
      %DslStyle{name: ^style_name} -> true
      _ -> false
    end)
  end

  defp find_theme(dsl_state, theme_name) do
    dsl_state
    |> Transformer.get_entities(:styles)
    |> Enum.find(fn
      %DslTheme{name: ^theme_name} -> true
      _ -> false
    end)
  end

  defp resolve_with_inheritance(
         _dsl_state,
         %DslStyle{extends: nil} = style_entity,
         overrides,
         _seen
       ) do
    base_attrs = style_entity.attributes || []
    Style.merge(new_style(base_attrs), new_style(overrides))
  end

  defp resolve_with_inheritance(
         dsl_state,
         %DslStyle{name: name, extends: parent_name} = style_entity,
         overrides,
         seen
       ) do
    # Check for circular reference
    if MapSet.member?(seen, name) do
      module = get_persisted_module(dsl_state)

      raise Spark.Error.DslError,
        module: module,
        path: [:styles, name],
        message: """
        Circular style reference detected

        Style '#{inspect(name)} extends '#{inspect(parent_name)}', which creates a circular reference.

        Style inheritance chain:
        #{format_seen_chain(seen)}

        To fix this, remove the circular reference by having one of the styles not extend the other.
        """
    end

    # Track this style as seen
    seen = MapSet.put(seen, name)

    parent_style = find_style(dsl_state, parent_name)

    if parent_style do
      # Resolve parent first (recursive)
      parent_resolved = resolve_with_inheritance(dsl_state, parent_style, [], seen)
      current_attrs = style_entity.attributes || []

      Style.merge(parent_resolved, new_style(current_attrs))
      |> Style.merge(new_style(overrides))
    else
      # Parent style not found, just use current style
      base_attrs = style_entity.attributes || []
      Style.merge(new_style(base_attrs), new_style(overrides))
    end
  end

  defp get_persisted_module(dsl_state) do
    Spark.Dsl.Verifier.get_persisted(dsl_state, :module)
  end

  defp format_seen_chain(seen) do
    seen
    |> MapSet.to_list()
    |> Enum.map_join("\n", fn style -> "  - #{inspect(style)}" end)
  end

  @doc """
  Gets all named styles defined in the DSL state.

  Returns a map of style_name => DslStyle struct.

  ## Examples

      iex> get_all_styles(dsl_state)
      %{header: %DslStyle{name: :header, ...}, ...}

  """
  @spec get_all_styles(map()) :: %{atom() => DslStyle.t()}
  def get_all_styles(dsl_state) do
    dsl_state
    |> Transformer.get_entities(:styles)
    |> Enum.reduce(%{}, fn
      %DslStyle{name: name} = style, acc -> Map.put(acc, name, style)
      _other, acc -> acc
    end)
  end

  @doc """
  Gets all named themes defined in the DSL state.

  Returns a map of `theme_name => DslTheme` structs.
  """
  @spec get_all_themes(map()) :: %{atom() => DslTheme.t()}
  def get_all_themes(dsl_state) do
    dsl_state
    |> Transformer.get_entities(:styles)
    |> Enum.reduce(%{}, fn
      %DslTheme{name: name} = theme, acc -> Map.put(acc, name, theme)
      _other, acc -> acc
    end)
  end

  @doc """
  Validates that a style reference is valid.

  Returns `:ok` if the style exists, `{:error, :style_not_found}` if not.

  ## Examples

      iex> validate_style_ref(dsl_state, :header)
      :ok

      iex> validate_style_ref(dsl_state, :nonexistent)
      {:error, :style_not_found}

  Inline styles (lists) always return `:ok`.

  """
  @spec validate_style_ref(map(), atom() | list()) :: :ok | {:error, atom()}
  def validate_style_ref(_dsl_state, style_ref) when is_list(style_ref), do: :ok
  def validate_style_ref(_dsl_state, nil), do: :ok

  def validate_style_ref(dsl_state, style_name) when is_atom(style_name) do
    case find_style(dsl_state, style_name) do
      nil -> {:error, :style_not_found}
      _style -> :ok
    end
  end

  defp resolve_theme_with_inheritance(
         dsl_state,
         %DslTheme{base_theme: nil, styles: styles},
         _seen
       ) do
    normalize_theme_styles(dsl_state, styles)
  end

  defp resolve_theme_with_inheritance(
         dsl_state,
         %DslTheme{name: name, base_theme: base_theme, styles: styles},
         seen
       ) do
    if MapSet.member?(seen, name) do
      module = get_persisted_module(dsl_state)

      raise Spark.Error.DslError,
        module: module,
        path: [:styles, name],
        message: """
        Circular theme inheritance detected

        Theme '#{inspect(name)} inherits from '#{inspect(base_theme)}', which creates a circular reference.

        Theme inheritance chain:
        #{format_seen_chain(seen)}

        To fix this, remove the circular reference by adjusting `base_theme`.
        """
    end

    seen = MapSet.put(seen, name)

    inherited =
      case find_theme(dsl_state, base_theme) do
        nil -> load_standard_theme(base_theme)
        parent_theme -> resolve_theme_with_inheritance(dsl_state, parent_theme, seen)
      end

    Map.merge(inherited, normalize_theme_styles(dsl_state, styles))
  end

  defp normalize_theme_styles(dsl_state, styles) when is_list(styles) do
    Enum.reduce(styles, %{}, fn
      {token, style_ref}, acc when is_atom(token) ->
        case normalize_theme_style_ref(dsl_state, style_ref) do
          nil -> acc
          normalized -> Map.put(acc, token, normalized)
        end

      _entry, acc ->
        acc
    end)
  end

  defp normalize_theme_styles(_dsl_state, _styles), do: %{}

  defp normalize_theme_style_ref(_dsl_state, %Style{} = style), do: style

  defp normalize_theme_style_ref(dsl_state, style_ref) do
    case style_ref do
      nil -> nil
      ref when is_atom(ref) or is_list(ref) -> resolve_style_ref(dsl_state, ref)
      _ -> nil
    end
  end

  defp load_standard_theme(theme_name) when is_atom(theme_name) do
    @standard_theme_attrs
    |> Map.get(theme_name, %{})
    |> Enum.into(%{}, fn {token, attrs} -> {token, new_style(attrs)} end)
  end

  defp new_style(attrs) when is_list(attrs) do
    attrs = normalize_style_keyword(attrs)
    Style.new(attrs)
  end

  defp new_style(_attrs), do: Style.new([])

  defp normalize_style_keyword(attrs) when is_list(attrs) do
    attrs = if Keyword.keyword?(attrs), do: attrs, else: []
    known = Keyword.take(attrs, @style_struct_keys)

    merged_attrs =
      known
      |> Keyword.get(:attrs, [])
      |> normalize_text_attrs()
      |> Kernel.++(encode_extended_attrs(attrs))
      |> Enum.uniq()

    known
    |> Keyword.put(:attrs, merged_attrs)
  end

  defp normalize_style_keyword(_attrs), do: [attrs: []]

  defp normalize_text_attrs(attrs) when is_list(attrs), do: attrs
  defp normalize_text_attrs(_attrs), do: []

  defp encode_extended_attrs(attrs) do
    attrs
    |> Enum.reduce([], fn
      {:spacing, value}, acc ->
        maybe_add_extended(acc, :spacing, normalize_non_negative_integer(value))

      {:font_family, value}, acc when is_binary(value) ->
        maybe_add_extended(acc, :font_family, value)

      {:font_size, value}, acc ->
        maybe_add_extended(acc, :font_size, normalize_font_size(value))

      {:font_weight, value}, acc ->
        acc
        |> maybe_add_extended(:font_weight, normalize_font_weight(value))
        |> maybe_add_bold_attr(value)

      {:border, value}, acc ->
        maybe_add_extended(acc, :border, normalize_border(value))

      {:border_width, value}, acc ->
        maybe_add_extended(acc, :border_width, normalize_non_negative_integer(value))

      {:border_color, value}, acc ->
        maybe_add_extended(acc, :border_color, normalize_color(value))

      {:border_style, value}, acc ->
        maybe_add_extended(acc, :border_style, normalize_border_style(value))

      {_key, _value}, acc ->
        acc
    end)
    |> Enum.reverse()
  end

  defp maybe_add_extended(acc, _key, nil), do: acc
  defp maybe_add_extended(acc, key, value), do: [{key, value} | acc]

  defp maybe_add_bold_attr(acc, value) do
    if bold_weight?(value), do: [:bold | acc], else: acc
  end

  defp bold_weight?(:bold), do: true
  defp bold_weight?(value) when is_integer(value) and value >= 600, do: true
  defp bold_weight?(_value), do: false

  defp normalize_non_negative_integer(value) when is_integer(value) and value >= 0, do: value
  defp normalize_non_negative_integer(_value), do: nil

  defp normalize_font_size(value) when is_integer(value) and value > 0, do: value

  defp normalize_font_size(value) when is_binary(value) and byte_size(value) > 0,
    do: value

  defp normalize_font_size(_value), do: nil

  defp normalize_font_weight(value)
       when value in [:normal, :bold, :bolder, :lighter] do
    value
  end

  defp normalize_font_weight(value) when is_integer(value) and value >= 100 and value <= 900,
    do: value

  defp normalize_font_weight(_value), do: nil

  defp normalize_border(value) when is_binary(value) and byte_size(value) > 0, do: value
  defp normalize_border(value) when is_integer(value) and value >= 0, do: %{width: value}
  defp normalize_border(value) when is_map(value), do: normalize_border_map(value)

  defp normalize_border(value) when is_list(value) do
    if Keyword.keyword?(value) do
      value
      |> Enum.into(%{})
      |> normalize_border_map()
    else
      nil
    end
  end

  defp normalize_border(_value), do: nil

  defp normalize_border_map(border) do
    width =
      map_get(border, :width)
      |> normalize_non_negative_integer()

    color =
      border
      |> map_get(:color)
      |> normalize_color()

    style =
      border
      |> map_get(:style)
      |> normalize_border_style()

    %{}
    |> maybe_put(:width, width)
    |> maybe_put(:color, color)
    |> maybe_put(:style, style)
    |> case do
      map when map_size(map) == 0 -> nil
      map -> map
    end
  end

  defp normalize_color(value) when is_atom(value), do: value
  defp normalize_color(value) when is_binary(value), do: value

  defp normalize_color({r, g, b}) when is_integer(r) and is_integer(g) and is_integer(b),
    do: {r, g, b}

  defp normalize_color({r, g, b, a})
       when is_integer(r) and is_integer(g) and is_integer(b) and is_integer(a), do: {r, g, b, a}

  defp normalize_color(_value), do: nil

  defp normalize_border_style(value) when value in [:none, :solid, :dashed, :dotted, :double],
    do: value

  defp normalize_border_style(_value), do: nil

  defp map_get(map, key) when is_map(map),
    do: Map.get(map, key) || Map.get(map, Atom.to_string(key))

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
