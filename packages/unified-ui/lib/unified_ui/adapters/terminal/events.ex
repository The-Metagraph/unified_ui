defmodule UnifiedUi.Adapters.Terminal.Events do
  @moduledoc """
  Event capture and signal dispatch for Terminal renderer.

  This module captures TermUi events (button clicks, text input changes,
  keyboard input) and converts them to JidoSignal messages for agent communication.

  ## Event Flow

  ```
  User Action → TermUi Event → UnifiedUi Event → JidoSignal → Agent
  ```

  ## Event Types

  ### Click Events

  Triggered by button press in the terminal:

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.to_signal(
        :click,
        %{widget_id: :submit_button, action: :submit_form}
      )

  ### Change Events

  Triggered by text input changes:

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.to_signal(
        :change,
        %{widget_id: :email_input, value: "user@example.com"}
      )

  ### Keyboard Events

  Triggered by key press:

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.to_signal(
        :key_press,
        %{key: :enter, modifiers: []}
      )

  ## Signal Dispatch

  Dispatch signals to the JidoSignal bus:

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.dispatch(
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

  @typedoc "Terminal event type."
  @type event_type :: :click | :change | :key_press | :mouse | :focus | :blur

  @typedoc "Event payload data."
  @type event_data :: map()

  @typedoc "Terminal event."
  @type event :: %{type: event_type(), data: event_data()}

  # Event Types

  @doc """
  Returns the list of supported terminal event types.

  ## Examples

      iex> UnifiedUi.Adapters.Terminal.Events.event_types()
      [:click, :change, :key_press, :mouse, :focus, :blur]
  """
  @spec event_types() :: [event_type()]
  def event_types, do: [:click, :change, :key_press, :mouse, :focus, :blur]

  # Event Creation

  @doc """
  Creates a terminal event from type and data.

  ## Examples

      iex> UnifiedUi.Adapters.Terminal.Events.create_event(:click, %{widget_id: :btn})
      %{type: :click, data: %{widget_id: :btn}}

  """
  @spec create_event(event_type(), event_data()) :: event()
  def create_event(type, data) do
    %{type: type, data: data}
  end

  # Event-to-Signal Conversion

  @doc """
  Converts a terminal event to a JidoSignal.

  ## Parameters

  * `event_type` - The type of terminal event (:click, :change, :key_press, etc.)
  * `data` - Event payload data

  ## Options

  * `:source` - Override the default source (default: "/unified_ui/terminal")
  * `:subject` - Optional subject for the signal

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.to_signal(
        :click,
        %{widget_id: :submit_button, action: :submit_form}
      )

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.to_signal(
        :change,
        %{widget_id: :email_input, value: "user@example.com"}
      )

  """
  @spec to_signal(event_type(), event_data(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def to_signal(event_type, data, opts \\ [])

  # Click events → unified.button.clicked
  def to_signal(:click, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(:click, signal_data, source: signal_source(opts))
    end
  end

  # Change events → unified.input.changed
  def to_signal(:change, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(:change, signal_data, source: signal_source(opts))
    end
  end

  # Submit events → unified.form.submitted
  def to_signal(:submit, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(:submit, signal_data, source: signal_source(opts))
    end
  end

  # Key press events → unified.key.pressed
  def to_signal(:key_press, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_type = "unified.key.pressed"
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(signal_type, signal_data, source: signal_source(opts))
    end
  end

  # Mouse events → unified.mouse.{action}
  # Security: Validate action before string interpolation to prevent signal injection
  def to_signal(:mouse, %{action: action} = data, opts) do
    with :ok <- Security.validate_event_action(:mouse, action),
         :ok <- Security.validate_signal_payload(data) do
      signal_type = "unified.mouse.#{action}"
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(signal_type, signal_data, source: signal_source(opts))
    end
  end

  # Focus events → unified.element.focused
  def to_signal(:focus, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(:focus, signal_data, source: signal_source(opts))
    end
  end

  # Blur events → unified.element.blurred
  def to_signal(:blur, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :terminal})
      Signals.create(:blur, signal_data, source: signal_source(opts))
    end
  end

  # Signal Dispatch

  @doc """
  Creates and dispatches a terminal event as a JidoSignal.

  This is a convenience function that combines `to_signal/3` with dispatch.

  ## Parameters

  * `event_type` - The type of terminal event
  * `data` - Event payload data
  * `opts` - Options passed to signal creation. Supports `:component_id` for
    direct dispatch to a running `UnifiedUi.Agent` component.

  ## Returns

  `{:ok, signal}` on success, `{:error, reason}` on failure.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.dispatch(
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

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.button_click(
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

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.input_change(
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

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.form_submit(
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

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.key_press(:enter, [])

      {:ok, signal} = UnifiedUi.Adapters.Terminal.Events.key_press(:char, [?a])

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

  # Event Extraction from Render Tree

  @doc """
  Extracts event handlers from a TermUI render tree.

  This function traverses the render tree to find all widgets with event
  handlers (buttons, inputs, etc.) and returns a map of widget IDs to their
  handler configurations.

  ## Examples

      handlers = UnifiedUi.Adapters.Terminal.Events.extract_handlers(render_tree)
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
    Keyword.get(opts, :source, "/unified_ui/terminal")
  end
end
