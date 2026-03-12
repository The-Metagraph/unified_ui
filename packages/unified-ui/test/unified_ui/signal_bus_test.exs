defmodule UnifiedUi.SignalBusTest do
  use ExUnit.Case, async: true

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
end
