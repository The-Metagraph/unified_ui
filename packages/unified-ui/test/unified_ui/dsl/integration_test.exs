defmodule UnifiedUi.Dsl.IntegrationTest do
  @moduledoc """
  Integration tests for the UnifiedUi DSL.

  These tests verify that the DSL components work together correctly:
  - State entity definition and struct creation
  - DSL sections can be used together
  - State can be converted to maps for Elm Architecture
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.State

  describe "State entity integration" do
    test "State struct can be created with various attribute types" do
      # Integer attributes
      state = %State{attrs: [count: 0, total: 100]}
      assert Keyword.get(state.attrs, :count) == 0
      assert Keyword.get(state.attrs, :total) == 100

      # String attributes
      state = %State{attrs: [name: "Test", message: "Hello"]}
      assert Keyword.get(state.attrs, :name) == "Test"
      assert Keyword.get(state.attrs, :message) == "Hello"

      # Boolean attributes
      state = %State{attrs: [active: true, visible: false]}
      assert Keyword.get(state.attrs, :active) == true
      assert Keyword.get(state.attrs, :visible) == false
    end

    test "State struct with mixed attribute types" do
      state = %State{
        attrs: [
          count: 42,
          name: "Example",
          active: true,
          rate: 3.14,
          items: [1, 2, 3],
          metadata: %{key: "value"}
        ]
      }

      assert Keyword.get(state.attrs, :count) == 42
      assert Keyword.get(state.attrs, :name) == "Example"
      assert Keyword.get(state.attrs, :active) == true
      assert Keyword.get(state.attrs, :rate) == 3.14
      assert Keyword.get(state.attrs, :items) == [1, 2, 3]
      assert Keyword.get(state.attrs, :metadata) == %{key: "value"}
    end
  end

  describe "State to Elm Architecture map conversion" do
    test "State converts to map with atom keys" do
      state = %State{attrs: [count: 0, name: "Test", active: true]}
      state_map = Enum.into(state.attrs, %{})

      assert is_map(state_map)
      assert Map.get(state_map, :count) == 0
      assert Map.get(state_map, :name) == "Test"
      assert Map.get(state_map, :active) == true
    end

    test "Empty state converts to empty map" do
      state = %State{attrs: []}
      state_map = Enum.into(state.attrs, %{})

      assert state_map == %{}
    end

    test "State with nil attrs converts to empty map" do
      state = %State{attrs: nil}
      # Enum.into with nil would fail, so we handle it
      state_map = if state.attrs, do: Enum.into(state.attrs, %{}), else: %{}

      assert state_map == %{}
    end
  end

  describe "DSL standard signals integration" do
    test "standard_signals/0 returns expected signals" do
      signals = UnifiedUi.Signals.standard_signals()

      assert is_list(signals)
      assert :click in signals
      assert :change in signals
      assert :submit in signals
      assert :focus in signals
      assert :blur in signals
      assert :select in signals
    end

    test "Dsl.standard_signals delegates to Signals module" do
      signals_dsl = UnifiedUi.Dsl.standard_signals()
      signals_module = UnifiedUi.Signals.standard_signals()

      assert signals_dsl == signals_module
    end
  end

  describe "Signal type mapping" do
    test "signal_type/1 returns correct type string for standard signals" do
      assert UnifiedUi.Signals.signal_type(:click) == "unified.button.clicked"
      assert UnifiedUi.Signals.signal_type(:change) == "unified.input.changed"
      assert UnifiedUi.Signals.signal_type(:submit) == "unified.form.submitted"
      assert UnifiedUi.Signals.signal_type(:focus) == "unified.element.focused"
      assert UnifiedUi.Signals.signal_type(:blur) == "unified.element.blurred"
      assert UnifiedUi.Signals.signal_type(:select) == "unified.item.selected"
    end

    test "signal_type/1 returns error for unknown signals" do
      assert UnifiedUi.Signals.signal_type(:unknown) == {:error, :unknown_signal}
      assert UnifiedUi.Signals.signal_type(:custom) == {:error, :unknown_signal}
    end
  end

  describe "Signal creation integration" do
    test "create/2 generates valid Jido.Signal" do
      {:ok, signal} = UnifiedUi.Signals.create(:click, %{button_id: :test_btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data == %{button_id: :test_btn}
      assert signal.source == "/unified_ui"
    end

    test "create/3 accepts custom source" do
      {:ok, signal} =
        UnifiedUi.Signals.create(:submit, %{form_id: :login}, source: "/my/app")

      assert signal.type == "unified.form.submitted"
      assert signal.source == "/my/app"
    end

    test "create!/2 raises on error" do
      assert_raise UnifiedUi.Errors.InvalidSignalError, ~r/Invalid signal name: :unknown/, fn ->
        UnifiedUi.Signals.create!(:unknown, %{})
      end
    end
  end

  describe "IUR Element protocol integration" do
    alias UnifiedIUR.Layouts.VBox
    alias UnifiedIUR.Widgets.Text
    alias UnifiedIUR.Widgets.Button

    test "VBox with children returns children via protocol" do
      vbox = %VBox{
        children: [
          %Text{content: "Hello"},
          %Button{label: "Click me"}
        ]
      }

      children = UnifiedIUR.Element.children(vbox)
      assert length(children) == 2
    end

    test "VBox metadata includes all properties" do
      vbox = %VBox{id: :main, spacing: 2, align_items: :center}
      metadata = UnifiedIUR.Element.metadata(vbox)

      assert metadata.type == :vbox
      assert metadata.id == :main
      assert metadata.spacing == 2
      assert metadata.align_items == :center
    end

    test "Text widget returns empty children list" do
      text = %Text{content: "Hello"}
      assert UnifiedIUR.Element.children(text) == []
    end

    test "Text widget metadata includes content" do
      text = %Text{content: "Test", id: :greeting}
      metadata = UnifiedIUR.Element.metadata(text)

      assert metadata.type == :text
      assert metadata.id == :greeting
    end

    test "Button widget metadata includes label" do
      button = %Button{label: "Submit", id: :submit_btn}
      metadata = UnifiedIUR.Element.metadata(button)

      assert metadata.type == :button
      assert metadata.label == "Submit"
      assert metadata.id == :submit_btn
    end
  end

  describe "End-to-end state flow" do
    test "State entity can flow through Elm Architecture pattern" do
      # 1. Define initial state
      initial_state = %State{attrs: [count: 0, max: 10]}

      # 2. Convert to map for Elm init
      init_map = Enum.into(initial_state.attrs, %{})

      # 3. Simulate update returning new state
      updated_map = Map.update!(init_map, :count, &(&1 + 1))

      # 4. Verify state transformation
      assert updated_map.count == 1
      assert updated_map.max == 10
    end
  end

  describe "Widget entity integration" do
    alias UnifiedUi.Dsl.Entities.Widgets, as: WidgetEntities
    alias UnifiedIUR.Widgets

    test "Button entity creates correct IUR struct" do
      entity = WidgetEntities.button_entity()

      assert entity.name == :button
      assert entity.target == Widgets.Button
      assert entity.args == [:label]
      assert Keyword.has_key?(entity.schema, :label)
      assert Keyword.has_key?(entity.schema, :on_click)
      assert Keyword.has_key?(entity.schema, :disabled)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "Text entity creates correct IUR struct" do
      entity = WidgetEntities.text_entity()

      assert entity.name == :text
      assert entity.target == Widgets.Text
      assert entity.args == [:content]
      assert Keyword.has_key?(entity.schema, :content)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "Label entity creates correct IUR struct" do
      entity = WidgetEntities.label_entity()

      assert entity.name == :label
      assert entity.target == Widgets.Label
      assert entity.args == [:for, :text]
      assert Keyword.has_key?(entity.schema, :for)
      assert Keyword.has_key?(entity.schema, :text)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "TextInput entity creates correct IUR struct" do
      entity = WidgetEntities.text_input_entity()

      assert entity.name == :text_input
      assert entity.target == Widgets.TextInput
      assert entity.args == [:id]
      assert Keyword.has_key?(entity.schema, :id)
      assert Keyword.has_key?(entity.schema, :value)
      assert Keyword.has_key?(entity.schema, :placeholder)
      assert Keyword.has_key?(entity.schema, :type)
      assert Keyword.has_key?(entity.schema, :on_change)
      assert Keyword.has_key?(entity.schema, :on_submit)
      assert Keyword.has_key?(entity.schema, :disabled)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "Button IUR struct integrates with Element protocol" do
      button = %Widgets.Button{
        label: "Submit",
        id: :submit_btn,
        on_click: :submit,
        disabled: false
      }

      assert UnifiedIUR.Element.children(button) == []
      metadata = UnifiedIUR.Element.metadata(button)

      assert metadata.type == :button
      assert metadata.label == "Submit"
      assert metadata.id == :submit_btn
      assert metadata.on_click == :submit
      assert metadata.disabled == false
    end

    test "Text IUR struct integrates with Element protocol" do
      text = %Widgets.Text{
        content: "Hello, World!",
        id: :greeting
      }

      assert UnifiedIUR.Element.children(text) == []
      metadata = UnifiedIUR.Element.metadata(text)

      assert metadata.type == :text
      assert metadata.id == :greeting
    end

    test "Label IUR struct integrates with Element protocol" do
      label = %Widgets.Label{
        for: :email_input,
        text: "Email:",
        id: :email_label
      }

      assert UnifiedIUR.Element.children(label) == []
      metadata = UnifiedIUR.Element.metadata(label)

      assert metadata.type == :label
      assert metadata.for == :email_input
      assert metadata.text == "Email:"
      assert metadata.id == :email_label
    end

    test "TextInput IUR struct integrates with Element protocol" do
      input = %Widgets.TextInput{
        id: :email,
        type: :email,
        placeholder: "user@example.com"
      }

      assert UnifiedIUR.Element.children(input) == []
      metadata = UnifiedIUR.Element.metadata(input)

      assert metadata.type == :text_input
      assert metadata.id == :email
      assert metadata.input_type == :email
      assert metadata.placeholder == "user@example.com"
    end

    test "All widgets have visible field for state binding" do
      button = %Widgets.Button{visible: true}
      text = %Widgets.Text{visible: false}
      label = %Widgets.Label{for: :test, text: "Test", visible: true}
      input = %Widgets.TextInput{id: :test, visible: false}

      button_meta = UnifiedIUR.Element.metadata(button)
      text_meta = UnifiedIUR.Element.metadata(text)
      label_meta = UnifiedIUR.Element.metadata(label)
      input_meta = UnifiedIUR.Element.metadata(input)

      assert button_meta.visible == true
      assert text_meta.visible == false
      assert label_meta.visible == true
      assert input_meta.visible == false
    end

    test "Widget signal handlers support multiple formats" do
      # Atom format
      button1 = %Widgets.Button{label: "Test", on_click: :submit}
      assert button1.on_click == :submit

      # Tuple with payload format
      button2 = %Widgets.Button{label: "Test", on_click: {:submit, %{id: 1}}}
      assert button2.on_click == {:submit, %{id: 1}}

      # MFA format
      button3 = %Widgets.Button{label: "Test", on_click: {MyModule, :function, []}}
      assert button3.on_click == {MyModule, :function, []}

      # TextInput on_change
      input1 = %Widgets.TextInput{id: :test, on_change: :value_changed}
      assert input1.on_change == :value_changed

      # TextInput on_change with payload
      input2 = %Widgets.TextInput{id: :test, on_change: {:value_changed, %{field: :email}}}
      assert input2.on_change == {:value_changed, %{field: :email}}

      # TextInput on_submit
      input3 = %Widgets.TextInput{id: :test, on_submit: :form_submitted}
      assert input3.on_submit == :form_submitted
    end

    test "TextInput supports all input types" do
      for type <- [:text, :password, :email, :number, :tel] do
        input = %Widgets.TextInput{id: :test, type: type}
        assert input.type == type
      end
    end
  end

  describe "Widget DSL extension registration" do
    test "widgets_section includes all widget entities" do
      # Get the widgets section from the extension
      sections = UnifiedUi.Dsl.Extension.sections()
      widgets_section = Enum.find(sections, fn %{name: name} -> name == :widgets end)

      assert widgets_section != nil
      # Includes core widgets plus advanced layout/container/specialized/monitoring entities.
      assert length(widgets_section.entities) == 28
    end

    test "widget entities are accessible from extension" do
      # All basic widget entity functions should be callable
      assert %Spark.Dsl.Entity{name: :button} = UnifiedUi.Dsl.Entities.Widgets.button_entity()
      assert %Spark.Dsl.Entity{name: :text} = UnifiedUi.Dsl.Entities.Widgets.text_entity()
      assert %Spark.Dsl.Entity{name: :label} = UnifiedUi.Dsl.Entities.Widgets.label_entity()

      assert %Spark.Dsl.Entity{name: :text_input} =
               UnifiedUi.Dsl.Entities.Widgets.text_input_entity()
    end

    test "data visualization widget entities are accessible from extension" do
      # Data visualization widget entity functions should be callable
      assert %Spark.Dsl.Entity{name: :gauge} = UnifiedUi.Dsl.Entities.DataViz.gauge_entity()

      assert %Spark.Dsl.Entity{name: :sparkline} =
               UnifiedUi.Dsl.Entities.DataViz.sparkline_entity()

      assert %Spark.Dsl.Entity{name: :bar_chart} =
               UnifiedUi.Dsl.Entities.DataViz.bar_chart_entity()

      assert %Spark.Dsl.Entity{name: :line_chart} =
               UnifiedUi.Dsl.Entities.DataViz.line_chart_entity()
    end

    test "table widget entity is accessible from extension" do
      # Table widget entity function should be callable
      assert %Spark.Dsl.Entity{name: :table} = UnifiedUi.Dsl.Entities.Tables.table_entity()
    end

    test "dialog and feedback widget entities are accessible from extension" do
      assert %Spark.Dsl.Entity{name: :dialog} =
               UnifiedUi.Dsl.Entities.DialogFeedback.dialog_entity()

      assert %Spark.Dsl.Entity{name: :alert_dialog} =
               UnifiedUi.Dsl.Entities.DialogFeedback.alert_dialog_entity()

      assert %Spark.Dsl.Entity{name: :toast} =
               UnifiedUi.Dsl.Entities.DialogFeedback.toast_entity()
    end

    test "input widget entities are accessible from extension" do
      assert %Spark.Dsl.Entity{name: :pick_list} =
               UnifiedUi.Dsl.Entities.InputWidgets.pick_list_entity()

      assert %Spark.Dsl.Entity{name: :form_builder} =
               UnifiedUi.Dsl.Entities.InputWidgets.form_builder_entity()
    end

    test "container widget entities are accessible from extension" do
      assert %Spark.Dsl.Entity{name: :grid} = UnifiedUi.Dsl.Entities.Layouts.grid_entity()
      assert %Spark.Dsl.Entity{name: :stack} = UnifiedUi.Dsl.Entities.Layouts.stack_entity()
      assert %Spark.Dsl.Entity{name: :zbox} = UnifiedUi.Dsl.Entities.Layouts.zbox_entity()

      assert %Spark.Dsl.Entity{name: :viewport} =
               UnifiedUi.Dsl.Entities.Containers.viewport_entity()

      assert %Spark.Dsl.Entity{name: :split_pane} =
               UnifiedUi.Dsl.Entities.Containers.split_pane_entity()

      assert %Spark.Dsl.Entity{name: :canvas} =
               UnifiedUi.Dsl.Entities.Specialized.canvas_entity()

      assert %Spark.Dsl.Entity{name: :command_palette} =
               UnifiedUi.Dsl.Entities.Specialized.command_palette_entity()

      assert %Spark.Dsl.Entity{name: :log_viewer} =
               UnifiedUi.Dsl.Entities.Monitoring.log_viewer_entity()

      assert %Spark.Dsl.Entity{name: :stream_widget} =
               UnifiedUi.Dsl.Entities.Monitoring.stream_widget_entity()

      assert %Spark.Dsl.Entity{name: :process_monitor} =
               UnifiedUi.Dsl.Entities.Monitoring.process_monitor_entity()
    end
  end

  describe "Layout entity integration" do
    alias UnifiedUi.Dsl.Entities.Layouts, as: LayoutEntities
    alias UnifiedIUR.Layouts

    test "VBox entity creates correct IUR struct" do
      entity = LayoutEntities.vbox_entity()

      assert entity.name == :vbox
      assert entity.target == Layouts.VBox
      assert entity.args == []
      assert Keyword.has_key?(entity.schema, :id)
      assert Keyword.has_key?(entity.schema, :spacing)
      assert Keyword.has_key?(entity.schema, :padding)
      assert Keyword.has_key?(entity.schema, :align_items)
      assert Keyword.has_key?(entity.schema, :justify_content)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "HBox entity creates correct IUR struct" do
      entity = LayoutEntities.hbox_entity()

      assert entity.name == :hbox
      assert entity.target == Layouts.HBox
      assert entity.args == []
      assert Keyword.has_key?(entity.schema, :id)
      assert Keyword.has_key?(entity.schema, :spacing)
      assert Keyword.has_key?(entity.schema, :padding)
      assert Keyword.has_key?(entity.schema, :align_items)
      assert Keyword.has_key?(entity.schema, :justify_content)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "Advanced layout entities create correct target structs" do
      grid_entity = LayoutEntities.grid_entity()
      stack_entity = LayoutEntities.stack_entity()
      zbox_entity = LayoutEntities.zbox_entity()

      assert grid_entity.name == :grid
      assert grid_entity.target == UnifiedUi.Widgets.Grid
      assert grid_entity.args == [:children]
      assert Keyword.has_key?(grid_entity.schema, :columns)
      assert Keyword.has_key?(grid_entity.schema, :rows)
      assert Keyword.has_key?(grid_entity.schema, :gap)

      assert stack_entity.name == :stack
      assert stack_entity.target == UnifiedUi.Widgets.Stack
      assert stack_entity.args == [:id, :children]
      assert Keyword.has_key?(stack_entity.schema, :active_index)
      assert Keyword.has_key?(stack_entity.schema, :transition)

      assert zbox_entity.name == :zbox
      assert zbox_entity.target == UnifiedUi.Widgets.ZBox
      assert zbox_entity.args == [:id, :children]
      assert Keyword.has_key?(zbox_entity.schema, :positions)
    end

    test "VBox IUR struct integrates with Element protocol" do
      text = %UnifiedIUR.Widgets.Text{content: "A"}
      button = %UnifiedIUR.Widgets.Button{label: "B", on_click: :b}

      vbox = %Layouts.VBox{
        id: :main,
        children: [text, button],
        spacing: 1,
        align_items: :center
      }

      assert UnifiedIUR.Element.children(vbox) == [text, button]
      metadata = UnifiedIUR.Element.metadata(vbox)

      assert metadata.type == :vbox
      assert metadata.id == :main
      assert metadata.spacing == 1
      assert metadata.align_items == :center
    end

    test "HBox IUR struct integrates with Element protocol" do
      text = %UnifiedIUR.Widgets.Text{content: "Label:"}
      input = %UnifiedIUR.Widgets.TextInput{id: :name}

      hbox = %Layouts.HBox{
        id: :form_row,
        children: [text, input],
        spacing: 2,
        align_items: :center
      }

      assert UnifiedIUR.Element.children(hbox) == [text, input]
      metadata = UnifiedIUR.Element.metadata(hbox)

      assert metadata.type == :hbox
      assert metadata.id == :form_row
      assert metadata.spacing == 2
      assert metadata.align_items == :center
    end

    test "Layouts can be nested" do
      button = %UnifiedIUR.Widgets.Button{label: "OK", on_click: :ok}

      inner_hbox = %Layouts.HBox{
        id: :button_row,
        children: [button],
        spacing: 1
      }

      vbox = %Layouts.VBox{
        id: :main,
        children: [inner_hbox],
        spacing: 2
      }

      assert UnifiedIUR.Element.children(vbox) == [inner_hbox]
      assert UnifiedIUR.Element.children(inner_hbox) == [button]
    end

    test "All layouts have visible field for state binding" do
      vbox = %Layouts.VBox{visible: true}
      hbox = %Layouts.HBox{visible: false}

      vbox_meta = UnifiedIUR.Element.metadata(vbox)
      hbox_meta = UnifiedIUR.Element.metadata(hbox)

      assert vbox_meta.visible == true
      assert hbox_meta.visible == false
    end

    test "Layouts support all alignment values" do
      # align_items values
      for align <- [:start, :center, :end, :stretch] do
        vbox = %Layouts.VBox{align_items: align}
        assert vbox.align_items == align

        hbox = %Layouts.HBox{align_items: align}
        assert hbox.align_items == align
      end

      # justify_content values
      for justify <- [:start, :center, :end, :stretch, :space_between, :space_around] do
        vbox = %Layouts.VBox{justify_content: justify}
        assert vbox.justify_content == justify

        hbox = %Layouts.HBox{justify_content: justify}
        assert hbox.justify_content == justify
      end
    end

    test "Layouts support padding option" do
      vbox = %Layouts.VBox{padding: 2}
      hbox = %Layouts.HBox{padding: 3}

      assert vbox.padding == 2
      assert hbox.padding == 3
    end
  end

  describe "Layout DSL extension registration" do
    test "layouts_section includes all layout entities" do
      sections = UnifiedUi.Dsl.Extension.sections()
      layouts_section = Enum.find(sections, fn %{name: name} -> name == :layouts end)

      assert layouts_section != nil
      assert length(layouts_section.entities) == 12
    end

    test "layout entities are accessible from extension" do
      # All layout entity functions should be callable
      assert %Spark.Dsl.Entity{name: :vbox} = UnifiedUi.Dsl.Entities.Layouts.vbox_entity()
      assert %Spark.Dsl.Entity{name: :hbox} = UnifiedUi.Dsl.Entities.Layouts.hbox_entity()
      assert %Spark.Dsl.Entity{name: :grid} = UnifiedUi.Dsl.Entities.Layouts.grid_entity()
      assert %Spark.Dsl.Entity{name: :stack} = UnifiedUi.Dsl.Entities.Layouts.stack_entity()
      assert %Spark.Dsl.Entity{name: :zbox} = UnifiedUi.Dsl.Entities.Layouts.zbox_entity()

      assert %Spark.Dsl.Entity{name: :viewport} =
               UnifiedUi.Dsl.Entities.Containers.viewport_entity()

      assert %Spark.Dsl.Entity{name: :split_pane} =
               UnifiedUi.Dsl.Entities.Containers.split_pane_entity()

      assert %Spark.Dsl.Entity{name: :canvas} =
               UnifiedUi.Dsl.Entities.Specialized.canvas_entity()

      assert %Spark.Dsl.Entity{name: :command_palette} =
               UnifiedUi.Dsl.Entities.Specialized.command_palette_entity()

      assert %Spark.Dsl.Entity{name: :log_viewer} =
               UnifiedUi.Dsl.Entities.Monitoring.log_viewer_entity()

      assert %Spark.Dsl.Entity{name: :stream_widget} =
               UnifiedUi.Dsl.Entities.Monitoring.stream_widget_entity()

      assert %Spark.Dsl.Entity{name: :process_monitor} =
               UnifiedUi.Dsl.Entities.Monitoring.process_monitor_entity()
    end
  end
end
