defmodule TerminalUi.Degradation do
  @moduledoc """
  Explicit capability-aware degradation planning for `terminal_ui`.
  """

  alias TerminalUi.Widget

  @overlay_kinds [:overlay, :popover, :dialog, :toast, :alert_dialog]
  @menu_kinds [:context_menu, :command_palette]
  @canvas_kinds [:canvas, :canvas_surface, :absolute, :positioned]
  @scroll_kinds [:viewport, :scroll_region]
  @component_degradations %{
    avatar: :initials_avatar,
    presence_dot: :text_presence,
    list_item_multi_column: :stacked_row,
    segmented_progress_bar: :ascii_progress,
    sticky_frosted_header: :plain_header,
    slide_over_panel: :inline_panel,
    event_callout: :inline_callout,
    redline_inline: :plain_redline_tokens,
    code_block_syntax_highlighted: :plain_code_tokens
  }

  @spec modules() :: [module()]
  def modules, do: [__MODULE__]

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [
      :capability_boundaries,
      :explicit_fallback_decisions,
      :bounded_variation_contract,
      :shared_runtime_preservation
    ]
  end

  @spec plan(map() | keyword()) :: map()
  def plan(snapshot_or_opts) do
    snapshot = normalize_snapshot(snapshot_or_opts)

    %{
      profile: snapshot.degradation_profile,
      glyph_set: snapshot.glyph_set,
      color_mode: snapshot.color_mode,
      pointer_mode: if(snapshot.mouse, do: :direct_mouse, else: :keyboard_fallback),
      overlay_mode: fallback_for_kind(:overlay, snapshot),
      menu_mode: fallback_for_kind(:context_menu, snapshot),
      canvas_mode: fallback_for_kind(:canvas, snapshot),
      scroll_mode: fallback_for_kind(:viewport, snapshot),
      component_modes: component_summary(snapshot),
      allowed_variation: TerminalUi.Capabilities.allowed_variation(snapshot)
    }
  end

  @spec resolve(Widget.t(), keyword()) :: atom() | nil
  def resolve(%Widget{} = widget, opts \\ []) do
    snapshot = normalize_snapshot(opts)

    explicit =
      Map.get(widget.metadata, :degradation_strategy) || Map.get(widget.styles, :degradation)

    cond do
      not is_nil(explicit) and snapshot.backend_mode == :tty ->
        explicit

      snapshot.backend_mode != :tty ->
        nil

      widget.kind in @overlay_kinds ->
        :inline_overlay

      widget.kind in @menu_kinds ->
        :inline_menu_selection

      widget.kind in @canvas_kinds and snapshot.glyph_set == :ascii ->
        :ascii_canvas

      widget.kind in @scroll_kinds ->
        :paged_scroll

      widget.family == :component ->
        Map.get(@component_degradations, widget.kind)

      true ->
        nil
    end
  end

  @spec component_summary(map() | keyword()) :: map()
  def component_summary(snapshot_or_opts \\ []) do
    snapshot = normalize_snapshot(snapshot_or_opts)

    if snapshot.backend_mode == :tty do
      @component_degradations
    else
      %{}
    end
  end

  @spec diagnostics(map() | keyword()) :: map()
  def diagnostics(snapshot_or_opts \\ []) do
    snapshot = normalize_snapshot(snapshot_or_opts)

    %{
      modules: modules(),
      responsibilities: responsibilities(),
      profile: snapshot.degradation_profile,
      plan: plan(snapshot),
      component_degradations: component_summary(snapshot),
      bounded_semantics: %{
        shared_runtime: true,
        transport_shared: true,
        renderer_meaning_preserved: true
      }
    }
  end

  defp fallback_for_kind(kind, snapshot) when kind in @overlay_kinds do
    if snapshot.backend_mode == :tty, do: :inline_overlay, else: :layered_overlay
  end

  defp fallback_for_kind(kind, snapshot) when kind in @menu_kinds do
    if snapshot.backend_mode == :tty, do: :inline_menu_selection, else: :context_menu
  end

  defp fallback_for_kind(kind, snapshot) when kind in @canvas_kinds do
    if snapshot.glyph_set == :ascii, do: :ascii_canvas, else: :positioned_canvas
  end

  defp fallback_for_kind(kind, snapshot) when kind in @scroll_kinds do
    if snapshot.backend_mode == :tty, do: :paged_scroll, else: :viewport_scroll
  end

  defp normalize_snapshot(%{backend_mode: _backend_mode} = snapshot), do: snapshot

  defp normalize_snapshot(opts) when is_list(opts) do
    Keyword.get(opts, :capabilities, TerminalUi.Capabilities.snapshot(opts))
  end

  defp normalize_snapshot(_other), do: TerminalUi.Capabilities.snapshot()
end
