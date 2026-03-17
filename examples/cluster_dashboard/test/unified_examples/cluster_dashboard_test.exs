defmodule UnifiedExamples.ClusterDashboardTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.ClusterDashboard

  test "cluster dashboard example exposes standalone example metadata" do
    metadata = ClusterDashboard.metadata()

    assert metadata.id == :cluster_dashboard_example_screen
    assert metadata.root_id == :cluster_dashboard_example_screen_root
    assert metadata.widget == :cluster_dashboard
    assert metadata.app == :unified_example_cluster_dashboard
    assert metadata.directory == "examples/cluster_dashboard"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :command
  end

  test "cluster dashboard example renders the shared shell and foregrounds one primary cluster summary" do
    assert {:ok, runtime_state} = ClusterDashboard.boot()
    assert {:ok, html} = ClusterDashboard.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :cluster_dashboard_example_screen_shell

    assert %UnifiedIUR.Element{kind: :cluster_dashboard} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :cluster_dashboard_example_primary_cluster_dashboard
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"cluster-dashboard\""
    assert html =~ "Cluster Dashboard Widget Example"
    assert html =~ "denver-a"
    assert html =~ "dallas-b"
    assert html =~ "Review the cluster dashboard command story"
    assert html =~ "Meaningful Interaction Story"
  end
end
