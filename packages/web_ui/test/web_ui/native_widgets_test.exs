defmodule WebUi.NativeWidgetsTest do
  use ExUnit.Case, async: true

  test "foundational constructors build direct-use widget contracts" do
    text = WebUi.Widgets.text("workspace-title", "Workspace")
    button = WebUi.Widgets.button("save-button", "Save", on_click: %{intent: :save_workspace})

    content =
      WebUi.Widgets.content("workspace-header", [text, button],
        presentation: :hero,
        style_hooks: [:tone, :variant]
      )

    assert text.kind == :text
    assert text.family == :content
    assert button.events == %{click: %{intent: :save_workspace}}
    assert content.attributes.presentation == :hero
    assert content.slot_children.default == [text, button]
    assert content.styles.hooks == [:tone, :variant]
  end

  test "input, navigation, layout, and grouped form widgets compose deterministically" do
    input =
      WebUi.Widgets.text_input("name-input",
        name: :name,
        value: "Pascal",
        placeholder: "Name",
        on_change: %{intent: :rename_profile}
      )

    field =
      WebUi.Widgets.field("name-field", input,
        name: :name,
        label: "Display Name",
        help: "Shown in navigation"
      )

    group = WebUi.Widgets.field_group("identity-group", [field], legend: "Identity")
    form = WebUi.Widgets.form("profile-form", [group], on_submit: %{intent: :save_profile})

    tabs =
      WebUi.Widgets.tabs(
        "profile-tabs",
        [
          [id: :overview, label: "Overview", active: true],
          [id: :activity, label: "Activity"]
        ],
        active_item: :overview,
        on_navigate: %{intent: :switch_tab}
      )

    layout = WebUi.Widgets.column("profile-layout", [form, tabs], gap: :lg)

    assert input.events == %{change: %{intent: :rename_profile}}
    assert hd(field.slot_children.label).kind == :label
    assert hd(field.slot_children.help).kind == :text
    assert field.slot_children.control == [input]
    assert form.events == %{submit: %{intent: :save_profile}}
    assert tabs.attributes.active_item == :overview
    assert tabs.events == %{navigation: %{intent: :switch_tab}}
    assert layout.kind == :column
    assert Enum.map(layout.slot_children.default, & &1.id) == ["profile-form", "profile-tabs"]
  end

  test "widgets catalog exposes foundational families and constructor modules" do
    modules = WebUi.Widgets.modules()

    assert WebUi.Widgets.Foundational in modules
    assert WebUi.Widgets.Input in modules
    assert WebUi.Widgets.Navigation in modules
    assert WebUi.Widgets.Layout in modules
    assert WebUi.Widgets.Forms in modules
    assert WebUi.Widgets.Data in modules
    assert WebUi.Widgets.Feedback in modules
    assert WebUi.Widgets.Visualization in modules
    assert WebUi.Widgets.Operational in modules

    assert :content in WebUi.Widgets.kinds()
    assert :form in WebUi.Widgets.kinds()
    assert :markdown_viewer in WebUi.Widgets.kinds()
    assert :bar_chart in WebUi.Widgets.kinds()
    assert :navigation in WebUi.Widgets.families()
    assert :document in WebUi.Widgets.families()
    assert :operational in WebUi.Widgets.families()
    assert WebUi.Widgets.validation_state().form_composition == :ready
    assert WebUi.Widgets.validation_state().advanced_data_widgets == :ready
  end

  test "advanced widget families normalize deterministic data, feedback, visualization, and operational state" do
    table =
      WebUi.Widgets.table(
        "cluster-table",
        [
          [id: :name, label: "Name", sortable: true],
          [id: :status, label: "Status"]
        ],
        [
          [id: "node-a", cells: ["Node A", "healthy"], selected: true],
          [id: "node-b", cells: ["Node B", "degraded"]]
        ],
        sort_key: :name,
        sort_direction: :asc,
        filters: [[field: :status, operator: :eq, value: :healthy]],
        page: 1,
        page_size: 20,
        total_entries: 42,
        on_sort: %{intent: :sort_cluster}
      )

    markdown =
      WebUi.Widgets.markdown_viewer(
        "ops-doc",
        "# Operations\n\nHealthy systems.",
        anchors: [[id: "operations", label: "Operations", level: 1]]
      )

    progress = WebUi.Widgets.progress("deploy-progress", current: 3, total: 5, label: "Deploy")
    sparkline = WebUi.Widgets.sparkline("cpu-sparkline", [4, 5, 7, 6])

    palette =
      WebUi.Widgets.command_palette(
        "ops-command-palette",
        [
          [id: :restart_node, label: "Restart Node"],
          [id: :drain_node, label: "Drain Node"]
        ],
        query: "rest",
        placeholder: "Run command",
        on_command: %{intent: :run_command}
      )

    assert table.family == :data
    assert table.events == %{sort: %{intent: :sort_cluster}}
    assert table.attributes.sorting == %{key: :name, direction: :asc}
    assert table.attributes.pagination.total_entries == 42
    assert markdown.family == :document
    assert hd(markdown.attributes.anchors).id == "operations"
    assert progress.family == :feedback
    assert progress.attributes.total == 5
    assert sparkline.family == :visualization
    assert hd(sparkline.attributes.series).values == [4, 5, 7, 6]
    assert palette.family == :operational
    assert palette.events == %{command: %{intent: :run_command}}
    assert palette.attributes.query == "rest"
  end
end
