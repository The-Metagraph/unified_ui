defmodule UnifiedExamples.FixturesTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared.Fixtures

  test "publishes stable sample fixtures for data-oriented example apps" do
    assert Fixtures.operations_table_columns() == [
             service: "Service",
             status: "Status",
             owner: "Owner"
           ]

    assert Enum.map(Fixtures.operations_table_rows(), &Keyword.fetch!(&1, :service)) == [
             "API",
             "Queue",
             "Billing"
           ]

    assert Enum.map(Fixtures.service_tree_nodes(), &Keyword.fetch!(&1, :label)) == [
             "Platform",
             "Payments"
           ]

    assert Fixtures.incident_markdown() =~ "# Incident Summary"

    assert Enum.map(Fixtures.event_log_entries(), &Keyword.fetch!(&1, :message)) == [
             "Deploy started",
             "Queue lag detected",
             "Lag recovered"
           ]

    assert Fixtures.status_snapshot() == %{
             text: "Release train stable",
             severity: :info,
             status: :ready
           }

    assert Fixtures.progress_snapshot() == %{
             current: 72,
             total: 100,
             label: "Deploy progress",
             severity: :info,
             status: :running
           }

    assert Fixtures.gauge_snapshot() == %{
             current: 74,
             minimum: 0,
             maximum: 100,
             label: "CPU load",
             severity: :warning,
             status: :degraded
           }

    assert Fixtures.inline_feedback_snapshot() == %{
             title: "Validation complete",
             message: "Runbook synced across regions",
             severity: :success,
             status: :complete
           }

    assert Fixtures.sparkline_points() == [34, 41, 39, 52, 48, 55]

    assert Fixtures.bar_chart_series() == [
             %{label: "API", value: 34},
             %{label: "Queue", value: 21},
             %{label: "Billing", value: 18}
           ]

    assert Fixtures.line_chart_series() == [
             %{x: "09:00", y: 12},
             %{x: "10:00", y: 18},
             %{x: "11:00", y: 15},
             %{x: "12:00", y: 24}
           ]

    assert Fixtures.viewport_document_lines() == [
             "Incident INC-101 escalated to the response lead",
             "Rollback approval is pending security review",
             "Queue depth stabilized after replay completion",
             "Status page update scheduled for the next checkpoint"
           ]

    assert Fixtures.scroll_bar_snapshot() == %{
             position: 18,
             viewport_size: 16,
             content_size: 120,
             orientation: :vertical
           }

    assert Fixtures.split_pane_snapshot() == %{
             ratio: 0.42,
             orientation: :horizontal,
             primary_heading: "Active incidents",
             secondary_heading: "Responder notes"
           }

    assert Fixtures.canvas_operations() == [
             %{kind: :cell, position: {1, 1}, text: "A"},
             %{kind: :fragment, position: {4, 2}, text: "Alert"},
             %{kind: :cell, position: {14, 5}, text: "R"}
           ]

    assert Fixtures.dialog_snapshot() == %{
             trigger_label: "Open settings",
             title: "Settings",
             copy: "Review escalation windows and routing defaults"
           }

    assert Fixtures.alert_dialog_snapshot() == %{
             trigger_label: "Escalate incident",
             title: "Escalate incident",
             message: "Paging the on-call owner will create a responder page.",
             severity: :warning
           }

    assert Fixtures.context_menu_options() == [
             retry: "Retry sync",
             silence: "Silence alert",
             assign: "Assign owner"
           ]

    assert Fixtures.toast_snapshot() == %{
             title: "Runbook synced",
             message: "Changes propagated to every region",
             severity: :success,
             placement: :bottom_end
           }

    assert Fixtures.overlay_snapshot() == %{
             base_title: "Coordinator workspace",
             background_fill: :scrim
           }
  end
end
