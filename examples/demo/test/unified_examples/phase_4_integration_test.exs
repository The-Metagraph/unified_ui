defmodule UnifiedExamples.Phase4IntegrationTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Runtime

  @endpoint UnifiedExamples.Demo.Endpoint

  test "signal lab stories execute through the full authored interaction path" do
    {:ok, view, _html} = live(build_conn(), "/")

    view
    |> element("#demo-category-tab-signal_lab")
    |> render_click()

    click_html =
      view
      |> element("#signal_lab_action_trigger")
      |> render_click()

    assert click_html =~ "Action signal acknowledged."
    assert click_html =~ "Action to Feedback reacted to a canonical click signal."
    assert click_html =~ "live_ui.click.action_to_feedback"

    change_html =
      view
      |> form(
        "#signal_lab_input_source_input-interaction-form",
        %{"signal_lab_input_source_input" => "Phase 4 note"}
      )
      |> render_change()

    assert change_html =~ "Phase 4 note"
    assert change_html =~ "Input to Preview mirrored the latest canonical change signal."
    assert change_html =~ "Payload detail: note = Phase 4 note."

    selection_html =
      view
      |> form(
        "#signal_lab_selection_source_select-interaction-form",
        %{"signal_lab_selection_source_select" => "operational"}
      )
      |> render_change()

    assert selection_html =~ "Showing 2 linked examples for operational stories."
    assert selection_html =~ "Availability and emphasis gate"
    assert selection_html =~ "Payload detail: filter = operational."

    toggle_html =
      view
      |> form(
        "#signal_lab_toggle_source_control-interaction-form",
        %{"signal_lab_toggle_source_control" => "on"}
      )
      |> render_change()

    assert toggle_html =~ "Run enabled follow-up"
    assert toggle_html =~ "Payload detail: enabled = true."
    assert toggle_html =~ "Toggle to Visibility / Enabled State updated the target control"
  end

  test "signal lab updates visible target surfaces rather than only debug panels" do
    {:ok, view, _html} = live(build_conn(), "/")

    html =
      view
      |> element("#demo-category-tab-signal_lab")
      |> render_click()

    assert html =~ "Waiting for action signal."
    assert html =~ "Start typing to update the preview."
    assert html =~ "Showing all linked examples."
    assert html =~ "Protected follow-up action"

    html =
      view
      |> element("#signal_lab_action_trigger")
      |> render_click()

    assert html =~ "Action signal acknowledged."

    html =
      view
      |> form(
        "#signal_lab_input_source_input-interaction-form",
        %{"signal_lab_input_source_input" => "Visible target state"}
      )
      |> render_change()

    assert html =~ "Visible target state"

    html =
      view
      |> form(
        "#signal_lab_selection_source_select-interaction-form",
        %{"signal_lab_selection_source_select" => "operational"}
      )
      |> render_change()

    assert html =~ "Selection-driven filter story"
    assert html =~ "Availability and emphasis gate"

    html =
      view
      |> form(
        "#signal_lab_toggle_source_control-interaction-form",
        %{"signal_lab_toggle_source_control" => "on"}
      )
      |> render_change()

    assert html =~ "Run enabled follow-up"
    refute html =~ "Toggle the source control to enable this follow-up action."
  end

  test "signal lab stays aligned with demo styling and contract metadata" do
    signal_lab = Categories.review_entry!(:signal_lab)

    assert Demo.review_metadata().signal_lab_contract.valid?
    assert {:ok, html} = Runtime.render_html(signal_lab.fragment_module)

    assert html =~ "Signal Lab"
    assert html =~ ~s(data-live-ui-variant="panel")
    assert html =~ ~s(data-live-ui-variant="solid")
    assert html =~ ~s(data-live-ui-variant="filled")
    assert html =~ ~s(data-live-ui-tone="accent")
    assert html =~ "Latest interaction summary"
    assert html =~ "Outcome panel"
  end
end
