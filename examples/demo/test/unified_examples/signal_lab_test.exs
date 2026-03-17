defmodule UnifiedExamples.SignalLabTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.SignalLab
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedUi.Compiler

  test "signal lab exposes the required story registry" do
    assert SignalLab.story_ids() == [
             :action_to_feedback,
             :input_to_preview,
             :selection_to_filter,
             :toggle_to_visibility_or_enabled_state
           ]

    assert SignalLab.example_directories() == ["button", "text_input", "select", "toggle"]

    for story_id <- SignalLab.story_ids() do
      story = SignalLab.story!(story_id)

      assert story.id == story_id
      assert is_binary(story.label)
      assert is_atom(story.family)
      assert is_binary(story.source_label)
      assert is_binary(story.outcome_label)
      assert is_binary(story.summary_label)
      assert is_binary(story.summary)
    end
  end

  test "signal lab compiles as a structured fragment with all required story panels" do
    assert {:ok, result} = Compiler.compile_fragment(SignalLab)
    assert result.composition.mode == :fragment
    assert result.identity.id == :signal_lab

    assert {:ok, html} = Runtime.render_html(SignalLab)

    assert html =~ "Signal Lab"
    assert html =~ "Action to Feedback"
    assert html =~ "Input to Preview"
    assert html =~ "Selection to Filter"
    assert html =~ "Toggle to Visibility / Enabled State"
    assert html =~ "Source control"
    assert html =~ "Outcome panel"
    assert html =~ "Latest interaction summary"
    assert html =~ "Canonical click meaning will appear here"
    assert html =~ "Canonical selection meaning will appear here"
  end
end
