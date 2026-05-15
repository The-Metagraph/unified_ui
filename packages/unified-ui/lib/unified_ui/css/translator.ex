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

  defp apply_declaration(style, %{property: "color", value: value}) do
    {:ok, Style.merge(style, %{foreground: value})}
  end

  defp apply_declaration(style, %{property: "background-color", value: value}) do
    {:ok, Style.merge(style, %{background: value})}
  end

  defp apply_declaration(style, %{property: "border-color", value: value}) do
    {:ok, Style.merge(style, %{border_color: value})}
  end

  defp apply_declaration(style, %{property: "font-weight", value: value}) do
    {:ok, Style.merge(style, %{typography: %{font_weight: normalize_font_weight(value)}})}
  end

  defp apply_declaration(style, %{property: "font-style", value: value}) do
    if String.downcase(value) == "italic" do
      {:ok, Style.merge(style, %{typography: %{italic?: true}})}
    else
      ignored_declaration(value, "font-style")
    end
  end

  defp apply_declaration(style, %{property: "text-decoration", value: value}) do
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

  defp apply_declaration(style, %{property: "opacity", value: value}) do
    {:ok, Style.merge(style, %{visibility: %{opacity: value}})}
  end

  defp apply_declaration(style, %{property: property, value: value})
       when property in ["padding", "margin", "gap"] do
    {:ok, Style.merge(style, %{spacing: %{String.to_atom(property) => value}})}
  end

  defp apply_declaration(style, %{property: property, value: value})
       when property in ["width", "height", "min-width", "min-height", "max-width", "max-height"] do
    key = property |> String.replace("-", "_") |> String.to_atom()
    {:ok, Style.merge(style, %{sizing: %{key => value}})}
  end

  defp apply_declaration(style, %{property: "text-align", value: value}) do
    {:ok, Style.merge(style, %{alignment: %{text_align: value}})}
  end

  defp apply_declaration(style, %{property: "border-width", value: value}) do
    {:ok, Style.merge(style, %{border: %{width: value}})}
  end

  defp apply_declaration(style, %{property: "border-radius", value: value}) do
    {:ok, Style.merge(style, %{border: %{radius: value}})}
  end

  defp apply_declaration(style, %{property: "border-style", value: value}) do
    {:ok, Style.merge(style, %{border: %{style: value}})}
  end

  defp apply_declaration(_style, declaration) do
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
      _other -> String.to_atom(String.downcase(value))
    end
  end

  defp ignored_declaration(value, property) do
    {:ignored,
     %{
       kind: :unsupported_value,
       severity: :warning,
       message: "Ignored unsupported CSS value #{inspect(value)} for #{property}",
       source: %{property: property, value: value}
     }}
  end

  defp maybe_put(map, _key, false), do: map
  defp maybe_put(map, key, true), do: Map.put(map, key, true)
end
