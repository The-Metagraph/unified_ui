defmodule UnifiedUi.Css.Matcher do
  @moduledoc """
  Matches supported CSS selectors against authored `UnifiedUi` nodes.
  """

  alias UnifiedUi.Css.{Parser, Selector}
  alias UnifiedUi.Dsl.Node

  @type indexed_node :: %{
          id: atom() | nil,
          kind: atom() | nil,
          classes: [String.t()],
          states: [atom()],
          node: Node.t(),
          parent_id: atom() | nil,
          path: [non_neg_integer()]
        }

  @type match_result :: %{
          block_id: atom() | nil,
          block_order: non_neg_integer() | nil,
          rule_order: non_neg_integer(),
          selector: Selector.selector(),
          selector_text: String.t(),
          node_id: atom() | nil,
          state: atom() | nil,
          specificity: Selector.specificity(),
          declarations: [Parser.declaration()]
        }

  @type diagnostic :: Selector.diagnostic() | Parser.diagnostic() | map()

  @spec match([Node.t()], [Parser.parsed_stylesheet()], keyword() | map()) :: map()
  def match(nodes, parsed_stylesheets, opts \\ [])
      when is_list(nodes) and is_list(parsed_stylesheets) do
    opts = normalize_opts(opts)
    index = build_index(nodes)

    {matches, diagnostics} =
      parsed_stylesheets
      |> Enum.reduce({[], []}, fn parsed, {matches, diagnostics} ->
        match_stylesheet(parsed, index, opts, matches, diagnostics)
      end)

    %{
      nodes: index,
      matches: Enum.reverse(matches),
      diagnostics: Enum.reverse(diagnostics)
    }
  end

  @spec build_index([Node.t()]) :: [indexed_node()]
  def build_index(nodes) when is_list(nodes) do
    nodes
    |> Enum.with_index()
    |> Enum.flat_map(fn {node, index} -> index_node(node, nil, [index]) end)
  end

  defp index_node(%Node{} = node, parent_id, path) do
    indexed = %{
      id: node.id,
      kind: node.kind,
      classes: UnifiedUi.Css.normalize_classes(node.class, node.classes),
      states: node_states(node),
      node: node,
      parent_id: parent_id,
      path: path
    }

    children =
      node.children
      |> Enum.with_index()
      |> Enum.flat_map(fn {child, index} -> index_node(child, node.id, path ++ [index]) end)

    [indexed | children]
  end

  defp match_stylesheet(parsed, index, opts, matches, diagnostics) do
    Enum.reduce(parsed.rules, {matches, parsed.diagnostics ++ diagnostics}, fn rule,
                                                                               {matches,
                                                                                diagnostics} ->
      source = %{block_id: parsed.block_id, source_order: rule.source_order}
      {selectors, selector_diagnostics} = Selector.parse_selector_list(rule.selector_text, source)

      Enum.reduce(selectors, {matches, selector_diagnostics ++ diagnostics}, fn selector,
                                                                                {matches,
                                                                                 diagnostics} ->
        node_matches = matching_nodes(selector, index)

        diagnostics =
          if node_matches == [] and opts.no_match_diagnostics? do
            [no_match_diagnostic(selector, parsed, rule) | diagnostics]
          else
            diagnostics
          end

        rule_matches =
          Enum.map(node_matches, fn indexed_node ->
            %{
              block_id: parsed.block_id,
              block_order: parsed.source_order,
              rule_order: rule.source_order,
              selector: selector,
              selector_text: selector.raw,
              node_id: indexed_node.id,
              state: selector_target_state(selector),
              specificity: selector.specificity,
              declarations: rule.declarations
            }
          end)

        {Enum.reverse(rule_matches) ++ matches, diagnostics}
      end)
    end)
  end

  defp matching_nodes(selector, index) do
    index_by_id = Map.new(index, &{&1.id, &1})

    Enum.filter(index, fn indexed_node ->
      selector_matches_node?(selector.parts |> Enum.reverse(), indexed_node, index_by_id)
    end)
  end

  defp selector_matches_node?([], _indexed_node, _index_by_id), do: true

  defp selector_matches_node?([target_part | ancestor_parts], indexed_node, index_by_id) do
    simple_matches?(target_part.simple, indexed_node) and
      match_ancestor_parts(ancestor_parts, indexed_node, index_by_id)
  end

  defp match_ancestor_parts([], _indexed_node, _index_by_id), do: true

  defp match_ancestor_parts([part | rest], indexed_node, index_by_id) do
    case part.combinator do
      :child ->
        parent = Map.get(index_by_id, indexed_node.parent_id)

        not is_nil(parent) and simple_matches?(part.simple, parent) and
          match_ancestor_parts(rest, parent, index_by_id)

      _descendant ->
        indexed_node
        |> ancestors(index_by_id)
        |> Enum.any?(fn ancestor ->
          simple_matches?(part.simple, ancestor) and
            match_ancestor_parts(rest, ancestor, index_by_id)
        end)
    end
  end

  defp simple_matches?(simple, indexed_node) do
    id_matches?(simple.id, indexed_node.id) and
      kind_matches?(simple.kind, indexed_node.kind) and
      classes_match?(simple.classes, indexed_node.classes) and
      states_match?(simple.states, indexed_node.states)
  end

  defp id_matches?(nil, _id), do: true
  defp id_matches?(id, id), do: true
  defp id_matches?(_selector_id, _node_id), do: false

  defp kind_matches?(nil, _kind), do: true
  defp kind_matches?(kind, kind), do: true
  defp kind_matches?(_selector_kind, _node_kind), do: false

  defp classes_match?(classes, node_classes) do
    Enum.all?(classes, &(&1 in node_classes))
  end

  defp states_match?(states, node_states) do
    Enum.all?(states, &(&1 in node_states))
  end

  defp ancestors(indexed_node, index_by_id) do
    case Map.get(index_by_id, indexed_node.parent_id) do
      nil -> []
      parent -> [parent | ancestors(parent, index_by_id)]
    end
  end

  defp selector_target_state(selector) do
    selector.parts
    |> List.last()
    |> case do
      nil -> nil
      %{simple: %{states: []}} -> nil
      %{simple: %{states: [state | _rest]}} -> state
    end
  end

  defp node_states(node) do
    []
    |> maybe_state(node.disabled?, :disabled)
    |> maybe_state(node.active?, :active)
    |> maybe_state(node.state == :focused, :focused)
    |> maybe_state(node.state == :selected, :selected)
    |> maybe_state(node.state == :active, :active)
    |> maybe_state(node.state == :disabled, :disabled)
    |> Enum.uniq()
  end

  defp maybe_state(states, true, state), do: [state | states]
  defp maybe_state(states, _condition, _state), do: states

  defp no_match_diagnostic(selector, parsed, rule) do
    %{
      kind: :selector_no_match,
      severity: :info,
      message: "CSS selector #{inspect(selector.raw)} matched no authored nodes",
      source: %{
        block_id: parsed.block_id,
        source_order: rule.source_order,
        selector: selector.raw
      }
    }
  end

  defp normalize_opts(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> normalize_opts()

  defp normalize_opts(opts) when is_map(opts) do
    %{no_match_diagnostics?: Map.get(opts, :no_match_diagnostics?, false)}
  end
end
