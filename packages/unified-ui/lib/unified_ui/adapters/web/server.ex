defmodule UnifiedUi.Adapters.Web.Server do
  @moduledoc """
  GenServer lifecycle wrapper for the Web renderer with WebSocket session
  coordination.

  In addition to render/update lifecycle management, this server tracks
  connected WebSocket session processes and broadcasts converted UI signals to
  them.
  """

  use GenServer

  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.Web
  alias UnifiedUi.Adapters.Web.Events

  @typedoc "Opaque socket/session identifier."
  @type socket_id :: term()
  @typedoc "Connected socket process registry."
  @type sockets :: %{socket_id() => pid()}

  @typedoc "Internal server state."
  @type t :: %{
          renderer_state: State.t() | nil,
          iur: UnifiedUi.Renderer.iur_tree() | nil,
          render_opts: keyword(),
          sockets: sockets()
        }

  @doc """
  Starts the web renderer server.

  ## Options

  * `:name` - Process name registration option for `GenServer.start_link/3`
  * `:render_opts` - Default render options merged into every render/update call
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) when is_list(opts) do
    render_opts = Keyword.get(opts, :render_opts, [])
    start_opts = Keyword.drop(opts, [:render_opts])
    GenServer.start_link(__MODULE__, render_opts, start_opts)
  end

  @doc """
  Renders a new IUR tree and stores the resulting renderer state.
  """
  @spec render(GenServer.server(), UnifiedUi.Renderer.iur_tree(), keyword()) ::
          {:ok, State.t()} | {:error, term()}
  def render(server, iur_tree, opts \\ []) when is_list(opts) do
    GenServer.call(server, {:render, iur_tree, opts})
  end

  @doc """
  Updates the current renderer state using a new IUR tree.

  If no prior render exists, this behaves like `render/3`.
  """
  @spec update(GenServer.server(), UnifiedUi.Renderer.iur_tree(), keyword()) ::
          {:ok, State.t()} | {:error, term()}
  def update(server, iur_tree, opts \\ []) when is_list(opts) do
    GenServer.call(server, {:update, iur_tree, opts})
  end

  @doc """
  Returns the current renderer state.
  """
  @spec state(GenServer.server()) :: {:ok, State.t()} | :error
  def state(server) do
    GenServer.call(server, :state)
  end

  @doc """
  Returns the last rendered IUR tree.
  """
  @spec current_iur(GenServer.server()) :: {:ok, UnifiedUi.Renderer.iur_tree()} | :error
  def current_iur(server) do
    GenServer.call(server, :current_iur)
  end

  @doc """
  Connects a WebSocket session process to receive UI signals.
  """
  @spec connect_socket(GenServer.server(), socket_id(), pid(), keyword()) ::
          :ok | {:error, term()}
  def connect_socket(server, socket_id, pid \\ self(), opts \\ []) when is_pid(pid) do
    GenServer.call(server, {:connect_socket, socket_id, pid, opts})
  end

  @doc """
  Disconnects a WebSocket session process.
  """
  @spec disconnect_socket(GenServer.server(), socket_id(), keyword()) ::
          :ok | {:error, term()}
  def disconnect_socket(server, socket_id, opts \\ []) do
    GenServer.call(server, {:disconnect_socket, socket_id, opts})
  end

  @doc """
  Dispatches a web event and broadcasts the resulting signal to connected
  WebSocket sessions.
  """
  @spec dispatch_event(GenServer.server(), Events.event_type() | :submit, map(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def dispatch_event(server, event_type, data, opts \\ []) when is_map(data) do
    GenServer.call(server, {:dispatch_event, event_type, data, opts})
  end

  @doc """
  Broadcasts an already-constructed signal to all connected WebSocket sessions.
  """
  @spec broadcast_signal(GenServer.server(), Jido.Signal.t()) :: :ok
  def broadcast_signal(server, signal) do
    GenServer.call(server, {:broadcast_signal, signal})
  end

  @doc """
  Returns currently connected sockets.
  """
  @spec sockets(GenServer.server()) :: sockets()
  def sockets(server) do
    GenServer.call(server, :sockets)
  end

  @doc """
  Returns the number of connected sockets.
  """
  @spec socket_count(GenServer.server()) :: non_neg_integer()
  def socket_count(server) do
    GenServer.call(server, :socket_count)
  end

  @doc """
  Stops the web renderer server.
  """
  @spec stop(GenServer.server(), term()) :: :ok
  def stop(server, reason \\ :normal) do
    GenServer.stop(server, reason)
  end

  @impl true
  @spec init(keyword()) :: {:ok, t()}
  def init(render_opts) when is_list(render_opts) do
    {:ok, %{renderer_state: nil, iur: nil, render_opts: render_opts, sockets: %{}}}
  end

  @impl true
  @spec handle_call(term(), GenServer.from(), t()) :: {:reply, term(), t()}
  def handle_call(:state, _from, %{renderer_state: nil} = state), do: {:reply, :error, state}
  def handle_call(:state, _from, state), do: {:reply, {:ok, state.renderer_state}, state}

  def handle_call(:current_iur, _from, %{iur: nil} = state), do: {:reply, :error, state}
  def handle_call(:current_iur, _from, state), do: {:reply, {:ok, state.iur}, state}

  def handle_call(:sockets, _from, state), do: {:reply, state.sockets, state}
  def handle_call(:socket_count, _from, state), do: {:reply, map_size(state.sockets), state}

  def handle_call({:render, iur_tree, opts}, _from, state) do
    do_render(iur_tree, opts, state)
  end

  def handle_call({:update, iur_tree, opts}, _from, %{renderer_state: nil} = state) do
    do_render(iur_tree, opts, state)
  end

  def handle_call({:update, iur_tree, opts}, _from, state) do
    merged_opts = Keyword.merge(state.render_opts, opts)

    case Web.update(iur_tree, state.renderer_state, merged_opts) do
      {:ok, renderer_state} ->
        {:reply, {:ok, renderer_state},
         %{state | renderer_state: renderer_state, iur: iur_tree, render_opts: merged_opts}}

      other ->
        {:reply, other, state}
    end
  end

  def handle_call({:connect_socket, socket_id, pid, opts}, _from, state) do
    if Process.alive?(pid) do
      sockets = Map.put(state.sockets, socket_id, pid)

      with {:ok, signal} <- ws_dispatch(:connected, socket_id, opts) do
        sockets = deliver_signal(sockets, signal)
        {:reply, :ok, %{state | sockets: sockets}}
      end
    else
      {:reply, {:error, :socket_process_not_alive}, state}
    end
  end

  def handle_call({:disconnect_socket, socket_id, opts}, _from, state) do
    case Map.has_key?(state.sockets, socket_id) do
      false ->
        {:reply, {:error, :socket_not_found}, state}

      true ->
        with {:ok, signal} <- ws_dispatch(:disconnected, socket_id, opts) do
          sockets =
            state.sockets
            |> Map.delete(socket_id)
            |> deliver_signal(signal)

          {:reply, :ok, %{state | sockets: sockets}}
        end
    end
  end

  def handle_call({:dispatch_event, event_type, data, opts}, _from, state) do
    with {:ok, signal} <- Events.dispatch(event_type, data, opts) do
      sockets = deliver_signal(state.sockets, signal)
      {:reply, {:ok, signal}, %{state | sockets: sockets}}
    end
  end

  def handle_call({:broadcast_signal, signal}, _from, state) do
    sockets = deliver_signal(state.sockets, signal)
    {:reply, :ok, %{state | sockets: sockets}}
  end

  @impl true
  @spec terminate(term(), t()) :: :ok
  def terminate(_reason, %{renderer_state: nil}), do: :ok

  def terminate(_reason, %{renderer_state: renderer_state}) do
    _ = Web.destroy(renderer_state)
    :ok
  end

  defp do_render(iur_tree, opts, state) do
    merged_opts = Keyword.merge(state.render_opts, opts)

    case Web.render(iur_tree, merged_opts) do
      {:ok, renderer_state} ->
        {:reply, {:ok, renderer_state},
         %{state | renderer_state: renderer_state, iur: iur_tree, render_opts: merged_opts}}

      other ->
        {:reply, other, state}
    end
  end

  defp ws_dispatch(hook_name, socket_id, opts) do
    Events.dispatch(
      :hook,
      %{hook_name: hook_name, data: %{socket_id: socket_id}},
      opts
    )
  end

  defp deliver_signal(sockets, signal) do
    Enum.reduce(sockets, %{}, fn {socket_id, socket_pid}, acc ->
      if Process.alive?(socket_pid) do
        send(socket_pid, {:websocket_signal, signal})
        Map.put(acc, socket_id, socket_pid)
      else
        acc
      end
    end)
  end
end
