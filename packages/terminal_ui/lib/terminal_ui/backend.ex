defmodule TerminalUi.Backend do
  @moduledoc """
  Backend selection boundary for `terminal_ui`.
  """

  @type mode :: :raw | :tty

  @spec modes() :: [atom()]
  def modes, do: [:raw, :tty]

  @spec select(keyword()) :: {:ok, mode()} | {:error, {:unsupported_backend_mode, term()}}
  def select(opts \\ []) do
    requested = Keyword.get(opts, :backend_mode, Keyword.get(opts, :backend, :auto))
    raw_supported = Keyword.get(opts, :raw_supported, true)

    case requested do
      :auto when raw_supported ->
        {:ok, :raw}

      :auto ->
        {:ok, :tty}

      mode ->
        if mode in modes() do
          {:ok, mode}
        else
          {:error, {:unsupported_backend_mode, mode}}
        end
    end
  end

  @spec adapter_summary(mode()) :: map()
  def adapter_summary(:raw), do: TerminalUi.Backend.RawMode.summary()
  def adapter_summary(:tty), do: TerminalUi.Backend.Tty.summary()

  @spec selection_contract() :: map()
  def selection_contract do
    %{
      requested_modes: [:auto, :raw, :tty],
      default_mode: :auto,
      fallback_rule: :raw_to_tty,
      raw_mode_requires: [:terminal_present, :raw_supported],
      tty_mode_assumptions: [:keyboard_first, :limited_mouse]
    }
  end

  @spec callback_contract() :: map()
  def callback_contract do
    %{
      shared: [:focus, :resize, :shutdown],
      raw_only: [:mouse, :paste],
      tty_alternatives: [:inline_menu_selection, :ctrl_resize, :arrow_navigation]
    }
  end

  @spec modules() :: [module()]
  def modules do
    [TerminalUi.Backend.RawMode, TerminalUi.Backend.Tty]
  end
end
