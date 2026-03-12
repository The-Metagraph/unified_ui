defmodule UnifiedUi.Adapters.Desktop.Events do
  @moduledoc """
  Event capture and signal dispatch for Desktop renderer.

  This module captures DesktopUi events (button clicks, text input changes,
  keyboard, mouse, window events) and converts them to JidoSignal messages
  for agent communication.

  ## Event Flow

  ```
  User Action → DesktopUi Event → UnifiedUi Event → JidoSignal → Agent
  ```

  ## Event Types

  ### Click Events

  Triggered by button press in the desktop window:

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :click,
        %{widget_id: :submit_button, action: :submit_form}
      )

  ### Change Events

  Triggered by text input changes:

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :change,
        %{widget_id: :email_input, value: "user@example.com"}
      )

  ### Keyboard Events

  Triggered by key press:

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :key_press,
        %{key: :enter, modifiers: []}
      )

  ### Mouse Events (Extended)

  Desktop supports rich mouse events with coordinates:

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :mouse,
        %{action: :click, x: 100, y: 200, button: :left}
      )

  ### Window Events (Desktop-specific)

  Window lifecycle events:

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :window,
        %{action: :resize, width: 800, height: 600}
      )

  ## Signal Dispatch

  Dispatch signals to the JidoSignal bus:

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.dispatch(
        :click,
        %{widget_id: :my_button, action: :clicked}
      )

  """

  alias UnifiedUi.Agent, as: UiAgent
  alias UnifiedUi.Signals
  alias UnifiedUi.Adapters.Security

  @navigation_key_actions %{
    up: :navigate_up,
    down: :navigate_down,
    left: :navigate_left,
    right: :navigate_right,
    home: :navigate_first,
    end: :navigate_last,
    page_up: :navigate_page_up,
    page_down: :navigate_page_down,
    tab: :navigate_next,
    shift_tab: :navigate_previous,
    enter: :activate,
    space: :activate,
    escape: :dismiss
  }

  @typedoc "Desktop event type."
  @type event_type ::
          :click
          | :change
          | :key_press
          | :mouse
          | :focus
          | :blur
          | :window

  @typedoc "Event payload data."
  @type event_data :: map()

  @typedoc "Desktop event."
  @type event :: %{type: event_type(), data: event_data()}

  # Event Types

  @doc """
  Returns the list of supported desktop event types.

  ## Examples

      iex> UnifiedUi.Adapters.Desktop.Events.event_types()
      [:click, :change, :key_press, :mouse, :focus, :blur, :window]

  """
  @spec event_types() :: [event_type()]
  def event_types, do: [:click, :change, :key_press, :mouse, :focus, :blur, :window]

  # Event Creation

  @doc """
  Creates a desktop event from type and data.

  ## Examples

      iex> UnifiedUi.Adapters.Desktop.Events.create_event(:click, %{widget_id: :btn})
      %{type: :click, data: %{widget_id: :btn}}

  """
  @spec create_event(event_type(), event_data()) :: event()
  def create_event(type, data) do
    %{type: type, data: data}
  end

  # Event-to-Signal Conversion

  @doc """
  Converts a desktop event to a JidoSignal.

  ## Parameters

  * `event_type` - The type of desktop event (:click, :change, :key_press, :mouse, :window, etc.)
  * `data` - Event payload data

  ## Options

  * `:source` - Override the default source (default: "/unified_ui/desktop")
  * `:subject` - Optional subject for the signal

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :click,
        %{widget_id: :submit_button, action: :submit_form}
      )

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :mouse,
        %{action: :click, x: 100, y: 200, button: :left}
      )

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.to_signal(
        :window,
        %{action: :resize, width: 800, height: 600}
      )

  """
  @spec to_signal(event_type(), event_data(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def to_signal(event_type, data, opts \\ [])

  # Click events → unified.button.clicked
  def to_signal(:click, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :desktop})
      Signals.create(:click, signal_data, source: signal_source(opts))
    end
  end

  # Change events → unified.input.changed
  def to_signal(:change, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :desktop})
      Signals.create(:change, signal_data, source: signal_source(opts))
    end
  end

  # Submit events → unified.form.submitted
  def to_signal(:submit, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :desktop})
      Signals.create(:submit, signal_data, source: signal_source(opts))
    end
  end

  # Key press events → unified.key.pressed
  def to_signal(:key_press, data, opts) do
    signal_type = "unified.key.pressed"
    signal_data = Map.merge(data, %{platform: :desktop})
    Signals.create(signal_type, signal_data, source: signal_source(opts))
  end

  # Mouse events → unified.mouse.{action}
  # Security: Validate action before string interpolation to prevent signal injection
  def to_signal(:mouse, %{action: action} = data, opts) do
    with :ok <- Security.validate_event_action(:mouse, action),
         :ok <- Security.validate_signal_payload(data) do
      signal_type = "unified.mouse.#{action}"
      signal_data = Map.merge(data, %{platform: :desktop})
      Signals.create(signal_type, signal_data, source: signal_source(opts))
    end
  end

  # Focus events → unified.element.focused
  def to_signal(:focus, data, opts) do
    signal_data = Map.merge(data, %{platform: :desktop})
    Signals.create(:focus, signal_data, source: signal_source(opts))
  end

  # Blur events → unified.element.blurred
  def to_signal(:blur, data, opts) do
    signal_data = Map.merge(data, %{platform: :desktop})
    Signals.create(:blur, signal_data, source: signal_source(opts))
  end

  # Window events → unified.window.{action}
  # Security: Validate action before string interpolation to prevent signal injection
  def to_signal(:window, %{action: action} = data, opts) do
    with :ok <- Security.validate_event_action(:window, action),
         :ok <- Security.validate_signal_payload(data) do
      signal_type = "unified.window.#{action}"
      signal_data = Map.merge(data, %{platform: :desktop})
      Signals.create(signal_type, signal_data, source: signal_source(opts))
    end
  end

  # Signal Dispatch

  @doc """
  Creates and dispatches a desktop event as a JidoSignal.

  This is a convenience function that combines `to_signal/3` with dispatch.

  ## Parameters

  * `event_type` - The type of desktop event
  * `data` - Event payload data
  * `opts` - Options passed to signal creation. Supports `:component_id` for
    direct dispatch to a running `UnifiedUi.Agent` component.

  ## Returns

  `{:ok, signal}` on success, `{:error, reason}` on failure.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.dispatch(
        :click,
        %{widget_id: :my_button, action: :clicked}
      )

  """
  @spec dispatch(event_type(), event_data(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def dispatch(event_type, data, opts \\ []) do
    with {:ok, signal} <- to_signal(event_type, data, opts),
         :ok <- maybe_dispatch_to_component(signal, opts) do
      {:ok, signal}
    end
  end

  defp maybe_dispatch_to_component(signal, opts) do
    case Keyword.get(opts, :component_id) do
      nil ->
        :ok

      component_id when is_atom(component_id) ->
        UiAgent.signal_component(component_id, signal)

      _other ->
        {:error, :invalid_component_id}
    end
  end

  # Widget-Specific Event Helpers

  @doc """
  Creates a click event signal for a button widget.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.button_click(
        :submit_button,
        :submit_form
      )

  """
  @spec button_click(atom(), atom(), keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def button_click(widget_id, action, opts \\ []) do
    to_signal(:click, %{widget_id: widget_id, action: action}, opts)
  end

  @doc """
  Creates a change event signal for a text input widget.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.input_change(
        :email_input,
        "user@example.com"
      )

  """
  @spec input_change(atom(), String.t(), keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def input_change(widget_id, value, opts \\ []) do
    to_signal(:change, %{widget_id: widget_id, value: value}, opts)
  end

  @doc """
  Creates a submit event signal for a form.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.form_submit(
        :login_form,
        %{email: "user@example.com", password: "secret"}
      )

  """
  @spec form_submit(atom(), map(), keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def form_submit(form_id, data, opts \\ []) do
    # Security: Redact sensitive fields (passwords, tokens) from form data
    {:ok, redacted_data} = Security.redact_sensitive_fields(data)
    to_signal(:submit, %{form_id: form_id, data: redacted_data}, opts)
  end

  @doc """
  Creates a key press event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.key_press(:enter, [])

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.key_press(:char, [?a])

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.key_press(:s, [:ctrl])  # Ctrl+S

  """
  @spec key_press(atom(), [atom()], keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def key_press(key, modifiers \\ [], opts \\ []) do
    to_signal(:key_press, %{key: key, modifiers: modifiers}, opts)
  end

  @doc """
  Creates a normalized keyboard navigation signal for navigation widgets.

  The `key` is mapped to a standard navigation action and emitted as
  `unified.key.pressed` with `widget_id`, `key`, and `action` metadata.
  """
  @spec navigation_key(atom(), atom(), keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def navigation_key(widget_id, key, opts \\ [])

  def navigation_key(widget_id, key, opts) when is_atom(widget_id) and is_atom(key) do
    case Map.fetch(@navigation_key_actions, key) do
      {:ok, action} ->
        to_signal(:key_press, %{widget_id: widget_id, key: key, action: action}, opts)

      :error ->
        {:error, :unsupported_navigation_key}
    end
  end

  # Mouse Event Helpers

  @doc """
  Creates a mouse click event signal with coordinates.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.mouse_click(
        :my_button,
        :left,
        100,
        200
      )

  """
  @spec mouse_click(atom(), atom(), integer(), integer(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def mouse_click(widget_id, button \\ :left, x \\ 0, y \\ 0, opts \\ []) do
    to_signal(:mouse, %{widget_id: widget_id, action: :click, button: button, x: x, y: y}, opts)
  end

  @doc """
  Creates a mouse double-click event signal with coordinates.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.mouse_double_click(
        :my_item,
        :left,
        150,
        250
      )

  """
  @spec mouse_double_click(atom(), atom(), integer(), integer(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def mouse_double_click(widget_id, button \\ :left, x \\ 0, y \\ 0, opts \\ []) do
    to_signal(
      :mouse,
      %{widget_id: widget_id, action: :double_click, button: button, x: x, y: y},
      opts
    )
  end

  @doc """
  Creates a mouse move event signal with coordinates.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.mouse_move(100, 200)

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.mouse_move(150, 300, [:left, :right])

  """
  @spec mouse_move(integer(), integer(), [atom()], keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def mouse_move(x, y, buttons \\ [], opts \\ []) do
    to_signal(:mouse, %{action: :move, x: x, y: y, buttons: buttons}, opts)
  end

  @doc """
  Creates a mouse wheel/scroll event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.mouse_scroll(100, 200, :down, 3)

  """
  @spec mouse_scroll(integer(), integer(), atom(), integer(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def mouse_scroll(x, y, direction \\ :down, delta \\ 1, opts \\ []) do
    to_signal(:mouse, %{action: :scroll, x: x, y: y, direction: direction, delta: delta}, opts)
  end

  # Window Event Helpers

  @doc """
  Creates a window resize event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_resize(800, 600)

  """
  @spec window_resize(integer(), integer(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def window_resize(width, height, opts \\ []) do
    to_signal(:window, %{action: :resize, width: width, height: height}, opts)
  end

  @doc """
  Creates a window move event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_move(100, 50)

  """
  @spec window_move(integer(), integer(), keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_move(x, y, opts \\ []) do
    to_signal(:window, %{action: :move, x: x, y: y}, opts)
  end

  @doc """
  Creates a window close event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_close()

  """
  @spec window_close(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_close(opts \\ []) do
    to_signal(:window, %{action: :close}, opts)
  end

  @doc """
  Creates a window minimize event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_minimize()

  """
  @spec window_minimize(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_minimize(opts \\ []) do
    to_signal(:window, %{action: :minimize}, opts)
  end

  @doc """
  Creates a window maximize event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_maximize()

  """
  @spec window_maximize(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_maximize(opts \\ []) do
    to_signal(:window, %{action: :maximize}, opts)
  end

  @doc """
  Creates a window restore event signal (restore from minimized/maximized).

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_restore()

  """
  @spec window_restore(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_restore(opts \\ []) do
    to_signal(:window, %{action: :restore}, opts)
  end

  @doc """
  Creates a window focus event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_focus()

  """
  @spec window_focus(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_focus(opts \\ []) do
    to_signal(:window, %{action: :focus}, opts)
  end

  @doc """
  Creates a window blur event signal (window lost focus).

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Desktop.Events.window_blur()

  """
  @spec window_blur(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def window_blur(opts \\ []) do
    to_signal(:window, %{action: :blur}, opts)
  end

  # Event Extraction from Render Tree

  @doc """
  Extracts event handlers from a DesktopUi render tree.

  This function traverses the render tree to find all widgets with event
  handlers (buttons, inputs, etc.) and returns a map of widget IDs to their
  handler configurations.

  ## Examples

      handlers = UnifiedUi.Adapters.Desktop.Events.extract_handlers(render_tree)
      # => %{submit_button: %{on_click: :submit}, email_input: %{on_change: :update_email}}

  """
  @spec extract_handlers(term()) :: map()
  def extract_handlers(render_tree) do
    extract_handlers(render_tree, %{})
  end

  defp extract_handlers({:button, _node, metadata}, acc) do
    case metadata do
      %{on_click: action, id: id} when not is_nil(id) ->
        Map.put(acc, id, %{on_click: action})

      _ ->
        acc
    end
  end

  defp extract_handlers({:text_input, _node, metadata}, acc) do
    base =
      case metadata do
        %{id: id, on_change: change} when not is_nil(id) and not is_nil(change) ->
          %{on_change: change}

        %{id: id, on_submit: submit} when not is_nil(id) and not is_nil(submit) ->
          %{on_submit: submit}

        %{id: id} when not is_nil(id) ->
          %{}

        _ ->
          nil
      end

    if base do
      Map.put(acc, metadata.id, base)
    else
      acc
    end
  end

  defp extract_handlers(%{type: _type, children: children} = node, acc) when is_list(children) do
    # Process container nodes
    acc =
      Enum.reduce(children, acc, fn child, inner_acc ->
        extract_handlers(child, inner_acc)
      end)

    # Check if this node has an ID and any handlers
    if Map.has_key?(node, :id) do
      case extract_node_handlers(node) do
        nil -> acc
        handlers -> Map.put(acc, node.id, handlers)
      end
    else
      acc
    end
  end

  defp extract_handlers(%{children: children}, acc) when is_list(children) do
    Enum.reduce(children, acc, fn child, inner_acc ->
      extract_handlers(child, inner_acc)
    end)
  end

  defp extract_handlers(_, acc), do: acc

  defp extract_node_handlers(%{type: :button, props: props}) do
    case props[:on_click] do
      # Skip buttons without on_click handler
      nil -> nil
      action -> %{on_click: action}
    end
  end

  defp extract_node_handlers(%{type: :label, props: _props}) do
    # Labels don't have handlers
    nil
  end

  # Unknown nodes have no handlers
  defp extract_node_handlers(_node), do: nil

  # Private helpers

  defp signal_source(opts) do
    Keyword.get(opts, :source, "/unified_ui/desktop")
  end
end
