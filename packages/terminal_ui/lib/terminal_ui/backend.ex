defmodule TerminalUi.Backend do
  @moduledoc """
  Backend selection boundary for `terminal_ui`.
  """

  @type mode :: :raw | :tty

  @spec modes() :: [atom()]
  def modes, do: [:raw, :tty]

  @spec select(keyword()) :: {:ok, mode()} | {:error, {:unsupported_backend_mode, term()}}
  def select(opts \\ []) do
    mode = Keyword.get(opts, :backend_mode, Keyword.get(opts, :backend, :raw))

    if mode in modes() do
      {:ok, mode}
    else
      {:error, {:unsupported_backend_mode, mode}}
    end
  end

  @spec adapter_summary(mode()) :: map()
  def adapter_summary(mode) do
    %{
      mode: mode,
      runtime_module: TermUI.Runtime,
      platform_module: TermUI.Platform,
      event_module: TermUI.Event,
      input_reader_module: TermUI.Terminal.InputReader,
      keyboard_first: true
    }
  end

  @spec modules() :: [module()]
  def modules, do: []
end
