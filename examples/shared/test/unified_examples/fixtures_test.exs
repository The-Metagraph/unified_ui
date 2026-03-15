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
  end
end
