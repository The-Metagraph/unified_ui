defmodule UnifiedExamples.Shared.Fixtures do
  @moduledoc """
  Shared sample fixtures for data-oriented example applications.
  """

  @spec operations_table_columns() :: keyword(String.t())
  def operations_table_columns do
    [
      service: "Service",
      status: "Status",
      owner: "Owner"
    ]
  end

  @spec operations_table_rows() :: [keyword(String.t())]
  def operations_table_rows do
    [
      [id: :api, service: "API", status: "Healthy", owner: "Platform"],
      [id: :queue, service: "Queue", status: "Lagging", owner: "SRE"],
      [id: :billing, service: "Billing", status: "Deploying", owner: "Payments"]
    ]
  end

  @spec service_tree_nodes() :: [keyword()]
  def service_tree_nodes do
    [
      [
        id: :platform,
        label: "Platform",
        expanded?: true,
        children: [
          [id: :api_node, label: "API"],
          [id: :queue_node, label: "Queue"]
        ]
      ],
      [
        id: :payments,
        label: "Payments",
        expanded?: true,
        children: [
          [id: :billing_node, label: "Billing"],
          [id: :ledger_node, label: "Ledger"]
        ]
      ]
    ]
  end

  @spec incident_markdown() :: String.t()
  def incident_markdown do
    """
    # Incident Summary

    - Primary system: API
    - Current status: Stable
    - Next step: Close the incident after validation
    """
  end

  @spec event_log_entries() :: [keyword()]
  def event_log_entries do
    [
      [
        id: "evt-001",
        timestamp: "2026-03-15T14:00:00Z",
        severity: :info,
        message: "Deploy started"
      ],
      [
        id: "evt-002",
        timestamp: "2026-03-15T14:02:00Z",
        severity: :warning,
        message: "Queue lag detected"
      ],
      [
        id: "evt-003",
        timestamp: "2026-03-15T14:05:00Z",
        severity: :info,
        message: "Lag recovered"
      ]
    ]
  end

  @spec status_snapshot() :: map()
  def status_snapshot do
    %{
      text: "Release train stable",
      severity: :info,
      status: :ready
    }
  end

  @spec progress_snapshot() :: map()
  def progress_snapshot do
    %{
      current: 72,
      total: 100,
      label: "Deploy progress",
      severity: :info,
      status: :running
    }
  end

  @spec gauge_snapshot() :: map()
  def gauge_snapshot do
    %{
      current: 74,
      minimum: 0,
      maximum: 100,
      label: "CPU load",
      severity: :warning,
      status: :degraded
    }
  end

  @spec inline_feedback_snapshot() :: map()
  def inline_feedback_snapshot do
    %{
      title: "Validation complete",
      message: "Runbook synced across regions",
      severity: :success,
      status: :complete
    }
  end

  @spec sparkline_points() :: [number()]
  def sparkline_points do
    [34, 41, 39, 52, 48, 55]
  end

  @spec bar_chart_series() :: [map()]
  def bar_chart_series do
    [
      %{label: "API", value: 34},
      %{label: "Queue", value: 21},
      %{label: "Billing", value: 18}
    ]
  end

  @spec line_chart_series() :: [map()]
  def line_chart_series do
    [
      %{x: "09:00", y: 12},
      %{x: "10:00", y: 18},
      %{x: "11:00", y: 15},
      %{x: "12:00", y: 24}
    ]
  end

  @spec viewport_document_lines() :: [String.t()]
  def viewport_document_lines do
    [
      "Incident INC-101 escalated to the response lead",
      "Rollback approval is pending security review",
      "Queue depth stabilized after replay completion",
      "Status page update scheduled for the next checkpoint"
    ]
  end

  @spec scroll_bar_snapshot() :: map()
  def scroll_bar_snapshot do
    %{
      position: 18,
      viewport_size: 16,
      content_size: 120,
      orientation: :vertical
    }
  end

  @spec split_pane_snapshot() :: map()
  def split_pane_snapshot do
    %{
      ratio: 0.42,
      orientation: :horizontal,
      primary_heading: "Active incidents",
      secondary_heading: "Responder notes"
    }
  end

  @spec canvas_operations() :: [map()]
  def canvas_operations do
    [
      %{kind: :cell, position: {1, 1}, text: "A"},
      %{kind: :fragment, position: {4, 2}, text: "Alert"},
      %{kind: :cell, position: {14, 5}, text: "R"}
    ]
  end

  @spec dialog_snapshot() :: map()
  def dialog_snapshot do
    %{
      trigger_label: "Open settings",
      title: "Settings",
      copy: "Review escalation windows and routing defaults"
    }
  end

  @spec alert_dialog_snapshot() :: map()
  def alert_dialog_snapshot do
    %{
      trigger_label: "Escalate incident",
      title: "Escalate incident",
      message: "Paging the on-call owner will create a responder page.",
      severity: :warning
    }
  end

  @spec context_menu_options() :: keyword(String.t())
  def context_menu_options do
    [retry: "Retry sync", silence: "Silence alert", assign: "Assign owner"]
  end

  @spec toast_snapshot() :: map()
  def toast_snapshot do
    %{
      title: "Runbook synced",
      message: "Changes propagated to every region",
      severity: :success,
      placement: :bottom_end
    }
  end

  @spec overlay_snapshot() :: map()
  def overlay_snapshot do
    %{
      base_title: "Coordinator workspace",
      background_fill: :scrim
    }
  end
end
