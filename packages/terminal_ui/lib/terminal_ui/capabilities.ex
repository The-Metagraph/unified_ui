defmodule TerminalUi.Capabilities do
  @moduledoc """
  Capability summary boundary for `terminal_ui`.
  """

  @spec categories() :: [atom()]
  def categories do
    [
      :backend,
      :color,
      :unicode,
      :mouse,
      :paste,
      :resize,
      :terminal,
      :layering,
      :positioning,
      :canvas
    ]
  end

  @spec modules() :: [module()]
  def modules, do: [__MODULE__, TerminalUi.Degradation]

  @spec snapshot(keyword()) :: map()
  def snapshot(opts \\ []) do
    backend_mode = Keyword.get(opts, :backend_mode, :raw)
    platform_info = platform_info()
    terminal_size = Map.get(platform_info, :terminal_size, {24, 80})

    %{
      backend_mode: backend_mode,
      color_depth: color_depth_for(backend_mode),
      color_mode: color_mode_for(backend_mode),
      unicode: backend_mode == :raw,
      glyph_set: glyph_set_for(backend_mode),
      mouse: backend_mode == :raw,
      paste: backend_mode == :raw,
      resize: true,
      layering: true,
      positioning: backend_mode == :raw,
      canvas: backend_mode == :raw,
      terminal_present: true,
      platform: Map.get(platform_info, :platform, :unknown),
      terminal_size: terminal_size,
      degradation_profile: degradation_profile(backend_mode),
      keyboard_alternatives: keyboard_alternatives(backend_mode)
    }
  end

  @spec profiles() :: [atom()]
  def profiles do
    [:rich_terminal, :fallback_terminal]
  end

  @spec color_modes() :: [atom()]
  def color_modes, do: [:rich_color, :limited_color]

  @spec glyph_modes() :: [atom()]
  def glyph_modes, do: [:unicode, :ascii]

  @spec degradation_profile(atom()) :: atom()
  def degradation_profile(:raw), do: :rich_terminal
  def degradation_profile(:tty), do: :fallback_terminal

  @spec keyboard_alternatives(atom()) :: [atom()]
  def keyboard_alternatives(:raw), do: []

  def keyboard_alternatives(:tty),
    do: [
      :inline_menu_selection,
      :ctrl_resize,
      :arrow_navigation,
      :inline_overlay,
      :paged_scroll,
      :inline_disclosure,
      :linearized_collection,
      :linearized_form,
      :inline_text_prompt
    ]

  @spec diagnostics(keyword()) :: map()
  def diagnostics(opts \\ []) do
    snapshot = Keyword.get(opts, :capabilities, snapshot(opts))

    %{
      profile: snapshot.degradation_profile,
      degraded_capabilities: degraded_capabilities(snapshot),
      keyboard_alternatives: snapshot.keyboard_alternatives,
      supported_categories: Enum.reject(categories(), &(&1 in degraded_capabilities(snapshot))),
      fallback_modes: fallback_modes(snapshot),
      allowed_variation: allowed_variation(snapshot),
      degradation_plan: TerminalUi.Degradation.plan(snapshot),
      module_boundaries: %{
        shared_runtime: [:runtime, :renderer, :transport],
        capability_modules: [TerminalUi.Capabilities, TerminalUi.Degradation]
      }
    }
  end

  @spec capability_contract() :: map()
  def capability_contract do
    %{
      required_categories: [:backend, :color, :unicode, :resize, :terminal],
      optional_categories: [:mouse, :paste, :layering, :positioning, :canvas],
      degradation_profiles: profiles(),
      bounded_variation: [:overlay_presentation, :positioned_canvas_rendering, :glyph_fallback]
    }
  end

  @spec fallback_modes(map()) :: map()
  def fallback_modes(snapshot), do: do_fallback_modes(snapshot)

  @spec allowed_variation(map()) :: [atom()]
  def allowed_variation(snapshot), do: do_allowed_variation(snapshot)

  defp color_depth_for(:raw), do: :true_color
  defp color_depth_for(:tty), do: :ansi16
  defp color_mode_for(:raw), do: :rich_color
  defp color_mode_for(:tty), do: :limited_color
  defp glyph_set_for(:raw), do: :unicode
  defp glyph_set_for(:tty), do: :ascii

  defp degraded_capabilities(snapshot) do
    []
    |> maybe_add(:unicode, not snapshot.unicode)
    |> maybe_add(:mouse, not snapshot.mouse)
    |> maybe_add(:paste, not snapshot.paste)
    |> maybe_add(:color, snapshot.color_depth != :true_color)
    |> maybe_add(:positioning, not snapshot.positioning)
    |> maybe_add(:canvas, not snapshot.canvas)
  end

  defp do_fallback_modes(snapshot) do
    %{}
    |> maybe_put(:overlay, if(snapshot.backend_mode == :tty, do: :inline_overlay))
    |> maybe_put(:menu, if(snapshot.backend_mode == :tty, do: :inline_menu_selection))
    |> maybe_put(:canvas, if(snapshot.backend_mode == :tty, do: :ascii_canvas))
    |> maybe_put(:scroll, if(snapshot.backend_mode == :tty, do: :paged_scroll))
    |> maybe_put(:promoted_widgets, if(snapshot.backend_mode == :tty, do: :explicit_fallbacks))
  end

  defp do_allowed_variation(snapshot) do
    if snapshot.backend_mode == :tty do
      [
        :overlay_presentation,
        :positioned_canvas_rendering,
        :context_menu_presentation,
        :glyph_fallback,
        :syntax_highlighting_fallback,
        :progress_visual_fallback,
        :attachment_fallback,
        :row_scope_linearization
      ]
    else
      []
    end
  end

  defp platform_info do
    if Code.ensure_loaded?(TermUI.Platform) do
      TermUI.Platform.info()
    else
      %{}
    end
  end

  defp maybe_add(list, item, true), do: list ++ [item]
  defp maybe_add(list, _item, false), do: list
  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
