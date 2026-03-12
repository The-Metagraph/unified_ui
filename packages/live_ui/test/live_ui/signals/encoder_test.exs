defmodule LiveUi.Signals.EncoderTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias LiveUi.Signals.Encoder

  test "normalizes button clicks into concrete jido signals" do
    assert {:ok, %Signal{} = signal} =
             Encoder.encode(
               "click",
               %{"widget_id" => "save", "widget_kind" => "button", "intent" => "activate"},
               %{
                 signal_source: "/host/live_ui"
               }
             )

    assert signal.type == "live_ui.button.activate"
    assert signal.subject == "save"
    assert signal.source == "/host/live_ui"
  end

  test "includes value and form context for input events" do
    assert {:ok, signal} =
             Encoder.encode("change", %{
               "widget_id" => "name",
               "widget_kind" => "text_input",
               "value" => "Pascal",
               "form" => %{"name" => "Pascal"}
             })

    assert signal.data.payload == %{"form" => %{"name" => "Pascal"}, "value" => "Pascal"}
    assert signal.type == "live_ui.text_input.change"
  end

  test "decodes scoped attrs for multi-event elements without leaking other event scopes" do
    assert {:ok, signal} =
             Encoder.encode("submit", %{
               "widget_id" => "name",
               "widget_kind" => "text_input",
               "value" => "Pascal",
               "event_change_intent" => "update_name",
               "event_submit_intent" => "commit_name",
               "event_submit_source" => "blur",
               "event_submit_json_meta" => Jason.encode!(%{"reason" => "enter"})
             })

    assert signal.type == "live_ui.text_input.commit_name"

    assert signal.data.payload == %{
             "meta" => %{"reason" => "enter"},
             "source" => "blur",
             "value" => "Pascal"
           }
  end

  test "preserves stable payloads for hook-driven advanced widgets" do
    assert {:ok, signal} =
             Encoder.encode("resize", %{
               "widget_id" => "main-split",
               "widget_kind" => "split_pane",
               "intent" => "resize",
               "sizes" => [30, 70],
               "active_pane" => "left"
             })

    assert signal.type == "live_ui.split_pane.resize"
    assert signal.data.payload == %{"active_pane" => "left", "sizes" => [30, 70]}
  end

  test "normalizes table and tree payloads without leaking browser structure" do
    assert {:ok, table_signal} =
             Encoder.encode("click", %{
               "widget_id" => "users-table",
               "widget_kind" => "table",
               "event_click_intent" => "select_row",
               "event_click_row_id" => "user-1",
               "event_click_row_index" => "0"
             })

    assert table_signal.type == "live_ui.table.select_row"
    assert table_signal.data.payload == %{"row_id" => "user-1", "row_index" => "0"}

    assert {:ok, tree_signal} =
             Encoder.encode("click", %{
               "widget_id" => "tree-node-1",
               "widget_kind" => "tree_node",
               "event_click_intent" => "toggle_node",
               "event_click_node_id" => "tree-node-1",
               "event_click_expanded" => "true"
             })

    assert tree_signal.type == "live_ui.tree_node.toggle_node"
    assert tree_signal.data.payload == %{"expanded" => "true", "node_id" => "tree-node-1"}
  end

  test "decodes hook-style viewport payload json into stable signal data" do
    assert {:ok, signal} =
             Encoder.encode("scroll", %{
               "widget_id" => "viewport-1",
               "widget_kind" => "viewport",
               "event_scroll_intent" => "sync_scroll",
               "event_scroll_axis" => "both",
               "event_scroll_json_position" => Jason.encode!(%{"left" => 4, "top" => 12})
             })

    assert signal.type == "live_ui.viewport.sync_scroll"
    assert signal.data.payload == %{"axis" => "both", "position" => %{"left" => 4, "top" => 12}}
  end
end
