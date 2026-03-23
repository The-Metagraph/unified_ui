defmodule TerminalUi.FoundationalWidgetFamiliesTest do
  use ExUnit.Case, async: true

  test "content and action widgets expose focus, shortcut, degradation, and command metadata" do
    icon = TerminalUi.Widgets.icon("save-icon", :save, fallback_text: "[S]")
    image = TerminalUi.Widgets.image("preview", "/tmp/preview.png", alt: "Preview")
    separator = TerminalUi.Widgets.separator("section-break")

    toggle =
      TerminalUi.Widgets.toggle("autosave-toggle", "Autosave",
        checked: true,
        shortcut: "a",
        binding: :autosave_enabled,
        on_toggle: %{intent: :toggle_autosave}
      )

    primary =
      TerminalUi.Widgets.command("save-command", "Save Workspace",
        command: :save_workspace,
        shortcut: "ctrl-s"
      )

    assert icon.kind == :icon
    assert icon.attributes.fallback_text == "[S]"
    assert image.kind == :image
    assert image.metadata.degradation == :placeholder
    assert separator.kind == :separator
    assert toggle.family == :action
    assert toggle.state.checked
    assert toggle.bindings.checked == :autosave_enabled
    assert toggle.metadata.shortcut == "a"
    assert toggle.events.toggle == %{intent: :toggle_autosave}
    assert primary.family == :action
    assert primary.metadata.command == :save_workspace
    assert primary.events.command == %{command: :save_workspace, source: :terminal_ui}
  end

  test "form and navigation widgets expose binding and keyboard-oriented interaction hooks" do
    query =
      TerminalUi.Widgets.text_input("query",
        value: "status:ok",
        binding: :query,
        on_submit: %{intent: :search}
      )

    filter =
      TerminalUi.Widgets.select("filter", [%{id: :all, label: "All"}],
        selected: :all,
        binding: :current_filter,
        on_change: %{intent: :change_filter}
      )

    sections =
      TerminalUi.Widgets.tabs("sections", [%{id: :overview, label: "Overview"}],
        current: :overview,
        current_binding: :active_section
      )

    trail =
      TerminalUi.Widgets.breadcrumbs("trail", [
        %{id: :workspace, label: "Workspace"},
        %{id: :details, label: "Details"}
      ])

    volume =
      TerminalUi.Widgets.slider("volume",
        value: 6,
        min: 0,
        max: 10,
        binding: :volume,
        on_change: %{intent: :set_volume}
      )

    artifacts =
      TerminalUi.Widgets.pick_list("artifacts", [%{id: :logs, label: "Logs"}],
        selected: [:logs],
        binding: :artifacts
      )

    assert query.family == :input
    assert query.bindings.value == :query
    assert query.events.submit == %{intent: :search}
    assert filter.kind == :select
    assert filter.bindings.selected == :current_filter
    assert filter.events.change == %{intent: :change_filter}
    assert sections.family == :navigation
    assert sections.bindings.current == :active_section
    assert sections.metadata.focusable
    assert trail.kind == :breadcrumbs
    assert Enum.map(trail.attributes.items, & &1.id) == [:workspace, :details]
    assert volume.kind == :slider
    assert volume.bindings.value == :volume
    assert volume.events.change == %{intent: :set_volume}
    assert artifacts.kind == :pick_list
    assert artifacts.bindings.selected == :artifacts
  end

  test "catalog and widget summaries expose phase two foundational coverage" do
    widget =
      TerminalUi.Widgets.checkbox("enabled", "Enabled",
        checked: true,
        binding: :enabled,
        shortcut: "space"
      )

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
             TerminalUi.Widgets.Operational
           ]

    assert :action in TerminalUi.Widgets.families()
    assert :command in TerminalUi.Widgets.kinds()
    assert :radio_group in TerminalUi.Widgets.kinds()
    assert :file_input in TerminalUi.Widgets.kinds()
    assert :form_builder in TerminalUi.Widgets.kinds()
    assert :tabs in TerminalUi.Widgets.kinds()

    assert TerminalUi.Widgets.validation_state().widget_contract == :ready
    assert TerminalUi.Widgets.validation_state().foundational_navigation_widgets == :ready
    assert TerminalUi.Widgets.validation_state().advanced_data_widgets == :ready

    assert TerminalUi.Info.widget_summary(widget).binding_keys == [:checked]
  end
end
