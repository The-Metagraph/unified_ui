defmodule UnifiedUi.Adapters.Web.EventsTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Web.Events
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Web.Events
  alias UnifiedUi.Agent, as: UiAgent

  defmodule DispatchComponent do
    @behaviour UnifiedUi.ElmArchitecture

    @impl true
    def init(opts), do: %{observer: Keyword.get(opts, :observer)}

    @impl true
    def update(state, signal) do
      if is_pid(state.observer), do: send(state.observer, {:web_dispatch_signal, signal})
      state
    end

    @impl true
    def view(_state), do: %UnifiedIUR.Widgets.Text{id: :web_dispatch_probe, content: "ok"}
  end

  describe "event_types/0" do
    test "returns list of supported event types" do
      types = Events.event_types()

      assert :click in types
      assert :change in types
      assert :key_press in types
      assert :key_release in types
      assert :focus in types
      assert :blur in types
      assert :hook in types
    end
  end

  describe "WebSocket constants" do
    test "returns base reconnection delay" do
      assert Events.base_reconnect_delay() == 1000
    end

    test "returns max reconnection delay" do
      assert Events.max_reconnect_delay() == 32_000
    end

    test "returns max reconnection attempts" do
      assert Events.max_reconnect_attempts() == 10
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

    test "creates a hook event" do
      event = Events.create_event(:hook, %{hook_name: :scroll_handler, data: %{scroll_top: 100}})

      assert event.type == :hook
      assert event.data.hook_name == :scroll_handler
      assert event.data.data.scroll_top == 100
    end
  end

  describe "to_signal/3" do
    test "converts click event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:click, %{widget_id: :btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :btn
      assert signal.data.platform == :web
      assert signal.source == "/unified_ui/web"
    end

    test "converts click event with action to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:click, %{widget_id: :submit, action: :submit_form})

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
      assert signal.data.platform == :web
    end

    test "converts submit event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:submit, %{form_id: :login, data: %{email: "user@example.com"}})

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
      assert signal.data.platform == :web
    end

    test "converts key_press event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:key_press, %{key: :enter, modifiers: []})

      assert signal.type == "unified.key.pressed"
      assert signal.data.key == :enter
      assert signal.data.platform == :web
    end

    test "converts key_release event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:key_release, %{key: :escape, modifiers: []})

      assert signal.type == "unified.key.released"
      assert signal.data.key == :escape
      assert signal.data.platform == :web
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

    test "converts hook event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(:hook, %{hook_name: :scroll_handler, data: %{scroll_top: 100}})

      assert signal.type == "unified.web.scroll_handler"
      assert signal.data.hook_name == :scroll_handler
      assert signal.data.data.scroll_top == 100
      assert signal.data.platform == :web
    end

    test "accepts custom source option" do
      assert {:ok, signal} =
               Events.to_signal(:click, %{widget_id: :btn}, source: "/custom/source")

      assert signal.source == "/custom/source"
    end
  end

  describe "dispatch/3" do
    test "creates and dispatches a click signal" do
      assert {:ok, signal} = Events.dispatch(:click, %{widget_id: :my_button, action: :clicked})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :my_button
    end

    test "creates and dispatches a change signal" do
      assert {:ok, signal} =
               Events.dispatch(:change, %{widget_id: :input, value: "new value"})

      assert signal.type == "unified.input.changed"
      assert signal.data.value == "new value"
    end

    test "creates and dispatches a form submit signal" do
      assert {:ok, signal} =
               Events.dispatch(:submit, %{form_id: :login, data: %{email: "test@example.com"}})

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
    end

    test "dispatches signal to a running component when component_id is provided" do
      component_id = :"web_dispatch_#{System.unique_integer([:positive])}"

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

      assert_receive {:web_dispatch_signal, delivered_signal}
      assert delivered_signal.type == "unified.button.clicked"
      assert delivered_signal.data.widget_id == :my_button
    end

    test "returns not_found when component_id is unknown" do
      missing_component_id = :"web_missing_#{System.unique_integer([:positive])}"

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

    test "creates form submit signal with multiple fields" do
      form_data = %{
        email: "user@example.com",
        password: "secret",
        remember_me: "true"
      }

      assert {:ok, signal} = Events.form_submit(:login, form_data)

      assert signal.data.data.remember_me == "true"
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

      assert signal.data.modifiers == [:ctrl, :shift]
    end
  end

  describe "navigation_key/3" do
    test "maps directional navigation keys to normalized actions" do
      assert {:ok, signal} = Events.navigation_key(:main_tabs, :down)

      assert signal.type == "unified.key.pressed"
      assert signal.data.widget_id == :main_tabs
      assert signal.data.key == :down
      assert signal.data.action == :navigate_down
      assert signal.data.platform == :web
    end

    test "maps tab to next navigation action" do
      assert {:ok, signal} = Events.navigation_key(:main_menu, :tab)

      assert signal.data.widget_id == :main_menu
      assert signal.data.key == :tab
      assert signal.data.action == :navigate_next
    end

    test "returns error for unsupported keys" do
      assert {:error, :unsupported_navigation_key} = Events.navigation_key(:main_tree, :f1)
    end
  end

  describe "key_release/3" do
    test "creates key release signal for Enter" do
      assert {:ok, signal} = Events.key_release(:enter)

      assert signal.type == "unified.key.released"
      assert signal.data.key == :enter
      assert signal.data.modifiers == []
    end

    test "creates key release signal with modifiers" do
      assert {:ok, signal} = Events.key_release(:s, [:ctrl])

      assert signal.data.key == :s
      assert signal.data.modifiers == [:ctrl]
    end
  end

  describe "hook_event/3" do
    test "creates hook event signal" do
      assert {:ok, signal} =
               Events.hook_event(:scroll_handler, %{scroll_top: 100, scroll_left: 0})

      assert signal.type == "unified.web.scroll_handler"
      assert signal.data.hook_name == :scroll_handler
      assert signal.data.data.scroll_top == 100
      assert signal.data.data.scroll_left == 0
    end

    test "creates hook event with custom data" do
      assert {:ok, signal} =
               Events.hook_event(:resize_observer, %{width: 800, height: 600})

      assert signal.type == "unified.web.resize_observer"
      assert signal.data.data.width == 800
      assert signal.data.data.height == 600
    end
  end

  describe "WebSocket event helpers" do
    test "creates ws_connecting signal" do
      assert {:ok, signal} = Events.ws_connecting()

      assert signal.type == "unified.web.connecting"
      assert signal.data.hook_name == :connecting
    end

    test "creates ws_connected signal" do
      assert {:ok, signal} = Events.ws_connected()

      assert signal.type == "unified.web.connected"
      assert signal.data.hook_name == :connected
    end

    test "creates ws_disconnected signal" do
      assert {:ok, signal} = Events.ws_disconnected()

      assert signal.type == "unified.web.disconnected"
      assert signal.data.hook_name == :disconnected
    end

    test "creates ws_reconnecting signal" do
      assert {:ok, signal} = Events.ws_reconnecting(3, 2000)

      assert signal.type == "unified.web.reconnecting"
      assert signal.data.hook_name == :reconnecting
      assert signal.data.data.attempt == 3
      assert signal.data.data.delay_ms == 2000
    end

    test "creates ws_reconnecting signal with different values" do
      assert {:ok, signal} = Events.ws_reconnecting(5, 8000)

      assert signal.data.data.attempt == 5
      assert signal.data.data.delay_ms == 8000
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

    test "extracts input change handlers from render tree" do
      render_tree =
        {:input, nil,
         %{
           id: :email,
           type: :email,
           placeholder: "user@example.com",
           on_change: :update_email
         }}

      handlers = Events.extract_handlers(render_tree)

      assert handlers.email == %{on_change: :update_email}
    end

    test "extracts input input handlers from render tree" do
      render_tree =
        {:input, nil,
         %{
           id: :search,
           type: :text,
           on_input: :search_input
         }}

      handlers = Events.extract_handlers(render_tree)

      assert handlers.search == %{on_input: :search_input}
    end

    test "extracts form submit handlers from render tree" do
      render_tree =
        {:form, nil,
         %{
           id: :login_form,
           on_submit: :submit_login
         }}

      handlers = Events.extract_handlers(render_tree)

      assert handlers.login_form == %{on_submit: :submit_login}
    end

    test "extracts handlers from container with multiple widgets" do
      render_tree = %{
        type: :div,
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
        type: :div,
        class: "container",
        children: [
          %{
            type: :div,
            class: "row",
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
        type: :div,
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

    test "skips input without ID" do
      render_tree =
        {:input, nil,
         %{
           type: :text,
           on_change: :update
           # No id
         }}

      handlers = Events.extract_handlers(render_tree)

      refute Map.has_key?(handlers, :on_change)
    end

    test "skips form without ID" do
      render_tree =
        {:form, nil,
         %{
           on_submit: :submit
           # No id
         }}

      handlers = Events.extract_handlers(render_tree)

      refute Map.has_key?(handlers, :on_submit)
    end
  end

  describe "integration scenarios" do
    test "complete form with submit button" do
      # Simulate a login form with email input and submit button
      render_tree = %{
        type: :div,
        children: [
          {:input, nil,
           %{
             id: :email_input,
             type: :email,
             placeholder: "user@example.com",
             on_change: :validate_email
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

    test "WebSocket reconnection sequence" do
      # Simulate reconnection flow
      assert {:ok, connecting} = Events.ws_connecting()
      assert {:ok, connected} = Events.ws_connected()

      assert {:ok, disconnected} = Events.ws_disconnected()
      assert {:ok, reconnecting1} = Events.ws_reconnecting(1, 1000)
      assert {:ok, reconnecting2} = Events.ws_reconnecting(2, 2000)
      assert {:ok, reconnecting3} = Events.ws_reconnecting(3, 4000)

      assert connecting.type == "unified.web.connecting"
      assert connected.type == "unified.web.connected"
      assert disconnected.type == "unified.web.disconnected"
      assert reconnecting1.data.data.attempt == 1
      assert reconnecting2.data.data.attempt == 2
      assert reconnecting3.data.data.attempt == 3
    end

    test "LiveView hook event for scroll tracking" do
      # Simulate scroll position tracking via JS hook
      assert {:ok, signal} =
               Events.hook_event(:scroll_tracker, %{
                 scroll_top: 250,
                 scroll_left: 0,
                 scroll_height: 2000,
                 viewport_height: 600
               })

      assert signal.type == "unified.web.scroll_tracker"
      assert signal.data.data.scroll_top == 250
      assert signal.data.data.scroll_height == 2000
    end

    test "LiveView hook event for resize observer" do
      # Simulate element resize observation via JS hook
      assert {:ok, signal} =
               Events.hook_event(:resize_observer, %{
                 element_id: :my_container,
                 width: 800,
                 height: 600
               })

      assert signal.type == "unified.web.resize_observer"
      assert signal.data.data.width == 800
      assert signal.data.data.height == 600
    end

    test "form submission with multiple field types" do
      # Simulate registration form
      form_data = %{
        username: "johndoe",
        email: "john@example.com",
        password: "secret123",
        confirm_password: "secret123",
        agree_terms: "true",
        newsletter: "false"
      }

      assert {:ok, signal} = Events.form_submit(:registration, form_data)

      assert signal.type == "unified.form.submitted"
      assert signal.data.data.username == "johndoe"
      assert signal.data.data.agree_terms == "true"
    end

    test "complete key press and release cycle" do
      # Simulate pressing and releasing a key
      assert {:ok, press} = Events.key_press(:a, [])
      assert {:ok, release} = Events.key_release(:a, [])

      assert press.type == "unified.key.pressed"
      assert release.type == "unified.key.released"
      assert press.data.key == :a
      assert release.data.key == :a
    end
  end
end
