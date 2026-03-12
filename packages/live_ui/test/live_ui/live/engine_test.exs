defmodule LiveUi.Live.EngineTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]

  alias LiveUi
  alias LiveUi.ConfigurationError
  alias LiveUi.Live.DynamicLive
  alias LiveUi.Live.Engine
  alias LiveUi.Runtime.Model
  alias LiveUi.TestSupport.CounterScreen
  alias LiveUi.TestSupport.RawIur
  alias LiveUi.TestSupport.WrapperLive
  alias Phoenix.LiveView.Socket

  test "mount initializes the shared runtime model from a screen wrapper" do
    socket = socket_for(WrapperLive, "wrapper-1", :show)

    assert {:ok, %Socket{} = mounted_socket} =
             Engine.mount(
               %{"request_id" => "req-100"},
               %{"count" => 4, "mount_token" => "alpha"},
               socket,
               WrapperLive
             )

    assert %Model{} = mounted_socket.assigns.live_ui_model
    assert mounted_socket.assigns.live_ui_error == nil
    assert mounted_socket.assigns.page_title == "CounterScreen"
    assert mounted_socket.assigns.live_ui_model.source.module == CounterScreen
    assert mounted_socket.assigns.live_ui_model.screen_state.count == 4
    assert mounted_socket.assigns.live_ui_model.runtime_context.request_id == "req-100"
    assert mounted_socket.assigns.live_ui_model.runtime_context.signal_source == "/host/live_ui"
    assert mounted_socket.assigns.live_ui_model.runtime_context.live_action == :show
    assert mounted_socket.assigns.live_ui_model.runtime_context.view == WrapperLive
  end

  test "mount_dynamic uses the same runtime model shape as wrapper-based mounts" do
    socket = socket_for(DynamicLive, "dynamic-1", nil)

    assert {:ok, %Socket{} = mounted_socket} =
             Engine.mount_dynamic(
               %{"request_id" => "req-200"},
               LiveUi.dynamic_session(CounterScreen,
                 context: %{signal_source: "/dynamic/live_ui", trace_id: "trace-1"},
                 source_opts: [count: 9, mount_token: "beta"]
               ),
               socket
             )

    assert %Model{} = mounted_socket.assigns.live_ui_model
    assert mounted_socket.assigns.live_ui_model.source.module == CounterScreen
    assert mounted_socket.assigns.live_ui_model.screen_state.count == 9
    assert mounted_socket.assigns.live_ui_model.runtime_context.trace_id == "trace-1"

    assert mounted_socket.assigns.live_ui_model.runtime_context.signal_source ==
             "/dynamic/live_ui"
  end

  test "mount_dynamic accepts canonical raw iur sessions through the shared engine" do
    socket = socket_for(DynamicLive, "dynamic-iur-1", nil)

    assert {:ok, %Socket{} = mounted_socket} =
             Engine.mount_dynamic(
               %{"request_id" => "req-iur-200"},
               LiveUi.dynamic_iur_session(RawIur.counter_tree(11),
                 context: %{signal_source: "/dynamic/live_ui", trace_id: "trace-iur-1"}
               ),
               socket
             )

    assert %Model{} = mounted_socket.assigns.live_ui_model
    assert mounted_socket.assigns.page_title == "vbox"
    assert mounted_socket.assigns.live_ui_model.source.kind == :iur
    assert mounted_socket.assigns.live_ui_model.screen_state == %{}
    assert mounted_socket.assigns.live_ui_model.descriptor_tree.id == "counter-root"
    assert mounted_socket.assigns.live_ui_model.runtime_context.trace_id == "trace-iur-1"
  end

  test "handle_event updates assigns through the shared engine" do
    socket = socket_for(WrapperLive, "wrapper-2", :edit)

    {:ok, mounted_socket} =
      Engine.mount(
        %{"request_id" => "req-300"},
        %{"count" => 1, "mount_token" => "gamma"},
        socket,
        WrapperLive
      )

    assert {:noreply, %Socket{} = updated_socket} =
             Engine.handle_event(
               "click",
               %{
                 "delta" => "2",
                 "intent" => "activate",
                 "widget_id" => "increment-button",
                 "widget_kind" => "button"
               },
               mounted_socket,
               WrapperLive
             )

    assert updated_socket.assigns.live_ui_error == nil
    assert updated_socket.assigns.live_ui_model.event_count == 1
    assert updated_socket.assigns.live_ui_model.screen_state.count == 3
    assert updated_socket.assigns.live_ui_model.last_signal.type == "live_ui.button.activate"
  end

  test "handle_event degrades into deterministic error assigns when validation fails" do
    socket = socket_for(WrapperLive, "wrapper-3", :index)

    {:ok, mounted_socket} =
      Engine.mount(
        %{"request_id" => "req-400"},
        %{"count" => 0},
        socket,
        WrapperLive
      )

    assert {:noreply, %Socket{} = errored_socket} =
             Engine.handle_event(
               "click",
               %{"widget_kind" => "button"},
               mounted_socket,
               WrapperLive
             )

    assert errored_socket.assigns.live_ui_model == nil
    assert %ConfigurationError{} = errored_socket.assigns.live_ui_error
    assert errored_socket.assigns.live_ui_error.message =~ "missing required metadata"

    rendered =
      render_component(&Engine.render/1,
        live_ui_error: errored_socket.assigns.live_ui_error,
        live_ui_model: nil
      )
      |> rendered_to_string()

    assert rendered =~ "live_ui configuration error"
    assert rendered =~ "missing required metadata"
  end

  defp socket_for(view, id, live_action) do
    %Socket{
      id: id,
      view: view,
      assigns: %{__changed__: %{}, live_action: live_action}
    }
  end
end
