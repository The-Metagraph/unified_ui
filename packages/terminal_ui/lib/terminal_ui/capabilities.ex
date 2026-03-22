defmodule TerminalUi.Capabilities do
  @moduledoc """
  Capability summary boundary for `terminal_ui`.
  """

  @spec categories() :: [atom()]
  def categories do
    [:backend, :color, :unicode, :mouse, :paste, :resize, :terminal]
  end

  @spec snapshot(keyword()) :: map()
  def snapshot(opts \\ []) do
    backend_mode = Keyword.get(opts, :backend_mode, :raw)
    platform_info = platform_info()
    terminal_size = Map.get(platform_info, :terminal_size, {24, 80})

    %{
      backend_mode: backend_mode,
      color_depth: color_depth_for(backend_mode),
      unicode: backend_mode == :raw,
      mouse: backend_mode == :raw,
      paste: backend_mode == :raw,
      resize: true,
      terminal_present: true,
      platform: Map.get(platform_info, :platform, :unknown),
      terminal_size: terminal_size,
      degradation_profile: degradation_profile(backend_mode)
    }
  end

  @spec degradation_profile(atom()) :: atom()
  def degradation_profile(:raw), do: :rich_terminal
  def degradation_profile(:tty), do: :fallback_terminal

  defp color_depth_for(:raw), do: :true_color
  defp color_depth_for(:tty), do: :ansi16

  defp platform_info do
    if Code.ensure_loaded?(TermUI.Platform) do
      TermUI.Platform.info()
    else
      %{}
    end
  end
end
