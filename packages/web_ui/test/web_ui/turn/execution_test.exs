defmodule WebUi.Turn.ExecutionTest do
  use ExUnit.Case, async: true

  alias WebUi.Turn.Execution

  test "turn_id is deterministic and zero-padded by sequence" do
    assert Execution.turn_id(0) == "turn-000000"
    assert Execution.turn_id(1) == "turn-000001"
    assert Execution.turn_id(42) == "turn-000042"
  end

  test "attach_turn_metadata sets canonical dispatch and turn fields" do
    data = %{"action" => "save"}

    assert Execution.attach_turn_metadata(data, 3) == %{
             "action" => "save",
             "dispatch_sequence" => 3,
             "turn_id" => "turn-000003"
           }
  end

  test "begin_turn sets active turn id and dispatch sequence" do
    slice_state = %{dispatch_sequence: 0, active_turn_id: nil}

    assert Execution.begin_turn(slice_state, 9) == %{
             dispatch_sequence: 9,
             active_turn_id: "turn-000009"
           }
  end

  test "complete_turn prefers active turn id and clears active turn state" do
    slice_state = %{
      dispatch_sequence: 4,
      active_turn_id: "turn-000004",
      last_completed_turn_id: nil
    }

    result = %{
      payload: %{turn_id: "turn-123456"},
      context: %{turn_id: "turn-999999"}
    }

    assert Execution.complete_turn(slice_state, result) == %{
             dispatch_sequence: 4,
             active_turn_id: nil,
             last_completed_turn_id: "turn-000004"
           }
  end

  test "complete_turn falls back to result payload/context/ui_patch turn ids" do
    slice_state = %{dispatch_sequence: 2, active_turn_id: nil, last_completed_turn_id: nil}

    assert Execution.complete_turn(slice_state, %{payload: %{turn_id: "turn-000002"}}).last_completed_turn_id ==
             "turn-000002"

    assert Execution.complete_turn(slice_state, %{context: %{turn_id: "turn-000003"}}).last_completed_turn_id ==
             "turn-000003"

    assert Execution.complete_turn(slice_state, %{payload: %{ui_patch: %{turn_id: "turn-000004"}}}).last_completed_turn_id ==
             "turn-000004"
  end
end
