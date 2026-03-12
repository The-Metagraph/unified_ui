defmodule UnifiedUi.Adapters.Terminal.EventsTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Terminal.Events
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Terminal.Events
  alias UnifiedUi.Agent, as: UiAgent

  defmodule DispatchComponent do
    @behaviour UnifiedUi.ElmArchitecture

    @impl true
    def init(opts), do: %{observer: Keyword.get(opts, :observer)}

    @impl true
    def update(state, signal) do
      if is_pid(state.observer), do: send(state.observer, {:terminal_dispatch_signal, signal})
      state
    end

    @impl true
    def view(_state), do: %UnifiedIUR.Widgets.Text{id: :terminal_dispatch_probe, content: "ok"}
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
  end

  describe "to_signal/3" do
    test "converts click event to JidoSignal" do
      assert {:ok, signal} = Events.to_signal(:click, %{widget_id: :btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :btn
      assert signal.data.platform == :terminal
      assert signal.source == "/unified_ui/terminal"
    end

    test "converts click event with action to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :click,
                 %{widget_id: :submit, action: :submit_form}
               )

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :submit
      assert signal.data.action == :submit_form
    end

    test "converts change event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :change,
                 %{widget_id: :email, value: "test@example.com"}
               )

      assert signal.type == "unified.input.changed"
      assert signal.data.widget_id == :email
      assert signal.data.value == "test@example.com"
      assert signal.data.platform == :terminal
    end

    test "converts submit event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :submit,
                 %{form_id: :login, data: %{email: "user@example.com"}}
               )

      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
      assert signal.data.platform == :terminal
    end

    test "converts key_press event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :key_press,
                 %{key: :enter, modifiers: []}
               )

      assert signal.type == "unified.key.pressed"
      assert signal.data.key == :enter
      assert signal.data.platform == :terminal
    end

    test "converts mouse event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :mouse,
                 %{action: :click, x: 10, y: 20}
               )

      assert signal.type == "unified.mouse.click"
      assert signal.data.action == :click
      assert signal.data.platform == :terminal
    end

    test "converts focus event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :focus,
                 %{widget_id: :input}
               )

      assert signal.type == "unified.element.focused"
      assert signal.data.widget_id == :input
    end

    test "converts blur event to JidoSignal" do
      assert {:ok, signal} =
               Events.to_signal(
                 :blur,
                 %{widget_id: :input}
               )

      assert signal.type == "unified.element.blurred"
      assert signal.data.widget_id == :input
    end

    test "accepts custom source option" do
      assert {:ok, signal} =
               Events.to_signal(
                 :click,
                 %{widget_id: :btn},
                 source: "/custom/source"
               )

      assert signal.source == "/custom/source"
    end
  end

  describe "dispatch/3" do
    test "creates and dispatches a click signal" do
      assert {:ok, signal} =
               Events.dispatch(
                 :click,
                 %{widget_id: :my_button, action: :clicked}
               )

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :my_button
    end

    test "creates and dispatches a change signal" do
      assert {:ok, signal} =
               Events.dispatch(
                 :change,
                 %{widget_id: :input, value: "new value"}
               )

      assert signal.type == "unified.input.changed"
      assert signal.data.value == "new value"
    end

    test "dispatches signal to a running component when component_id is provided" do
      component_id = :"terminal_dispatch_#{System.unique_integer([:positive])}"

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

      assert_receive {:terminal_dispatch_signal, delivered_signal}
      assert delivered_signal.type == "unified.button.clicked"
      assert delivered_signal.data.widget_id == :my_button
    end

    test "returns not_found when component_id is unknown" do
      missing_component_id = :"terminal_missing_#{System.unique_integer([:positive])}"

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
      assert {:ok, signal} =
               Events.button_click(
                 :save,
                 :save_data,
                 source: "/app/save"
               )

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
      assert {:ok, signal} =
               Events.input_change(
                 :query,
                 "search term",
                 source: "/custom"
               )

      assert signal.source == "/custom"
    end
  end

  describe "form_submit/3" do
    test "creates form submit signal" do
      assert {:ok, signal} =
               Events.form_submit(
                 :login,
                 %{email: "user@example.com", password: "secret"}
               )

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
      assert {:ok, signal} = Events.key_press(:char, [?c])

      assert signal.data.key == :char
      assert signal.data.modifiers == [?c]
    end

    test "creates key press signal for Ctrl+S" do
      assert {:ok, signal} = Events.key_press(:s, [:ctrl])

      assert signal.data.key == :s
      assert signal.data.modifiers == [:ctrl]
    end
  end

  describe "navigation_key/3" do
    test "maps directional navigation keys to normalized actions" do
      assert {:ok, signal} = Events.navigation_key(:main_tabs, :right)

      assert signal.type == "unified.key.pressed"
      assert signal.data.widget_id == :main_tabs
      assert signal.data.key == :right
      assert signal.data.action == :navigate_right
      assert signal.data.platform == :terminal
    end

    test "maps activation keys to activate action" do
      assert {:ok, signal} = Events.navigation_key(:main_menu, :enter)

      assert signal.data.widget_id == :main_menu
      assert signal.data.key == :enter
      assert signal.data.action == :activate
    end

    test "returns error for unsupported keys" do
      assert {:error, :unsupported_navigation_key} = Events.navigation_key(:main_tree, :f1)
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
        type: :stack,
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
        type: :stack,
        direction: :vertical,
        children: [
          %{
            type: :stack,
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
        type: :stack,
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
        type: :stack,
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

    test "Ctrl+C to exit" do
      assert {:ok, signal} = Events.key_press(:c, [:ctrl])

      assert signal.data.key == :c
      assert signal.data.modifiers == [:ctrl]
    end
  end
end
