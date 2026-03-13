# spec-coverage: unified_ui.runtime.signal_delivery

defmodule UnifiedUi.SignalBusTest do
  use ExUnit.Case, async: false

  alias UnifiedUi.SignalBus
  alias UnifiedUi.Signals

  describe "pubsub broadcasts" do
    test "broadcasts signal to subscribed topic" do
      topic = "unified_ui:test:#{System.unique_integer([:positive])}"
      signal = Signals.create!(:click, %{widget_id: :save_btn, action: :save})

      assert :ok = SignalBus.subscribe(topic)
      on_exit(fn -> _ = SignalBus.unsubscribe(topic) end)

      assert :ok = SignalBus.broadcast(signal, topic)
      assert_receive {:unified_ui_signal, ^signal}
    end

    test "unsubscribe removes topic subscription" do
      topic = "unified_ui:test:#{System.unique_integer([:positive])}"
      signal = Signals.create!(:focus, %{widget_id: :email})

      assert :ok = SignalBus.subscribe(topic)
      assert :ok = SignalBus.unsubscribe(topic)
      assert :ok = SignalBus.broadcast(signal, topic)
      refute_receive {:unified_ui_signal, _}
    end

    test "returns error for invalid topic input" do
      assert {:error, :invalid_topic} = SignalBus.subscribe(:invalid_topic)
      assert {:error, :invalid_topic} = SignalBus.unsubscribe(:invalid_topic)

      signal = Signals.create!(:blur, %{widget_id: :name})
      assert {:error, :invalid_topic} = SignalBus.broadcast(signal, :invalid_topic)
    end

    test "returns error for invalid signal payload" do
      topic = "unified_ui:test:#{System.unique_integer([:positive])}"
      assert {:error, :invalid_signal} = SignalBus.broadcast(%{}, topic)
    end
  end

  describe "readiness errors" do
    test "returns pubsub_not_started when pubsub is unavailable" do
      topic = "unified_ui:test:#{System.unique_integer([:positive])}"
      signal = Signals.create!(:click, %{widget_id: :save_btn, action: :save})

      with_pubsub_stopped(fn ->
        assert {:error, :pubsub_not_started} = SignalBus.subscribe(topic)
        assert {:error, :pubsub_not_started} = SignalBus.unsubscribe(topic)
        assert {:error, :pubsub_not_started} = SignalBus.broadcast(signal, topic)
      end)
    end
  end

  defp with_pubsub_stopped(fun) do
    child_id =
      case Enum.find(Supervisor.which_children(UnifiedUi.Supervisor), fn
             {id, _pid, _type, _modules} -> id == Phoenix.PubSub.Supervisor
           end) do
        {resolved_child_id, _pid, _type, _modules} -> resolved_child_id
        nil -> flunk("could not resolve Phoenix.PubSub child id")
      end

    assert :ok = Supervisor.terminate_child(UnifiedUi.Supervisor, child_id)

    try do
      fun.()
    after
      assert {:ok, _pid} = Supervisor.restart_child(UnifiedUi.Supervisor, child_id)
    end
  end
end
