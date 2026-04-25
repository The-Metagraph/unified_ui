defmodule UnifiedUi.ToolingTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.{Export, Tooling}

  test "inspects maintained examples with compiler, signal, and spec context" do
    assert {:ok, report} = Tooling.inspect_example(:themed_signal_workspace)

    assert report.example.id == :themed_signal_workspace
    assert report.compiler.summary.identity_id == :themed_signal_workspace

    assert report.construct_families == [
             :canvas,
             :data,
             :display,
             :feedback,
             :forms,
             :foundational,
             :input,
             :layout,
             :navigation,
             :overlay
           ]

    assert report.signal_coverage == %{
             namespace: :workspace,
             mode: :canonical,
             binding_names: [:active_tab, :filters],
             interaction_ids: [
               :filters_change,
               :filters_submit,
               :navigate_activity,
               :open_commands,
               :open_settings
             ],
             families: [:change, :command, :navigation, :open, :submit],
             interaction_target_kinds: %{
               filters_change: :generic,
               filters_submit: :generic,
               navigate_activity: :local_destination,
               open_commands: :generic,
               open_settings: :generic
             },
             navigation_actions: [
               :navigate_to,
               :replace_with,
               :go_back,
               :go_forward,
               :open_modal,
               :close_modal
             ],
             navigation_contract: %{
               transition_fields: [:action, :screen, :modal, :params, :metadata],
               local_navigation_fields: [:binding, :destination],
               actions: %{
                 navigate_to: %{
                   kind: :screen_transition,
                   required_fields: [:screen],
                   optional_fields: [:params, :metadata]
                 },
                 replace_with: %{
                   kind: :replace_transition,
                   required_fields: [:screen],
                   optional_fields: [:params, :metadata]
                 },
                 go_back: %{
                   kind: :history_transition,
                   required_fields: [],
                   optional_fields: [:metadata]
                 },
                 go_forward: %{
                   kind: :history_transition,
                   required_fields: [],
                   optional_fields: [:metadata]
                 },
                 open_modal: %{
                   kind: :modal_transition,
                   required_fields: [:modal],
                   optional_fields: [:params, :metadata]
                 },
                 close_modal: %{
                   kind: :modal_transition,
                   required_fields: [],
                   optional_fields: [:modal, :metadata]
                 }
               }
             },
             target_bindings: [:active_tab, :filters]
           }

    assert ".spec/specs/unified-ui/display_systems.spec.md" in report.related_specs
    assert ".spec/specs/unified-ui/signals.spec.md" in report.related_specs
    assert Enum.any?(report.related_examples, &(&1.id == :overlay_workspace))
  end

  test "builds diff-oriented reporting for maintained examples" do
    assert {:ok, diff} = Tooling.diff_examples(:foundational_screen, :operations_dashboard)

    assert diff.left_example == :foundational_screen
    assert diff.right_example == :operations_dashboard
    assert diff.snapshot_changed?

    assert diff.changes.widget_kinds.added == [
             :cluster_dashboard,
             :gauge,
             :log_viewer,
             :markdown_viewer,
             :process_monitor,
             :sparkline,
             :stream_widget,
             :table,
             :tree_view
           ]

    assert diff.changes.widget_kinds.removed == [:button, :link, :menu, :text]
    assert ".spec/specs/unified-ui/widgets.spec.md" in diff.related_specs
  end

  test "exports inspection, signal, and coverage artifacts for review" do
    assert {:ok, inspection} = Export.example(:operations_dashboard, :inspection)
    assert inspection =~ "UnifiedUi compiler inspection"
    assert inspection =~ "widget kinds:"

    assert {:ok, signals} = Export.example(:themed_signal_workspace, :signals)
    assert signals =~ "filters_change"
    assert signals =~ "namespace"

    assert {:ok, coverage} = Export.coverage()
    assert coverage =~ "operations_dashboard"
    assert coverage =~ "total_examples"
  end

  test "surfaces actionable diagnostics for authored modules" do
    diagnostics =
      UnifiedUi.Examples.ThemedSignalWorkspace
      |> Tooling.module_diagnostics()

    assert diagnostics.status == :ok

    assert diagnostics.related_specs
           |> Enum.any?(&(&1 == ".spec/specs/unified-ui/signals.spec.md"))

    assert diagnostics.related_examples == [
             :foundational_screen,
             :profile_form,
             :overlay_workspace,
             :operations_dashboard
           ]

    rendered = Tooling.render_diagnostics(diagnostics)

    assert rendered =~ "status: ok"
    assert rendered =~ "related specs:"
    assert rendered =~ "signal families:"
    assert rendered =~ "navigation target kinds:"
  end
end
