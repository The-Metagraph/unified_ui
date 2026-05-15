defmodule UnifiedUi.Css do
  @moduledoc """
  Authored CSS stylesheet block helpers for `UnifiedUi`.

  CSS blocks are an authoring input. Later compiler passes parse and lower
  supported CSS meaning into canonical style data.
  """

  alias Spark.Dsl.Extension
  alias UnifiedUi.Css.Parser
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

    %{
      count: length(stylesheets),
      blocks: Enum.map(stylesheets, &Stylesheet.summary/1)
    }
  end

  @spec parse_module(module()) :: [Parser.parsed_stylesheet()]
  def parse_module(module) when is_atom(module) do
    module
    |> stylesheets()
    |> Parser.parse_all()
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
