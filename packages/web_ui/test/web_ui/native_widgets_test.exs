defmodule WebUi.NativeWidgetsTest do
  use ExUnit.Case, async: true

  alias WebUi.Widgets.{Data, Feedback, Forms, Foundational, Input, Layout, Navigation}
  alias WebUi.Widgets.{Operational, Visualization}

  test "foundational constructors build direct-use widget contracts" do
    text = Foundational.text("Workspace", id: "workspace-title")
    button = Foundational.button("Save", id: "save-button", click: "save_workspace")

    content =
      Foundational.content([text, button],
        id: "workspace-header",
        presentation: :hero,
        style_hooks: [:tone, :variant]
      )

    assert text.kind == :text
    assert text.family == :foundational
    assert button.events == %{click: "save_workspace"}
    assert content.props.presentation == :hero
    assert content.slots.default == [text, button]
    assert content.style_hooks == [:tone, :variant]
  end

  test "input, navigation, layout, and grouped form widgets compose deterministically" do
    input =
      Input.text_input(
        id: "name-input",
        name: :name,
        value: "Pascal",
        placeholder: "Name",
        change: "rename_profile"
      )

    field =
      Forms.field(input,
        id: "name-field",
        name: :name,
        label: "Display Name",
        help: "Shown in navigation"
      )

    group = Forms.field_group([field], id: "identity-group", legend: "Identity")
    form = Forms.form_builder([group], id: "profile-form", submit: "save_profile")

    tabs =
      Navigation.tabs(
        [
          [id: :overview, label: "Overview", active?: true],
          [id: :activity, label: "Activity"]
        ],
        id: "profile-tabs",
        active_item: :overview,
        navigation: "switch_tab"
      )

    layout = Layout.column([form, tabs], id: "profile-layout", gap: :lg)

    assert input.events == %{change: "rename_profile"}

    assert [%WebUi.Widget{kind: :label}, %WebUi.Widget{kind: :text}] = [
             hd(field.slots.label),
             hd(field.slots.help)
           ]

    assert field.slots.control == [input]
    assert form.events == %{submit: "save_profile"}
    assert tabs.props.active_item == :overview
    assert tabs.events == %{navigation: "switch_tab"}
    assert layout.kind == :column
    assert Enum.map(layout.slots.default, & &1.id) == ["profile-form", "profile-tabs"]
  end

  test "widgets catalog exposes foundational families and public constructor modules" do
    modules = WebUi.Widgets.modules()

    assert Foundational in modules
    assert Input in modules
    assert Navigation in modules
    assert Layout in modules
    assert Forms in modules
    assert Data in modules
    assert Feedback in modules
    assert Visualization in modules
    assert Operational in modules

    assert :content in WebUi.Widgets.kinds()
    assert :form_builder in WebUi.Widgets.kinds()
    assert :markdown_viewer in WebUi.Widgets.kinds()
    assert :bar_chart in WebUi.Widgets.kinds()
    assert :navigation in WebUi.Widgets.families()
    assert :document in WebUi.Widgets.families()
    assert WebUi.Widgets.validation_state().form_composition == :ready
  end

  test "advanced widget families normalize deterministic data, document, and visualization props" do
    table =
      Data.table(
        [
          [id: :name, label: "Name", sortable?: true],
          [id: :status, label: "Status"]
        ],
        [
          [id: "node-a", cells: ["Node A", "healthy"], selected?: true],
          [id: "node-b", cells: ["Node B", "degraded"]]
        ],
        id: "cluster-table",
        sort_key: :name,
        sort_direction: :asc,
        filters: [[field: :status, operator: :eq, value: :healthy]],
        page: 1,
        page_size: 20,
        total_entries: 42,
        sort: "sort_cluster"
      )

    markdown =
      Data.markdown_viewer(
        "# Operations\n\nHealthy systems.",
        id: "ops-doc",
        anchors: [[id: "operations", label: "Operations", level: 1]]
      )

    progress = Feedback.progress(id: "deploy-progress", current: 3, total: 5, label: "Deploy")
    sparkline = Visualization.sparkline([4, 5, 7, 6], id: "cpu-sparkline")

    cluster =
      Operational.cluster_dashboard(
        [
          [id: "node-a", status: :healthy],
          [id: "node-b", status: :degraded]
        ],
        id: "cluster-dashboard",
        summary: %{healthy: 1, degraded: 1}
      )

    assert table.family == :data
    assert table.events == %{sort: "sort_cluster"}
    assert table.props.sorting == %{key: :name, direction: :asc}
    assert table.props.pagination.total_entries == 42
    assert markdown.family == :document
    assert hd(markdown.props.anchors).id == "operations"
    assert progress.props.total == 5
    assert sparkline.family == :visualization
    assert hd(sparkline.props.series).values == [4, 5, 7, 6]
    assert cluster.family == :operational
    assert cluster.props.summary == %{healthy: 1, degraded: 1}
  end
end
