defmodule UnifiedUi.ElmArchitecture do
  @moduledoc """
  Behaviour for UI components following The Elm Architecture.

  The Elm Architecture is a simple pattern for building user interfaces
  that guarantees consistency, testability, and maintainability.

  ## The Pattern

  Every UI component has three parts:

  1. **Model** - The state of the application
  2. **Update** - A way to update the state in response to signals
  3. **View** - A function to render the state as UI

  ## Callbacks

  Components implementing this behaviour must provide:

  * `c:init/1` - Initialize the component state
  * `c:update/2` - Handle signals and return new state
  * `c:view/1` - Render the state as IUR (Intermediate UI Representation)

  ## Example

  A simple counter component:

      defmodule Counter do
        @behaviour UnifiedUi.ElmArchitecture

        @impl true
        def init(_opts) do
          %{count: 0}
        end

        @impl true
        def update(state, %Jido.Signal{type: "unified.button.clicked", data: %{action: :increment}}) do
          %{state | count: state.count + 1}
        end

        def update(state, %Jido.Signal{type: "unified.button.clicked", data: %{action: :decrement}}) do
          %{state | count: state.count - 1}
        end

        def update(state, _signal) do
          state
        end

        @impl true
        def view(state) do
          %UnifiedIUR.Layouts.VBox{
            spacing: 1,
            children: [
              %UnifiedIUR.Widgets.Text{
                content: "Count: " <> Integer.to_string(state.count)
              },
              %UnifiedIUR.Widgets.Button{label: "+", on_click: {:increment, %{}}},
              %UnifiedIUR.Widgets.Button{label: "-", on_click: {:decrement, %{}}}
            ]
          }
        end
      end

  ## Signals

  The `c:update/2` callback receives `Jido.Signal` structs. Signal types
  follow the pattern `"domain.entity.action"` (e.g., `"unified.button.clicked"`).

  Pattern matching on signal types provides clean signal routing:

      def update(state, %Jido.Signal{type: "unified.input.changed", data: data}) do
        %{state | value: data.value}
      end

  ## State Shape

  State should be a map with atom keys for type safety and consistency:

      # Good
      %{username: "alice", count: 5, active: true}

      # Avoid - string keys less ergonomic for pattern matching
      %{"username" => "alice", "count" => 5}
  """

  @doc """
  Initialize the component state.

  Called once when the component starts. Use this to set up initial state.

  ## Parameters

  * `opts` - Keyword list of options passed to the component

  ## Returns

  A map with atom keys representing the initial state.

  ## Examples

      def init(_opts) do
        %{count: 0, text: "", active: true}
      end
  """
  @callback init(keyword()) :: %{atom() => any()}

  @doc """
  Update the component state in response to a signal.

  This callback receives the current state and an incoming signal, and
  must return the new state. Use pattern matching on signal types for routing.

  ## Parameters

  * `state` - Current component state (map with atom keys)
  * `signal` - Incoming `Jido.Signal` struct

  ## Returns

  Updated state map with atom keys.

  ## Examples

      # Handle specific signal
      def update(state, %Jido.Signal{type: "unified.button.clicked"}) do
        %{state | clicked: true}
      end

      # Extract signal data
      def update(state, %Jido.Signal{type: "unified.input.changed", data: data}) do
        %{state | value: data.value}
      end

      # Fallback for unrecognized signals
      def update(state, _signal) do
        state
      end
  """
  @callback update(%{atom() => any()}, Jido.Signal.t()) :: %{atom() => any()}

  @doc """
  Render the component state as UI.

  Returns an IUR (Intermediate UI Representation) tree representing
  the component's UI. The IUR is platform-agnostic and can be rendered
  by any platform-specific renderer (Terminal, Desktop, Web).

  ## Parameters

  * `state` - Current component state

  ## Returns

  An IUR struct implementing `UnifiedIUR.Element` protocol.

  ## Examples

      def view(state) do
        %UnifiedIUR.Layouts.VBox{
          spacing: 1,
          children: [
            %UnifiedIUR.Widgets.Text{content: "Hello, " <> Map.get(state, :name, "World")},
            %UnifiedIUR.Widgets.Button{label: "Click", on_click: :button_click}
          ]
        }
      end
  """
  @callback view(%{atom() => any()}) :: UnifiedIUR.Element.t()

  @optional_callbacks []
end
