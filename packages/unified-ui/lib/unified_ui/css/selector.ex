defmodule UnifiedUi.Css.Selector do
  @moduledoc """
  Supported CSS selector model for canonical style lowering.

  The selector model is intentionally smaller than browser CSS. It represents
  selectors that can target authored canonical nodes: ids, portable classes,
  widget/component kinds, supported child/descendant structure, and canonical
  state pseudo-classes.
  """

  @type combinator :: nil | :descendant | :child
  @type specificity :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}

  @type simple_selector :: %{
          id: atom() | nil,
          classes: [String.t()],
          kind: atom() | nil,
          states: [atom()]
        }

  @type part :: %{
          combinator: combinator(),
          simple: simple_selector()
        }

  @type selector :: %{
          raw: String.t(),
          parts: [part()],
          specificity: specificity()
        }

  @type diagnostic :: %{
          kind: :unsupported_selector,
          severity: :warning,
          message: String.t(),
          source: map()
        }

  @supported_states %{
    "active" => :active,
    "disabled" => :disabled,
    "focus" => :focused,
    "focus-visible" => :focused,
    "focused" => :focused,
    "selected" => :selected
  }

  @unsupported_patterns [
    {"::", "pseudo-elements are not canonical style selectors"},
    {"[", "attribute selectors are not canonical style selectors"},
    {"]", "attribute selectors are not canonical style selectors"},
    {"+", "sibling combinators are not canonical style selectors"},
    {"~", "sibling combinators are not canonical style selectors"},
    {"*", "universal selectors are not canonical style selectors"},
    {"(", "functional pseudo-classes are not canonical style selectors"}
  ]

  @spec parse_selector_list(String.t(), map()) :: {[selector()], [diagnostic()]}
  def parse_selector_list(selector_text, source \\ %{}) when is_binary(selector_text) do
    selector_text
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reduce({[], []}, fn selector, {selectors, diagnostics} ->
      case parse(selector, source) do
        {:ok, parsed} -> {[parsed | selectors], diagnostics}
        {:error, diagnostic} -> {selectors, [diagnostic | diagnostics]}
      end
    end)
    |> then(fn {selectors, diagnostics} ->
      {Enum.reverse(selectors), Enum.reverse(diagnostics)}
    end)
  end

  @spec parse(String.t(), map()) :: {:ok, selector()} | {:error, diagnostic()}
  def parse(selector, source \\ %{}) when is_binary(selector) do
    selector = String.trim(selector)

    with :ok <- reject_unsupported(selector, source),
         {:ok, parts} <- parse_parts(selector, source) do
      {:ok,
       %{
         raw: selector,
         parts: parts,
         specificity: specificity(parts)
       }}
    end
  end

  defp reject_unsupported(selector, source) do
    case Enum.find(@unsupported_patterns, fn {pattern, _reason} ->
           String.contains?(selector, pattern)
         end) do
      nil ->
        :ok

      {_pattern, reason} ->
        {:error, diagnostic(selector, reason, source)}
    end
  end

  defp parse_parts(selector, source) do
    selector
    |> tokenize()
    |> Enum.reduce_while({[], nil}, fn token, {parts, next_combinator} ->
      cond do
        token == ">" ->
          {:cont, {parts, :child}}

        token == "" ->
          {:cont, {parts, next_combinator}}

        true ->
          case parse_simple(token, source) do
            {:ok, simple} ->
              combinator = if(parts == [], do: nil, else: next_combinator || :descendant)
              {:cont, {[%{combinator: combinator, simple: simple} | parts], nil}}

            {:error, diagnostic} ->
              {:halt, {:error, diagnostic}}
          end
      end
    end)
    |> case do
      {:error, diagnostic} -> {:error, diagnostic}
      {[], _next_combinator} -> {:error, diagnostic(selector, "empty selector", source)}
      {parts, _next_combinator} -> {:ok, Enum.reverse(parts)}
    end
  end

  defp tokenize(selector) do
    selector
    |> String.replace(">", " > ")
    |> String.split(~r/\s+/, trim: true)
  end

  defp parse_simple(token, source) do
    captures = Regex.scan(~r/(^[a-zA-Z_][\w-]*)|([#.][\w-]+)|(:[\w-]+)/, token)
    consumed = captures |> Enum.map(&List.first/1) |> Enum.join("")

    if consumed != token do
      {:error, diagnostic(token, "unsupported selector syntax", source)}
    else
      captures
      |> Enum.map(&List.first/1)
      |> Enum.reduce_while({%{id: nil, classes: [], kind: nil, states: []}, []}, fn item,
                                                                                    {simple,
                                                                                     errors} ->
        cond do
          String.starts_with?(item, "#") ->
            {:cont,
             {%{simple | id: item |> String.trim_leading("#") |> String.to_atom()}, errors}}

          String.starts_with?(item, ".") ->
            class = String.trim_leading(item, ".")
            {:cont, {%{simple | classes: simple.classes ++ [class]}, errors}}

          String.starts_with?(item, ":") ->
            state_name = item |> String.trim_leading(":") |> String.downcase()

            case Map.fetch(@supported_states, state_name) do
              {:ok, state} ->
                {:cont, {%{simple | states: simple.states ++ [state]}, errors}}

              :error ->
                {:halt, {simple, [diagnostic(item, "unsupported pseudo-class", source) | errors]}}
            end

          true ->
            {:cont, {%{simple | kind: String.to_atom(item)}, errors}}
        end
      end)
      |> case do
        {_simple, [diagnostic | _rest]} -> {:error, diagnostic}
        {simple, []} -> {:ok, simple}
      end
    end
  end

  defp specificity(parts) do
    Enum.reduce(parts, {0, 0, 0}, fn %{simple: simple}, {ids, classes, kinds} ->
      {
        ids + if(simple.id, do: 1, else: 0),
        classes + length(simple.classes) + length(simple.states),
        kinds + if(simple.kind, do: 1, else: 0)
      }
    end)
  end

  defp diagnostic(selector, reason, source) do
    %{
      kind: :unsupported_selector,
      severity: :warning,
      message: "Ignored unsupported CSS selector #{inspect(selector)}: #{reason}",
      source: Map.put(source, :selector, selector)
    }
  end
end
