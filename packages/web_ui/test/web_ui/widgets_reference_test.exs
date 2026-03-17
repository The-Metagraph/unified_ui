defmodule WebUi.WidgetsReferenceTest do
  use ExUnit.Case, async: true

  test "widget normalization produces stable widget definitions with inferred families" do
    assert {:ok, widget} =
             WebUi.Widgets.normalize(
               id: "profile-name",
               kind: :text_input,
               props: %{value: "Pascal"},
               events: %{change: "rename"},
               style_hooks: [:variant, :tone]
             )

    assert widget.family == :input
    assert widget.kind == :text_input
    assert WebUi.Info.widget_summary(widget).style_hooks == [:tone, :variant]
  end

  test "reference surfaces expose widget, runtime, and tooling boundaries" do
    reference = WebUi.reference()

    assert :input in reference.widgets.families
    assert WebUi.Widget in reference.widgets.modules
    assert WebUi.Server.Screen in reference.runtime.modules
    assert reference.runtime.assumptions.server.authoritative_server?
    assert :package_summary in reference.tooling.capabilities
  end

  test "package info reports validation state across widgets and split runtimes" do
    summary = WebUi.info()

    assert :input in summary.widget_families
    assert summary.validation_state.widgets.widget_definition == :ready
    assert summary.validation_state.server.server_state == :ready
    assert summary.validation_state.frontend.hydration == :ready
  end
end
