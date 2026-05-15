defmodule UnifiedUi.Css.Cascade do
  @moduledoc """
  Resolves CSS-derived declarations by specificity, source order, and
  CSS-derived source precedence.
  """

  alias UnifiedUi.Css.Matcher

  @type declaration_key :: {atom() | nil, atom() | nil, String.t()}

  @type declaration_entry :: %{
          node_id: atom() | nil,
          state: atom() | nil,
          property: String.t(),
          value: String.t(),
          important?: boolean(),
          selector_text: String.t(),
          specificity: Matcher.match_result() | tuple(),
          order: tuple()
        }

  @spec source_precedence() :: [atom()]
  def source_precedence, do: [:theme_defaults, :style_refs, :css, :local_style]

  @spec resolve(map()) :: map()
  def resolve(%{matches: matches, diagnostics: diagnostics}) when is_list(matches) do
    {entries, conflicts} =
      matches
      |> Enum.flat_map(&declaration_entries/1)
      |> Enum.reduce({%{}, []}, &pick_winner/2)

    %{
      declarations: entries,
      styles_by_node: styles_by_node(entries),
      conflicts: Enum.reverse(conflicts),
      diagnostics: diagnostics,
      source_precedence: source_precedence()
    }
  end

  defp declaration_entries(match) do
    match.declarations
    |> Enum.map(fn declaration ->
      %{
        node_id: match.node_id,
        state: match.state,
        property: declaration.property,
        value: declaration.value,
        important?: declaration.important?,
        selector_text: match.selector_text,
        specificity: match.specificity,
        order: {
          Map.get(match, :block_order, 0) || 0,
          match.rule_order,
          declaration.source_order
        }
      }
    end)
  end

  defp pick_winner(entry, {entries, conflicts}) do
    key = {entry.node_id, entry.state, entry.property}

    case Map.fetch(entries, key) do
      :error ->
        {Map.put(entries, key, entry), conflicts}

      {:ok, current} ->
        if outranks?(entry, current) do
          {Map.put(entries, key, entry), [conflict(entry, current, :overrode) | conflicts]}
        else
          {entries, [conflict(current, entry, :retained) | conflicts]}
        end
    end
  end

  defp outranks?(left, right) do
    compare_tuple(left) > compare_tuple(right)
  end

  defp compare_tuple(entry) do
    {
      if(entry.important?, do: 1, else: 0),
      entry.specificity,
      entry.order
    }
  end

  defp conflict(winner, loser, reason) do
    %{
      kind: :css_cascade_conflict,
      reason: reason,
      node_id: winner.node_id,
      state: winner.state,
      property: winner.property,
      winner: provenance(winner),
      loser: provenance(loser)
    }
  end

  defp provenance(entry) do
    %{
      selector: entry.selector_text,
      value: entry.value,
      important?: entry.important?,
      specificity: entry.specificity,
      order: entry.order
    }
  end

  defp styles_by_node(entries) do
    entries
    |> Map.values()
    |> Enum.group_by(& &1.node_id)
    |> Map.new(fn {node_id, node_entries} ->
      {node_id, styles_for_node(node_entries)}
    end)
  end

  defp styles_for_node(entries) do
    %{
      default: declarations_for_state(entries, nil),
      states:
        entries
        |> Enum.reject(&is_nil(&1.state))
        |> Enum.group_by(& &1.state)
        |> Map.new(fn {state, state_entries} ->
          {state, declarations_for_state(state_entries, state)}
        end)
    }
  end

  defp declarations_for_state(entries, state) do
    entries
    |> Enum.filter(&(&1.state == state))
    |> Map.new(fn entry -> {entry.property, entry} end)
  end
end
