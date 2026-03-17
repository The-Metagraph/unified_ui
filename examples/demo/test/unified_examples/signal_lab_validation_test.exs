defmodule UnifiedExamples.SignalLabValidationTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.SignalLab

  test "signal lab story contract summary reports a valid registry and surface map" do
    summary = SignalLab.story_contract_summary()

    assert summary.valid?
    assert summary.story_count == 4
    assert summary.surface_count == 4
    assert summary.errors == []
  end

  test "signal lab story contract validation catches family drift and missing surfaces" do
    invalid_stories = [
      SignalLab.story!(:action_to_feedback),
      Map.put(SignalLab.story!(:input_to_preview), :family, :submit),
      SignalLab.story!(:selection_to_filter)
    ]

    invalid_surfaces =
      SignalLab.story_surface_registry()
      |> Map.delete(:selection_to_filter)
      |> Map.put(:action_to_feedback, %{summary_id: :signal_lab_action_feedback_latest_summary})

    assert {:error, errors} = SignalLab.validate_story_contract(invalid_stories, invalid_surfaces)

    assert "missing required story toggle_to_visibility_or_enabled_state" in errors
    assert "story input_to_preview must use family change, got submit" in errors
    assert "missing surface registry for selection_to_filter" in errors
    assert "story action_to_feedback is missing source_region_id" in errors
    assert "story action_to_feedback is missing outcome_region_id" in errors
    assert "story action_to_feedback is missing detail_id" in errors
  end
end
