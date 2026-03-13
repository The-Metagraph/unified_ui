# spec-coverage: unified_ui.runtime.component_lifecycle unified_ui.runtime.batching_and_dirty_tracking unified_ui.runtime.signal_delivery

defmodule UnifiedUi.AgentTest do
  use ExUnit.Case, async: false

  alias Jido.Signal
  alias UnifiedUi.Adapters.Coordinator
  alias UnifiedUi.Agent

  defmodule CounterComponent do
    @behaviour UnifiedUi.ElmArchitecture

    @impl true
    def init(_opts), do: %{count: 0}

    @impl true
    def update(state, %Signal{type: "inc", data: %{delta: delta}}) when is_integer(delta) do
      %{state | count: state.count + delta}
    end

    def update(state, %Signal{type: "inc"}) do
      %{state | count: state.count + 1}
    end

    def update(state, _signal), do: state

    @impl true
    def view(state) do
      %UnifiedIUR.Widgets.Text{
        id: :counter_text,
        content: Integer.to_string(state.count)
      }
    end
  end

  defmodule ObservedCounterComponent do
    @behaviour UnifiedUi.ElmArchitecture

    @impl true
    def init(opts) do
      %{count: 0, observer: Keyword.get(opts, :observer)}
    end

    @impl true
    def update(state, %Signal{type: "inc"}) do
      %{state | count: state.count + 1}
    end

    def update(state, _signal), do: state

    @impl true
    def view(state) do
      if is_pid(state.observer) do
        send(state.observer, {:view_called, state.count})
      end

      %UnifiedIUR.Widgets.Text{
        id: :observed_counter_text,
        content: Integer.to_string(state.count)
      }
    end
  end

  describe "component lifecycle" do
    test "start_component/3 starts a supervised process addressable by id" do
      component_id = :counter_component_lifecycle
      assert {:ok, pid} = Agent.start_component(CounterComponent, component_id)

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      assert Process.alive?(pid)
      assert {:ok, ^pid} = Agent.whereis(component_id)
      assert {:ok, %{count: 0}} = Agent.current_state(component_id)

      assert {:ok, %UnifiedIUR.Widgets.Text{id: :counter_text, content: "0"}} =
               Agent.current_iur(component_id)
    end

    test "signal_component/2 updates model state through component update/2" do
      component_id = :counter_component_signal
      assert {:ok, _pid} = Agent.start_component(CounterComponent, component_id)

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      assert :ok = Agent.signal_component(component_id, build_signal!("inc", %{delta: 3}))
      # Allow cast processing.
      Process.sleep(20)

      assert {:ok, %{count: 3}} = Agent.current_state(component_id)
      assert {:ok, %UnifiedIUR.Widgets.Text{content: "3"}} = Agent.current_iur(component_id)
    end

    test "stop_component/1 terminates and unregisters the component" do
      component_id = :counter_component_stop
      assert {:ok, _pid} = Agent.start_component(CounterComponent, component_id)
      assert {:ok, _pid} = Agent.whereis(component_id)

      assert :ok = Agent.stop_component(component_id)
      assert_component_stopped(component_id)
    end

    test "component receives bus-routed signal on default component topic" do
      component_id = :counter_component_topic_route
      assert {:ok, _pid} = Agent.start_component(CounterComponent, component_id)

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      topic = Agent.component_signal_topic(component_id)
      {:ok, signal} = Signal.new(type: "inc", data: %{delta: 2}, source: "/unified_ui/test")

      assert :ok = Coordinator.route_signal(signal, {:topic, topic})
      Process.sleep(20)

      assert {:ok, %{count: 2}} = Agent.current_state(component_id)
    end
  end

  describe "error paths" do
    test "returns :not_found for unknown component ids" do
      component_id = :missing_component
      signal = build_signal!("inc", %{})

      assert {:error, :not_found} = Agent.whereis(component_id)
      assert {:error, :not_found} = Agent.signal_component(component_id, signal)
      assert {:error, :not_found} = Agent.current_state(component_id)
      assert {:error, :not_found} = Agent.current_iur(component_id)
      assert {:error, :not_found} = Agent.render_results(component_id)
      assert {:error, :not_found} = Agent.stop_component(component_id)
    end

    test "start_component/3 returns already_started when component id is reused" do
      component_id = :counter_component_duplicate
      assert {:ok, pid} = Agent.start_component(CounterComponent, component_id)

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      assert {:error, {:already_started, ^pid}} =
               Agent.start_component(CounterComponent, component_id)
    end

    test "start_component/3 returns runtime_not_started when runtime supervisor is stopped" do
      with_runtime_child_stopped(UnifiedUi.AgentSupervisor, fn ->
        assert {:error, :agent_runtime_not_started} =
                 Agent.start_component(CounterComponent, :runtime_down_start)
      end)
    end

    test "stop_component/1 returns runtime_not_started when registry is stopped" do
      with_runtime_child_stopped(UnifiedUi.AgentRegistry, fn ->
        assert {:error, :agent_runtime_not_started} = Agent.stop_component(:runtime_down_stop)
      end)
    end

    test "lookup and query helpers return runtime_not_started when registry is stopped" do
      signal = build_signal!("inc", %{})

      with_runtime_child_stopped(UnifiedUi.AgentRegistry, fn ->
        assert {:error, :agent_runtime_not_started} = Agent.whereis(:runtime_down_lookup)
        assert {:error, :agent_runtime_not_started} = Agent.current_state(:runtime_down_lookup)
        assert {:error, :agent_runtime_not_started} = Agent.current_iur(:runtime_down_lookup)
        assert {:error, :agent_runtime_not_started} = Agent.render_results(:runtime_down_lookup)

        assert {:error, :agent_runtime_not_started} =
                 Agent.signal_component(:runtime_down_lookup, signal)
      end)
    end

    test "start_component/3 returns signal_subscription_failed when pubsub is stopped" do
      component_id = :counter_component_pubsub_down
      expected_topic = Agent.component_signal_topic(component_id)

      with_runtime_child_stopped(pubsub_child_id(), fn ->
        assert {:error, {:signal_subscription_failed, ^expected_topic, :pubsub_not_started}} =
                 Agent.start_component(CounterComponent, component_id)
      end)
    end

    test "start_component/3 rejects non-binary signal topics" do
      assert {:error, :invalid_signal_topic} =
               Agent.start_component(CounterComponent, :counter_component_invalid_topic,
                 signal_topics: [:invalid]
               )
    end

    test "signal_component/2 rejects non-signal values" do
      component_id = :counter_component_invalid_signal
      assert {:ok, _pid} = Agent.start_component(CounterComponent, component_id)

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      assert {:error, :invalid_signal} = Agent.signal_component(component_id, %{type: "inc"})
    end
  end

  describe "render optimization" do
    test "does not rebuild render output when updates do not change state" do
      component_id = :counter_component_dirty_tracking

      assert {:ok, _pid} =
               Agent.start_component(ObservedCounterComponent, component_id,
                 observer: self(),
                 platforms: [:terminal]
               )

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      assert_receive {:view_called, 0}
      drain_view_calls()

      assert :ok = Agent.signal_component(component_id, build_signal!("noop", %{}))
      assert {:ok, %{count: 0}} = Agent.current_state(component_id)

      refute_receive {:view_called, _count}, 30
    end

    test "batches burst signals and applies updates in order" do
      component_id = :counter_component_batching
      burst_count = 25

      assert {:ok, _pid} =
               Agent.start_component(ObservedCounterComponent, component_id,
                 observer: self(),
                 platforms: [:terminal]
               )

      on_exit(fn ->
        Agent.stop_component(component_id)
      end)

      assert_receive {:view_called, 0}
      drain_view_calls()

      Enum.each(1..burst_count, fn _ ->
        assert :ok = Agent.signal_component(component_id, build_signal!("inc", %{}))
      end)

      assert {:ok, %{count: ^burst_count}} = Agent.current_state(component_id)

      Process.sleep(20)
      view_counts = collect_view_calls()

      assert view_counts != []
      assert List.last(view_counts) == burst_count
      assert length(view_counts) < burst_count
    end
  end

  defp assert_component_stopped(component_id, attempts \\ 20)

  defp assert_component_stopped(_component_id, 0) do
    flunk("component is still registered after stop_component/1")
  end

  defp assert_component_stopped(component_id, attempts) do
    case Agent.whereis(component_id) do
      {:error, :not_found} ->
        :ok

      {:ok, _pid} ->
        Process.sleep(10)
        assert_component_stopped(component_id, attempts - 1)
    end
  end

  defp with_runtime_child_stopped(child_id, fun) do
    assert :ok = Supervisor.terminate_child(UnifiedUi.Supervisor, child_id)

    try do
      fun.()
    after
      assert {:ok, _pid} = Supervisor.restart_child(UnifiedUi.Supervisor, child_id)
    end
  end

  defp pubsub_child_id do
    case Enum.find(Supervisor.which_children(UnifiedUi.Supervisor), fn
           {id, _pid, _type, _modules} -> id == Phoenix.PubSub.Supervisor
         end) do
      {child_id, _pid, _type, _modules} -> child_id
      nil -> flunk("could not resolve Phoenix.PubSub child id")
    end
  end

  defp drain_view_calls do
    receive do
      {:view_called, _count} ->
        drain_view_calls()
    after
      0 ->
        :ok
    end
  end

  defp collect_view_calls(acc \\ []) do
    receive do
      {:view_called, count} ->
        collect_view_calls([count | acc])
    after
      0 ->
        Enum.reverse(acc)
    end
  end

  defp build_signal!(type, data) do
    {:ok, signal} = Signal.new(type: type, data: data, source: "/unified_ui/test")
    signal
  end
end
