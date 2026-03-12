defmodule UnifiedUi.Adapters.Event do
  @moduledoc """
  Event-to-signal conversion utilities for platform renderers.

  This module provides helpers for converting platform-specific events
  into JidoSignal format for the unified event system.

  ## Event Types

  Platform events typically include:
  * Click events (button presses, taps)
  * Change events (text input changes, selection changes)
  * Submit events (form submissions, enter key)
  * Focus events (focus gained/lost)
  * Keyboard events (key press, release)
  * Mouse events (movement, clicks, scroll)

  ## Signal Format

  Signals follow this format:
  `{:signal_name, %{metadata: ..., payload: ...}}`

  ## Examples

  Convert a click event:

      iex> Event.to_signal(:click, :submit_button, %{timestamp: 123})
      {:click, %{element_id: :submit_button, timestamp: 123}}

  Convert a change event with payload:

      iex> Event.to_signal(:change, :email_input, %{value: "user@example.com"})
      {:change, %{element_id: :email_input, value: "user@example.com"}}

  Dispatch a signal:

      iex> Event.dispatch(signal, target_pid)
      :ok

  """

  alias UnifiedIUR.Element

  @type event_type :: :click | :change | :submit | :focus | :blur | :key_down | :key_up | :mouse_move | :scroll
  @type element_id :: atom()
  @type event_payload :: map()
  @type signal :: {atom(), map()}
  @type element :: UnifiedUi.Renderer.iur_element()

  @doc """
  Converts a platform event to a signal tuple.

  The signal format is: `{signal_name, metadata_map}`

  ## Parameters

  * `event_type` - The type of event (:click, :change, :submit, etc.)
  * `element_id` - The ID of the element that generated the event
  * `payload` - Additional event data (coordinates, values, etc.)

  ## Returns

  A signal tuple: `{signal_name, %{element_id: ..., ...payload}}`

  ## Examples

      iex> to_signal(:click, :submit_button, %{})
      {:click, %{element_id: :submit_button}}

      iex> to_signal(:change, :email_input, %{value: "new@email.com"})
      {:change, %{element_id: :email_input, value: "new@email.com"}}

      iex> to_signal(:key_down, :main, %{key: :enter, ctrl: true})
      {:key_down, %{element_id: :main, key: :enter, ctrl: true}}

  """
  @spec to_signal(event_type(), element_id(), event_payload()) :: signal()
  def to_signal(event_type, element_id, payload \\ %{}) when is_atom(event_type) and is_atom(element_id) do
    metadata = Map.put(payload, :element_id, element_id)
    {event_type, metadata}
  end

  @doc """
  Extracts the signal handler from an IUR element's metadata.

  For example, a button might have `on_click: :submit` in its metadata.
  This function extracts that handler for use in event dispatch.

  ## Parameters

  * `element` - The IUR element
  * `event_type` - The event type to look for (:click, :change, :submit)

  ## Returns

  * `{:ok, handler}` - Handler found (atom, tuple, or MFA)
  * `:error` - No handler for this event type

  ## Examples

      iex> get_handler(%Button{on_click: :submit}, :click)
      {:ok, :submit}

      iex> get_handler(%Button{on_click: :submit}, :change)
      :error

      iex> get_handler(%TextInput{on_change: {:value_changed, %{field: :email}}}, :change)
      {:ok, {:value_changed, %{field: :email}}}

  """
  @spec get_handler(element(), atom()) :: {:ok, term()} | :error
  def get_handler(element, event_type) when is_atom(event_type) do
    metadata = Element.metadata(element)

    handler_key = case event_type do
      :click -> :on_click
      :change -> :on_change
      :submit -> :on_submit
      :focus -> :on_focus
      :blur -> :on_blur
      _ -> nil
    end

    if handler_key do
      case Map.get(metadata, handler_key) do
        nil -> :error
        handler -> {:ok, handler}
      end
    else
      :error
    end
  end

  @doc """
  Builds a complete signal from an IUR element and event payload.

  This combines:
  1. Extracting the handler from the element's metadata
  2. Converting the platform event to a signal format
  3. Including the element ID and any additional payload

  ## Parameters

  * `element` - The IUR element
  * `event_type` - The type of event
  * `payload` - Additional event data

  ## Returns

  * `{:ok, signal}` - Signal built successfully
  * `:error` - No handler for this event type

  ## Examples

      iex> build_signal(button, :click, %{timestamp: 123})
      {:ok, {:submit, %{element_id: :submit_button, timestamp: 123}}}

      iex> build_signal(text_input, :change, %{value: "test"})
      {:ok, {:value_changed, %{element_id: :email, value: "test"}}}

  """
  @spec build_signal(element(), event_type(), event_payload()) :: {:ok, signal()} | :error
  def build_signal(element, event_type, payload \\ %{}) do
    with {:ok, handler} <- get_handler(element, event_type),
         metadata <- Element.metadata(element),
         element_id when not is_nil(element_id) <- Map.get(metadata, :id) do

      # Merge element_id into payload
      full_payload = Map.put(payload, :element_id, element_id)

      # Build signal based on handler type
      signal = case handler do
        signal_name when is_atom(signal_name) ->
          {signal_name, full_payload}

        {signal_name, extra_payload} when is_atom(signal_name) and is_map(extra_payload) ->
          {signal_name, Map.merge(full_payload, extra_payload)}

        {module, function, args} when is_atom(module) and is_atom(function) and is_list(args) ->
          {:mfa_call, %{module: module, function: function, args: args, context: full_payload}}
      end

      {:ok, signal}
    else
      nil -> :error  # element_id was nil
      _ -> :error
    end
  end

  @doc """
  Normalizes a signal payload to ensure consistent structure.

  All signals should have an `:element_id` key. This function ensures
  that's present and adds a timestamp if not present.

  ## Parameters

  * `payload` - The signal payload to normalize

  ## Returns

  A normalized payload map.

  ## Examples

      iex> normalize_payload(%{element_id: :button, value: "test"})
      %{element_id: :button, value: "test", timestamp: _}

      iex> normalize_payload(%{value: "test"})
      %{element_id: :unknown, value: "test", timestamp: _}

  """
  @spec normalize_payload(map()) :: map()
  def normalize_payload(payload) when is_map(payload) do
    payload
    |> Map.put_new(:element_id, :unknown)
    |> Map.put_new(:timestamp, System.monotonic_time(:millisecond))
  end

  @doc """
  Dispatches a signal to a target process.

  ## Parameters

  * `signal` - The signal tuple to dispatch
  * `target` - The PID or registered name to send to

  ## Returns

  * `:ok` - Signal sent successfully
  * `{:error, reason}` - Send failed

  ## Examples

      iex> dispatch({:submit, %{element_id: :button}}, self())
      :ok

      iex> dispatch({:submit, %{element_id: :button}}, :nonexistent)
      {:error, :noproc}

  """
  @spec dispatch(signal(), pid() | atom()) :: :ok | {:error, term()}
  def dispatch(signal, target) when is_tuple(signal) do
    send(target, signal)
    :ok
  rescue
    ArgumentError -> {:error, :invalid_target}
  end

  @doc """
  Dispatches a signal to multiple targets.

  ## Parameters

  * `signal` - The signal tuple to dispatch
  * `targets` - List of PIDs or registered names

  ## Returns

  * `{:ok, successful_count}` - Number of successful dispatches
  * `{:error, failed_count}` - Number of failed dispatches

  ## Examples

      iex> broadcast({:update, %{data: 1}}, [pid1, pid2, pid3])
      {:ok, 3}

  """
  @spec broadcast(signal(), [pid() | atom()]) :: {:ok, non_neg_integer()} | {:error, non_neg_integer()}
  def broadcast(signal, targets) when is_list(targets) do
    results = Enum.map(targets, fn target ->
      dispatch(signal, target)
    end)

    successes = Enum.count(results, &(&1 == :ok))

    if successes == length(targets) do
      {:ok, successes}
    else
      {:error, length(targets) - successes}
    end
  end

  @doc """
  Creates a signal dispatcher function for a specific event type.

  Returns a function that can be used as an event handler callback.

  ## Parameters

  * `element` - The IUR element
  * `event_type` - The type of event to handle

  ## Returns

  A function that takes a payload and returns a signal.

  ## Examples

      iex> dispatcher = Event.dispatcher(button, :click)
      iex> dispatcher.(%{timestamp: 123})
      {:submit, %{element_id: :button, timestamp: 123}}

  """
  @spec dispatcher(element(), event_type()) :: (event_payload() -> signal() | nil)
  def dispatcher(element, event_type) do
    fn payload ->
      case build_signal(element, event_type, payload) do
        {:ok, signal} -> signal
        :error -> nil
      end
    end
  end

  @doc """
  Validates a signal tuple has the correct structure.

  ## Parameters

  * `signal` - The signal to validate

  ## Returns

  * `:ok` - Signal is valid
  * `{:error, reason}` - Signal is invalid

  ## Examples

      iex> validate_signal({:click, %{element_id: :button}})
      :ok

      iex> validate_signal({:click, %{}})
      {:error, :missing_element_id}

      iex> :invalid_signal
      {:error, :invalid_format}

  """
  @spec validate_signal(term()) :: :ok | {:error, atom()}
  def validate_signal(signal)

  def validate_signal({signal_name, payload}) when is_atom(signal_name) and is_map(payload) do
    if Map.has_key?(payload, :element_id) do
      :ok
    else
      {:error, :missing_element_id}
    end
  end

  def validate_signal(_), do: {:error, :invalid_format}

  @doc """
  Extracts common event metadata from a platform event.

  Platform events often have different structures. This function
  normalizes common fields like coordinates, modifiers, and timestamps.

  ## Parameters

  * `platform_event` - The raw platform event map

  ## Returns

  A normalized metadata map.

  ## Examples

      iex> extract_metadata(%{x: 10, y: 20, ctrl: true, time: 123456})
      %{x: 10, y: 20, ctrl: true, timestamp: 123456}

  """
  @spec extract_metadata(map()) :: map()
  def extract_metadata(platform_event) when is_map(platform_event) do
    %{}
    |> maybe_put(platform_event, :x)
    |> maybe_put(platform_event, :y)
    |> maybe_put(platform_event, :ctrl, [:control, :ctrl])
    |> maybe_put(platform_event, :alt, [:modifier_alt, :alt])
    |> maybe_put(platform_event, :shift, [:modifier_shift, :shift])
    |> maybe_put(platform_event, :meta, [:modifier_meta, :meta])
    |> maybe_put(platform_event, :timestamp, [:time, :timestamp_ms, :ms])
  end

  # Private helpers

  defp maybe_put(acc, source, key) do
    maybe_put(acc, source, key, key)
  end

  defp maybe_put(acc, source, target_key, source_keys) when is_list(source_keys) do
    case Enum.find_value(source_keys, fn source_key ->
      case Map.fetch(source, source_key) do
        {:ok, value} -> {:found, Map.put(acc, target_key, value)}
        :error -> nil
      end
    end) do
      {:found, result} -> result
      _ -> acc
    end
  end

  defp maybe_put(acc, source, target_key, source_key) do
    case Map.fetch(source, source_key) do
      {:ok, value} -> Map.put(acc, target_key, value)
      :error -> acc
    end
  end
end
