defmodule LiveUi.DemoInteractionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias LiveUi.Runtime.ScreenComponent
  alias UnifiedIUR.Interaction

  test "button examples auto-wire canonical click interactions through the demo hook" do
    runtime_state = demo_runtime_state(example: :button)

    assert {:noreply, updated_socket} =
             ScreenComponent.handle_event(
               "canonical_interaction",
               %{
                 "interaction" => encode_interaction(Interaction.click(intent: :widget_demo_button)),
                 "element_id" => "live-ui-demo-widget-button-button",
                 "widget" => "button"
               },
               demo_socket(runtime_state)
             )

    assert updated_socket.assigns.runtime_state.assigns.widget_demo_state.button.clicks == 1

    html =
      render_component(LiveUi.Runtime.component(),
        id: "live-ui-demo-runtime",
        runtime_state: updated_socket.assigns.runtime_state,
        show_demo_panels: false
      )

    assert html =~ ~s(phx-click="canonical_interaction")
    assert html =~ "Clicks recorded: 1"
  end

  test "text input examples auto-wire canonical change interactions through the demo hook" do
    runtime_state = demo_runtime_state(example: :text_input)

    assert {:noreply, updated_socket} =
             ScreenComponent.handle_event(
               "canonical_interaction",
               %{
                 "interaction" =>
                   encode_interaction(
                     Interaction.change(intent: :widget_demo_text_input, binding: :widget_name)
                   ),
                 "element_id" => "live-ui-demo-widget-text_input-text-input",
                 "widget" => "text_input",
                 "widget_name" => "Signals"
               },
               demo_socket(runtime_state)
             )

    assert updated_socket.assigns.runtime_state.assigns.widget_demo_state.text_input.value ==
             "Signals"

    html =
      render_component(LiveUi.Runtime.component(),
        id: "live-ui-demo-runtime",
        runtime_state: updated_socket.assigns.runtime_state,
        show_demo_panels: false
      )

    assert html =~ "canonical_interaction"
    assert html =~ "Current value: Signals"
  end

  test "tabs examples auto-wire canonical selection interactions through the demo hook" do
    runtime_state = demo_runtime_state(example: :tabs)

    assert {:noreply, updated_socket} =
             ScreenComponent.handle_event(
               "canonical_interaction",
               %{
                 "interaction" =>
                   encode_interaction(Interaction.selection(intent: :widget_demo_tabs)),
                 "element_id" => "live-ui-demo-widget-tabs-tabs",
                 "widget" => "tabs",
                 "item_id" => "signals"
               },
               demo_socket(runtime_state)
             )

    assert updated_socket.assigns.runtime_state.assigns.widget_demo_state.tabs.active == "signals"

    html =
      render_component(LiveUi.Runtime.component(),
        id: "live-ui-demo-runtime",
        runtime_state: updated_socket.assigns.runtime_state,
        show_demo_panels: false
      )

    assert html =~ ~s(phx-click="canonical_interaction")
    assert html =~ ~s(data-item-id="signals")
    assert html =~ "Active tab: Signals"
  end

  defp demo_runtime_state(opts) do
    {:ok, assigns} = LiveUi.Demo.screen_assigns(opts)
    {:ok, runtime_state} = LiveUi.Runtime.mount(LiveUi.Demo.screen(), assigns: assigns)
    runtime_state
  end

  defp demo_socket(runtime_state) do
    %Phoenix.LiveView.Socket{}
    |> Phoenix.Component.assign(:runtime_state, runtime_state)
  end

  defp encode_interaction(%Interaction{} = interaction) do
    interaction
    |> :erlang.term_to_binary()
    |> Base.url_encode64(padding: false)
  end
end
