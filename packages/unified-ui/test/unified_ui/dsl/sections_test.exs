defmodule UnifiedUi.Dsl.SectionsTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Sections.Layouts
  alias UnifiedUi.Dsl.Sections.Signals
  alias UnifiedUi.Dsl.Sections.Styles
  alias UnifiedUi.Dsl.Sections.Ui
  alias UnifiedUi.Dsl.Sections.Widgets

  test "layouts section exposes canonical metadata and entities" do
    section = Layouts.section()
    entity_names = Layouts.entities() |> Enum.map(& &1.name)

    assert section.name == :layouts
    assert Layouts.name() == :layouts
    refute Layouts.top_level?()
    assert section.entities == Layouts.entities()
    assert :vbox in entity_names
    assert :hbox in entity_names
    assert :grid in entity_names
    assert :stack in entity_names
    assert :zbox in entity_names
    assert :viewport in entity_names
    assert :split_pane in entity_names
    assert :canvas in entity_names
    assert :command_palette in entity_names
    assert :log_viewer in entity_names
    assert :stream_widget in entity_names
    assert :process_monitor in entity_names
  end

  test "styles section exposes schema and style entity" do
    section = Styles.section()
    entity_names = Styles.entities() |> Enum.map(& &1.name)

    assert section.name == :styles
    assert Styles.name() == :styles
    refute Styles.top_level?()
    assert section.entities == Styles.entities()
    assert :style in entity_names
    assert :theme in entity_names

    assert Keyword.has_key?(section.schema, :fg)
    assert Keyword.has_key?(section.schema, :bg)
    assert Keyword.has_key?(section.schema, :attrs)
    assert Keyword.has_key?(section.schema, :spacing)
    assert Keyword.has_key?(section.schema, :font_family)
    assert Keyword.has_key?(section.schema, :font_size)
    assert Keyword.has_key?(section.schema, :font_weight)
    assert Keyword.has_key?(section.schema, :border)
    assert Keyword.has_key?(section.schema, :border_width)
    assert Keyword.has_key?(section.schema, :border_color)
    assert Keyword.has_key?(section.schema, :border_style)
  end

  test "signals section delegates standard signal list" do
    section = Signals.section()

    assert section.name == :signals
    assert Signals.name() == :signals
    refute Signals.top_level?()
    assert Signals.entities() == []
    assert Signals.standard_signals() == UnifiedUi.Signals.standard_signals()
  end

  test "widgets section includes core and advanced widget entities" do
    section = Widgets.section()
    entity_names = Widgets.entities() |> Enum.map(& &1.name)

    assert section.name == :widgets
    assert Widgets.name() == :widgets
    refute Widgets.top_level?()
    assert section.entities == Widgets.entities()

    assert :button in entity_names
    assert :text in entity_names
    assert :text_input in entity_names
    assert :grid in entity_names
    assert :stack in entity_names
    assert :zbox in entity_names
    assert :gauge in entity_names
    assert :tabs in entity_names
    assert :tree_view in entity_names
    assert :dialog in entity_names
    assert :alert_dialog in entity_names
    assert :toast in entity_names
    assert :pick_list in entity_names
    assert :form_builder in entity_names
    assert :viewport in entity_names
    assert :split_pane in entity_names
    assert :canvas in entity_names
    assert :command_palette in entity_names
    assert :log_viewer in entity_names
    assert :stream_widget in entity_names
    assert :process_monitor in entity_names
  end

  test "ui section is top level and includes state/layout/widget entities" do
    section = Ui.section()
    entity_names = Ui.entities() |> Enum.map(& &1.name)

    assert section.name == :ui
    assert Ui.name() == :ui
    assert Ui.top_level?()
    assert section.entities == Ui.entities()

    assert hd(Ui.entities()).name == :state
    assert :vbox in entity_names
    assert :hbox in entity_names
    assert :grid in entity_names
    assert :stack in entity_names
    assert :zbox in entity_names
    assert :button in entity_names
    assert :line_chart in entity_names
    assert :table in entity_names
    assert :dialog in entity_names
    assert :toast in entity_names
    assert :pick_list in entity_names
    assert :form_builder in entity_names
  end
end
