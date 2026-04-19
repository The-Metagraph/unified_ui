defmodule UnifiedExamples.ClusterDashboardTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.ClusterDashboard
  alias UnifiedExamples.ClusterDashboard.Screen

  @endpoint UnifiedExamples.ClusterDashboard.Endpoint

  test "cluster-dashboard example exposes self-contained example metadata" do
    metadata = ClusterDashboard.metadata()

    assert metadata.id == :cluster_dashboard_example_screen
    assert metadata.root_id == :cluster_dashboard_example_screen_root
    assert metadata.title == "Cluster Dashboard Widget Example"
    assert metadata.summary == "Focused operational example using the local example shell"
    assert metadata.notes == "Cluster-dashboard examples foreground one canonical node-health summary inside the local shell."
    assert metadata.widget == :cluster_dashboard
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_cluster_dashboard
    assert metadata.directory == "examples/cluster_dashboard"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.ClusterDashboard.Application,
             UnifiedExamples.ClusterDashboard.Endpoint,
             UnifiedExamples.ClusterDashboard.Router,
             UnifiedExamples.ClusterDashboard.Layouts,
             UnifiedExamples.ClusterDashboard.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.ClusterDashboard.Screen,
             UnifiedExamples.ClusterDashboard.Theme,
             UnifiedExamples.ClusterDashboard.StyleProfile,
             UnifiedExamples.ClusterDashboard.Helpers
           ]
    assert metadata.style_contract.component_style_ids == [
             :example_shell,
             :example_panel,
             :example_form_shell,
             :example_title,
             :example_summary,
             :example_notes,
             :example_primary_button,
             :example_primary_input
           ]
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :command
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "cluster-dashboard example renders the local shell and foregrounds one primary cluster dashboard" do
    assert {:ok, runtime_state} = ClusterDashboard.boot()
    assert {:ok, html} = ClusterDashboard.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :cluster_dashboard_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"cluster-dashboard\""
    assert html =~ "Cluster Dashboard Widget Example"
    assert html =~ "dallas-b"
    assert html =~ "Inspect the cluster dashboard monitoring story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "cluster-dashboard example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/cluster_dashboard\""
    assert body =~ "Cluster Dashboard Widget Example"
    assert body =~ "data-live-ui-widget=\"cluster-dashboard\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
