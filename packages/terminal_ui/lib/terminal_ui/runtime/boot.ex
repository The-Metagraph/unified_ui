defmodule TerminalUi.Runtime.Boot do
  @moduledoc """
  Runtime boot helpers for the `terminal_ui` Phase 1 scaffold.
  """

  alias TerminalUi.{Backend, Capabilities}
  alias TerminalUi.Runtime.{Error, EventLoop, State}

  @required_screen_keys [:id, :title, :root]

  @spec prepare_native_screen(map(), atom(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def prepare_native_screen(screen, backend_mode, opts \\ []) do
    with :ok <- validate_screen(screen) do
      {:ok, build_state(screen, backend_mode, :native, opts)}
    end
  end

  @spec prepare_rendered_screen(map(), State.source_kind(), keyword()) ::
          {:ok, State.t()} | {:error, Error.t()}
  def prepare_rendered_screen(rendered_root, source_kind, opts \\ [])
      when is_map(rendered_root) do
    backend_mode = Keyword.get(opts, :backend_mode, :raw)

    screen = %{
      id: Keyword.get(opts, :screen_id, "canonical-screen"),
      title: Keyword.get(opts, :title, "Canonical Screen"),
      root: rendered_root
    }

    {:ok, build_state(screen, backend_mode, source_kind, opts)}
  end

  defp build_state(screen, backend_mode, source_kind, opts) do
    screen_id = to_string(Map.fetch!(screen, :id))

    %State{
      runtime_id: Keyword.get(opts, :runtime_id, "terminal-ui:#{screen_id}"),
      screen_id: screen_id,
      title: Map.get(screen, :title),
      source_kind: source_kind,
      backend_mode: backend_mode,
      capabilities: Capabilities.snapshot(backend_mode: backend_mode),
      root: Map.fetch!(screen, :root),
      backend_adapter: Backend.adapter_summary(backend_mode),
      event_loop: EventLoop.scaffold(backend_mode: backend_mode, screen_id: screen_id),
      lifecycle: %{
        boot: :initialized,
        terminal: :not_yet_attached,
        shutdown: :idle
      },
      validation_state: :backbone_ready
    }
  end

  defp validate_screen(screen) when is_map(screen) do
    missing_keys =
      Enum.reject(@required_screen_keys, fn key ->
        value = Map.get(screen, key)
        not is_nil(value)
      end)

    cond do
      missing_keys != [] ->
        {:error, Error.new(:invalid_screen, %{missing_keys: missing_keys})}

      not valid_root?(Map.get(screen, :root)) ->
        {:error, Error.new(:invalid_screen_root, %{root: Map.get(screen, :root)})}

      true ->
        :ok
    end
  end

  defp valid_root?(%{kind: _kind}), do: true
  defp valid_root?(%{id: _id}), do: true
  defp valid_root?(_root), do: false
end
