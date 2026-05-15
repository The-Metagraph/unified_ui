defmodule UnifiedUi.Css.Parser do
  @moduledoc """
  CSS parser adapter used by the authored CSS style pipeline.

  The adapter keeps parser-specific structs out of the DSL and compiler. It
  currently uses `CSSerpent` for stylesheet parsing and normalizes the parsed
  output into deterministic rule, declaration, and diagnostic maps.
  """

  alias UnifiedUi.Css.Stylesheet

  @type diagnostic :: %{
          kind: atom(),
          severity: :info | :warning | :error,
          message: String.t(),
          source: map()
        }

  @type declaration :: %{
          property: String.t(),
          value: String.t(),
          important?: boolean(),
          source_order: non_neg_integer()
        }

  @type rule :: %{
          type: :style,
          selector_text: String.t(),
          selectors: [String.t()],
          declarations: [declaration()],
          source_order: non_neg_integer(),
          raw: String.t() | nil
        }

  @type parsed_stylesheet :: %{
          parser: :csserpent,
          block_id: atom() | nil,
          source_order: non_neg_integer() | nil,
          rules: [rule()],
          diagnostics: [diagnostic()],
          summary: map()
        }

  @spec parse(Stylesheet.t()) :: parsed_stylesheet()
  def parse(%Stylesheet{} = stylesheet) do
    source = stylesheet.source || ""
    rules = CSSerpent.parse(source, stylesheet.id)

    {normalized_rules, diagnostics} =
      rules
      |> Enum.with_index()
      |> Enum.reduce({[], parser_recovery_diagnostics(source, stylesheet)}, fn {rule, index},
                                                                               {rules,
                                                                                diagnostics} ->
        case normalize_rule(rule, index, stylesheet) do
          {:ok, normalized_rule} ->
            {[normalized_rule | rules], diagnostics}

          {:ignored, diagnostic} ->
            {rules, [diagnostic | diagnostics]}
        end
      end)

    normalized_rules = Enum.reverse(normalized_rules)
    diagnostics = Enum.reverse(diagnostics)

    %{
      parser: :csserpent,
      block_id: stylesheet.id,
      source_order: stylesheet.order,
      rules: normalized_rules,
      diagnostics: diagnostics,
      summary: summary(normalized_rules, diagnostics)
    }
  end

  @spec parse_all([Stylesheet.t()]) :: [parsed_stylesheet()]
  def parse_all(stylesheets) when is_list(stylesheets), do: Enum.map(stylesheets, &parse/1)

  defp normalize_rule(%{identifier: identifier}, index, stylesheet)
       when is_binary(identifier) do
    {:ignored,
     diagnostic(:ignored_at_rule, stylesheet, %{
       source_order: index,
       at_rule: identifier,
       message: "Ignored unsupported CSS at-rule #{identifier}"
     })}
  end

  defp normalize_rule(%{selector: selector, props: props, raw: raw}, index, _stylesheet)
       when is_binary(selector) do
    declarations =
      props
      |> List.wrap()
      |> Enum.with_index()
      |> Enum.map(fn {prop, declaration_index} ->
        normalize_declaration(prop, declaration_index)
      end)
      |> Enum.reject(&is_nil/1)

    {:ok,
     %{
       type: :style,
       selector_text: String.trim(selector),
       selectors: split_selectors(selector),
       declarations: declarations,
       source_order: index,
       raw: raw
     }}
  end

  defp normalize_rule(rule, index, stylesheet) do
    {:ignored,
     diagnostic(:ignored_rule, stylesheet, %{
       source_order: index,
       rule: inspect(rule),
       message: "Ignored CSS rule without supported style-rule shape"
     })}
  end

  defp normalize_declaration(%{property: property, value: value}, index)
       when is_binary(property) and is_binary(value) do
    {value, important?} = split_important(value)

    %{
      property: property |> String.trim() |> String.downcase(),
      value: value,
      important?: important?,
      source_order: index
    }
  end

  defp normalize_declaration(_other, _index), do: nil

  defp split_selectors(selector) do
    selector
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp split_important(value) do
    value = String.trim(value)

    if String.match?(value, ~r/!\s*important\z/i) do
      {value |> String.replace(~r/!\s*important\z/i, "") |> String.trim(), true}
    else
      {value, false}
    end
  end

  defp parser_recovery_diagnostics(source, stylesheet) do
    []
    |> maybe_unbalanced_brace_diagnostic(source, stylesheet, "{", "}")
    |> maybe_empty_source_diagnostic(source, stylesheet)
  end

  defp maybe_unbalanced_brace_diagnostic(diagnostics, source, stylesheet, open, close) do
    opens = source |> String.graphemes() |> Enum.count(&(&1 == open))
    closes = source |> String.graphemes() |> Enum.count(&(&1 == close))

    if opens == closes do
      diagnostics
    else
      [
        diagnostic(:parse_recovery, stylesheet, %{
          message: "CSS parser recovered from unbalanced stylesheet braces",
          opens: opens,
          closes: closes
        })
        | diagnostics
      ]
    end
  end

  defp maybe_empty_source_diagnostic(diagnostics, source, stylesheet) do
    if String.trim(source) == "" do
      [
        diagnostic(:empty_stylesheet, stylesheet, %{
          message: "Ignored empty CSS stylesheet block"
        })
        | diagnostics
      ]
    else
      diagnostics
    end
  end

  defp diagnostic(kind, stylesheet, attrs) do
    message = Map.fetch!(attrs, :message)

    %{
      kind: kind,
      severity: diagnostic_severity(kind),
      message: message,
      source:
        %{
          block_id: stylesheet.id,
          block_order: stylesheet.order
        }
        |> maybe_put(:selector, Map.get(attrs, :selector))
        |> maybe_put(:property, Map.get(attrs, :property))
        |> maybe_put(:source_order, Map.get(attrs, :source_order))
        |> maybe_put(:at_rule, Map.get(attrs, :at_rule))
        |> maybe_put(:opens, Map.get(attrs, :opens))
        |> maybe_put(:closes, Map.get(attrs, :closes))
    }
  end

  defp diagnostic_severity(:parse_recovery), do: :warning
  defp diagnostic_severity(:empty_stylesheet), do: :info
  defp diagnostic_severity(_kind), do: :warning

  defp summary(rules, diagnostics) do
    %{
      rule_count: length(rules),
      declaration_count: rules |> Enum.flat_map(& &1.declarations) |> length(),
      ignored_count: Enum.count(diagnostics, &(&1.kind in [:ignored_at_rule, :ignored_rule])),
      diagnostic_count: length(diagnostics)
    }
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
