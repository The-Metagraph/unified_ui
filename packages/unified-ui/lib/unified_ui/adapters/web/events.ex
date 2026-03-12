defmodule UnifiedUi.Adapters.Web.Events do
  @moduledoc """
  Event capture and signal dispatch for Web renderer.

  This module captures browser events via Phoenix LiveView (phx-click,
  phx-change, phx-submit, etc.) and converts them to JidoSignal messages
  for agent communication, using WebSocket for real-time updates.

  ## Event Flow

  ```
  Browser Event → LiveView phx-event → UnifiedUi Event → JidoSignal → Agent
  ```

  ## LiveView Event Mapping

  | LiveView Event | UnifiedUi Signal |
  |----------------|------------------|
  | `phx-click` | `unified.button.clicked` |
  | `phx-change` | `unified.input.changed` |
  | `phx-submit` | `unified.form.submitted` |
  | `phx-keydown` | `unified.key.pressed` |
  | `phx-keyup` | `unified.key.released` |
  | `phx-focus` | `unified.element.focused` |
  | `phx-blur` | `unified.element.blurred` |

  ## Signal Dispatch

  Dispatch signals to the JidoSignal bus:

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.dispatch(
        :click,
        %{widget_id: :my_button, action: :clicked}
      )

  ## Form Events

  Form submissions include all field values:

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.form_submit(
        :login_form,
        %{email: "user@example.com", password: "secret", remember_me: "true"}
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

  @typedoc "Web event type."
  @type event_type ::
          :click
          | :change
          | :key_press
          | :key_release
          | :focus
          | :blur
          | :hook

  @typedoc "Event payload data."
  @type event_data :: map()

  @typedoc "Web event."
  @type event :: %{type: event_type(), data: event_data()}

  # WebSocket Reconnection Constants

  @doc """
  Base reconnection delay in milliseconds.

  Used for exponential backoff when WebSocket connection is lost.
  """
  @spec base_reconnect_delay() :: pos_integer()
  def base_reconnect_delay, do: 1000

  @doc """
  Maximum reconnection delay in milliseconds.

  Caps the exponential backoff to avoid excessive delays.
  """
  @spec max_reconnect_delay() :: pos_integer()
  def max_reconnect_delay, do: 32_000

  @doc """
  Maximum number of reconnection attempts.

  After this many attempts, the connection is considered failed.
  """
  @spec max_reconnect_attempts() :: pos_integer()
  def max_reconnect_attempts, do: 10

  # Event Types

  @doc """
  Returns the list of supported web event types.

  ## Examples

      iex> UnifiedUi.Adapters.Web.Events.event_types()
      [:click, :change, :key_press, :key_release, :focus, :blur, :hook]

  """
  @spec event_types() :: [event_type()]
  def event_types, do: [:click, :change, :key_press, :key_release, :focus, :blur, :hook]

  # Event Creation

  @doc """
  Creates a web event from type and data.

  ## Examples

      iex> UnifiedUi.Adapters.Web.Events.create_event(:click, %{widget_id: :btn})
      %{type: :click, data: %{widget_id: :btn}}

  """
  @spec create_event(event_type(), event_data()) :: event()
  def create_event(type, data) do
    %{type: type, data: data}
  end

  # Event-to-Signal Conversion

  @doc """
  Converts a web event to a JidoSignal.

  ## Parameters

  * `event_type` - The type of web event (:click, :change, :key_press, etc.)
  * `data` - Event payload data

  ## Options

  * `:source` - Override the default source (default: "/unified_ui/web")
  * `:subject` - Optional subject for the signal

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.to_signal(
        :click,
        %{widget_id: :submit_button, action: :submit_form}
      )

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.to_signal(
        :change,
        %{widget_id: :email_input, value: "user@example.com"}
      )

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.to_signal(
        :hook,
        %{hook_name: :scroll_handler, data: %{scroll_top: 100}}
      )

  """
  @spec to_signal(event_type(), event_data(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def to_signal(event_type, data, opts \\ [])

  # Click events → unified.button.clicked
  def to_signal(:click, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(:click, signal_data, source: signal_source(opts))
    end
  end

  # Change events → unified.input.changed
  def to_signal(:change, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(:change, signal_data, source: signal_source(opts))
    end
  end

  # Submit events → unified.form.submitted
  def to_signal(:submit, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(:submit, signal_data, source: signal_source(opts))
    end
  end

  # Key press events → unified.key.pressed
  def to_signal(:key_press, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_type = "unified.key.pressed"
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(signal_type, signal_data, source: signal_source(opts))
    end
  end

  # Key release events → unified.key.released
  def to_signal(:key_release, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_type = "unified.key.released"
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(signal_type, signal_data, source: signal_source(opts))
    end
  end

  # Focus events → unified.element.focused
  def to_signal(:focus, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(:focus, signal_data, source: signal_source(opts))
    end
  end

  # Blur events → unified.element.blurred
  def to_signal(:blur, data, opts) do
    with :ok <- Security.validate_signal_payload(data) do
      signal_data = Map.merge(data, %{platform: :web})
      Signals.create(:blur, signal_data, source: signal_source(opts))
    end
  end

  # Hook events → unified.web.{hook_name}
  # Security: Validate hook_name against allowlist to prevent signal injection
  def to_signal(:hook, %{hook_name: hook_name} = data, opts) do
    # Only allow predefined hook names (no arbitrary strings)
    # Includes WebSocket lifecycle events and LiveView hook events
    allowed_hooks = [
      # LiveView hook events
      :scroll_handler,
      :resize_handler,
      :focus_handler,
      :blur_handler,
      :scroll_tracker,
      :resize_observer,
      :visibility_observer,
      # WebSocket lifecycle events
      :connecting,
      :connected,
      :disconnected,
      :reconnecting
    ]

    if hook_name in allowed_hooks do
      with :ok <- Security.validate_signal_payload(data) do
        signal_type = "unified.web.#{hook_name}"
        signal_data = Map.merge(data, %{platform: :web})
        Signals.create(signal_type, signal_data, source: signal_source(opts))
      end
    else
      {:error, :invalid_hook}
    end
  end

  # Signal Dispatch

  @doc """
  Creates and dispatches a web event as a JidoSignal.

  This is a convenience function that combines `to_signal/3` with dispatch.

  ## Parameters

  * `event_type` - The type of web event
  * `data` - Event payload data
  * `opts` - Options passed to signal creation. Supports `:component_id` for
    direct dispatch to a running `UnifiedUi.Agent` component.

  ## Returns

  `{:ok, signal}` on success, `{:error, reason}` on failure.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.dispatch(
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

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.button_click(
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

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.input_change(
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

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.form_submit(
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

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.key_press(:enter, [])

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.key_press(:char, [?a])

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.key_press(:s, [:ctrl])  # Ctrl+S

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

  @doc """
  Creates a key release event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.key_release(:enter, [])

  """
  @spec key_release(atom(), [atom()], keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def key_release(key, modifiers \\ [], opts \\ []) do
    to_signal(:key_release, %{key: key, modifiers: modifiers}, opts)
  end

  # Hook Event Helpers (LiveView JS Hooks)

  @doc """
  Creates a hook event signal for LiveView JS hooks.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.hook_event(
        :scroll_handler,
        %{scroll_top: 100, scroll_left: 0}
      )

  """
  @spec hook_event(atom(), map(), keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def hook_event(hook_name, data, opts \\ []) do
    to_signal(:hook, %{hook_name: hook_name, data: data}, opts)
  end

  # WebSocket Reconnection Events (for future GenServer)

  @doc """
  Creates a WebSocket connecting event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.ws_connecting()

  """
  @spec ws_connecting(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def ws_connecting(opts \\ []) do
    to_signal(:hook, %{hook_name: :connecting, data: %{}}, opts)
  end

  @doc """
  Creates a WebSocket connected event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.ws_connected()

  """
  @spec ws_connected(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def ws_connected(opts \\ []) do
    to_signal(:hook, %{hook_name: :connected, data: %{}}, opts)
  end

  @doc """
  Creates a WebSocket disconnected event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.ws_disconnected()

  """
  @spec ws_disconnected(keyword()) :: {:ok, Jido.Signal.t()} | {:error, term()}
  def ws_disconnected(opts \\ []) do
    to_signal(:hook, %{hook_name: :disconnected, data: %{}}, opts)
  end

  @doc """
  Creates a WebSocket reconnecting event signal.

  ## Examples

      {:ok, signal} = UnifiedUi.Adapters.Web.Events.ws_reconnecting(3, 2000)

  """
  @spec ws_reconnecting(pos_integer(), pos_integer(), keyword()) ::
          {:ok, Jido.Signal.t()} | {:error, term()}
  def ws_reconnecting(attempt, delay_ms, opts \\ []) do
    to_signal(
      :hook,
      %{hook_name: :reconnecting, data: %{attempt: attempt, delay_ms: delay_ms}},
      opts
    )
  end

  # Event Extraction from Render Tree

  @doc """
  Extracts event handlers from an HTML render tree.

  This function traverses the render tree to find all elements with event
  handlers (buttons, inputs, etc.) and returns a map of element IDs to their
  handler configurations.

  ## Examples

      handlers = UnifiedUi.Adapters.Web.Events.extract_handlers(render_tree)
      # => %{submit_button: %{on_click: :submit}, email_input: %{on_change: :update_email}}

  """
  @spec extract_handlers(term()) :: map()
  def extract_handlers(render_tree) do
    extract_handlers(render_tree, %{})
  end

  defp extract_handlers({:button, _attrs, metadata}, acc) do
    case metadata do
      %{on_click: action, id: id} when not is_nil(id) ->
        Map.put(acc, id, %{on_click: action})

      _ ->
        acc
    end
  end

  defp extract_handlers({:input, _attrs, metadata}, acc) do
    base =
      case metadata do
        %{id: id, on_change: change} when not is_nil(id) and not is_nil(change) ->
          %{on_change: change}

        %{id: id, on_input: input} when not is_nil(id) and not is_nil(input) ->
          %{on_input: input}

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

  defp extract_handlers({:form, _attrs, metadata}, acc) do
    case metadata do
      %{on_submit: action, id: id} when not is_nil(id) ->
        Map.put(acc, id, %{on_submit: action})

      _ ->
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

  defp extract_node_handlers(%{type: :input, props: props}) do
    cond do
      props[:on_change] -> %{on_change: props[:on_change]}
      props[:on_input] -> %{on_input: props[:on_input]}
      true -> nil
    end
  end

  defp extract_node_handlers(%{type: :form, props: props}) do
    case props[:on_submit] do
      # Skip forms without on_submit handler
      nil -> nil
      action -> %{on_submit: action}
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
    Keyword.get(opts, :source, "/unified_ui/web")
  end
end
