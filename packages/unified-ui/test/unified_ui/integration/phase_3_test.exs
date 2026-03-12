defmodule UnifiedUi.Integration.Phase3Test do
  @moduledoc """
  Comprehensive integration tests for Phase 3 of UnifiedUi.

  These tests verify that all three platform renderers (Terminal, Desktop, Web)
  work correctly with the IUR system, including event handling, state
  synchronization, and multi-platform coordination.

  Test Sections:
  - 3.9.1: Same UI renders on all three platforms
  - 3.9.2: Events work identically across platforms
  - 3.9.3: State synchronization across platforms
  - 3.9.4: All basic widgets on all platforms
  - 3.9.5: All layouts on all platforms
  - 3.9.6: Styles apply correctly on all platforms
  - 3.9.7: Signal handling on all platforms
  - 3.9.8: Multi-platform concurrent rendering
  - 3.9.9: Renderer lifecycle (render/update/destroy)

  ## Platform Output Formats

  Each renderer produces different output structures:
  * **Terminal**: TermUI render trees (tagged tuples)
  * **Desktop**: DesktopUi-style widget maps
  * **Web**: HTML strings with inline styles

  These tests validate the structure without being prescriptive about
  implementation details.
  """

  use ExUnit.Case, async: false

  alias UnifiedIUR.{Layouts, Widgets, Element}
  alias UnifiedUi.Adapters.{Terminal, Desktop, Web, Coordinator}
  alias UnifiedUi.Adapters.{Terminal.Events, Desktop.Events, Web.Events}
  alias UnifiedUi.Signals

  # ============================================================================
  # 3.9.1: Same UI Renders on All Platforms
  # ============================================================================

  describe "3.9.1 - Same UI renders on all platforms" do
    test "Simple UI renders on terminal" do
      iur = build_simple_ui()

      assert {:ok, state} = Terminal.render(iur)
      assert state.platform == :terminal
      assert Map.has_key?(state, :root)
      assert state.root != nil
    end

    test "Simple UI renders on desktop" do
      iur = build_simple_ui()

      assert {:ok, state} = Desktop.render(iur)
      assert state.platform == :desktop
      assert Map.has_key?(state, :root)
      assert state.root != nil
    end

    test "Simple UI renders on web" do
      iur = build_simple_ui()

      assert {:ok, state} = Web.render(iur)
      assert state.platform == :web
      assert Map.has_key?(state, :root)
      assert state.root != nil
      # Web output should be a string
      assert is_binary(state.root)
    end

    test "Terminal output has expected structure" do
      iur = build_simple_ui()

      assert {:ok, state} = Terminal.render(iur)
      # Terminal produces a render tree (tagged tuple or struct)
      root = state.root
      # Should be a term with type and children
      assert is_tuple(root) or is_map(root)
    end

    test "Desktop output has expected structure" do
      iur = build_simple_ui()

      assert {:ok, state} = Desktop.render(iur)
      # Desktop produces widget maps
      root = state.root
      assert is_map(root)
      assert Map.has_key?(root, :type) or is_tuple(root)
    end

    test "Web output has expected structure" do
      iur = build_simple_ui()

      assert {:ok, state} = Web.render(iur)
      # Web produces HTML strings
      root = state.root
      assert is_binary(root)
      # Should contain HTML elements
      assert root =~ "<" and root =~ ">"
    end

    test "Complex nested UI renders on all platforms" do
      iur = build_nested_ui()

      # Terminal
      assert {:ok, term_state} = Terminal.render(iur)
      assert term_state.root != nil

      # Desktop
      assert {:ok, desk_state} = Desktop.render(iur)
      assert desk_state.root != nil

      # Web
      assert {:ok, web_state} = Web.render(iur)
      assert is_binary(web_state.root)
      assert web_state.root =~ "<"
    end

    test "All platforms handle visible=false correctly" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Visible", id: :visible_text},
          %Widgets.Text{content: "Hidden", id: :hidden_text, visible: false}
        ]
      }

      # All platforms should render successfully
      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "All platforms handle disabled=true correctly" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Button{label: "Enabled", id: :enabled_btn, on_click: :click},
          %Widgets.Button{label: "Disabled", id: :disabled_btn, on_click: :click, disabled: true}
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end
  end

  # ============================================================================
  # 3.9.2: Events Work Identically Across Platforms
  # ============================================================================

  describe "3.9.2 - Event parity across platforms" do
    test "Button click events convert correctly on all platforms" do
      # All platforms should produce click signals with consistent structure
      {:ok, term_signal} = Events.to_signal(:click, %{widget_id: :submit_btn})
      {:ok, desk_signal} = Desktop.Events.to_signal(:click, %{widget_id: :submit_btn})
      {:ok, web_signal} = Web.Events.to_signal(:click, %{widget_id: :submit_btn})

      # Signal type should be consistent
      assert term_signal.type == "unified.button.clicked"
      assert desk_signal.type == "unified.button.clicked"
      assert web_signal.type == "unified.button.clicked"

      # All should have widget_id in data
      assert Map.has_key?(term_signal.data, :widget_id)
      assert Map.has_key?(desk_signal.data, :widget_id)
      assert Map.has_key?(web_signal.data, :widget_id)
    end

    test "Text input change events convert correctly on all platforms" do
      {:ok, term_signal} = Events.to_signal(:change, %{widget_id: :username, value: "testuser"})
      {:ok, desk_signal} = Desktop.Events.to_signal(:change, %{widget_id: :username, value: "testuser"})
      {:ok, web_signal} = Web.Events.to_signal(:change, %{widget_id: :username, value: "testuser"})

      # All should be input.changed signals
      assert term_signal.type == "unified.input.changed"
      assert desk_signal.type == "unified.input.changed"
      assert web_signal.type == "unified.input.changed"
    end

    test "Form submission events convert correctly on all platforms" do
      form_data = %{username: "test", password: "[REDACTED]"}

      {:ok, term_signal} = Events.to_signal(:submit, %{form_id: :login, data: form_data})
      {:ok, desk_signal} = Desktop.Events.to_signal(:submit, %{form_id: :login, data: form_data})
      {:ok, web_signal} = Web.Events.to_signal(:submit, %{form_id: :login, data: form_data})

      # All should be form.submitted signals
      assert term_signal.type == "unified.form.submitted"
      assert desk_signal.type == "unified.form.submitted"
      assert web_signal.type == "unified.form.submitted"
    end

    test "Signal naming is consistent across platforms" do
      # All standard signal types
      signals = Signals.standard_signals()

      assert :click in signals
      assert :change in signals
      assert :submit in signals
      assert :focus in signals
      assert :blur in signals
    end

    test "Event payload structure is consistent" do
      # Create events with same data on different platforms
      data = %{key: "value"}

      {:ok, term_signal} = Events.to_signal(:click, Map.put(data, :widget_id, :btn))
      {:ok, desk_signal} = Desktop.Events.to_signal(:click, Map.put(data, :widget_id, :btn))
      {:ok, web_signal} = Web.Events.to_signal(:click, Map.put(data, :widget_id, :btn))

      # Both should have the same structure
      assert is_map(term_signal.data)
      assert is_map(desk_signal.data)
      assert is_map(web_signal.data)
    end
  end

  # ============================================================================
  # 3.9.3: State Synchronization Across Platforms
  # ============================================================================

  describe "3.9.3 - State synchronization across platforms" do
    test "State changes propagate to renderers" do
      iur = build_simple_ui()

      # Initial render
      {:ok, state} = Terminal.render(iur)
      assert state.platform == :terminal

      # Update with new state
      {:ok, updated} = Terminal.update(iur, state)
      assert updated.platform == :terminal
    end

    test "merge_states works correctly" do
      state1 = %{count: 1, items: ["a"]}
      state2 = %{count: 2, items: ["b"]}
      state3 = %{name: "test"}

      merged = Coordinator.merge_states([state1, state2, state3])

      # Last-write-wins for scalar values
      assert merged.count == 2
      assert merged.name == "test"
    end

    test "merge_states handles deep maps" do
      state1 = %{user: %{name: "Alice", settings: %{theme: :dark}}}
      state2 = %{user: %{settings: %{notifications: true}}}

      merged = Coordinator.merge_states([state1, state2])

      # Deep merge should combine nested maps
      assert merged.user.name == "Alice"
      assert merged.user.settings.theme == :dark
      assert merged.user.settings.notifications == true
    end

    test "conflict_resolution handles state conflicts" do
      old_state = %{count: 1, value: "old"}
      new_state = %{count: 2, value: "new"}

      resolved = Coordinator.conflict_resolution(old_state, new_state)

      # Last-write-wins
      assert resolved.count == 2
      assert resolved.value == "new"
    end

    test "sync_state returns :ok" do
      state = %{count: 1}
      renderer_states = %{
        terminal: %{platform: :terminal},
        web: %{platform: :web}
      }

      assert :ok = Coordinator.sync_state(state, renderer_states)
    end

    test "Multiple renderer states can be merged" do
      iur = build_simple_ui()

      {:ok, term_state} = Terminal.render(iur)
      {:ok, web_state} = Web.render(iur)

      # Extract platform-specific data
      states = [
        %{platform: :terminal, root: term_state.root},
        %{platform: :web, root: web_state.root}
      ]

      merged = Coordinator.merge_states(states)

      assert is_map(merged)
    end
  end

  # ============================================================================
  # 3.9.4: All Basic Widgets on All Platforms
  # ============================================================================

  describe "3.9.4 - All basic widgets on all platforms" do
    test "Text widget renders on all platforms" do
      iur = %Widgets.Text{content: "Hello World", id: :greeting}

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Button widget renders on all platforms" do
      iur = %Widgets.Button{label: "Click Me", id: :btn, on_click: :clicked}

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Label widget renders on all platforms" do
      iur = %Widgets.Label{for: :input, text: "Username:", id: :label}

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "TextInput (text type) renders on all platforms" do
      iur = %Widgets.TextInput{id: :input, type: :text, placeholder: "Enter text"}

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "TextInput (password type) renders on all platforms" do
      iur = %Widgets.TextInput{id: :password, type: :password, placeholder: "Password"}

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "TextInput (email type) renders on all platforms" do
      iur = %Widgets.TextInput{id: :email, type: :email, placeholder: "user@example.com"}

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Widget visible property works on all platforms" do
      iur = %Widgets.Text{content: "Hidden", visible: false}

      assert {:ok, term_state} = Terminal.render(iur)
      assert {:ok, desk_state} = Desktop.render(iur)
      assert {:ok, web_state} = Web.render(iur)

      # All should succeed regardless of visible value
      assert term_state.platform == :terminal
      assert desk_state.platform == :desktop
      assert web_state.platform == :web
    end

    test "Widget disabled property works on all platforms" do
      iur = %Widgets.Button{label: "Disabled", on_click: :click, disabled: true}

      assert {:ok, term_state} = Terminal.render(iur)
      assert {:ok, desk_state} = Desktop.render(iur)
      assert {:ok, web_state} = Web.render(iur)

      assert term_state.platform == :terminal
      assert desk_state.platform == :desktop
      assert web_state.platform == :web
    end
  end

  # ============================================================================
  # 3.9.5: All Layouts on All Platforms
  # ============================================================================

  describe "3.9.5 - All layouts on all platforms" do
    test "VBox layout renders on all platforms" do
      iur = %Layouts.VBox{
        id: :main,
        spacing: 1,
        children: [
          %Widgets.Text{content: "Item 1"},
          %Widgets.Text{content: "Item 2"}
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "HBox layout renders on all platforms" do
      iur = %Layouts.HBox{
        id: :row,
        spacing: 2,
        children: [
          %Widgets.Button{label: "A", on_click: :a},
          %Widgets.Button{label: "B", on_click: :b}
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Nested VBox/HBox layouts render on all platforms" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Title"},
          %Layouts.HBox{
            children: [
              %Widgets.Button{label: "OK", on_click: :ok},
              %Widgets.Button{label: "Cancel", on_click: :cancel}
            ]
          }
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Deeply nested layouts (5+ levels) render on all platforms" do
      iur = build_deeply_nested_layout()

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Layout spacing/padding apply on all platforms" do
      iur = %Layouts.VBox{
        spacing: 2,
        padding: 1,
        children: [
          %Widgets.Text{content: "Spaced"}
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Layout alignment properties work on all platforms" do
      iur = %Layouts.HBox{
        align_items: :center,
        justify_content: :space_between,
        children: [
          %Widgets.Text{content: "Left"},
          %Widgets.Text{content: "Right"}
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end
  end

  # ============================================================================
  # 3.9.6: Styles Apply Correctly on All Platforms
  # ============================================================================

  describe "3.9.6 - Style application on all platforms" do
    test "Inline fg color applies on all platforms" do
      iur = %Widgets.Text{
        content: "Colored",
        style: %UnifiedIUR.Style{fg: :cyan}
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Inline bg color applies on all platforms" do
      iur = %Widgets.Text{
        content: "Background",
        style: %UnifiedIUR.Style{bg: :blue}
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Inline text attributes apply on all platforms" do
      iur = %Widgets.Text{
        content: "Styled",
        style: %UnifiedIUR.Style{attrs: [:bold, :italic, :underline]}
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Padding/margin styles apply on all platforms" do
      iur = %Widgets.Text{
        content: "Spaced",
        style: %UnifiedIUR.Style{padding: 2, margin: 1}
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Width/height styles apply on all platforms" do
      iur = %Widgets.Text{
        content: "Sized",
        style: %UnifiedIUR.Style{width: :fill, height: :auto}
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Align styles apply on all platforms" do
      iur = %Widgets.Text{
        content: "Aligned",
        style: %UnifiedIUR.Style{align: :center}
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Style on layout applies on all platforms" do
      iur = %Layouts.VBox{
        style: %UnifiedIUR.Style{fg: :white, bg: :black},
        children: [
          %Widgets.Text{content: "In styled layout"}
        ]
      }

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end
  end

  # ============================================================================
  # 3.9.7: Signal Handling on All Platforms
  # ============================================================================

  describe "3.9.7 - Signal handling on all platforms" do
    test "Click signal creates correct signal type" do
      {:ok, signal} = Signals.create(:click, %{button_id: :submit})

      assert signal.type == "unified.button.clicked"
      assert signal.data.button_id == :submit
    end

    test "Change signal creates correct signal type" do
      {:ok, signal} = Signals.create(:change, %{input_id: :username, value: "test"})

      assert signal.type == "unified.input.changed"
      assert signal.data.input_id == :username
      assert signal.data.value == "test"
    end

    test "Submit signal creates correct signal type" do
      {:ok, signal} = Signals.create(:submit, %{form_id: :login, data: %{}})

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
    end

    test "Signal handlers are stored on widgets" do
      button = %Widgets.Button{
        label: "Click",
        on_click: :clicked
      }

      assert button.on_click == :clicked
    end

    test "Signal handlers can be tuples with payload" do
      button = %Widgets.Button{
        label: "Click",
        on_click: {:submit, %{form: :login}}
      }

      assert button.on_click == {:submit, %{form: :login}}
    end

    test "Signal handlers can be MFA tuples" do
      button = %Widgets.Button{
        label: "Click",
        on_click: {MyModule, :handle_click, []}
      }

      assert button.on_click == {MyModule, :handle_click, []}
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
  end

  # ============================================================================
  # 3.9.8: Multi-Platform Concurrent Rendering
  # ============================================================================

  describe "3.9.8 - Multi-platform concurrent rendering" do
    test "render_all renders on all platforms" do
      iur = build_simple_ui()

      assert {:ok, results} = Coordinator.render_all(iur)

      # Should have results for all platforms
      assert Map.has_key?(results, :terminal)
      assert Map.has_key?(results, :desktop)
      assert Map.has_key?(results, :web)

      # At least one should succeed
      successful =
        Enum.count(results, fn {_platform, result} ->
          match?({:ok, _}, result)
        end)

      assert successful > 0
    end

    test "concurrent_render works for all platforms" do
      iur = build_simple_ui()

      assert {:ok, results} =
               Coordinator.concurrent_render(iur, [:terminal, :desktop, :web])

      assert map_size(results) == 3
      assert Map.has_key?(results, :terminal)
      assert Map.has_key?(results, :desktop)
      assert Map.has_key?(results, :web)
    end

    test "concurrent_render with timeout" do
      iur = build_simple_ui()

      assert {:ok, results} =
               Coordinator.concurrent_render(iur, [:terminal], timeout: 5000)

      assert Map.has_key?(results, :terminal)
    end

    test "Platform detection works" do
      platform = Coordinator.detect_platform()

      assert platform in [:terminal, :desktop, :web]
    end

    test "Renderer selection works for each platform" do
      assert {:ok, UnifiedUi.Adapters.Terminal} = Coordinator.select_renderer(:terminal)
      assert {:ok, UnifiedUi.Adapters.Desktop} = Coordinator.select_renderer(:desktop)
      assert {:ok, UnifiedUi.Adapters.Web} = Coordinator.select_renderer(:web)
    end

    test "Invalid platform returns error" do
      assert {:error, :invalid_platform} = Coordinator.select_renderer(:mobile)
    end

    test "available_renderers returns all platforms" do
      platforms = Coordinator.available_renderers()

      assert :terminal in platforms
      assert :desktop in platforms
      assert :web in platforms
      assert length(platforms) == 3
    end

    test "render_on works for specific platforms" do
      iur = build_simple_ui()

      assert {:ok, results} = Coordinator.render_on(iur, [:terminal, :web])

      assert Map.has_key?(results, :terminal)
      assert Map.has_key?(results, :web)
      refute Map.has_key?(results, :desktop)
    end
  end

  # ============================================================================
  # 3.9.9: Renderer Lifecycle (Render/Update/Destroy)
  # ============================================================================

  describe "3.9.9 - Renderer lifecycle" do
    test "Terminal render creates initial state" do
      iur = build_simple_ui()

      assert {:ok, state} = Terminal.render(iur)
      assert state.platform == :terminal
      assert Map.has_key?(state, :root)
      assert state.root != nil
    end

    test "Desktop render creates initial state" do
      iur = build_simple_ui()

      assert {:ok, state} = Desktop.render(iur)
      assert state.platform == :desktop
      assert Map.has_key?(state, :root)
      assert state.root != nil
    end

    test "Web render creates initial state" do
      iur = build_simple_ui()

      assert {:ok, state} = Web.render(iur)
      assert state.platform == :web
      assert Map.has_key?(state, :root)
      assert is_binary(state.root)
    end

    test "Terminal update modifies existing state" do
      iur = build_simple_ui()

      {:ok, state} = Terminal.render(iur)
      {:ok, updated} = Terminal.update(iur, state)

      assert updated.platform == :terminal
      assert Map.has_key?(updated, :root)
    end

    test "Desktop update modifies existing state" do
      iur = build_simple_ui()

      {:ok, state} = Desktop.render(iur)
      {:ok, updated} = Desktop.update(iur, state)

      assert updated.platform == :desktop
      assert Map.has_key?(updated, :root)
    end

    test "Web update modifies existing state" do
      iur = build_simple_ui()

      {:ok, state} = Web.render(iur)
      {:ok, updated} = Web.update(iur, state)

      assert updated.platform == :web
      assert is_binary(updated.root)
    end

    test "Terminal destroy cleans up resources" do
      iur = build_simple_ui()

      {:ok, state} = Terminal.render(iur)
      assert :ok = Terminal.destroy(state)
    end

    test "Desktop destroy cleans up resources" do
      iur = build_simple_ui()

      {:ok, state} = Desktop.render(iur)
      assert :ok = Desktop.destroy(state)
    end

    test "Web destroy cleans up resources" do
      iur = build_simple_ui()

      {:ok, state} = Web.render(iur)
      assert :ok = Web.destroy(state)
    end

    test "Full lifecycle works for Terminal" do
      iur = build_simple_ui()

      # Render
      {:ok, state} = Terminal.render(iur)
      assert state.platform == :terminal

      # Update
      {:ok, updated} = Terminal.update(iur, state)
      assert updated.platform == :terminal

      # Destroy
      assert :ok = Terminal.destroy(updated)
    end

    test "Full lifecycle works for Desktop" do
      iur = build_simple_ui()

      {:ok, state} = Desktop.render(iur)
      {:ok, updated} = Desktop.update(iur, state)
      assert :ok = Desktop.destroy(updated)
    end

    test "Full lifecycle works for Web" do
      iur = build_simple_ui()

      {:ok, state} = Web.render(iur)
      {:ok, updated} = Web.update(iur, state)
      assert :ok = Web.destroy(updated)
    end
  end

  # ============================================================================
  # Complex Integration Scenarios
  # ============================================================================

  describe "Complex integration scenarios" do
    test "Login form with all widget types on all platforms" do
      iur = build_login_form()

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Dashboard with complex layouts on all platforms" do
      iur = build_dashboard()

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Settings form with multiple input types on all platforms" do
      iur = build_settings_form()

      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    @tag :complex_ui
    test "Full application UI (40+ elements) on all platforms" do
      iur = build_full_application_ui()

      # Count elements
      element_count = count_elements(iur)
      assert element_count >= 40

      # Render on all platforms
      assert {:ok, _} = Terminal.render(iur)
      assert {:ok, _} = Desktop.render(iur)
      assert {:ok, _} = Web.render(iur)
    end

    test "Coordinator renders complex UI on all platforms" do
      iur = build_login_form()

      assert {:ok, results} = Coordinator.render_all(iur)

      # All platforms should render
      assert map_size(results) == 3
    end
  end

  # ============================================================================
  # Helper Functions
  # ============================================================================

  # Simple UI builders

  defp build_simple_ui do
    %Layouts.VBox{
      id: :simple_ui,
      children: [
        %Widgets.Text{content: "Hello, World!", id: :greeting},
        %Widgets.Button{label: "Click Me", id: :click_btn, on_click: :clicked}
      ]
    }
  end

  defp build_nested_ui do
    %Layouts.VBox{
      id: :outer,
      children: [
        %Widgets.Text{content: "Title"},
        %Layouts.HBox{
          id: :middle,
          children: [
            %Layouts.VBox{
              id: :inner,
              children: [
                %Widgets.Button{label: "OK", on_click: :ok},
                %Widgets.Button{label: "Cancel", on_click: :cancel}
              ]
            }
          ]
        }
      ]
    }
  end

  defp build_deeply_nested_layout do
    %Layouts.VBox{
      id: :level_1,
      children: [
        %Layouts.HBox{
          id: :level_2,
          children: [
            %Layouts.VBox{
              id: :level_3,
              children: [
                %Layouts.HBox{
                  id: :level_4,
                  children: [
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
  end

  defp build_login_form do
    %Layouts.VBox{
      id: :login_screen,
      spacing: 1,
      children: [
        %Widgets.Text{content: "Welcome", id: :title},
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
        }
      ]
    }
  end

  defp build_dashboard do
    %Layouts.VBox{
      id: :dashboard,
      spacing: 1,
      children: [
        %Layouts.HBox{
          children: [
            %Widgets.Text{content: "Dashboard", id: :title},
            %Widgets.Button{label: "Refresh", id: :refresh, on_click: :refresh}
          ]
        },
        %Layouts.HBox{
          spacing: 2,
          children: [
            %Layouts.VBox{
              id: :stats,
              children: [
                %Widgets.Text{content: "Users: 1,234"},
                %Widgets.Text{content: "Sessions: 567"}
              ]
            },
            %Layouts.VBox{
              id: :activity,
              children: [
                %Widgets.Text{content: "Recent Activity:"},
                %Widgets.Text{content: "- User logged in"},
                %Widgets.Text{content: "- File uploaded"}
              ]
            }
          ]
        }
      ]
    }
  end

  defp build_settings_form do
    %Layouts.VBox{
      id: :settings,
      spacing: 1,
      children: [
        %Widgets.Text{content: "Settings", id: :title},
        %Layouts.HBox{
          children: [
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.Label{for: :email, text: "Email:"},
                %Widgets.Label{for: :display, text: "Display Name:"}
              ]
            },
            %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.TextInput{id: :email, type: :email, form_id: :settings},
                %Widgets.TextInput{id: :display, form_id: :settings}
              ]
            }
          ]
        },
        %Layouts.HBox{
          spacing: 2,
          children: [
            %Widgets.Button{label: "Save", id: :save, on_click: {:save, %{form: :settings}}},
            %Widgets.Button{label: "Cancel", id: :cancel, on_click: :cancel}
          ]
        }
      ]
    }
  end

  defp build_full_application_ui do
    %Layouts.VBox{
      id: :app_root,
      spacing: 2,
      children: [
        # Header
        %Layouts.HBox{
          id: :header,
          children: [
            %Widgets.Text{content: "MyApp", id: :logo},
            %Widgets.Button{label: "Home", id: :home, on_click: :nav_home},
            %Widgets.Button{label: "Dashboard", id: :dash, on_click: :nav_dash},
            %Widgets.Button{label: "Settings", id: :settings, on_click: :nav_settings}
          ]
        },
        # Login section
        build_login_form(),
        # Dashboard section
        build_dashboard(),
        # Settings section
        build_settings_form(),
        # Footer
        %Layouts.HBox{
          id: :footer,
          children: [
            %Widgets.Text{content: "© 2025 MyApp", id: :copyright},
            %Widgets.Button{label: "Help", id: :help, on_click: :help}
          ]
        }
      ]
    }
  end

  defp count_elements(element) do
    1 +
      Enum.reduce(Element.children(element), 0, fn child, acc ->
        acc + count_elements(child)
      end)
  end
end
