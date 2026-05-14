defmodule TerminalUi.Inspection do
  @moduledoc """
  Package and runtime inspection helpers for `terminal_ui`.
  """

  alias TerminalUi.Runtime.State

  @spec helpers() :: [atom()]
  def helpers do
    [:package_overview, :runtime_snapshot, :realization_nodes, :style_nodes, :degradation_nodes]
  end

  @spec package_overview() :: map()
  def package_overview do
    %{
      widgets: %{
        families: TerminalUi.Widgets.families(),
        kinds: TerminalUi.Widgets.kinds()
      },
      style: %{
        primitives: Map.keys(TerminalUi.Style.primitives()),
        hooks: TerminalUi.Style.widget_style_hooks(),
        responsibilities: TerminalUi.Style.responsibilities()
      },
      theme: %{
        catalog: TerminalUi.Theme.catalog_ids(),
        default: TerminalUi.Theme.default_theme().id,
        continuity_rules: TerminalUi.Theme.continuity_rules()
      },
      degradation: %{
        responsibilities: TerminalUi.Degradation.responsibilities(),
        profiles: TerminalUi.Capabilities.profiles()
      },
      runtime: %{
        capabilities: TerminalUi.Runtime.capabilities(),
        assumptions: TerminalUi.Runtime.assumptions(),
        modules: TerminalUi.Runtime.modules()
      }
    }
  end

  @spec runtime_snapshot(State.t()) :: map()
  def runtime_snapshot(%State{} = state) do
    nodes = realization_nodes(state.realization.tree)
    capability_diagnostics = TerminalUi.Capabilities.diagnostics(capabilities: state.capabilities)

    %{
      runtime: %{
        runtime_id: state.runtime_id,
        screen_id: state.screen_id,
        source_kind: state.source_kind,
        backend_mode: state.backend_mode,
        validation_state: state.validation_state,
        theme: Map.get(state.screen.metadata, :theme)
      },
      capabilities: %{
        snapshot: state.capabilities,
        diagnostics: capability_diagnostics
      },
      style: %{
        themes: nodes |> Enum.map(& &1.theme) |> Enum.uniq() |> Enum.sort(),
        style_nodes: style_nodes(nodes),
        diagnostics: Enum.flat_map(nodes, & &1.style_diagnostics)
      },
      degradation: %{
        plan: TerminalUi.Degradation.plan(state.capabilities),
        active: degradation_nodes(nodes)
      },
      navigation: state.navigation,
      event_loop: TerminalUi.Runtime.EventLoop.diagnostics(state.event_loop)
    }
  end

  @spec realization_nodes(map()) :: [map()]
  def realization_nodes(tree) when is_map(tree) do
    collect_nodes(tree)
  end

  @spec style_nodes([map()]) :: [map()]
  def style_nodes(nodes) when is_list(nodes) do
    Enum.map(nodes, fn node ->
      %{
        id: node.id,
        kind: node.kind,
        family: node.family,
        theme: node.theme,
        resolved_styles: node.resolved_styles,
        degradation: node.degradation,
        style_diagnostics: node.style_diagnostics
      }
    end)
  end

  @spec degradation_nodes([map()]) :: [map()]
  def degradation_nodes(nodes) when is_list(nodes) do
    nodes
    |> Enum.filter(&(not is_nil(&1.degradation)))
    |> Enum.map(fn node ->
      %{id: node.id, kind: node.kind, degradation: node.degradation, theme: node.theme}
    end)
  end

  defp collect_nodes(node) do
    [
      %{
        id: node.id,
        kind: node.kind,
        family: node.family,
        theme: get_in(node, [:theme, :id]),
        active_states: get_in(node, [:theme, :active_states]) || [],
        token_refs: get_in(node, [:theme, :token_refs]) || %{},
        resolved_styles: Map.get(node, :resolved_styles, %{}),
        degradation: Map.get(node, :degradation),
        style_diagnostics: Map.get(node, :style_diagnostics, [])
      }
    ] ++ Enum.flat_map(node.children, &collect_nodes/1)
  end
end
