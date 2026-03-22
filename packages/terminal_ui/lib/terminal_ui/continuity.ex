defmodule TerminalUi.Continuity do
  @moduledoc """
  Native-versus-canonical and cross-capability continuity diagnostics for
  `terminal_ui`.
  """

  alias TerminalUi.Inspection
  alias TerminalUi.Runtime.State

  @seams [:widget_identity, :theme_resolution, :style_resolution, :degradation_boundaries]
  @diagnostic_kinds [
    :kind_mismatch,
    :theme_mismatch,
    :resolved_style_mismatch,
    :degradation_mismatch,
    :unexpected_capability_profile
  ]

  @spec seams() :: [atom()]
  def seams, do: @seams

  @spec diagnostic_kinds() :: [atom()]
  def diagnostic_kinds, do: @diagnostic_kinds

  @spec contract() :: map()
  def contract do
    %{
      seams: seams(),
      diagnostic_kinds: diagnostic_kinds(),
      validation: [:pass, :fail]
    }
  end

  @spec compare(State.t(), State.t()) :: map()
  def compare(%State{} = native_state, %State{} = canonical_state) do
    native_snapshot = Inspection.runtime_snapshot(native_state)
    canonical_snapshot = Inspection.runtime_snapshot(canonical_state)

    diagnostics =
      build_diagnostics(
        index_by_id(native_snapshot.style.style_nodes),
        index_by_id(canonical_snapshot.style.style_nodes),
        &continuity_diagnostics/3
      )

    %{
      native: native_snapshot,
      canonical: canonical_snapshot,
      diagnostics: diagnostics,
      continuity: summary(diagnostics)
    }
  end

  @spec compare_capabilities(State.t(), State.t()) :: map()
  def compare_capabilities(%State{} = rich_state, %State{} = fallback_state) do
    rich_snapshot = Inspection.runtime_snapshot(rich_state)
    fallback_snapshot = Inspection.runtime_snapshot(fallback_state)

    diagnostics =
      profile_diagnostics(rich_snapshot, fallback_snapshot) ++
        build_diagnostics(
          index_by_id(rich_snapshot.style.style_nodes),
          index_by_id(fallback_snapshot.style.style_nodes),
          &capability_diagnostics/3
        )

    %{
      rich: rich_snapshot,
      fallback: fallback_snapshot,
      diagnostics: diagnostics,
      continuity: summary(diagnostics)
    }
  end

  defp build_diagnostics(left_nodes, right_nodes, callback) do
    left_nodes
    |> Map.keys()
    |> Enum.filter(&Map.has_key?(right_nodes, &1))
    |> Enum.sort()
    |> Enum.flat_map(fn id -> callback.(id, left_nodes[id], right_nodes[id]) end)
  end

  defp continuity_diagnostics(id, native_node, canonical_node) do
    []
    |> maybe_add_diagnostic(
      native_node.kind != canonical_node.kind,
      :widget_identity,
      :kind_mismatch,
      id,
      native_node.kind,
      canonical_node.kind
    )
    |> maybe_add_diagnostic(
      native_node.theme != canonical_node.theme,
      :theme_resolution,
      :theme_mismatch,
      id,
      native_node.theme,
      canonical_node.theme
    )
    |> maybe_add_diagnostic(
      native_node.resolved_styles != canonical_node.resolved_styles,
      :style_resolution,
      :resolved_style_mismatch,
      id,
      native_node.resolved_styles,
      canonical_node.resolved_styles
    )
    |> maybe_add_diagnostic(
      native_node.degradation != canonical_node.degradation,
      :degradation_boundaries,
      :degradation_mismatch,
      id,
      native_node.degradation,
      canonical_node.degradation
    )
  end

  defp capability_diagnostics(id, rich_node, fallback_node) do
    []
    |> maybe_add_diagnostic(
      rich_node.kind != fallback_node.kind,
      :widget_identity,
      :kind_mismatch,
      id,
      rich_node.kind,
      fallback_node.kind
    )
    |> maybe_add_diagnostic(
      rich_node.theme != fallback_node.theme,
      :theme_resolution,
      :theme_mismatch,
      id,
      rich_node.theme,
      fallback_node.theme
    )
    |> maybe_add_diagnostic(
      rich_node.resolved_styles != fallback_node.resolved_styles,
      :style_resolution,
      :resolved_style_mismatch,
      id,
      rich_node.resolved_styles,
      fallback_node.resolved_styles
    )
  end

  defp profile_diagnostics(rich_snapshot, fallback_snapshot) do
    []
    |> maybe_add_diagnostic(
      rich_snapshot.capabilities.snapshot.degradation_profile != :rich_terminal,
      :degradation_boundaries,
      :unexpected_capability_profile,
      :rich_runtime,
      rich_snapshot.capabilities.snapshot.degradation_profile,
      :rich_terminal
    )
    |> maybe_add_diagnostic(
      fallback_snapshot.capabilities.snapshot.degradation_profile != :fallback_terminal,
      :degradation_boundaries,
      :unexpected_capability_profile,
      :fallback_runtime,
      fallback_snapshot.capabilities.snapshot.degradation_profile,
      :fallback_terminal
    )
  end

  defp summary(diagnostics) do
    %{
      widget_identity_match?: no_reason?(diagnostics, :kind_mismatch),
      theme_resolution_match?: no_reason?(diagnostics, :theme_mismatch),
      style_resolution_match?: no_reason?(diagnostics, :resolved_style_mismatch),
      degradation_bounded?: no_reason?(diagnostics, :degradation_mismatch),
      validation: %{
        status: if(diagnostics == [], do: :pass, else: :fail),
        failing_seams: diagnostics |> Enum.map(& &1.seam) |> Enum.uniq() |> Enum.sort(),
        actionable_output: diagnostics
      }
    }
  end

  defp maybe_add_diagnostic(diagnostics, false, _seam, _reason, _id, _left, _right),
    do: diagnostics

  defp maybe_add_diagnostic(diagnostics, true, seam, reason, id, left, right) do
    diagnostics ++ [%{seam: seam, reason: reason, id: id, left: left, right: right}]
  end

  defp no_reason?(diagnostics, reason) do
    not Enum.any?(diagnostics, &(&1.reason == reason))
  end

  defp index_by_id(nodes) do
    Map.new(nodes, &{to_string(&1.id), &1})
  end
end
