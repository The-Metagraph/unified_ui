# spec-coverage: unified_ui.runtime.component_lifecycle unified_ui.runtime.batching_and_dirty_tracking unified_ui.runtime.recovery_patterns

defmodule UnifiedUi.Agent do
  @moduledoc """
  Runtime helpers for starting UI components as supervised processes.

  `UnifiedUi.Agent` provides a thin process runtime around modules that
  implement `UnifiedUi.ElmArchitecture`.
  """

  alias Jido.Signal
  alias UnifiedUi.Agent.Server

  @registry UnifiedUi.AgentRegistry
  @supervisor UnifiedUi.AgentSupervisor

  @type component_id :: atom()
  @type signal :: Signal.t()
  @type signal_topic :: String.t()

  @doc """
  Returns the default signal topic used for a component id.

  Components subscribe to this topic on startup and can receive routed
  `Jido.Signal` messages through `UnifiedUi.SignalBus`.
  """
  @spec component_signal_topic(component_id()) :: signal_topic()
  def component_signal_topic(component_id) when is_atom(component_id) do
    "unified_ui:component:#{component_id}"
  end

  @doc """
  Starts a component process for the given module and component id.

  Supported opts:
  - `:platforms` - list of platforms for adapter rendering (`[:terminal | :desktop | :web]`)
  - `:render_opts` - options forwarded to adapter rendering
  - `:signal_topic` - additional signal topic to subscribe to
  - `:signal_topics` - additional list of signal topics to subscribe to
  - any additional opts are passed to the component `init/1` callback
  """
  @spec start_component(module(), component_id(), keyword()) :: {:ok, pid()} | {:error, term()}
  def start_component(module, component_id, opts \\ [])
      when is_atom(module) and is_atom(component_id) and is_list(opts) do
    with :ok <- ensure_runtime_ready() do
      child_spec = {Server, module: module, component_id: component_id, opts: opts}
      DynamicSupervisor.start_child(@supervisor, child_spec)
    end
  rescue
    _ -> {:error, :agent_runtime_not_started}
  catch
    :exit, _ -> {:error, :agent_runtime_not_started}
  end

  @doc """
  Stops a running component process by component id.
  """
  @spec stop_component(component_id()) :: :ok | {:error, term()}
  def stop_component(component_id) when is_atom(component_id) do
    with {:ok, pid} <- whereis(component_id),
         :ok <- terminate_component(pid) do
      :ok
    else
      {:error, _} = error -> error
      _ -> {:error, :stop_failed}
    end
  rescue
    _ -> {:error, :agent_runtime_not_started}
  catch
    :exit, _ -> {:error, :agent_runtime_not_started}
  end

  @doc """
  Sends a signal to a running component process.
  """
  @spec signal_component(component_id(), signal()) :: :ok | {:error, term()}
  def signal_component(component_id, %Signal{} = signal) when is_atom(component_id) do
    with {:ok, pid} <- whereis(component_id) do
      if Process.alive?(pid) do
        GenServer.cast(pid, {:signal, signal})
        :ok
      else
        {:error, :not_found}
      end
    end
  end

  def signal_component(component_id, _signal) when is_atom(component_id) do
    {:error, :invalid_signal}
  end

  @doc """
  Returns the current component model state.
  """
  @spec current_state(component_id()) :: {:ok, map()} | {:error, term()}
  def current_state(component_id) when is_atom(component_id) do
    with {:ok, pid} <- whereis(component_id),
         {:ok, response} <- safe_component_call(pid, :state) do
      response
    end
  end

  @doc """
  Returns the latest IUR value produced by the component.
  """
  @spec current_iur(component_id()) :: {:ok, term()} | {:error, term()}
  def current_iur(component_id) when is_atom(component_id) do
    with {:ok, pid} <- whereis(component_id),
         {:ok, response} <- safe_component_call(pid, :iur) do
      response
    end
  end

  @doc """
  Returns the latest adapter render results for the component.
  """
  @spec render_results(component_id()) :: {:ok, map()} | {:error, term()}
  def render_results(component_id) when is_atom(component_id) do
    with {:ok, pid} <- whereis(component_id),
         {:ok, response} <- safe_component_call(pid, :render_results) do
      response
    end
  end

  @doc """
  Looks up a component process by id.
  """
  @spec whereis(component_id()) ::
          {:ok, pid()} | {:error, :not_found | :agent_runtime_not_started}
  def whereis(component_id) when is_atom(component_id) do
    with :ok <- ensure_runtime_ready() do
      lookup_component(component_id)
    end
  end

  defp ensure_runtime_ready do
    if runtime_process_ready?(@registry) and runtime_process_ready?(@supervisor) do
      :ok
    else
      {:error, :agent_runtime_not_started}
    end
  end

  defp runtime_process_ready?(name) when is_atom(name) do
    case Process.whereis(name) do
      pid when is_pid(pid) -> Process.alive?(pid)
      nil -> false
    end
  end

  defp lookup_component(component_id) when is_atom(component_id) do
    case Registry.lookup(@registry, component_id) do
      [{pid, _}] when is_pid(pid) ->
        if Process.alive?(pid) do
          {:ok, pid}
        else
          {:error, :not_found}
        end

      [{_pid, _}] ->
        {:error, :not_found}

      [] ->
        {:error, :not_found}
    end
  rescue
    _ -> {:error, :agent_runtime_not_started}
  catch
    :exit, _ -> {:error, :agent_runtime_not_started}
  end

  defp terminate_component(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(@supervisor, pid)
  rescue
    _ -> {:error, :agent_runtime_not_started}
  catch
    :exit, _ -> {:error, :agent_runtime_not_started}
  end

  defp safe_component_call(pid, request) when is_pid(pid) do
    {:ok, GenServer.call(pid, request)}
  rescue
    _ -> {:error, :not_found}
  catch
    :exit, _ -> {:error, :not_found}
  end
end

defmodule UnifiedUi.Agent.Server do
  @moduledoc false
  use GenServer

  alias Jido.Signal
  alias UnifiedUi.Adapters.Coordinator
  alias UnifiedUi.SignalBus

  @registry UnifiedUi.AgentRegistry
  @flush_delay_ms 5

  defstruct [
    :module,
    :component_id,
    :model_state,
    :iur,
    pending_signals: [],
    flush_timer_ref: nil,
    signal_topics: [],
    platforms: [],
    render_opts: [],
    render_results: %{}
  ]

  @type t :: %__MODULE__{
          module: module(),
          component_id: atom(),
          model_state: map(),
          iur: term(),
          pending_signals: [Signal.t()],
          flush_timer_ref: reference() | nil,
          signal_topics: [String.t()],
          platforms: [atom()],
          render_opts: keyword(),
          render_results: map()
        }

  @spec child_spec(keyword()) :: Supervisor.child_spec()
  @spec code_change(term(), t(), term()) :: {:ok, t()} | {:error, term()}
  @spec handle_info(term(), t()) :: {:noreply, t()}
  @spec terminate(term(), t()) :: term()

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    module = Keyword.fetch!(opts, :module)
    component_id = Keyword.fetch!(opts, :component_id)
    server_opts = Keyword.get(opts, :opts, [])

    GenServer.start_link(__MODULE__, {module, component_id, server_opts},
      name: via_tuple(component_id)
    )
  end

  @impl true
  @spec init({module(), atom(), keyword()}) :: {:ok, t()}
  def init({module, component_id, opts}) do
    with {:ok, signal_topics} <- normalize_signal_topics(component_id, opts),
         :ok <- subscribe_signal_topics(signal_topics) do
      platforms = normalize_platforms(Keyword.get(opts, :platforms, []))
      render_opts = Keyword.get(opts, :render_opts, [])

      model_state = init_model_state(module, opts)
      {iur, render_results} = build_render_data(module, model_state, platforms, render_opts)

      {:ok,
       %__MODULE__{
         module: module,
         component_id: component_id,
         model_state: model_state,
         iur: iur,
         signal_topics: signal_topics,
         platforms: platforms,
         render_opts: render_opts,
         render_results: render_results
       }}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  @spec terminate(term(), t()) :: :ok
  def terminate(_reason, %__MODULE__{signal_topics: signal_topics}) do
    Enum.each(signal_topics, fn topic ->
      _ = SignalBus.unsubscribe(topic)
    end)

    :ok
  end

  @impl true
  @spec handle_cast({:signal, Signal.t()}, t()) :: {:noreply, t()}
  def handle_cast({:signal, signal}, %__MODULE__{} = state) do
    {:noreply, enqueue_signal(state, signal)}
  end

  @impl true
  @spec handle_call(atom(), GenServer.from(), t()) :: {:reply, term(), t()}
  def handle_call(:state, _from, %__MODULE__{} = state) do
    state = flush_pending_signals(state)
    {:reply, {:ok, state.model_state}, state}
  end

  @impl true
  def handle_call(:iur, _from, %__MODULE__{} = state) do
    state = flush_pending_signals(state)
    {:reply, {:ok, state.iur}, state}
  end

  @impl true
  def handle_call(:render_results, _from, %__MODULE__{} = state) do
    state = flush_pending_signals(state)
    {:reply, {:ok, state.render_results}, state}
  end

  @impl true
  @spec handle_info(term(), t()) :: {:noreply, t()}
  def handle_info({:unified_ui_signal, signal}, %__MODULE__{} = state) do
    {:noreply, enqueue_signal(state, signal)}
  end

  @impl true
  def handle_info(:flush_signals, %__MODULE__{} = state) do
    {:noreply, flush_pending_signals(%{state | flush_timer_ref: nil})}
  end

  @impl true
  def handle_info(_message, %__MODULE__{} = state) do
    {:noreply, state}
  end

  defp normalize_signal_topics(component_id, opts) when is_atom(component_id) and is_list(opts) do
    default_topic = UnifiedUi.Agent.component_signal_topic(component_id)
    single_topic = Keyword.get(opts, :signal_topic)
    extra_topics = Keyword.get(opts, :signal_topics, [])

    topics =
      [default_topic, single_topic | List.wrap(extra_topics)]
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    if Enum.all?(topics, &is_binary/1) do
      {:ok, topics}
    else
      {:error, :invalid_signal_topic}
    end
  end

  defp subscribe_signal_topics(topics) when is_list(topics) do
    topics
    |> Enum.reduce_while({:ok, []}, fn topic, {:ok, subscribed_topics} ->
      case SignalBus.subscribe(topic) do
        :ok -> {:cont, {:ok, [topic | subscribed_topics]}}
        {:error, reason} -> {:halt, {:error, {topic, reason, subscribed_topics}}}
      end
    end)
    |> case do
      {:ok, _subscribed_topics} ->
        :ok

      {:error, {topic, reason, subscribed_topics}} ->
        Enum.each(subscribed_topics, fn subscribed_topic ->
          _ = SignalBus.unsubscribe(subscribed_topic)
        end)

        {:error, {:signal_subscription_failed, topic, reason}}
    end
  end

  defp via_tuple(component_id) do
    {:via, Registry, {@registry, component_id}}
  end

  defp normalize_platforms(platforms) when is_list(platforms) do
    platforms
    |> Enum.filter(&(&1 in [:terminal, :desktop, :web]))
    |> Enum.uniq()
  end

  defp normalize_platforms(_), do: []

  defp init_model_state(module, opts) do
    if function_exported?(module, :init, 1) do
      module
      |> then(& &1.init(opts))
      |> normalize_model_state(%{})
    else
      %{}
    end
  rescue
    _ -> %{}
  end

  defp update_model_state(module, current_state, signal) do
    if function_exported?(module, :update, 2) do
      module
      |> then(& &1.update(current_state, signal))
      |> normalize_model_state(current_state)
    else
      current_state
    end
  rescue
    _ -> current_state
  end

  defp normalize_model_state(%{} = model_state, _fallback), do: model_state
  defp normalize_model_state({:ok, %{} = model_state}, _fallback), do: model_state
  defp normalize_model_state({:noreply, %{} = model_state}, _fallback), do: model_state
  defp normalize_model_state(_other, fallback), do: fallback

  defp enqueue_signal(%__MODULE__{} = state, signal) do
    state = %{state | pending_signals: [signal | state.pending_signals]}

    case state.flush_timer_ref do
      nil ->
        timer_ref = Process.send_after(self(), :flush_signals, @flush_delay_ms)
        %{state | flush_timer_ref: timer_ref}

      _ref ->
        state
    end
  end

  defp flush_pending_signals(%__MODULE__{} = state) do
    state = cancel_flush_timer(state)

    case state.pending_signals do
      [] ->
        state

      pending_signals ->
        model_state =
          pending_signals
          |> Enum.reverse()
          |> Enum.reduce(state.model_state, fn signal, current_state ->
            update_model_state(state.module, current_state, signal)
          end)

        state
        |> Map.put(:pending_signals, [])
        |> maybe_update_render(model_state)
    end
  end

  defp maybe_update_render(%__MODULE__{} = state, model_state) do
    if model_state == state.model_state do
      state
    else
      {iur, render_results} =
        build_render_data(state.module, model_state, state.platforms, state.render_opts)

      %{state | model_state: model_state, iur: iur, render_results: render_results}
    end
  end

  defp cancel_flush_timer(%__MODULE__{flush_timer_ref: nil} = state), do: state

  defp cancel_flush_timer(%__MODULE__{flush_timer_ref: timer_ref} = state) do
    _ = Process.cancel_timer(timer_ref)
    %{state | flush_timer_ref: nil}
  end

  defp build_render_data(module, model_state, platforms, render_opts) do
    iur = build_iur(module, model_state)

    render_results =
      case {platforms, iur} do
        {[], _} ->
          %{}

        {_, nil} ->
          %{}

        {platforms, iur} ->
          case Coordinator.render_on(iur, platforms, render_opts) do
            {:ok, results} -> results
            {:error, reason} -> %{error: reason}
          end
      end

    {iur, render_results}
  end

  defp build_iur(module, model_state) do
    if function_exported?(module, :view, 1) do
      module.view(model_state)
    else
      nil
    end
  rescue
    _ -> nil
  end
end
