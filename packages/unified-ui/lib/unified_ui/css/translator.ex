defmodule UnifiedUi.Css.Translator do
  @moduledoc """
  Translates cascaded CSS declarations into canonical `UnifiedUi.Style` values.
  """

  alias UnifiedUi.Style

  @type translated_node_styles :: %{
          default: Style.t(),
          states: %{optional(atom()) => Style.t()}
        }

  @spec translate(map()) :: map()
  def translate(%{styles_by_node: styles_by_node, diagnostics: diagnostics} = cascade) do
    {translated, translation_diagnostics} =
      Map.new(styles_by_node, fn {node_id, styles} ->
        {node_id, translate_node_styles(styles)}
      end)
      |> collect_translation_diagnostics()

    %{
      styles_by_node: translated,
      diagnostics: diagnostics ++ translation_diagnostics,
      conflicts: Map.get(cascade, :conflicts, []),
      source_precedence: Map.get(cascade, :source_precedence, [])
    }
  end

  defp translate_node_styles(styles) do
    default = translate_declarations(styles.default)

    states =
      styles.states
      |> Map.new(fn {state, declarations} ->
        {state, translate_declarations(declarations)}
      end)

    %{default: default, states: states}
  end

  defp translate_declarations(declarations) do
    declarations
    |> Map.values()
    |> Enum.sort_by(& &1.order)
    |> Enum.reduce({Style.new(nil), []}, fn declaration, {style, diagnostics} ->
      case apply_declaration(style, declaration) do
        {:ok, style} -> {style, diagnostics}
        {:ignored, diagnostic} -> {style, [diagnostic | diagnostics]}
      end
    end)
    |> then(fn {style, diagnostics} ->
      %{style: style, diagnostics: Enum.reverse(diagnostics)}
    end)
  end

  defp apply_declaration(style, declaration) do
    cond do
      unsafe_value?(declaration.value) ->
        unsafe_declaration(declaration)

      unsupported_function_value?(declaration.value) ->
        unsupported_function_declaration(declaration)

      custom_property?(declaration.property) ->
        unsupported_custom_property(declaration)

      true ->
        apply_supported_declaration(style, declaration)
    end
  end

  defp apply_supported_declaration(style, %{property: "color", value: value}) do
    {:ok, Style.merge(style, %{foreground: normalize_color(value)})}
  end

  defp apply_supported_declaration(style, %{property: "background-color", value: value}) do
    {:ok, Style.merge(style, %{background: normalize_color(value)})}
  end

  defp apply_supported_declaration(style, %{property: "border-color", value: value}) do
    {:ok, Style.merge(style, %{border_color: normalize_color(value)})}
  end

  defp apply_supported_declaration(style, %{property: "font-weight", value: value}) do
    {:ok, Style.merge(style, %{typography: %{font_weight: normalize_font_weight(value)}})}
  end

  defp apply_supported_declaration(style, %{property: "font-style", value: value}) do
    if String.downcase(value) == "italic" do
      {:ok, Style.merge(style, %{typography: %{italic?: true}})}
    else
      ignored_declaration(value, "font-style")
    end
  end

  defp apply_supported_declaration(style, %{property: "text-decoration", value: value}) do
    values = value |> String.downcase() |> String.split(~r/\s+/, trim: true)

    decoration =
      %{}
      |> maybe_put(:underline?, "underline" in values)
      |> maybe_put(:strikethrough?, "line-through" in values)

    if decoration == %{} do
      ignored_declaration(value, "text-decoration")
    else
      {:ok, Style.merge(style, %{typography: decoration})}
    end
  end

  defp apply_supported_declaration(style, %{property: "opacity", value: value}) do
    {:ok, Style.merge(style, %{visibility: %{opacity: normalize_number(value)}})}
  end

  defp apply_supported_declaration(style, %{property: property, value: value})
       when property in ["padding", "margin"] do
    {:ok, Style.merge(style, %{spacing: expand_box_shorthand(property, value)})}
  end

  defp apply_supported_declaration(style, %{property: property, value: value})
       when property in [
              "padding-top",
              "padding-right",
              "padding-bottom",
              "padding-left",
              "margin-top",
              "margin-right",
              "margin-bottom",
              "margin-left",
              "gap"
            ] do
    {:ok, Style.merge(style, %{spacing: %{css_key(property) => normalize_length(value)}})}
  end

  defp apply_supported_declaration(style, %{property: property, value: value})
       when property in ["width", "height", "min-width", "min-height", "max-width", "max-height"] do
    {:ok, Style.merge(style, %{sizing: %{css_key(property) => normalize_length(value)}})}
  end

  defp apply_supported_declaration(style, %{property: "text-align", value: value}) do
    {:ok, Style.merge(style, %{alignment: %{text_align: normalize_keyword(value)}})}
  end

  defp apply_supported_declaration(style, %{property: "border-width", value: value}) do
    {:ok, Style.merge(style, %{border: %{width: normalize_box_value(value)}})}
  end

  defp apply_supported_declaration(style, %{property: "border-radius", value: value}) do
    {:ok, Style.merge(style, %{border: %{radius: normalize_box_value(value)}})}
  end

  defp apply_supported_declaration(style, %{property: "border-style", value: value}) do
    {:ok, Style.merge(style, %{border: %{style: normalize_keyword(value)}})}
  end

  defp apply_supported_declaration(style, %{property: "font", value: value}) do
    case normalize_font_shorthand(value) do
      %{} = font when map_size(font) > 0 -> {:ok, Style.merge(style, %{typography: font})}
      _other -> ignored_declaration(value, "font")
    end
  end

  defp apply_supported_declaration(_style, declaration) do
    {:ignored,
     %{
       kind: :unsupported_property,
       severity: :warning,
       message: "Ignored unsupported CSS property #{inspect(declaration.property)}",
       source: %{
         node_id: declaration.node_id,
         state: declaration.state,
         selector: declaration.selector_text,
         property: declaration.property
       }
     }}
  end

  defp collect_translation_diagnostics(translated) do
    diagnostics =
      translated
      |> Enum.flat_map(fn {_node_id, styles} ->
        styles.default.diagnostics ++
          Enum.flat_map(styles.states, fn {_state, state_style} -> state_style.diagnostics end)
      end)

    styles =
      Map.new(translated, fn {node_id, styles} ->
        {
          node_id,
          %{
            default: styles.default.style,
            states:
              Map.new(styles.states, fn {state, state_style} -> {state, state_style.style} end)
          }
        }
      end)

    {styles, diagnostics}
  end

  defp normalize_font_weight(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _other -> normalize_keyword(value)
    end
  end

  defp normalize_color(value) do
    value = String.trim(value)

    cond do
      match = Regex.run(~r/^#([0-9a-fA-F]{3})$/, value) ->
        match
        |> List.last()
        |> String.graphemes()
        |> Enum.map(&String.duplicate(&1, 2))
        |> Enum.map(&String.to_integer(&1, 16))
        |> then(fn [red, green, blue] -> {:rgb, red, green, blue} end)

      match = Regex.run(~r/^#([0-9a-fA-F]{6})$/, value) ->
        match
        |> List.last()
        |> String.graphemes()
        |> Enum.chunk_every(2)
        |> Enum.map(&(&1 |> Enum.join() |> String.to_integer(16)))
        |> then(fn [red, green, blue] -> {:rgb, red, green, blue} end)

      match = Regex.run(~r/^rgba?\(([^)]+)\)$/i, value) ->
        match
        |> List.last()
        |> String.split(",", trim: true)
        |> Enum.take(3)
        |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))
        |> then(fn [red, green, blue] -> {:rgb, red, green, blue} end)

      true ->
        normalize_keyword(value)
    end
  end

  defp normalize_length(value) do
    value = String.trim(value)

    cond do
      value == "0" ->
        0

      match = Regex.run(~r/^(-?\d+(?:\.\d+)?)(px|rem|em|ch|vh|vw)$/i, value) ->
        [_, number, unit] = match
        %{value: normalize_number(number), unit: unit |> String.downcase() |> String.to_atom()}

      match = Regex.run(~r/^(-?\d+(?:\.\d+)?)%$/i, value) ->
        [_, number] = match
        %{value: normalize_number(number), unit: :percent}

      true ->
        normalize_keyword(value)
    end
  end

  defp normalize_number(value) when is_integer(value) or is_float(value), do: value

  defp normalize_number(value) when is_binary(value) do
    value = String.trim(value)

    case Integer.parse(value) do
      {integer, ""} ->
        integer

      _other ->
        case Float.parse(value) do
          {float, ""} -> float
          _other -> value
        end
    end
  end

  defp normalize_keyword(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  defp normalize_box_value(value) do
    values = value |> String.split(~r/\s+/, trim: true) |> Enum.map(&normalize_length/1)

    case values do
      [one] -> one
      [_top, _right, _bottom, _left] -> box_map(values)
      [_top, _right, _bottom] -> box_map(values)
      [_top, _right] -> box_map(values)
      _other -> value
    end
  end

  defp expand_box_shorthand(property, value) do
    value
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&normalize_length/1)
    |> box_map()
    |> Map.new(fn {side, side_value} -> {String.to_atom("#{property}_#{side}"), side_value} end)
  end

  defp box_map([one]), do: %{top: one, right: one, bottom: one, left: one}

  defp box_map([vertical, horizontal]),
    do: %{top: vertical, right: horizontal, bottom: vertical, left: horizontal}

  defp box_map([top, horizontal, bottom]),
    do: %{top: top, right: horizontal, bottom: bottom, left: horizontal}

  defp box_map([top, right, bottom, left]),
    do: %{top: top, right: right, bottom: bottom, left: left}

  defp box_map(values), do: %{value: values}

  defp normalize_font_shorthand(value) do
    values = value |> String.downcase() |> String.split(~r/\s+/, trim: true)

    %{}
    |> maybe_put(:italic?, "italic" in values)
    |> maybe_put(:font_weight, Enum.find_value(values, &font_weight_token/1))
    |> maybe_put(:font_size, Enum.find_value(values, &font_size_token/1))
  end

  defp font_weight_token("bold"), do: :bold

  defp font_weight_token(value),
    do: if(String.match?(value, ~r/^\d+$/), do: normalize_font_weight(value))

  defp font_size_token(value) do
    if String.match?(value, ~r/^\d/) and String.contains?(value, ["/", "px", "rem", "em", "%"]) do
      value
      |> String.split("/", parts: 2)
      |> hd()
      |> normalize_length()
    end
  end

  defp css_key(property), do: property |> String.replace("-", "_") |> String.to_atom()

  defp ignored_declaration(value, property) do
    {:ignored,
     %{
       kind: :unsupported_value,
       severity: :warning,
       message: "Ignored unsupported CSS value #{inspect(value)} for #{property}",
       source: %{property: property, value: value}
     }}
  end

  defp unsafe_value?(value) when is_binary(value) do
    value |> String.downcase() |> String.contains?("url(")
  end

  defp unsafe_value?(_value), do: false

  defp unsupported_function_value?(value) when is_binary(value) do
    lowered = String.downcase(value)
    String.contains?(lowered, "calc(") or String.contains?(lowered, "var(")
  end

  defp unsupported_function_value?(_value), do: false

  defp custom_property?(property) when is_binary(property),
    do: String.starts_with?(property, "--")

  defp custom_property?(_property), do: false

  defp unsafe_declaration(declaration) do
    {:ignored,
     %{
       kind: :unsafe_external_resource,
       severity: :warning,
       message: "Ignored CSS declaration with unsafe external resource value",
       source: declaration_source(declaration)
     }}
  end

  defp unsupported_function_declaration(declaration) do
    {:ignored,
     %{
       kind: :unsupported_function,
       severity: :warning,
       message: "Ignored CSS declaration with unsupported function value",
       source: declaration_source(declaration)
     }}
  end

  defp unsupported_custom_property(declaration) do
    {:ignored,
     %{
       kind: :unsupported_custom_property,
       severity: :warning,
       message: "Ignored unsupported CSS custom property",
       source: declaration_source(declaration)
     }}
  end

  defp declaration_source(declaration) do
    %{
      node_id: declaration.node_id,
      state: declaration.state,
      selector: declaration.selector_text,
      property: declaration.property,
      value: declaration.value
    }
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, false), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
