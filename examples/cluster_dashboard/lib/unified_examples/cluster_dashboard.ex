defmodule UnifiedExamples.ClusterDashboard do
  @moduledoc """
  Standalone cluster-dashboard example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_cluster_dashboard,
    directory: "examples/cluster_dashboard"
end
