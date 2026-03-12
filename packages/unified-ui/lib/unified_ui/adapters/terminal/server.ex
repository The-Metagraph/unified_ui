defmodule UnifiedUi.Adapters.Terminal.Server do
  @moduledoc """
  GenServer lifecycle wrapper for the Terminal renderer.

  This server keeps renderer state between calls and exposes a runtime API for
  rendering, updating, and querying the current terminal render state.
  """

  use GenServer

  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.Terminal

  @typedoc "Internal server state."
  @type t :: %{
          renderer_state: State.t() | nil,
          iur: UnifiedUi.Renderer.iur_tree() | nil,
          render_opts: keyword()
        }

  @doc """
  Starts the terminal renderer server.

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
  Stops the terminal renderer server.
  """
  @spec stop(GenServer.server(), term()) :: :ok
  def stop(server, reason \\ :normal) do
    GenServer.stop(server, reason)
  end

  @impl true
  @spec init(keyword()) :: {:ok, t()}
  def init(render_opts) when is_list(render_opts) do
    {:ok, %{renderer_state: nil, iur: nil, render_opts: render_opts}}
  end

  @impl true
  @spec handle_call(term(), GenServer.from(), t()) :: {:reply, term(), t()}
  def handle_call(:state, _from, %{renderer_state: nil} = state), do: {:reply, :error, state}
  def handle_call(:state, _from, state), do: {:reply, {:ok, state.renderer_state}, state}

  def handle_call(:current_iur, _from, %{iur: nil} = state), do: {:reply, :error, state}
  def handle_call(:current_iur, _from, state), do: {:reply, {:ok, state.iur}, state}

  def handle_call({:render, iur_tree, opts}, _from, state) do
    do_render(iur_tree, opts, state)
  end

  def handle_call({:update, iur_tree, opts}, _from, %{renderer_state: nil} = state) do
    do_render(iur_tree, opts, state)
  end

  def handle_call({:update, iur_tree, opts}, _from, state) do
    merged_opts = Keyword.merge(state.render_opts, opts)

    case Terminal.update(iur_tree, state.renderer_state, merged_opts) do
      {:ok, renderer_state} ->
        {:reply, {:ok, renderer_state},
         %{state | renderer_state: renderer_state, iur: iur_tree, render_opts: merged_opts}}

      other ->
        {:reply, other, state}
    end
  end

  @impl true
  @spec terminate(term(), t()) :: :ok
  def terminate(_reason, %{renderer_state: nil}), do: :ok

  def terminate(_reason, %{renderer_state: renderer_state}) do
    _ = Terminal.destroy(renderer_state)
    :ok
  end

  defp do_render(iur_tree, opts, state) do
    merged_opts = Keyword.merge(state.render_opts, opts)

    case Terminal.render(iur_tree, merged_opts) do
      {:ok, renderer_state} ->
        {:reply, {:ok, renderer_state},
         %{state | renderer_state: renderer_state, iur: iur_tree, render_opts: merged_opts}}

      other ->
        {:reply, other, state}
    end
  end
end
