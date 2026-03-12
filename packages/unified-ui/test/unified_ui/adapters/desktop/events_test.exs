defmodule UnifiedUi.Adapters.Desktop.EventsTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Desktop.Events
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Desktop.Events
  alias UnifiedUi.Agent, as: UiAgent

  defmodule DispatchComponent do
    @behaviour UnifiedUi.ElmArchitecture

    @impl true
    def init(opts), do: %{observer: Keyword.get(opts, :observer)}

    @impl true
    def update(state, signal) do
      if is_pid(state.observer), do: send(state.observer, {:desktop_dispatch_signal, signal})
      state
    end

    @impl true
    def view(_state), do: %UnifiedIUR.Widgets.Text{id: :desktop_dispatch_probe, content: "ok"}
  end

  describe "event_types/0" do
    test "returns list of supported event types" do
      types = Events.event_types()

      assert :click in types
      assert :change in types
      assert :key_press in types
      assert :mouse in types
      assert :focus in types
      assert :blur in types
      assert :window in types
    end
  end

  describe "create_event/2" do
    test "creates a click event" do
      event = Events.create_event(:click, %{widget_id: :btn})

      assert event.type == :click
      assert event.data.widget_id == :btn
    end

    test "creates a change event" do
      event = Events.create_event(:change, %{widget_id: :input, value: "test"})

      assert event.type == :change
      assert event.data.widget_id == :input
      assert event.data.value == "test"
    end

    test "creates a key_press event" do
      event = Events.create_event(:key_press, %{key: :enter})

      assert event.type == :key_press
      assert event.data.key == :enter
    end

    test "creates a mouse event" do
      event = Events.create_event(:mouse, %{action: :click, x: 100, y: 200})

      assert event.type == :mouse
      assert event.data.action == :click
      assert event.data.x == 100
      assert event.data.y == 200
    end

    test "creates a window event" do
      event = Events.create_event(:window, %{action: :resize, width: 800, height: 600})

      assert event.type == :window
      assert event.data.action == :resize
      assert event.data.width == 800
      assert event.data.height == 600
    end
  end

  describe "to_signal/3" do
    test "converts click event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:click, %{widget_id: :btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :btn
      assert signal.data.platform == :desktop
      assert signal.source == "/unified_ui/desktop"
    end

    test "converts click event with action to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:click, %{widget_id: :submit, action: :submit_form})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :submit
      assert signal.data.action == :submit_form
    end

    test "converts change event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:change, %{widget_id: :email, value: "test@example.com"})

      assert signal.type == "unified.input.changed"
      assert signal.data.widget_id == :email
      assert signal.data.value == "test@example.com"
      assert signal.data.platform == :desktop
    end

    test "converts submit event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:submit, %{form_id: :login, data: %{email: "user@example.com"}})

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
      assert signal.data.platform == :desktop
    end

    test "converts key_press event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:key_press, %{key: :enter, modifiers: []})

      assert signal.type == "unified.key.pressed"
      assert signal.data.key == :enter
      assert signal.data.platform == :desktop
    end

    test "converts mouse event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:mouse, %{action: :click, x: 10, y: 20})

      assert signal.type == "unified.mouse.click"
      assert signal.data.action == :click
      assert signal.data.x == 10
      assert signal.data.y == 20
      assert signal.data.platform == :desktop
    end

    test "converts mouse event with button to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:mouse, %{action: :click, button: :right, x: 50, y: 100})

      assert signal.type == "unified.mouse.click"
      assert signal.data.button == :right
      assert signal.data.x == 50
      assert signal.data.y == 100
    end

    test "converts mouse double_click event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:mouse, %{action: :double_click, x: 100, y: 200})

      assert signal.type == "unified.mouse.double_click"
      assert signal.data.action == :double_click
    end

    test "converts mouse move event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:mouse, %{action: :move, x: 150, y: 250, buttons: []})

      assert signal.type == "unified.mouse.move"
      assert signal.data.action == :move
      assert signal.data.x == 150
      assert signal.data.y == 250
    end

    test "converts mouse scroll event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:mouse, %{action: :scroll, x: 200, y: 300, direction: :down})

      assert signal.type == "unified.mouse.scroll"
      assert signal.data.direction == :down
    end

    test "converts focus event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:focus, %{widget_id: :input})

      assert signal.type == "unified.element.focused"
      assert signal.data.widget_id == :input
    end

    test "converts blur event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:blur, %{widget_id: :input})

      assert signal.type == "unified.element.blurred"
      assert signal.data.widget_id == :input
    end

    test "converts window resize event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:window, %{action: :resize, width: 800, height: 600})

      assert signal.type == "unified.window.resize"
      assert signal.data.width == 800
      assert signal.data.height == 600
      assert signal.data.platform == :desktop
    end

    test "converts window move event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:window, %{action: :move, x: 100, y: 50})

      assert signal.type == "unified.window.move"
      assert signal.data.x == 100
      assert signal.data.y == 50
    end

    test "converts window close event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:window, %{action: :close})

      assert signal.type == "unified.window.close"
      assert signal.data.action == :close
    end

    test "converts window minimize event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:window, %{action: :minimize})

      assert signal.type == "unified.window.minimize"
    end

    test "converts window maximize event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:window, %{action: :maximize})

      assert signal.type == "unified.window.maximize"
    end

    test "converts window restore event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:window, %{action: :restore})

      assert signal.type == "unified.window.restore"
    end

    test "accepts custom source option" do
      assert {:ok, signal} =
               Events.to_signal(:click, %{widget_id: :btn}, source: "/custom/source")

      assert signal.source == "/custom/source"
    end
  end

  describe "dispatch/3" do
    test "creates and dispatches a click signal" do
      assert {:ok, signal} =
               Events.dispatch(:click, %{widget_id: :my_button, action: :clicked})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :my_button
    end

    test "creates and dispatches a change signal" do
      assert {:ok, signal} =
               Events.dispatch(:change, %{widget_id: :input, value: "new value"})

      assert signal.type == "unified.input.changed"
      assert signal.data.value == "new value"
    end

    test "creates and dispatches a window resize signal" do
      assert {:ok, signal} =
               Events.dispatch(:window, %{action: :resize, width: 1024, height: 768})

      assert signal.type == "unified.window.resize"
      assert signal.data.width == 1024
      assert signal.data.height == 768
    end

    test "dispatches signal to a running component when component_id is provided" do
      component_id = :"desktop_dispatch_#{System.unique_integer([:positive])}"

      assert {:ok, _pid} =
               UiAgent.start_component(DispatchComponent, component_id, observer: self())

      on_exit(fn -> UiAgent.stop_component(component_id) end)

      assert {:ok, signal} =
               Events.dispatch(
                 :click,
                 %{widget_id: :my_button, action: :clicked},
                 component_id: component_id
               )

      assert signal.type == "unified.button.clicked"

      assert_receive {:desktop_dispatch_signal, delivered_signal}
      assert delivered_signal.type == "unified.button.clicked"
      assert delivered_signal.data.widget_id == :my_button
    end

    test "returns not_found when component_id is unknown" do
      missing_component_id = :"desktop_missing_#{System.unique_integer([:positive])}"

      assert {:error, :not_found} =
               Events.dispatch(
                 :click,
                 %{widget_id: :my_button, action: :clicked},
                 component_id: missing_component_id
               )
    end

    test "returns invalid_component_id when component_id is not an atom" do
      assert {:error, :invalid_component_id} =
               Events.dispatch(
                 :click,
                 %{widget_id: :my_button, action: :clicked},
                 component_id: "not_an_atom"
               )
    end
  end

  describe "button_click/3" do
    test "creates button click signal" do
      assert {:ok, signal} = Events.button_click(:submit, :submit_form)

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :submit
      assert signal.data.action == :submit_form
    end

    test "creates button click signal with options" do
      assert {:ok, signal} = Events.button_click(:save, :save_data, source: "/app/save")

      assert signal.source == "/app/save"
    end
  end

  describe "input_change/3" do
    test "creates input change signal" do
      assert {:ok, signal} = Events.input_change(:email, "user@example.com")

      assert signal.type == "unified.input.changed"
      assert signal.data.widget_id == :email
      assert signal.data.value == "user@example.com"
    end

    test "creates input change signal with options" do
      assert {:ok, signal} = Events.input_change(:query, "search term", source: "/custom")

      assert signal.source == "/custom"
    end
  end

  describe "form_submit/3" do
    test "creates form submit signal" do
      assert {:ok, signal} =
               Events.form_submit(:login, %{email: "user@example.com", password: "secret"})

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
      assert signal.data.data.email == "user@example.com"
    end
  end

  describe "key_press/3" do
    test "creates key press signal for Enter" do
      assert {:ok, signal} = Events.key_press(:enter)

      assert signal.type == "unified.key.pressed"
      assert signal.data.key == :enter
      assert signal.data.modifiers == []
    end

    test "creates key press signal with modifiers" do
      assert {:ok, signal} = Events.key_press(:char, [?a])

      assert signal.data.key == :char
      assert signal.data.modifiers == [?a]
    end

    test "creates key press signal for Ctrl+S" do
      assert {:ok, signal} = Events.key_press(:s, [:ctrl])

      assert signal.data.key == :s
      assert signal.data.modifiers == [:ctrl]
    end

    test "creates key press signal for multiple modifiers" do
      assert {:ok, signal} = Events.key_press(:s, [:ctrl, :shift])

      assert signal.data.key == :s
      assert signal.data.modifiers == [:ctrl, :shift]
    end
  end

  describe "navigation_key/3" do
    test "maps directional navigation keys to normalized actions" do
      assert {:ok, signal} = Events.navigation_key(:main_tabs, :left)

      assert signal.type == "unified.key.pressed"
      assert signal.data.widget_id == :main_tabs
      assert signal.data.key == :left
      assert signal.data.action == :navigate_left
      assert signal.data.platform == :desktop
    end

    test "maps escape to dismiss action" do
      assert {:ok, signal} = Events.navigation_key(:main_menu, :escape)

      assert signal.data.widget_id == :main_menu
      assert signal.data.key == :escape
      assert signal.data.action == :dismiss
    end

    test "returns error for unsupported keys" do
      assert {:error, :unsupported_navigation_key} = Events.navigation_key(:main_tree, :f1)
    end
  end

  describe "mouse_click/5" do
    test "creates mouse click signal with default values" do
      assert {:ok, signal} = Events.mouse_click(:my_button)

      assert signal.type == "unified.mouse.click"
      assert signal.data.widget_id == :my_button
      assert signal.data.button == :left
      assert signal.data.x == 0
      assert signal.data.y == 0
    end

    test "creates mouse click signal with right button" do
      assert {:ok, signal} = Events.mouse_click(:context_menu, :right, 100, 200)

      assert signal.type == "unified.mouse.click"
      assert signal.data.button == :right
      assert signal.data.x == 100
      assert signal.data.y == 200
    end

    test "creates mouse click signal with coordinates" do
      assert {:ok, signal} = Events.mouse_click(:my_button, :left, 150, 250)

      assert signal.data.x == 150
      assert signal.data.y == 250
    end
  end

  describe "mouse_double_click/5" do
    test "creates mouse double click signal" do
      assert {:ok, signal} = Events.mouse_double_click(:my_item, :left, 100, 200)

      assert signal.type == "unified.mouse.double_click"
      assert signal.data.widget_id == :my_item
      assert signal.data.button == :left
      assert signal.data.x == 100
      assert signal.data.y == 200
    end
  end

  describe "mouse_move/4" do
    test "creates mouse move signal" do
      assert {:ok, signal} = Events.mouse_move(100, 200)

      assert signal.type == "unified.mouse.move"
      assert signal.data.x == 100
      assert signal.data.y == 200
      assert signal.data.buttons == []
    end

    test "creates mouse move signal with pressed buttons" do
      assert {:ok, signal} = Events.mouse_move(150, 250, [:left])

      assert signal.data.x == 150
      assert signal.data.y == 250
      assert signal.data.buttons == [:left]
    end

    test "creates mouse move signal with multiple buttons pressed" do
      assert {:ok, signal} = Events.mouse_move(200, 300, [:left, :right])

      assert signal.data.buttons == [:left, :right]
    end
  end

  describe "mouse_scroll/5" do
    test "creates mouse scroll signal" do
      assert {:ok, signal} = Events.mouse_scroll(100, 200, :down, 3)

      assert signal.type == "unified.mouse.scroll"
      assert signal.data.x == 100
      assert signal.data.y == 200
      assert signal.data.direction == :down
      assert signal.data.delta == 3
    end

    test "creates mouse scroll signal with default values" do
      assert {:ok, signal} = Events.mouse_scroll(50, 75)

      assert signal.data.direction == :down
      assert signal.data.delta == 1
    end

    test "creates mouse scroll up signal" do
      assert {:ok, signal} = Events.mouse_scroll(100, 200, :up, 2)

      assert signal.data.direction == :up
      assert signal.data.delta == 2
    end
  end

  describe "window_resize/3" do
    test "creates window resize signal" do
      assert {:ok, signal} = Events.window_resize(800, 600)

      assert signal.type == "unified.window.resize"
      assert signal.data.width == 800
      assert signal.data.height == 600
    end

    test "creates window resize signal for large window" do
      assert {:ok, signal} = Events.window_resize(1920, 1080)

      assert signal.data.width == 1920
      assert signal.data.height == 1080
    end
  end

  describe "window_move/3" do
    test "creates window move signal" do
      assert {:ok, signal} = Events.window_move(100, 50)

      assert signal.type == "unified.window.move"
      assert signal.data.x == 100
      assert signal.data.y == 50
    end

    test "creates window move signal for negative coordinates" do
      assert {:ok, signal} = Events.window_move(-10, -20)

      assert signal.data.x == -10
      assert signal.data.y == -20
    end
  end

  describe "window_close/1" do
    test "creates window close signal" do
      assert {:ok, signal} = Events.window_close()

      assert signal.type == "unified.window.close"
      assert signal.data.action == :close
    end
  end

  describe "window_minimize/1" do
    test "creates window minimize signal" do
      assert {:ok, signal} = Events.window_minimize()

      assert signal.type == "unified.window.minimize"
      assert signal.data.action == :minimize
    end
  end

  describe "window_maximize/1" do
    test "creates window maximize signal" do
      assert {:ok, signal} = Events.window_maximize()

      assert signal.type == "unified.window.maximize"
      assert signal.data.action == :maximize
    end
  end

  describe "window_restore/1" do
    test "creates window restore signal" do
      assert {:ok, signal} = Events.window_restore()

      assert signal.type == "unified.window.restore"
      assert signal.data.action == :restore
    end
  end

  describe "window_focus/1" do
    test "creates window focus signal" do
      assert {:ok, signal} = Events.window_focus()

      assert signal.type == "unified.window.focus"
      assert signal.data.action == :focus
    end
  end

  describe "window_blur/1" do
    test "creates window blur signal" do
      assert {:ok, signal} = Events.window_blur()

      assert signal.type == "unified.window.blur"
      assert signal.data.action == :blur
    end
  end

  describe "extract_handlers/1" do
    test "extracts button click handlers from render tree" do
      render_tree =
        {:button, nil,
         %{
           on_click: :submit,
           id: :submit_button,
           disabled: false
         }}

      handlers = Events.extract_handlers(render_tree)

      assert handlers.submit_button == %{on_click: :submit}
    end

    test "extracts text input change handlers from render tree" do
      render_tree =
        {:text_input, nil,
         %{
           id: :email,
           value: nil,
           placeholder: "user@example.com",
           type: nil,
           on_change: :update_email,
           on_submit: nil,
           disabled: nil,
           form_id: nil
         }}

      handlers = Events.extract_handlers(render_tree)

      assert handlers.email == %{on_change: :update_email}
    end

    test "extracts text input submit handlers from render tree" do
      render_tree =
        {:text_input, nil,
         %{
           id: :password,
           type: :password,
           on_submit: :submit_login
         }}

      handlers = Events.extract_handlers(render_tree)

      assert handlers.password == %{on_submit: :submit_login}
    end

    test "extracts handlers from container with multiple widgets" do
      render_tree = %{
        type: :vbox,
        children: [
          {:button, nil, %{on_click: :ok, id: :ok_button, disabled: false}},
          {:button, nil, %{on_click: :cancel, id: :cancel_button, disabled: false}}
        ]
      }

      handlers = Events.extract_handlers(render_tree)

      assert handlers.ok_button == %{on_click: :ok}
      assert handlers.cancel_button == %{on_click: :cancel}
    end

    test "handles nested containers" do
      render_tree = %{
        type: :vbox,
        direction: :vertical,
        children: [
          %{
            type: :hbox,
            direction: :horizontal,
            children: [
              {:button, nil, %{on_click: :nested, id: :nested_btn, disabled: false}}
            ]
          }
        ]
      }

      handlers = Events.extract_handlers(render_tree)

      assert handlers.nested_btn == %{on_click: :nested}
    end

    test "returns empty map for render tree with no handlers" do
      render_tree = %{
        type: :vbox,
        children: [
          {:text, nil, %{content: "Plain text"}}
        ]
      }

      handlers = Events.extract_handlers(render_tree)

      assert handlers == %{}
    end

    test "skips button without ID" do
      render_tree =
        {:button, nil,
         %{
           on_click: :submit,
           disabled: false
           # No id
         }}

      handlers = Events.extract_handlers(render_tree)

      refute Map.has_key?(handlers, :on_click)
    end

    test "skips button without on_click" do
      render_tree =
        {:button, nil,
         %{
           id: :button,
           disabled: false
           # No on_click
         }}

      handlers = Events.extract_handlers(render_tree)

      # Button without on_click is not added to handlers
      refute Map.has_key?(handlers, :button)
    end
  end

  describe "integration scenarios" do
    test "complete form with submit button" do
      # Simulate a form with email input and submit button
      render_tree = %{
        type: :vbox,
        children: [
          {:text_input, nil,
           %{
             id: :email_input,
             type: :email,
             placeholder: "user@example.com",
             on_change: :validate_email,
             on_submit: nil
           }},
          {:button, nil,
           %{
             on_click: :submit_form,
             id: :submit_button,
             disabled: false
           }}
        ]
      }

      handlers = Events.extract_handlers(render_tree)

      # Extract handlers
      assert handlers.email_input.on_change == :validate_email
      assert handlers.submit_button.on_click == :submit_form

      # Simulate user interaction
      assert {:ok, change_signal} = Events.input_change(:email_input, "user@test.com")
      assert change_signal.data.value == "user@test.com"

      assert {:ok, click_signal} = Events.button_click(:submit_button, :submit_form)
      assert click_signal.data.action == :submit_form
    end

    test "keyboard navigation with Tab" do
      assert {:ok, signal} = Events.key_press(:tab, [])

      assert signal.type == "unified.key.pressed"
      assert signal.data.key == :tab
    end

    test "Ctrl+S to save" do
      assert {:ok, signal} = Events.key_press(:s, [:ctrl])

      assert signal.data.key == :s
      assert signal.data.modifiers == [:ctrl]
    end

    test "window resize event sequence" do
      # User resizes window from 800x600 to 1024x768
      assert {:ok, signal1} = Events.window_resize(800, 600)
      assert {:ok, signal2} = Events.window_resize(900, 700)
      assert {:ok, signal3} = Events.window_resize(1024, 768)

      assert signal1.data.width == 800
      assert signal2.data.width == 900
      assert signal3.data.width == 1024
    end

    test "mouse drag operation" do
      # Simulate a drag operation: click, move, release
      assert {:ok, click} = Events.mouse_click(:draggable, :left, 100, 200)
      assert {:ok, move1} = Events.mouse_move(110, 210, [:left])
      assert {:ok, move2} = Events.mouse_move(120, 220, [:left])
      assert {:ok, move3} = Events.mouse_move(150, 250, [:left])

      assert click.data.action == :click
      assert move1.data.action == :move
      assert move2.data.x == 120
      assert move3.data.x == 150
    end

    test "complete window lifecycle" do
      # Window opened, moved, resized, maximized, restored, minimized, restored, closed
      assert {:ok, _move} = Events.window_move(100, 100)
      assert {:ok, _resize} = Events.window_resize(800, 600)
      assert {:ok, _maximize} = Events.window_maximize()
      assert {:ok, _restore} = Events.window_restore()
      assert {:ok, _minimize} = Events.window_minimize()
      assert {:ok, _restore2} = Events.window_restore()
      assert {:ok, _close} = Events.window_close()
    end
  end

  # ============================================================================
  # Security Tests
  # ============================================================================

  describe "security" do
    test "rejects invalid mouse actions (signal injection prevention)" do
      # Attempt to inject malicious action
      assert {:error, :invalid_action} =
               Events.to_signal(:mouse, %{action: :malicious_action, x: 100, y: 200})

      assert {:error, :invalid_action} =
               Events.to_signal(:mouse, %{action: :"../../etc/passwd", x: 100, y: 200})

      assert {:error, :invalid_action} =
               Events.to_signal(:mouse, %{action: :"<script>", x: 100, y: 200})
    end

    test "rejects invalid window actions (signal injection prevention)" do
      # Attempt to inject malicious action
      assert {:error, :invalid_action} =
               Events.to_signal(:window, %{action: :format_c})

      assert {:error, :invalid_action} =
               Events.to_signal(:window, %{action: :delete_all_files})

      assert {:error, :invalid_action} =
               Events.to_signal(:window, %{action: :"<script>alert('xss')</script>"})
    end

    test "accepts valid mouse actions" do
      valid_actions = [:click, :double_click, :right_click, :scroll, :move]

      Enum.each(valid_actions, fn action ->
        data = %{action: action, x: 100, y: 200}
        assert {:ok, _signal} = Events.to_signal(:mouse, data)
      end)
    end

    test "accepts valid window actions" do
      valid_actions = [:move, :resize, :close, :minimize, :maximize, :restore, :focus, :blur]

      Enum.each(valid_actions, fn action ->
        data = %{action: action}
        assert {:ok, _signal} = Events.to_signal(:window, data)
      end)
    end

    test "rejects payloads that are too large" do
      # Create a payload that exceeds size limits
      # The limit is 10KB, so create a map with many keys to exceed it
      large_data = Map.new(1..500, fn i -> {:"key#{i}", String.duplicate("x", 50)} end)

      assert {:error, :payload_too_large} =
               Events.to_signal(:click, Map.put(large_data, :widget_id, :btn))
    end

    test "redacts sensitive fields in form submissions" do
      form_data = %{
        username: "user",
        password: "secret123",
        email: "user@example.com",
        api_key: "abc123xyz"
      }

      assert {:ok, signal} = Events.form_submit(:login, form_data)

      # Password and API key should be redacted
      assert signal.data.data.password == "[REDACTED]"
      assert signal.data.data.api_key == "[REDACTED]"

      # Regular fields should be preserved
      assert signal.data.data.username == "user"
      assert signal.data.data.email == "user@example.com"
    end
  end
end
