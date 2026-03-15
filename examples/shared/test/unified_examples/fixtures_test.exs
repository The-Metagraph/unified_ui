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

    assert Fixtures.stream_widget_entries() == [
             %{
               id: "evt-ops-001",
               timestamp: "2026-03-15T15:04:00Z",
               severity: :info,
               message: "Deploy pipeline resumed after approval"
             },
             %{
               id: "evt-ops-002",
               timestamp: "2026-03-15T15:06:00Z",
               severity: :warning,
               message: "Queue latency crossed the warning threshold"
             },
             %{
               id: "evt-ops-003",
               timestamp: "2026-03-15T15:08:00Z",
               severity: :success,
               message: "Responder handoff completed successfully"
             }
           ]

    assert Fixtures.process_monitor_snapshot() == %{
             sort_by: :cpu,
             severity: :warning,
             processes: [
               %{id: "proc-api", pid: "#PID<0.210.0>", label: "api-supervisor", state: :running},
               %{
                 id: "proc-queue",
                 pid: "#PID<0.211.0>",
                 label: "queue-consumer",
                 state: :waiting
               },
               %{
                 id: "proc-sync",
                 pid: "#PID<0.212.0>",
                 label: "sync-coordinator",
                 state: :running
               }
             ]
           }

    assert Fixtures.cluster_dashboard_snapshot() == %{
             severity: :warning,
             summary: %{healthy: 2, degraded: 1, regions: 3},
             nodes: [
               %{id: "denver-a", status: :up},
               %{id: "dallas-b", status: :degraded},
               %{id: "atlanta-c", status: :up}
             ]
           }

    assert Fixtures.supervision_tree_snapshot() == %{
             expanded?: true,
             topology: [
               %{
                 id: "root-sup",
                 type: :supervisor,
                 status: :running,
                 label: "Root Supervisor",
                 children: [
                   %{
                     id: "api-sup",
                     type: :supervisor,
                     status: :running,
                     label: "API Supervisor",
                     children: [
                       %{
                         id: "api-worker",
                         type: :worker,
                         status: :running,
                         label: "API Worker"
                       }
                     ]
                   },
                   %{
                     id: "queue-sup",
                     type: :supervisor,
                     status: :degraded,
                     label: "Queue Supervisor",
                     children: [
                       %{
                         id: "queue-worker",
                         type: :worker,
                         status: :restarting,
                         label: "Queue Worker"
                       }
                     ]
                   }
                 ]
               }
             ]
           }
  end
end
