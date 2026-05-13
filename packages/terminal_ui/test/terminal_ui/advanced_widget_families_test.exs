defmodule TerminalUi.AdvancedWidgetFamiliesTest do
  use ExUnit.Case, async: true

  test "advanced data and feedback widgets expose selection, sorting, and overlay lifecycle metadata" do
    table =
      TerminalUi.Widgets.table(
        "jobs-table",
        [%{id: :name, label: "Name"}],
        [%{id: :alpha, cells: ["Alpha"]}],
        selection_binding: :selected_job,
        sort_key: :name,
        on_sort: %{intent: :sort_jobs}
      )

    tree =
      TerminalUi.Widgets.tree_view(
        "service-tree",
        [%{id: :root, label: "Root", children: [%{id: :child, label: "Child"}]}],
        selection_binding: :selected_node,
        on_expand: %{intent: :toggle_node}
      )

    dialog =
      TerminalUi.Widgets.alert_dialog(
        "danger-alert",
        "Delete workspace?",
        [TerminalUi.Widgets.button("confirm-delete", "Delete")],
        severity: :critical,
        on_close: %{intent: :cancel_delete}
      )

    progress =
      TerminalUi.Widgets.progress("sync-progress", current: 3, total: 10, binding: :sync_progress)

    assert table.family == :data
    assert table.metadata.selection_mode == :single
    assert table.metadata.sort_key == :name
    assert table.bindings.selection == :selected_job
    assert table.events.sort == %{intent: :sort_jobs}
    assert tree.kind == :tree_view
    assert tree.bindings.selection == :selected_node
    assert tree.events.expand == %{intent: :toggle_node}
    assert dialog.family == :feedback
    assert dialog.metadata.overlay_role == :alert_dialog
    assert dialog.state.severity == :critical
    assert dialog.events.close == %{intent: :cancel_delete}
    assert progress.bindings.value == :sync_progress
  end

  test "advanced visualization and operational widgets expose capability-aware metadata" do
    chart =
      TerminalUi.Widgets.line_chart("latency-chart", [%{id: :p95, values: [10, 15, 12]}],
        capability_profile: :rich_terminal
      )

    canvas =
      TerminalUi.Widgets.canvas("network-canvas", [%{kind: :text, text: "node", x: 2, y: 1}],
        degradation_strategy: :ascii_canvas
      )

    palette =
      TerminalUi.Widgets.command_palette("workspace-palette", [%{id: :deploy, label: "Deploy"}],
        query_binding: :palette_query,
        on_command: %{intent: :run_command}
      )

    logs =
      TerminalUi.Widgets.log_viewer("workspace-logs", [%{id: 1, message: "Started"}],
        streaming: true,
        filters_binding: :log_filters
      )

    assert chart.family == :visualization
    assert chart.metadata.capability_profile == :rich_terminal
    assert canvas.kind == :canvas
    assert canvas.metadata.degradation_strategy == :ascii_canvas
    assert palette.family == :operational
    assert palette.bindings.query == :palette_query
    assert palette.events.command == %{intent: :run_command}
    assert logs.state.streaming
    assert logs.bindings.filters == :log_filters
  end

  test "advanced widget catalog exposes phase three families and modules" do
    assert TerminalUi.Widgets.modules() == [
             TerminalUi.Widgets,
             TerminalUi.Widget,
             TerminalUi.Widgets.Foundational,
             TerminalUi.Widgets.Input,
             TerminalUi.Widgets.Forms,
             TerminalUi.Widgets.Navigation,
             TerminalUi.Widgets.Data,
             TerminalUi.Widgets.Feedback,
             TerminalUi.Widgets.Visualization,
             TerminalUi.Widgets.Operational,
             TerminalUi.Widgets.Portable
           ]

    assert :data in TerminalUi.Widgets.families()
    assert :visualization in TerminalUi.Widgets.families()
    assert :operational in TerminalUi.Widgets.families()
    assert :table in TerminalUi.Widgets.kinds()
    assert :toast in TerminalUi.Widgets.kinds()
    assert :gauge in TerminalUi.Widgets.kinds()
    assert :command_palette in TerminalUi.Widgets.kinds()
    assert TerminalUi.Widgets.validation_state().advanced_operational_widgets == :ready
    assert :overlay_role in TerminalUi.Widget.contract().metadata
    assert :streaming in TerminalUi.Widget.contract().state
    assert :filters in TerminalUi.Widget.contract().bindings
    assert :sort in TerminalUi.Widget.contract().events
  end
end
