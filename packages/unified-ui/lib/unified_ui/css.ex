defmodule UnifiedUi.Css do
  @moduledoc """
  Authored CSS stylesheet block helpers for `UnifiedUi`.

  CSS blocks are an authoring input. Later compiler passes parse and lower
  supported CSS meaning into canonical style data.
  """

  alias Spark.Dsl.Extension
  alias UnifiedUi.Css.{Cascade, Matcher, Parser}
  alias UnifiedUi.Css.Stylesheet

  @spec stylesheets(module()) :: [Stylesheet.t()]
  def stylesheets(module) when is_atom(module) do
    module
    |> Extension.get_entities([:themes])
    |> Enum.filter(&match?(%Stylesheet{}, &1))
    |> Enum.with_index()
    |> Enum.map(fn {stylesheet, order} ->
      stylesheet
      |> Stylesheet.new()
      |> Map.put(:order, order)
    end)
  end

  @spec module_summary(module()) :: map()
  def module_summary(module) when is_atom(module) do
    stylesheets = stylesheets(module)
    parsed = Parser.parse_all(stylesheets)
    parse_summary = parsed_summary(parsed)

    %{
      count: length(stylesheets),
      blocks: Enum.map(stylesheets, &Stylesheet.summary/1),
      parser: parse_summary.parser,
      rule_count: parse_summary.rule_count,
      declaration_count: parse_summary.declaration_count,
      ignored_count: parse_summary.ignored_count,
      diagnostic_count: parse_summary.diagnostic_count
    }
  end

  @spec parse_module(module()) :: [Parser.parsed_stylesheet()]
  def parse_module(module) when is_atom(module) do
    module
    |> stylesheets()
    |> Parser.parse_all()
  end

  @spec inspection(module()) :: map()
  def inspection(module) when is_atom(module) do
    parsed = parse_module(module)
    summary = parsed_summary(parsed)

    %{
      summary: summary,
      blocks:
        Enum.map(parsed, fn block ->
          %{
            id: block.block_id,
            source_order: block.source_order,
            parser: block.parser,
            summary: block.summary,
            diagnostics: block.diagnostics
          }
        end),
      diagnostics: diagnostics(parsed)
    }
  end

  @spec diagnostics(module() | [Parser.parsed_stylesheet()]) :: [Parser.diagnostic()]
  def diagnostics(module) when is_atom(module), do: module |> parse_module() |> diagnostics()

  def diagnostics(parsed_stylesheets) when is_list(parsed_stylesheets) do
    Enum.flat_map(parsed_stylesheets, & &1.diagnostics)
  end

  @spec match_module(module(), keyword() | map()) :: map()
  def match_module(module, opts \\ []) when is_atom(module) do
    module
    |> UnifiedUi.Info.composition_nodes()
    |> Matcher.match(parse_module(module), opts)
  end

  @spec cascade_module(module(), keyword() | map()) :: map()
  def cascade_module(module, opts \\ []) when is_atom(module) do
    module
    |> match_module(opts)
    |> Cascade.resolve()
  end

  defp parsed_summary(parsed_stylesheets) do
    %{
      parser: :csserpent,
      block_count: length(parsed_stylesheets),
      rule_count: sum_summary(parsed_stylesheets, :rule_count),
      declaration_count: sum_summary(parsed_stylesheets, :declaration_count),
      ignored_count: sum_summary(parsed_stylesheets, :ignored_count),
      diagnostic_count: sum_summary(parsed_stylesheets, :diagnostic_count)
    }
  end

  defp sum_summary(parsed_stylesheets, key) do
    Enum.reduce(parsed_stylesheets, 0, fn parsed, total ->
      total + Map.get(parsed.summary, key, 0)
    end)
  end

  @spec normalize_classes(String.t() | nil, [String.t()] | nil) :: [String.t()]
  def normalize_classes(class, classes \\ [])

  def normalize_classes(class, classes) do
    [split_class_string(class) | List.wrap(classes)]
    |> List.flatten()
    |> Enum.map(&normalize_class/1)
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()
  end

  @spec class_string(String.t() | nil, [String.t()] | nil) :: String.t() | nil
  def class_string(class, classes \\ []) do
    case normalize_classes(class, classes) do
      [] -> nil
      normalized -> Enum.join(normalized, " ")
    end
  end

  defp split_class_string(nil), do: []

  defp split_class_string(class) when is_binary(class) do
    class
    |> String.split(~r/\s+/, trim: true)
  end

  defp split_class_string(class), do: [class]

  defp normalize_class(class) when is_atom(class), do: Atom.to_string(class)
  defp normalize_class(class) when is_binary(class), do: String.trim(class)
  defp normalize_class(class), do: class |> to_string() |> String.trim()
end
