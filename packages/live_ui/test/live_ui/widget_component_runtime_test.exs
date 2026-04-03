defmodule LiveUi.WidgetComponentRuntimeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias LiveUi.Component.Metadata
  alias LiveUi.Runtime.ScreenComponent
  alias LiveUi.Widget.Identity
  alias UnifiedIUR.Layout
  alias UnifiedIUR.Widgets.Foundational

  defmodule NativeComponentScreen do
    use LiveUi.Screen, id: :native_component_screen, title: "Native Component Screen"

    @impl true
    def mount_defaults do
      %{status: "Ready"}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <LiveUi.Widgets.ScreenShell.render id="native-component-screen" title={title()}>
        <LiveUi.Widgets.Button.component
          id="save-button"
          label="Save"
          runtime_state={@runtime_state}
          event_target={@event_target}
        />
        <LiveUi.Widgets.Text.component
          id="status-text"
          content={@status}
          runtime_state={@runtime_state}
          event_target={@event_target}
        />
      </LiveUi.Widgets.ScreenShell.render>
      """
    end
  end

  defmodule LocalCounterWidget do
    @moduledoc """
    Test widget demonstrating local state management within the widget component boundary.
    """
    use Phoenix.Component

    def metadata do
      Metadata.new(__MODULE__,
        family: :content,
        name: :local_counter,
        assigns: [:id, :label, :metadata],
        component_module: Component,
        wrapper_module: __MODULE__,
        mountable?: true,
        local_state_keys: [:count],
        identity_keys: [:id],
        runtime_boundary: :live_component
      )
    end

    def render(assigns) do
      local_state = Map.get(assigns.metadata, :widget_local_state, %{})
      widget_identity = Map.get(assigns.metadata, :widget_identity)

      assigns =
        assigns
        |> assign(:count, Map.get(local_state, :count, 0))
        |> assign(:widget_key, widget_identity && Identity.key(widget_identity))
        |> assign(:event_target, Map.get(assigns.metadata, :widget_event_target))
        |> assign(:widget_component, inspect(Component))

      ~H"""
      <div data-local-counter="true">
        <button
          type="button"
          phx-click="widget_component_event"
          phx-target={@event_target}
          phx-value-widget_component={@widget_component}
          phx-value-widget_key={@widget_key}
          phx-value-widget_event="increment"
        ><%= @label %></button>
        <span data-local-counter-value="true"><%= @count %></span>
      </div>
      """
    end

    defmodule Component do
      use LiveUi.Widget,
        wrapper: LiveUi.WidgetComponentRuntimeTest.LocalCounterWidget,
        family: :content,
        name: :local_counter,
        assigns: [:label],
        events: [:click],
        local_state_keys: [:count]

      @impl true
      def mount_defaults, do: %{count: 0}

      @impl true
      def event_routes, do: %{"increment" => :increment}

      @impl true
      def handle_widget_event(:increment, _payload, local_state) do
        {:ok, Map.update(local_state, :count, 1, &(&1 + 1))}
      end
    end
  end

  defmodule LocalCounterScreen do
    use LiveUi.Screen, id: :local_counter_screen, title: "Local Counter Screen"

    @impl true
    def render(assigns) do
      ~H"""
      <LiveUi.Widgets.ScreenShell.render id="local-counter-screen" title={title()}>
        <LiveUi.Component.mount
          module={LiveUi.WidgetComponentRuntimeTest.LocalCounterWidget}
          assigns={%{id: "counter-widget", label: "Increment"}}
          runtime_state={@runtime_state}
          event_target={@event_target}
        />
      </LiveUi.Widgets.ScreenShell.render>
      """
    end
  end

  test "native screens can compose mountable widget component boundaries through the shared runtime" do
    assert {:ok, runtime_state} = LiveUi.Runtime.mount(NativeComponentScreen)

    html =
      render_component(LiveUi.Runtime.component(),
        id: "native-runtime",
        runtime_state: runtime_state
      )

    assert html =~ ~s(data-live-ui-widget-boundary="button")
    assert html =~ ~s(data-live-ui-widget-boundary="text")
    assert html =~ ~s(data-live-ui-widget-key="native:content:button:save-button:root")
    assert html =~ "Save"
    assert html =~ "Ready"
  end

  test "runtime routes widget-targeted events and preserves bounded widget-local state" do
    assert {:ok, runtime_state} = LiveUi.Runtime.mount(LocalCounterScreen)

    initial_html =
      render_component(LiveUi.Runtime.component(),
        id: "counter-runtime",
        runtime_state: runtime_state
      )

    assert initial_html =~ ~s(data-local-counter-value="true">0</span>)

    identity =
      Identity.new(LocalCounterWidget.metadata(), %{id: "counter-widget"})

    socket =
      %Phoenix.LiveView.Socket{}
      |> Phoenix.Component.assign(:runtime_state, runtime_state)

    assert {:noreply, updated_socket} =
             ScreenComponent.handle_event(
               "widget_component_event",
               %{
                 "widget_component" => inspect(LocalCounterWidget.Component),
                 "widget_key" => Identity.key(identity),
                 "widget_event" => "increment"
               },
               socket
             )

    assert updated_socket.assigns.runtime_state.widget_local_state[Identity.key(identity)] == %{count: 1}

    updated_html =
      render_component(LiveUi.Runtime.component(),
        id: "counter-runtime",
        runtime_state: updated_socket.assigns.runtime_state
      )

    assert updated_html =~ ~s(data-local-counter-value="true">1</span>)
  end

  test "canonical runtime rendering reuses widget component boundaries for mounted widgets" do
    element =
      Layout.column([
        Foundational.text("Ready", id: "status-text"),
        Foundational.button("Save", id: "save-button")
      ])

    assert {:ok, runtime_state} = LiveUi.Runtime.mount_iur(element)

    html =
      render_component(LiveUi.Runtime.component(),
        id: "canonical-runtime",
        runtime_state: runtime_state
      )

    assert html =~ ~s(data-live-ui-widget-boundary="text")
    assert html =~ ~s(data-live-ui-widget-boundary="button")
    assert html =~ ~s(data-live-ui-widget-key="canonical:content:text:status-text:root")
    assert html =~ ~s(data-live-ui-widget-key="canonical:content:button:save-button:root")
  end
end
