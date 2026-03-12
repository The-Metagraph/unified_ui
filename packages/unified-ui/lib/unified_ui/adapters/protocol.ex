defmodule UnifiedUi.Renderer do
  @moduledoc """
  Behaviour definition for platform-specific UI renderers.

  All renderers (Terminal, Desktop, Web) must implement this behaviour
  to ensure a consistent interface for converting IUR (Intermediate UI
  Representation) to platform-specific widgets.

  ## Renderer Lifecycle

  1. **render/2** - Convert IUR tree to platform widgets
  2. **update/3** - Update existing widgets with new IUR state
  3. **destroy/1** - Clean up platform resources

  ## Required Callbacks

  * `render/2` - Convert IUR element tree to platform widgets
  * `update/3` - Update existing widgets with new IUR state
  * `destroy/1` - Cleanup resources when renderer is shut down

  ## Platform State

  Renderers should maintain their own state structures that track:
  * Platform widget references (mapped by element ID)
  * Event handlers and subscriptions
  * Platform-specific context (windows, terminals, etc.)

  ## Example

  A minimal renderer implementation:

      defmodule MyRenderer do
        @behaviour UnifiedUi.Renderer

        alias UnifiedIUR.Element

        @impl true
        def render(iur_tree, opts \\ []) do
          # Convert IUR to platform widgets
          # Return {:ok, renderer_state} or {:error, reason}
        end

        @impl true
        def update(iur_tree, renderer_state, opts \\ []) do
          # Update existing widgets with new IUR state
          # Return {:ok, updated_state} or {:error, reason}
        end

        @impl true
        def destroy(renderer_state) do
          # Clean up platform resources
          :ok
        end
      end

  ## Using a Renderer

      # Initial render
      {:ok, state} = MyRenderer.render(iur_tree)

      # Update with new state
      {:ok, updated_state} = MyRenderer.update(new_iur_tree, state)

      # Cleanup
      :ok = MyRenderer.destroy(state)

  ## Error Handling

  All callbacks should return:
  * `{:ok, state}` on success
  * `{:error, reason}` on failure

  Errors should be descriptive and include context about what went wrong.
  """

  @type iur_element :: UnifiedIUR.Widgets.Text.t() |
                       UnifiedIUR.Widgets.Button.t() |
                       UnifiedIUR.Widgets.Label.t() |
                       UnifiedIUR.Widgets.TextInput.t() |
                       UnifiedIUR.Layouts.VBox.t() |
                       UnifiedIUR.Layouts.HBox.t()

  @type iur_tree :: iur_element()

  @type renderer_state :: term()

  @type render_opts :: keyword()
  @type update_opts :: keyword()

  @doc """
  Renders an IUR tree to platform-specific widgets.

  This is the main entry point for creating a UI. The renderer should
  traverse the IUR tree and create corresponding platform widgets,
  establishing the widget hierarchy and applying styles.

  ## Parameters

  * `iur_tree` - The root element of the IUR tree to render
  * `opts` - Optional renderer configuration:
    * `:window_title` - Title for the window/container
    * `:window_size` - Initial size `{width, height}`
    * `:debug` - Enable debug output

  ## Returns

  * `{:ok, renderer_state}` - Rendering successful, state contains platform widgets
  * `{:error, reason}` - Rendering failed

  ## Examples

      iex> Renderer.render(%VBox{children: [%Text{content: "Hello"}]})
      {:ok, %RendererState{root: #PID<0.123.0>}}

  """
  @callback render(iur_tree(), render_opts()) :: {:ok, renderer_state()} | {:error, term()}

  @doc """
  Updates an existing rendered UI with a new IUR tree.

  Instead of destroying and recreating widgets, the renderer should
  update the existing widgets where possible for better performance.
  This is especially important for interactive applications.

  ## Parameters

  * `iur_tree` - The new IUR tree with updated state
  * `renderer_state` - Current renderer state from previous render/update
  * `opts` - Optional update configuration

  ## Returns

  * `{:ok, updated_state}` - Update successful
  * `{:error, reason}` - Update failed

  ## Update Strategy

  Renderers should implement a diffing strategy:
  1. Match elements by ID
  2. Update existing widgets in place
  3. Add new widgets for new elements
  4. Remove widgets for deleted elements

  ## Examples

      iex> Renderer.update(new_iur_tree, state)
      {:ok, %RendererState{root: #PID<0.123.0>, version: 2}}

  """
  @callback update(iur_tree(), renderer_state(), update_opts()) :: {:ok, renderer_state()} | {:error, term()}

  @doc """
  Cleans up platform resources when the renderer is no longer needed.

  This should release all platform resources including windows, widgets,
  event subscriptions, and any other allocated resources.

  ## Parameters

  * `renderer_state` - The renderer state to clean up

  ## Returns

  * `:ok` - Cleanup successful
  * `{:error, reason}` - Cleanup failed (should be rare)

  ## Examples

      iex> Renderer.destroy(state)
      :ok

  """
  @callback destroy(renderer_state()) :: :ok | {:error, term()}

  @optional_callbacks []
end
