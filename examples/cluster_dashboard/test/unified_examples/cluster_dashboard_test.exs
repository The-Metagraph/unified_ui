defmodule UnifiedExamples.ClusterDashboardTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.ClusterDashboard

  test "cluster dashboard example exposes standalone example metadata" do
    assert ClusterDashboard.metadata() == %{
             id: :cluster_dashboard_example_screen,
             root_id: :cluster_dashboard_example_screen_root,
             title: "Cluster Dashboard Widget Example",
             summary: "Focused operational example using the shared suite shell",
             notes:
               "Cluster-dashboard examples foreground one canonical node-health summary inside the shared shell.",
             widget: :cluster_dashboard,
             theme_id: :example_suite_default,
             app: :unified_example_cluster_dashboard,
             directory: "examples/cluster_dashboard",
             purpose: :widget_proof
           }
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
  end
end
