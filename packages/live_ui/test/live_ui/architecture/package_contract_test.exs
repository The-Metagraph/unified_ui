defmodule LiveUi.Architecture.PackageContractTest do
  use ExUnit.Case, async: true

  alias LiveUi
  alias LiveUi.Assets
  alias LiveUi.Live.DynamicLive
  alias LiveUi.Router
  alias LiveUi.Screen
  alias LiveUi.TestSupport.RawIur
  alias LiveUi.Widgets
  alias LiveUi.WidgetRegistry

  test "exposes the package entrypoints used by host apps" do
    session =
      LiveUi.dynamic_session(LiveUi.TestSupport.CounterScreen,
        context: %{trace_id: "trace-1"},
        source_opts: [count: 3]
      )

    assert LiveUi.dynamic_session_key() == "live_ui_dynamic"
    assert {:ok, config} = LiveUi.fetch_dynamic_session(session)
    assert config["source"] == LiveUi.TestSupport.CounterScreen
    assert config["source_opts"] == [count: 3]
    assert config["context"] == %{trace_id: "trace-1"}

    iur_session =
      LiveUi.dynamic_iur_session(RawIur.counter_tree(4), context: %{trace_id: "trace-iur-1"})

    assert {:ok, iur_config} = LiveUi.fetch_dynamic_session(iur_session)
    assert iur_config["iur"] == RawIur.counter_tree(4)
    assert iur_config["context"] == %{trace_id: "trace-iur-1"}

    assert Router.dynamic_live() == DynamicLive
    assert Router.screen(LiveUi.TestSupport.WrapperLive) == LiveUi.TestSupport.WrapperLive
    assert macro_exported?(Screen, :__using__, 1)
    assert Code.ensure_loaded?(Widgets)
    assert function_exported?(Widgets, :vbox, 1)
    assert function_exported?(Widgets, :button, 1)
    assert function_exported?(Widgets, :tabs, 1)
    assert function_exported?(Widgets, :dialog, 1)
    assert function_exported?(Widgets, :table, 1)
    assert function_exported?(Widgets, :gauge, 1)
    assert function_exported?(Widgets, :process_monitor, 1)
    assert WidgetRegistry.supported_kind?("canvas")
    assert Assets.hook_name("viewport") == "LiveUi.Viewport"
    assert Assets.javascript_import_path() == "../../deps/live_ui/assets/js/live_ui"
  end
end
