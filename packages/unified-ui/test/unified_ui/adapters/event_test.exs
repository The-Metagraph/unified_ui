# spec-coverage: unified_ui.adapters.event_normalization

defmodule UnifiedUi.Adapters.EventTest do
  use ExUnit.Case, async: false

  alias UnifiedUi.Adapters.Event
  alias UnifiedUi.Agent, as: UiAgent

  defmodule DispatchProbeComponent do
    @behaviour UnifiedUi.ElmArchitecture

    @impl true
    def init(opts), do: %{observer: Keyword.get(opts, :observer)}

    @impl true
    def update(state, signal) do
      if is_pid(state.observer), do: send(state.observer, {:adapter_event_signal, signal})
      state
    end

    @impl true
    def view(_state), do: %UnifiedIUR.Widgets.Text{id: :adapter_event_probe, content: "ok"}
  end

  describe "create_event/2" do
    test "creates a typed adapter event map" do
      event = Event.create_event(:click, %{widget_id: :save})

      assert event == %{type: :click, data: %{widget_id: :save}}
    end
  end

  describe "normalize_payload/2" do
    test "adds canonical platform metadata" do
      assert Event.normalize_payload(:desktop, %{widget_id: :save}) == %{
               widget_id: :save,
               platform: :desktop
             }
    end
  end

  describe "to_signal/4" do
    test "normalizes standard click events to canonical signals" do
      assert {:ok, signal} = Event.to_signal(:terminal, :click, %{widget_id: :save})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :save
      assert signal.data.platform == :terminal
      assert signal.source == "/unified_ui/terminal"
    end

    test "normalizes action-backed mouse events to canonical signals" do
      assert {:ok, signal} =
               Event.to_signal(:desktop, :mouse, %{action: :double_click, x: 10, y: 20})

      assert signal.type == "unified.mouse.double_click"
      assert signal.data.action == :double_click
      assert signal.data.platform == :desktop
    end

    test "normalizes web hook events when the hook is allowed" do
      assert {:ok, signal} =
               Event.to_signal(
                 :web,
                 :hook,
                 %{hook_name: :scroll_handler, data: %{scroll_top: 120}},
                 allowed_hook_names: [:scroll_handler]
               )

      assert signal.type == "unified.web.scroll_handler"
      assert signal.data.hook_name == :scroll_handler
      assert signal.data.platform == :web
    end

    test "rejects unsupported hook names" do
      assert {:error, :invalid_hook} =
               Event.to_signal(
                 :web,
                 :hook,
                 %{hook_name: :unknown_hook, data: %{}},
                 allowed_hook_names: [:scroll_handler]
               )
    end

    test "rejects unsupported event types" do
      assert {:error, :unsupported_event} =
               Event.to_signal(:terminal, :window, %{action: :resize})
    end

    test "rejects non-map payloads" do
      assert {:error, :invalid_payload} = Event.to_signal(:web, :click, :invalid)
    end
  end

  describe "dispatch/4" do
    test "returns the canonical signal when no component target is provided" do
      assert {:ok, signal} = Event.dispatch(:web, :click, %{widget_id: :save, action: :save})

      assert signal.type == "unified.button.clicked"
      assert signal.data.action == :save
    end

    test "dispatches canonical signals through UnifiedUi.Agent when component_id is provided" do
      component_id = :"adapter_event_dispatch_#{System.unique_integer([:positive])}"

      assert {:ok, _pid} =
               UiAgent.start_component(DispatchProbeComponent, component_id, observer: self())

      on_exit(fn -> UiAgent.stop_component(component_id) end)

      assert {:ok, signal} =
               Event.dispatch(
                 :terminal,
                 :change,
                 %{widget_id: :email, value: "user@example.com"},
                 component_id: component_id
               )

      assert signal.type == "unified.input.changed"

      assert_receive {:adapter_event_signal, delivered_signal}
      assert delivered_signal.type == "unified.input.changed"
      assert delivered_signal.data.widget_id == :email
    end

    test "returns invalid_component_id for non-atom component targets" do
      assert {:error, :invalid_component_id} =
               Event.dispatch(:terminal, :click, %{widget_id: :save}, component_id: "save")
    end
  end

  describe "extract_metadata/1" do
    test "extracts coordinates, modifiers, and timestamps from platform payloads" do
      metadata =
        Event.extract_metadata(%{
          x: 10,
          y: 20,
          ctrl: true,
          shift: false,
          time: 123_456
        })

      assert metadata == %{x: 10, y: 20, ctrl: true, shift: false, timestamp: 123_456}
    end

    test "supports alternative modifier and timestamp keys" do
      metadata =
        Event.extract_metadata(%{
          modifier_alt: true,
          modifier_meta: false,
          timestamp_ms: 99
        })

      assert metadata == %{alt: true, meta: false, timestamp: 99}
    end

    test "returns an empty map for empty payloads" do
      assert Event.extract_metadata(%{}) == %{}
    end
  end
end
