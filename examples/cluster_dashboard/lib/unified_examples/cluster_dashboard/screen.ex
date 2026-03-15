defmodule UnifiedExamples.ClusterDashboard.Screen do
  @moduledoc """
  Shared-template cluster-dashboard proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @cluster_snapshot Fixtures.cluster_dashboard_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :cluster_dashboard_example_screen,
    title: "Cluster Dashboard Widget Example",
    summary: "Focused operational example using the shared suite shell",
    widget: :cluster_dashboard,
    notes:
      "Cluster-dashboard examples foreground one canonical node-health summary inside the shared shell."

  example_panel do
    cluster_dashboard :cluster_dashboard_example_primary_cluster_dashboard do
      cluster_nodes(@cluster_snapshot.nodes)
      metrics(@cluster_snapshot.summary)
      severity(@cluster_snapshot.severity)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
