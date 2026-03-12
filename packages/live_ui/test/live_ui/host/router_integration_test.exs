defmodule LiveUi.Host.RouterIntegrationTest do
  use ExUnit.Case, async: true

  alias LiveUi
  alias LiveUi.Live.DynamicLive
  alias LiveUi.Router
  alias LiveUi.TestSupport.CounterScreen
  alias LiveUi.TestSupport.RawIur
  alias LiveUi.TestSupport.WrapperLive
  alias Phoenix.LiveView.Socket

  test "screen wrappers mount through normal host liveview modules" do
    socket = socket_for(WrapperLive, "host-wrapper", :show)

    assert Router.screen(WrapperLive) == WrapperLive

    assert {:ok, %Socket{} = mounted_socket} =
             WrapperLive.mount(
               %{"request_id" => "router-1"},
               %{"count" => 7, "mount_token" => "host"},
               socket
             )

    assert mounted_socket.assigns.page_title == "CounterScreen"
    assert mounted_socket.assigns.live_ui_model.source.module == CounterScreen
    assert mounted_socket.assigns.live_ui_model.runtime_context.view == WrapperLive
    assert mounted_socket.assigns.live_ui_model.runtime_context.live_action == :show
  end

  test "dynamic entrypoint mounts through the host without a standalone live_ui app shell" do
    socket = socket_for(DynamicLive, "host-dynamic", nil)

    session =
      LiveUi.dynamic_session(CounterScreen, source_opts: [count: 5, mount_token: "dynamic"])

    assert Router.dynamic_live() == DynamicLive

    assert {:ok, %Socket{} = mounted_socket} =
             DynamicLive.mount(%{"request_id" => "router-2"}, session, socket)

    assert mounted_socket.assigns.page_title == "CounterScreen"
    assert mounted_socket.assigns.live_ui_model.source.module == CounterScreen
    assert mounted_socket.assigns.live_ui_model.screen_state.count == 5
    assert mounted_socket.assigns.live_ui_model.runtime_context.view == DynamicLive
  end

  test "dynamic entrypoint mounts canonical raw iur payloads through the host" do
    socket = socket_for(DynamicLive, "host-dynamic-iur", nil)

    session =
      LiveUi.dynamic_iur_session(RawIur.counter_tree(6), context: %{trace_id: "raw-iur-1"})

    assert {:ok, %Socket{} = mounted_socket} =
             DynamicLive.mount(%{"request_id" => "router-3"}, session, socket)

    assert mounted_socket.assigns.page_title == "vbox"
    assert mounted_socket.assigns.live_ui_model.source.kind == :iur
    assert mounted_socket.assigns.live_ui_model.descriptor_tree.id == "counter-root"
    assert mounted_socket.assigns.live_ui_model.runtime_context.view == DynamicLive
    assert mounted_socket.assigns.live_ui_model.runtime_context.trace_id == "raw-iur-1"
  end

  defp socket_for(view, id, live_action) do
    %Socket{id: id, view: view, assigns: %{__changed__: %{}, live_action: live_action}}
  end
end
