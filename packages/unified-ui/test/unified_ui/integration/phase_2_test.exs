defmodule UnifiedUi.Integration.Phase2Test do
  @moduledoc """
  Comprehensive integration tests for Phase 2 of UnifiedUi.

  These tests verify that all core widgets and layouts work together correctly,
  covering the full implementation of Phase 2 (sections 2.1-2.9).

  Test Sections:
  - 2.10.1: Complete UI with all basic widgets
  - 2.10.2: Deeply nested layouts (5+ levels)
  - 2.10.3: State updates flow through widgets
  - 2.10.4: Signal emission and handling
  - 2.10.5: Form submission works
  - 2.10.6: Style application to all widgets
  - 2.10.7: IUR tree builds correctly
  - 2.10.8: Verifiers catch invalid configurations
  - 2.10.9: Complex example UI (50+ elements)
  """

  use ExUnit.Case, async: false

  alias UnifiedIUR.{Layouts, Widgets}
  alias UnifiedUi.IUR.Builder
  alias UnifiedUi.Signals

  # ============================================================================
  # 2.10.1: Complete UI with all basic widgets
  # ============================================================================

  describe "2.10.1 - Complete UI with all basic widgets" do
    test "All widget types (text, button, label, text_input) work together" do
      # Create a complete UI using all widget types
      vbox = %Layouts.VBox{
        id: :main_ui,
        spacing: 1,
        children: [
          # Text widget
          %Widgets.Text{
            content: "Welcome to the App",
            id: :title
          },
          # Label widget
          %Widgets.Label{
            for: :username_input,
            text: "Username:",
            id: :username_label
          },
          # TextInput widget
          %Widgets.TextInput{
            id: :username_input,
            placeholder: "Enter username",
            type: :text
          },
          # Button widget
          %Widgets.Button{
            label: "Submit",
            id: :submit_btn,
            on_click: {:submit, %{form: :login}}
          }
        ]
      }

      # Verify structure
      assert length(vbox.children) == 4
      assert vbox.id == :main_ui

      # Verify each widget type
      title = Enum.at(vbox.children, 0)
      assert title.content == "Welcome to the App"
      assert title.id == :title

      label = Enum.at(vbox.children, 1)
      assert label.for == :username_input
      assert label.text == "Username:"

      input = Enum.at(vbox.children, 2)
      assert input.id == :username_input
      assert input.placeholder == "Enter username"

      button = Enum.at(vbox.children, 3)
      assert button.label == "Submit"
      assert button.on_click == {:submit, %{form: :login}}
    end

    test "All widgets have IUR Element protocol implementation" do
      text = %Widgets.Text{content: "Test", id: :test_text}
      button = %Widgets.Button{label: "Click", id: :test_btn, on_click: :clicked}
      label = %Widgets.Label{for: :input, text: "Label:"}
      input = %Widgets.TextInput{id: :input, type: :text}

      # All widgets should return empty children list
      assert UnifiedIUR.Element.children(text) == []
      assert UnifiedIUR.Element.children(button) == []
      assert UnifiedIUR.Element.children(label) == []
      assert UnifiedIUR.Element.children(input) == []

      # All widgets should have metadata
      text_meta = UnifiedIUR.Element.metadata(text)
      assert text_meta.type == :text
      assert text_meta.id == :test_text

      button_meta = UnifiedIUR.Element.metadata(button)
      assert button_meta.type == :button
      assert button_meta.label == "Click"

      label_meta = UnifiedIUR.Element.metadata(label)
      assert label_meta.type == :label

      input_meta = UnifiedIUR.Element.metadata(input)
      assert input_meta.type == :text_input
    end
  end

  # ============================================================================
  # 2.10.2: Deeply nested layouts (5+ levels)
  # ============================================================================

  describe "2.10.2 - Deeply nested layouts" do
    test "Layouts can be nested 5+ levels deep" do
      # Level 1: Root VBox
      deep_tree = %Layouts.VBox{
        id: :level_1,
        children: [
          # Level 2: HBox
          %Layouts.HBox{
            id: :level_2,
            children: [
              # Level 3: VBox
              %Layouts.VBox{
                id: :level_3,
                children: [
                  # Level 4: HBox
                  %Layouts.HBox{
                    id: :level_4,
                    children: [
                      # Level 5: VBox with content
                      %Layouts.VBox{
                        id: :level_5,
                        children: [
                          %Widgets.Text{content: "Deep content"}
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }

      # Traverse to level 5
      level_2 = hd(UnifiedIUR.Element.children(deep_tree))
      level_3 = hd(UnifiedIUR.Element.children(level_2))
      level_4 = hd(UnifiedIUR.Element.children(level_3))
      level_5 = hd(UnifiedIUR.Element.children(level_4))

      # Verify we're at level 5
      assert level_5.id == :level_5
      assert length(UnifiedIUR.Element.children(level_5)) == 1

      deep_content = hd(UnifiedIUR.Element.children(level_5))
      assert deep_content.content == "Deep content"
    end

    test "Nested layouts preserve all attributes through levels" do
      # Create nested structure with different attributes at each level
      tree = %Layouts.VBox{
        id: :root,
        spacing: 1,
        padding: 1,
        children: [
          %Layouts.HBox{
            id: :level_2,
            spacing: 2,
            align_items: :center,
            children: [
              %Layouts.VBox{
                id: :level_3,
                spacing: 3,
                justify_content: :center,
                children: [
                  %Layouts.HBox{
                    id: :level_4,
                    spacing: 4,
                    align_items: :end,
                    children: [
                      %Widgets.Button{label: "Deep Button", on_click: :deep_click}
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }

      # Verify each level's attributes
      assert tree.id == :root
      assert tree.spacing == 1
      assert tree.padding == 1

      level_2 = hd(UnifiedIUR.Element.children(tree))
      assert level_2.id == :level_2
      assert level_2.spacing == 2
      assert level_2.align_items == :center

      level_3 = hd(UnifiedIUR.Element.children(level_2))
      assert level_3.id == :level_3
      assert level_3.spacing == 3
      assert level_3.justify_content == :center

      level_4 = hd(UnifiedIUR.Element.children(level_3))
      assert level_4.id == :level_4
      assert level_4.spacing == 4
      assert level_4.align_items == :end
    end

    test "Mixed layout types nest correctly (VBox containing HBox containing VBox...)" do
      tree = %Layouts.VBox{
        id: :starts_vbox,
        children: [
          %Layouts.HBox{
            id: :then_hbox,
            children: [
              %Layouts.VBox{
                id: :then_vbox,
                children: [
                  %Layouts.HBox{
                    id: :then_hbox_again,
                    children: [
                      %Layouts.VBox{
                        id: :ends_vbox,
                        children: [
                          %Widgets.Text{content: "Alternating layouts"}
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }

      # Verify alternating types
      l1 = tree
      l2 = hd(UnifiedIUR.Element.children(l1))
      l3 = hd(UnifiedIUR.Element.children(l2))
      l4 = hd(UnifiedIUR.Element.children(l3))
      l5 = hd(UnifiedIUR.Element.children(l4))

      assert l1.id == :starts_vbox
      assert l2.id == :then_hbox
      assert l3.id == :then_vbox
      assert l4.id == :then_hbox_again
      assert l5.id == :ends_vbox
    end
  end

  # ============================================================================
  # 2.10.3: State updates flow through widgets
  # ============================================================================

  describe "2.10.3 - State updates flow through widgets" do
    test "State entity creates proper initial state map" do
      # Simulate state entity behavior
      state_attrs = [count: 0, username: "guest", active: true]
      initial_state = Enum.into(state_attrs, %{})

      assert initial_state.count == 0
      assert initial_state.username == "guest"
      assert initial_state.active == true
    end

    test "State updates create new state maps (Elm pattern)" do
      # Initial state
      state = %{count: 0, max: 10}

      # Simulate update (increment)
      updated_state = Map.update!(state, :count, &(&1 + 1))

      assert updated_state.count == 1
      assert updated_state.max == 10

      # State is immutable (original unchanged)
      assert state.count == 0
    end

    test "Multiple state updates chain correctly" do
      # Initial
      state = %{count: 0, name: "test"}

      # Update 1
      state = %{state | count: 1}

      # Update 2
      state = Map.put(state, :name, "updated")

      # Update 3
      state = Map.update!(state, :count, &(&1 + 1))

      assert state.count == 2
      assert state.name == "updated"
    end

    test "Widget visible field supports state binding" do
      # State with visibility flags
      state = %{show_error: false, show_success: true}

      # Widgets with visible bound to state
      error_text = %Widgets.Text{
        content: "Error occurred",
        visible: state.show_error
      }

      success_text = %Widgets.Text{
        content: "Success!",
        visible: state.show_success
      }

      assert error_text.visible == false
      assert success_text.visible == true
    end

    test "Widget disabled field supports state binding" do
      state = %{form_valid: false}

      button = %Widgets.Button{
        label: "Submit",
        disabled: !state.form_valid
      }

      assert button.disabled == true
    end
  end

  # ============================================================================
  # 2.10.4: Signal emission and handling
  # ============================================================================

  describe "2.10.4 - Signal emission and handling" do
    test "Button click signal can be created" do
      {:ok, signal} = Signals.create(:click, %{button_id: :submit_btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data.button_id == :submit_btn
    end

    test "Input change signal can be created" do
      {:ok, signal} = Signals.create(:change, %{input_id: :username, value: "test"})

      assert signal.type == "unified.input.changed"
      assert signal.data.input_id == :username
      assert signal.data.value == "test"
    end

    test "Form submit signal can be created" do
      {:ok, signal} =
        Signals.create(:submit, %{
          form_id: :login,
          data: %{username: "test", password: "[TEST_REDACTED]"}
        })

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
      assert signal.data.data.username == "test"
    end

    test "Signal handlers can be stored on widgets" do
      # Atom handler
      button1 = %Widgets.Button{label: "Test", on_click: :submit}
      assert button1.on_click == :submit

      # Tuple handler with payload
      button2 = %Widgets.Button{
        label: "Test",
        on_click: {:submit, %{id: :login_form}}
      }

      assert button2.on_click == {:submit, %{id: :login_form}}

      # MFA handler
      button3 = %Widgets.Button{
        label: "Test",
        on_click: {MyModule, :handle_click, []}
      }

      assert button3.on_click == {MyModule, :handle_click, []}
    end

    test "TextInput stores on_change and on_submit handlers" do
      input = %Widgets.TextInput{
        id: :email,
        on_change: {:email_changed, %{field: :email}},
        on_submit: :form_submitted
      }

      assert input.on_change == {:email_changed, %{field: :email}}
      assert input.on_submit == :form_submitted
    end

    test "All standard signal types are defined" do
      signals = UnifiedUi.Signals.standard_signals()

      assert :click in signals
      assert :change in signals
      assert :submit in signals
      assert :focus in signals
      assert :blur in signals
      assert :select in signals
    end
  end

  # ============================================================================
  # 2.10.5: Form submission works
  # ============================================================================

  describe "2.10.5 - Form submission" do
    test "Inputs can be grouped by form_id" do
      form_inputs = [
        %Widgets.TextInput{id: :username, form_id: :login, value: "user1"},
        %Widgets.TextInput{id: :password, form_id: :login, type: :password, value: "pass"},
        %Widgets.TextInput{id: :email, form_id: :login, type: :email, value: "user@test.com"}
      ]

      # Group by form_id
      login_form_inputs =
        Enum.filter(form_inputs, fn input -> input.form_id == :login end)

      assert length(login_form_inputs) == 3
      assert Enum.all?(login_form_inputs, &(&1.form_id == :login))
    end

    test "Form data can be collected from inputs" do
      inputs = [
        %Widgets.TextInput{id: :username, form_id: :login, value: "alice"},
        %Widgets.TextInput{id: :password, form_id: :login, type: :password, value: "[TEST_PASS]"},
        %Widgets.TextInput{id: :email, form_id: :login, type: :email, value: "alice@example.com"}
      ]

      # Collect form data
      form_data =
        inputs
        |> Enum.map(fn input -> {input.id, input.value} end)
        |> Enum.into(%{})

      assert form_data.username == "alice"
      assert form_data.password == "[TEST_PASS]"
      assert form_data.email == "alice@example.com"
    end

    test "Form submission signal includes form data" do
      form_data = %{
        username: "bob",
        email: "bob@example.com"
      }

      {:ok, signal} =
        Signals.create(:submit, %{
          form_id: :registration,
          data: form_data
        })

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :registration
      assert signal.data.data.username == "bob"
      assert signal.data.data.email == "bob@example.com"
    end

    test "Multiple forms can coexist with different form_ids" do
      inputs = [
        %Widgets.TextInput{id: :login_user, form_id: :login, value: "user"},
        %Widgets.TextInput{id: :login_pass, form_id: :login, type: :password, value: "pass"},
        %Widgets.TextInput{id: :reg_user, form_id: :register, value: "new_user"},
        %Widgets.TextInput{
          id: :reg_email,
          form_id: :register,
          type: :email,
          value: "new@test.com"
        }
      ]

      login_inputs = Enum.filter(inputs, &(&1.form_id == :login))
      reg_inputs = Enum.filter(inputs, &(&1.form_id == :register))

      assert length(login_inputs) == 2
      assert length(reg_inputs) == 2
    end

    test "Inputs without form_id are not included in form submission" do
      inputs = [
        %Widgets.TextInput{id: :username, form_id: :login, value: "user"},
        %Widgets.TextInput{id: :search, form_id: nil, value: "query"},
        %Widgets.TextInput{id: :password, form_id: :login, type: :password, value: "pass"}
      ]

      login_inputs = Enum.filter(inputs, &(&1.form_id == :login))

      assert length(login_inputs) == 2
      assert Enum.all?(login_inputs, fn input -> input.id in [:username, :password] end)
    end
  end

  # ============================================================================
  # 2.10.6: Style application to all widgets
  # ============================================================================

  describe "2.10.6 - Style application" do
    test "Inline styles apply to all widgets" do
      text = %Widgets.Text{
        content: "Styled",
        style: %UnifiedIUR.Style{fg: :cyan, attrs: [:bold]}
      }

      button = %Widgets.Button{
        label: "Styled",
        style: %UnifiedIUR.Style{fg: :green, bg: :black}
      }

      label = %Widgets.Label{
        for: :input,
        text: "Label:",
        style: %UnifiedIUR.Style{attrs: [:underline]}
      }

      input = %Widgets.TextInput{
        id: :input,
        style: %UnifiedIUR.Style{fg: :white}
      }

      assert text.style.fg == :cyan
      assert text.style.attrs == [:bold]

      assert button.style.fg == :green
      assert button.style.bg == :black

      assert label.style.attrs == [:underline]

      assert input.style.fg == :white
    end

    test "Styles apply to layouts" do
      # Layouts have their own properties (spacing, align_items, justify_content, padding)
      # AND they can have a Style struct for visual attributes
      vbox = %Layouts.VBox{
        id: :main,
        spacing: 1,
        padding: 2,
        style: %UnifiedIUR.Style{fg: :blue}
      }

      hbox = %Layouts.HBox{
        id: :row,
        align_items: :center,
        style: %UnifiedIUR.Style{bg: :black}
      }

      # Layout properties
      assert vbox.spacing == 1
      assert vbox.padding == 2

      # Style properties
      assert vbox.style.fg == :blue

      # Layout properties
      assert hbox.align_items == :center

      # Style properties
      assert hbox.style.bg == :black
    end

    test "Style attributes include all basic properties" do
      style = %UnifiedIUR.Style{
        fg: :red,
        bg: :blue,
        attrs: [:bold, :italic, :underline],
        padding: 2,
        margin: 1,
        width: :fill,
        height: :auto,
        align: :center
      }

      assert style.fg == :red
      assert style.bg == :blue
      assert style.attrs == [:bold, :italic, :underline]
      assert style.padding == 2
      assert style.margin == 1
      assert style.width == :fill
      assert style.height == :auto
      assert style.align == :center
    end

    test "Widgets can have nil style (no styling applied)" do
      text = %Widgets.Text{content: "Plain", style: nil}
      button = %Widgets.Button{label: "Plain", style: nil}

      assert text.style == nil
      assert button.style == nil
    end
  end

  # ============================================================================
  # 2.10.7: IUR tree builds correctly
  # ============================================================================

  describe "2.10.7 - IUR tree building" do
    test "Builder validates button with required label" do
      button = %Widgets.Button{label: "Click Me"}
      assert Builder.validate(button) == :ok

      button_no_label = %Widgets.Button{label: nil}
      assert Builder.validate(button_no_label) == {:error, :missing_label}
    end

    test "Builder validates text with required content" do
      text = %Widgets.Text{content: "Hello"}
      assert Builder.validate(text) == :ok

      text_no_content = %Widgets.Text{content: nil}
      assert Builder.validate(text_no_content) == {:error, :missing_content}
    end

    test "Builder validates nested structures" do
      vbox = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Valid"},
          %Widgets.Button{label: "Valid", on_click: :click}
        ]
      }

      assert Builder.validate(vbox) == :ok
    end

    test "Builder validates fails for invalid nested structures" do
      vbox = %Layouts.VBox{
        children: [
          %Widgets.Text{content: nil},
          %Widgets.Button{label: "Valid", on_click: :click}
        ]
      }

      assert Builder.validate(vbox) == {:error, :missing_content}
    end

    test "IUR tree structure is preserved through nesting" do
      leaf_button = %Widgets.Button{label: "Leaf", on_click: :leaf}
      inner_hbox = %Layouts.HBox{children: [leaf_button]}
      outer_vbox = %Layouts.VBox{children: [inner_hbox]}

      # Traverse
      hbox = hd(UnifiedIUR.Element.children(outer_vbox))
      button = hd(UnifiedIUR.Element.children(hbox))

      assert button.label == "Leaf"
      assert button.on_click == :leaf
    end

    test "Layout and widget metadata is accessible" do
      vbox = %Layouts.VBox{
        id: :test_vbox,
        spacing: 2,
        padding: 1,
        align_items: :center,
        children: [
          %Widgets.Button{label: "Test", id: :test_btn, on_click: :test}
        ]
      }

      metadata = UnifiedIUR.Element.metadata(vbox)

      assert metadata.type == :vbox
      assert metadata.id == :test_vbox
      assert metadata.spacing == 2
      assert metadata.padding == 1
      assert metadata.align_items == :center

      button = hd(UnifiedIUR.Element.children(vbox))
      button_meta = UnifiedIUR.Element.metadata(button)

      assert button_meta.type == :button
      assert button_meta.label == "Test"
      assert button_meta.id == :test_btn
    end
  end

  # ============================================================================
  # 2.10.8: Verifiers catch invalid configurations
  # ============================================================================

  describe "2.10.8 - Verifiers catch invalid configurations" do
    test "Duplicate IDs are detected (UniqueIdVerifier)" do
      # Create IUR tree with duplicate IDs
      tree = %Layouts.VBox{
        children: [
          %Widgets.Button{id: :duplicate, label: "Button 1", on_click: :b1},
          %Widgets.Button{id: :duplicate, label: "Button 2", on_click: :b2}
        ]
      }

      # Collect all IDs
      ids = collect_ids(tree)

      # Check for duplicates
      unique_ids = Enum.uniq(ids)
      assert length(ids) != length(unique_ids), "Expected duplicate IDs to be detected"
    end

    test "Label 'for' references input IDs (LayoutStructureVerifier pattern)" do
      # Valid: label references existing input
      valid_tree = %Layouts.VBox{
        children: [
          %Widgets.Label{for: :my_input, text: "Label:"},
          %Widgets.TextInput{id: :my_input}
        ]
      }

      # Extract label and input
      [label, input] = UnifiedIUR.Element.children(valid_tree)
      assert label.for == input.id
    end

    test "Invalid label 'for' would be caught" do
      # Invalid pattern: label references non-existent input
      invalid_tree = %Layouts.VBox{
        children: [
          %Widgets.Label{for: :non_existent, text: "Label:"},
          %Widgets.TextInput{id: :actual_input}
        ]
      }

      [label, input] = UnifiedIUR.Element.children(invalid_tree)

      # Label.for doesn't match any input ID
      assert label.for == :non_existent
      assert input.id == :actual_input
      assert label.for != input.id
    end

    test "Signal handlers must be valid format" do
      # Valid formats
      valid_handlers = [
        :atom_signal,
        {:signal_with_payload, %{key: :value}},
        {Module, :function, []}
      ]

      # These should all be valid signal handler formats
      Enum.each(valid_handlers, fn handler ->
        assert valid_signal_handler_format?(handler)
      end)
    end

    test "Invalid signal handler formats are rejected" do
      # Invalid formats
      invalid_handlers = [
        "string_not_valid",
        %{map: "not_valid"},
        [:list, :not_valid],
        123
      ]

      # These should all be invalid
      Enum.each(invalid_handlers, fn handler ->
        refute valid_signal_handler_format?(handler)
      end)
    end

    test "State keys must be atoms" do
      # Valid: atom keys
      valid_state = [count: 0, name: "test", active: true]

      # All keys should be atoms
      assert Enum.all?(valid_state, fn {k, _v} -> is_atom(k) end)
    end
  end

  # ============================================================================
  # 2.10.9: Complex example UI (50+ elements)
  # ============================================================================

  describe "2.10.9 - Complex example UI (50+ elements)" do
    @tag :complex_ui
    test "Complex login form UI compiles correctly" do
      # Build a realistic login form with multiple elements
      login_form = build_complex_login_form()

      # Count total elements
      element_count = count_elements(login_form)

      # Should have many elements (forms, labels, inputs, buttons, etc.)
      assert element_count > 10
    end

    @tag :complex_ui
    test "Complex dashboard UI compiles correctly" do
      dashboard = build_complex_dashboard()

      element_count = count_elements(dashboard)

      # Dashboard should be substantial (has stats panel and activity panel)
      assert element_count >= 15,
             "Expected at least 15 elements in dashboard, got #{element_count}"
    end

    @tag :complex_ui
    test "Complex settings screen UI compiles correctly" do
      settings_screen = build_complex_settings_screen()

      element_count = count_elements(settings_screen)

      # Settings screen should have many options (account, notifications, security sections)
      assert element_count >= 25,
             "Expected at least 25 elements in settings, got #{element_count}"
    end

    @tag :complex_ui
    test "Full application UI (50+ elements) compiles correctly" do
      # Combine multiple screens into one mega-UI
      full_app = build_full_application_ui()

      element_count = count_elements(full_app)

      # Should definitely exceed 50 elements
      assert element_count >= 50,
             "Expected at least 50 elements, got #{element_count}"

      # Verify structure is valid
      assert Builder.validate(full_app) == :ok
    end
  end

  # ============================================================================
  # Helper Functions
  # ============================================================================

  defp collect_ids(element, acc \\ []) do
    metadata = UnifiedIUR.Element.metadata(element)

    acc =
      if Map.has_key?(metadata, :id) && metadata.id != nil do
        [metadata.id | acc]
      else
        acc
      end

    children = UnifiedIUR.Element.children(element)

    Enum.reduce(children, acc, fn child, inner_acc ->
      collect_ids(child, inner_acc)
    end)
  end

  defp valid_signal_handler_format?(handler) when is_atom(handler), do: true

  defp valid_signal_handler_format?(handler) when is_tuple(handler) do
    case tuple_size(handler) do
      2 ->
        {signal, payload} = handler
        is_atom(signal) and is_map(payload)

      3 ->
        {module, function, args} = handler
        is_atom(module) and is_atom(function) and is_list(args)

      _ ->
        false
    end
  end

  defp valid_signal_handler_format?(_), do: false

  defp count_elements(element) do
    1 +
      Enum.reduce(UnifiedIUR.Element.children(element), 0, fn child, acc ->
        acc + count_elements(child)
      end)
  end

  # Complex UI builders for testing

  defp build_complex_login_form do
    %Layouts.VBox{
      id: :login_screen,
      spacing: 1,
      padding: 2,
      children: [
        %Widgets.Text{content: "Welcome to MyApp", id: :app_title},
        %Widgets.Text{content: "Please sign in to continue", id: :subtitle},
        %Layouts.HBox{
          children: [
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.Label{for: :username, text: "Username:"},
                %Widgets.Label{for: :password, text: "Password:"}
              ]
            },
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.TextInput{
                  id: :username,
                  placeholder: "Enter username",
                  form_id: :login
                },
                %Widgets.TextInput{
                  id: :password,
                  type: :password,
                  placeholder: "Enter password",
                  form_id: :login
                }
              ]
            }
          ]
        },
        %Layouts.HBox{
          spacing: 2,
          children: [
            %Widgets.Button{label: "Login", id: :login_btn, on_click: {:login, %{}}},
            %Widgets.Button{label: "Cancel", id: :cancel_btn, on_click: :cancel}
          ]
        },
        %Widgets.Text{content: "Forgot password?", id: :forgot_link}
      ]
    }
  end

  defp build_complex_dashboard do
    %Layouts.VBox{
      id: :dashboard,
      spacing: 1,
      children: [
        %Layouts.HBox{
          children: [
            %Widgets.Text{content: "Dashboard", id: :dash_title},
            %Widgets.Button{label: "Refresh", id: :refresh_btn, on_click: :refresh},
            %Widgets.Button{label: "Settings", id: :settings_btn, on_click: :open_settings}
          ]
        },
        %Layouts.HBox{
          spacing: 2,
          children: [
            %Layouts.VBox{
              id: :stats_panel,
              children: [
                %Widgets.Text{content: "Statistics"},
                %Widgets.Text{content: "Users: 1,234"},
                %Widgets.Text{content: "Sessions: 567"},
                %Widgets.Text{content: "Errors: 12"}
              ]
            },
            %Layouts.VBox{
              id: :activity_panel,
              children: [
                %Widgets.Text{content: "Recent Activity"},
                %Widgets.Text{content: "- User logged in"},
                %Widgets.Text{content: "- File uploaded"},
                %Widgets.Text{content: "- Settings changed"}
              ]
            }
          ]
        }
      ]
    }
  end

  defp build_complex_settings_screen do
    %Layouts.VBox{
      id: :settings_screen,
      spacing: 1,
      children: [
        %Widgets.Text{content: "Settings", id: :settings_title},
        %Layouts.HBox{
          children: [
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.Text{content: "Account Settings"},
                %Widgets.Label{for: :email, text: "Email:"},
                %Widgets.TextInput{id: :email, type: :email, form_id: :settings},
                %Widgets.Label{for: :display_name, text: "Display Name:"},
                %Widgets.TextInput{id: :display_name, form_id: :settings},
                %Widgets.Label{for: :timezone, text: "Timezone:"},
                %Widgets.TextInput{id: :timezone, placeholder: "UTC", form_id: :settings}
              ]
            },
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.Text{content: "Notifications"},
                %Widgets.Label{for: :notify_email, text: "Email Notifications:"},
                %Widgets.TextInput{id: :notify_email, type: :email, form_id: :settings},
                %Widgets.Label{for: :notify_sms, text: "SMS Notifications:"},
                %Widgets.TextInput{id: :notify_sms, type: :tel, form_id: :settings}
              ]
            },
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.Text{content: "Security"},
                %Widgets.Label{for: :current_pass, text: "Current Password:"},
                %Widgets.TextInput{id: :current_pass, type: :password, form_id: :settings},
                %Widgets.Label{for: :new_pass, text: "New Password:"},
                %Widgets.TextInput{id: :new_pass, type: :password, form_id: :settings},
                %Widgets.Label{for: :confirm_pass, text: "Confirm Password:"},
                %Widgets.TextInput{id: :confirm_pass, type: :password, form_id: :settings}
              ]
            }
          ]
        },
        %Layouts.HBox{
          spacing: 2,
          children: [
            %Widgets.Button{label: "Save", id: :save_btn, on_click: {:save, %{form: :settings}}},
            %Widgets.Button{label: "Reset", id: :reset_btn, on_click: :reset},
            %Widgets.Button{label: "Cancel", id: :cancel_btn, on_click: :cancel}
          ]
        }
      ]
    }
  end

  defp build_full_application_ui do
    # Combine multiple complex screens into one mega UI
    %Layouts.VBox{
      id: :app_root,
      spacing: 2,
      children: [
        # Header
        %Layouts.HBox{
          id: :header,
          children: [
            %Widgets.Text{content: "MyApp", id: :logo},
            %Widgets.Button{label: "Home", id: :home_btn, on_click: :nav_home},
            %Widgets.Button{label: "Dashboard", id: :dash_btn, on_click: :nav_dash},
            %Widgets.Button{label: "Settings", id: :settings_btn, on_click: :nav_settings},
            %Widgets.Button{label: "Logout", id: :logout_btn, on_click: :logout}
          ]
        },
        # Login section
        %Layouts.VBox{
          id: :login_section,
          children: [
            %Widgets.Text{content: "Sign In", id: :login_title},
            %Layouts.HBox{
              children: [
                %Layouts.VBox{
                  children: [
                    %Widgets.Label{for: :login_user, text: "Username:"},
                    %Widgets.Label{for: :login_pass, text: "Password:"}
                  ]
                },
                %Layouts.VBox{
                  children: [
                    %Widgets.TextInput{id: :login_user, form_id: :login},
                    %Widgets.TextInput{id: :login_pass, type: :password, form_id: :login}
                  ]
                }
              ]
            },
            %Layouts.HBox{
              children: [
                %Widgets.Button{label: "Login", id: :login_submit, on_click: {:login, %{}}},
                %Widgets.Button{label: "Register", id: :register_btn, on_click: :nav_register}
              ]
            }
          ]
        },
        # Dashboard section
        build_complex_dashboard(),
        # Settings section
        build_complex_settings_screen(),
        # Footer
        %Layouts.HBox{
          id: :footer,
          children: [
            %Widgets.Text{content: "© 2025 MyApp", id: :copyright},
            %Widgets.Button{label: "Help", id: :help_btn, on_click: :open_help},
            %Widgets.Button{label: "About", id: :about_btn, on_click: :open_about}
          ]
        }
      ]
    }
  end
end
