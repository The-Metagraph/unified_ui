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
end
