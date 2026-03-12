defmodule LiveUi.Host.EntrypointParityTest do
  use ExUnit.Case, async: true

  alias LiveUi
  alias LiveUi.Live.DynamicLive
  alias LiveUi.TestSupport.CounterScreen
  alias LiveUi.TestSupport.RawIur
  alias LiveUi.TestSupport.WrapperLive
  alias Phoenix.LiveView.Socket

  test "wrapper and dynamic entrypoints delegate to the same runtime model shape" do
    wrapper_socket = socket_for(WrapperLive, "wrapper-parity", :show)
    dynamic_socket = socket_for(DynamicLive, "dynamic-parity", nil)

    {:ok, wrapper_mounted} =
      WrapperLive.mount(
        %{"request_id" => "parity-1"},
        %{"count" => 4, "mount_token" => "same"},
        wrapper_socket
      )

    {:ok, dynamic_mounted} =
      DynamicLive.mount(
        %{"request_id" => "parity-2"},
        LiveUi.dynamic_session(CounterScreen, source_opts: [count: 4, mount_token: "same"]),
        dynamic_socket
      )

    wrapper_model = wrapper_mounted.assigns.live_ui_model
    dynamic_model = dynamic_mounted.assigns.live_ui_model

    assert wrapper_model.source.module == dynamic_model.source.module
    assert wrapper_model.screen_state == dynamic_model.screen_state
    assert wrapper_model.iur_tree == dynamic_model.iur_tree
    assert wrapper_model.status == :ready
    assert dynamic_model.status == :ready
    assert Map.keys(Map.from_struct(wrapper_model)) == Map.keys(Map.from_struct(dynamic_model))
  end

  test "dynamic raw iur entrypoints still initialize the same runtime model struct" do
    wrapper_socket = socket_for(WrapperLive, "wrapper-iur-parity", :show)
    dynamic_socket = socket_for(DynamicLive, "dynamic-iur-parity", nil)

    {:ok, wrapper_mounted} =
      WrapperLive.mount(
        %{"request_id" => "parity-iur-wrapper"},
        %{"count" => 5, "mount_token" => "iur-shape"},
        wrapper_socket
      )

    {:ok, dynamic_mounted} =
      DynamicLive.mount(
        %{"request_id" => "parity-iur-1"},
        LiveUi.dynamic_iur_session(RawIur.counter_tree(5)),
        dynamic_socket
      )

    wrapper_model = wrapper_mounted.assigns.live_ui_model
    dynamic_model = dynamic_mounted.assigns.live_ui_model

    assert dynamic_model.source.kind == :iur
    assert dynamic_model.screen_state == %{}
    assert dynamic_model.status == :ready
    assert dynamic_model.descriptor_tree.id == "counter-root"
    assert Map.keys(Map.from_struct(wrapper_model)) == Map.keys(Map.from_struct(dynamic_model))
  end

  defp socket_for(view, id, live_action) do
    %Socket{id: id, view: view, assigns: %{__changed__: %{}, live_action: live_action}}
  end
end
