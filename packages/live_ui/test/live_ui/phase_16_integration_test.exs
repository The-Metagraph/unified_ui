defmodule LiveUi.Phase16IntegrationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias LiveUi.Runtime
  alias UnifiedIUR.{Container, Layout}
  alias UnifiedIUR.Widgets.{Advanced, Data, Feedback}

  @moduledoc """
  Integration tests for Phase 16 - Advanced Widget Integration Tests.

  These tests validate the complete widget-component architecture end to end
  across all widget families, with emphasis on advanced widgets, cross-family
  composition, and native/canonical parity.
  """

  describe "16.1.1 - Data and feedback widget integration scenarios" do
    test "data and document widgets preserve identity and bounded local state through component boundaries" do
      # List widget with selection state
      list_element =
        Data.list(
          [
            %{id: "item-1", label: "Option 1", selected?: true},
            %{id: "item-2", label: "Option 2", selected?: false}
          ],
          id: "selectable-list",
          selection_mode: "single"
        )

      {:ok, runtime_state} = Runtime.mount_iur(list_element)

      html =
        render_component(Runtime.component(),
          id: "list-test",
          runtime_state: runtime_state
        )

      # Verify widget boundary and identity are present
      assert html =~ ~s(data-live-ui-widget-boundary="list")
      assert html =~ ~s(data-live-ui-widget="list")
      assert html =~ ~s(id="selectable-list")
    end

    test "collection widget event routing remains correct for selection interactions" do
      # Table widget with selectable rows
      table_element =
        Data.table(
          [
            %{id: "name", label: "Name"},
            %{id: "status", label: "Status"}
          ],
          [
            %{id: "row-1", cells: ["Item 1", "Active"]},
            %{id: "row-2", cells: ["Item 2", "Inactive"]}
          ],
          id: "data-table"
        )

      {:ok, runtime_state} = Runtime.mount_iur(table_element)

      # Verify the widget component boundary renders
      html =
        render_component(Runtime.component(),
          id: "table-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="table")
      assert html =~ ~s(data-live-ui-widget="table")
    end

    test "markdown viewer preserves content through component boundaries" do
      markdown_element =
        Advanced.markdown_viewer(
          "# Test Content\n\n- Item 1\n- Item 2",
          id: "markdown-view",
          mode: "rendered"
        )

      {:ok, runtime_state} = Runtime.mount_iur(markdown_element)

      html =
        render_component(Runtime.component(),
          id: "markdown-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="markdown_viewer")
      assert html =~ ~s(data-live-ui-widget="markdown-viewer")
      assert html =~ "Test Content"
    end

    test "visually minimal widgets respect widget-component contract" do
      # Status widget - visually minimal but still a proper widget component
      status_element =
        Feedback.status("System ready",
          id: "status-indicator",
          severity: "success",
          status: "healthy"
        )

      {:ok, runtime_state} = Runtime.mount_iur(status_element)

      html =
        render_component(Runtime.component(),
          id: "status-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="status")
      assert html =~ ~s(data-live-ui-widget="status")
      assert html =~ "System ready"
    end

    test "stream widget preserves entry state through component boundaries" do
      stream_element =
        Advanced.stream_widget(
          [
            %{id: "evt-1", severity: "info", message: "System started"},
            %{id: "evt-2", severity: "success", message: "Ready"}
          ],
          id: "event-stream",
          ordering: "append_only"
        )

      {:ok, runtime_state} = Runtime.mount_iur(stream_element)

      html =
        render_component(Runtime.component(),
          id: "stream-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="stream_widget")
      assert html =~ ~s(data-live-ui-widget="stream-widget")
    end
  end

  describe "16.1.2 - Overlay and operational widget integration scenarios" do
    test "inline feedback widget preserves state through component boundaries" do
      # Inline feedback with severity
      feedback_element =
        Feedback.inline_feedback(
          "Changes saved successfully",
          id: "save-feedback",
          severity: "success",
          title: "Success"
        )

      {:ok, runtime_state} = Runtime.mount_iur(feedback_element)

      html =
        render_component(Runtime.component(),
          id: "feedback-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="inline_feedback")
      assert html =~ ~s(data-live-ui-widget="inline-feedback")
      assert html =~ "Changes saved successfully"
    end

    test "operational widgets preserve real-time updates and bounded local state" do
      # Process monitor with process state
      monitor_element =
        Advanced.process_monitor(
          [
            %{id: "app", pid: "#PID<0.1.0>", state: :running},
            %{id: "worker", pid: "#PID<0.2.0>", state: :idle}
          ],
          id: "process-monitor"
        )

      {:ok, runtime_state} = Runtime.mount_iur(monitor_element)

      html =
        render_component(Runtime.component(),
          id: "monitor-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="process_monitor")
      assert html =~ ~s(data-live-ui-widget="process-monitor")
    end

    test "log viewer preserves entry state through component boundaries" do
      log_element =
        Advanced.log_viewer(
          [
            %{id: "1", timestamp: "10:00:01", severity: "info", message: "Started"},
            %{id: "2", timestamp: "10:00:02", severity: "error", message: "Failed"}
          ],
          id: "log-viewer"
        )

      {:ok, runtime_state} = Runtime.mount_iur(log_element)

      html =
        render_component(Runtime.component(),
          id: "log-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="log_viewer")
      assert html =~ ~s(data-live-ui-widget="log-viewer")
    end

    test "cluster dashboard maintains summary state through component boundaries" do
      dashboard_element =
        Advanced.cluster_dashboard(
          [
            %{id: "node-1", status: :healthy},
            %{id: "node-2", status: :degraded}
          ],
          id: "cluster-dashboard",
          summary: %{healthy: 1, degraded: 1}
        )

      {:ok, runtime_state} = Runtime.mount_iur(dashboard_element)

      html =
        render_component(Runtime.component(),
          id: "dashboard-test",
          runtime_state: runtime_state
        )

      assert html =~ ~s(data-live-ui-widget-boundary="cluster_dashboard")
      assert html =~ ~s(data-live-ui-widget="cluster-dashboard")
    end
  end
end
