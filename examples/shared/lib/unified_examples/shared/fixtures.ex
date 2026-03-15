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
end
