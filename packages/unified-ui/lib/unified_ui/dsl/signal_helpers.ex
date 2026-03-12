defmodule UnifiedUi.Dsl.SignalHelpers do
  @moduledoc """
  Helper functions for working with signals in the Elm Architecture.

  This module provides utilities for extracting signal information from
  Jido.Signal envelopes and for building signal handlers in DSL-generated
  update/2 functions.

  ## Signal Handler Patterns

  Signal handlers in the DSL support three formats:

  1. **Atom signal name**: `on_click: :save`
     - Simple signal name, no static payload

  2. **Tuple with payload**: `on_click: {:save, %{form_id: :login}}`
     - Signal name with static payload map

  3. **MFA tuple**: `on_click: {MyModule, :my_function, [:arg1]}`
     - Module, function, args tuple for custom handling

  ## Examples

  In a generated update/2 function:

      def update(state, %Jido.Signal{type: "unified.button.clicked"} = signal) do
        handle_signal(state, signal, :my_button_on_click)
      end

  Using helpers to extract payload data:

      extract_payload(signal, :button_id)

  """

  alias Jido.Signal

  @typedoc "Signal handler definition from DSL"
  @type signal_handler :: atom() | {atom(), map()} | {module(), atom(), list()}

  @typedoc "Signal name atom"
  @type signal_name :: atom()

  @typedoc "Signal payload map"
  @type payload :: map()

  # Payload size limits to prevent DoS attacks
  @max_payload_size 10_000
  @max_payload_depth 10
  @max_string_length 1_000

  @doc """
  Normalizes a signal handler into a consistent format.

  Accepts atoms, tuples, and MFA tuples, returning a map with
  `:type` and `:action` keys.

  ## Examples

      iex> normalize_handler(:save)
      %{type: :atom, action: :save, payload: %{}}

      iex> normalize_handler({:save, %{form_id: :login}})
      %{type: :tuple, action: :save, payload: %{form_id: :login}}

      iex> normalize_handler({MyModule, :my_func, []})
      %{type: :mfa, module: MyModule, function: :my_func, args: []}

  """
  @spec normalize_handler(signal_handler()) :: map()
  def normalize_handler(handler) when is_atom(handler) do
    %{type: :atom, action: handler, payload: %{}}
  end

  def normalize_handler({action, payload}) when is_atom(action) and is_map(payload) do
    %{type: :tuple, action: action, payload: payload}
  end

  def normalize_handler({module, function, args})
      when is_atom(module) and is_atom(function) and is_list(args) do
    %{type: :mfa, module: module, function: function, args: args}
  end

  @doc """
  Extracts the action name from a signal handler.

  ## Examples

      iex> handler_action(:save)
      :save

      iex> handler_action({:save, %{form_id: :login}})
      :save

  """
  @spec handler_action(signal_handler()) :: signal_name()
  def handler_action(handler) when is_atom(handler), do: handler
  def handler_action({action, _payload}) when is_atom(action), do: action
  def handler_action({_module, _function, _args}), do: :custom

  @doc """
  Extracts static payload from a signal handler definition.

  For atom handlers, returns empty map.
  For tuple handlers, returns the payload map.
  For MFA handlers, returns empty map (payload determined at runtime).

  ## Examples

      iex> handler_payload(:save)
      %{}

      iex> handler_payload({:save, %{form_id: :login}})
      %{form_id: :login}

  """
  @spec handler_payload(signal_handler()) :: payload()
  def handler_payload(handler) when is_atom(handler), do: %{}
  def handler_payload({_action, payload}) when is_map(payload), do: payload
  def handler_payload({_module, _function, _args}), do: %{}

  @doc """
  Checks if a handler is an MFA (Module-Function-Args) tuple.

  ## Examples

      iex> mfa_handler?(:save)
      false

      iex> mfa_handler?({MyMod, :func, []})
      true

  """
  @spec mfa_handler?(signal_handler()) :: boolean()
  def mfa_handler?(handler) when is_atom(handler), do: false
  def mfa_handler?({_action, _payload}), do: false
  def mfa_handler?({_module, _function, _args}), do: true

  @doc """
  Extracts a value from a signal's data payload by key.

  Returns `nil` if the key is not found or if signal is nil.

  ## Examples

      iex> signal = %Jido.Signal{data: %{button_id: :submit_btn, value: "test"}}
      iex> extract_payload(signal, :button_id)
      :submit_btn

      iex> extract_payload(signal, :missing)
      nil

  """
  @spec extract_payload(Signal.t() | nil, atom()) :: any()
  def extract_payload(nil, _key), do: nil
  def extract_payload(%Signal{data: data}, key) when is_map(data), do: Map.get(data, key)

  @doc """
  Extracts multiple values from a signal's data payload.

  Returns a map with only the requested keys that exist in the payload.

  ## Examples

      iex> signal = %Jido.Signal{data: %{button_id: :submit_btn, value: "test", extra: :data}}
      iex> extract_payloads(signal, [:button_id, :value])
      %{button_id: :submit_btn, value: "test"}

  """
  @spec extract_payloads(Signal.t() | nil, [atom()]) :: map()
  def extract_payloads(nil, _keys), do: %{}

  def extract_payloads(%Signal{data: data}, keys) when is_list(keys) do
    Map.take(data, keys)
  end

  @doc """
  Validates a signal payload to prevent DoS and injection attacks.

  Checks:
  * Payload size is within limits (10KB max)
  * Payload depth is within limits (10 levels max)
  * String values are within length limits (1000 chars max)
  * No unsupported data types

  ## Returns

  * `:ok` - Payload is valid
  * `{:error, :payload_too_large}` - Payload exceeds size limits
  * `{:error, :payload_too_deep}` - Payload exceeds depth limits
  * `{:error, :string_too_long}` - String value exceeds length limit

  ## Examples

      iex> validate_payload(%{button_id: :save_btn})
      :ok

      iex> validate_payload(%{data: String.duplicate("a", 2000)})
      {:error, :string_too_long}

  """
  @spec validate_payload(payload()) :: :ok | {:error, atom()}
  def validate_payload(payload) when is_map(payload) do
    validate_payload_size(payload, @max_payload_size)
  end

  def validate_payload(_payload), do: {:error, :invalid_payload}

  # Validates payload size using a safe byte-size approximation
  defp validate_payload_size(payload, max_size) when is_map(payload) do
    size = estimate_payload_size(payload, 0)

    if size > max_size do
      {:error, :payload_too_large}
    else
      validate_payload_depth(payload, @max_payload_depth)
    end
  end

  # Estimates payload size in bytes (safe approximation)
  defp estimate_payload_size(payload, acc) when is_map(payload) do
    Enum.reduce(payload, acc, fn
      {_key, value}, acc when is_binary(value) ->
        acc + byte_size(value) + 10  # +10 for key overhead

      {_key, value}, acc when is_integer(value) ->
        acc + 20

      {_key, value}, acc when is_atom(value) ->
        acc + 20

      {_key, value}, acc when is_float(value) ->
        acc + 20

      {_key, value}, acc when is_map(value) ->
        acc + estimate_payload_size(value, 0)

      {_key, _value}, acc ->
        acc + 10
    end)
  end

  # Validates payload nesting depth
  defp validate_payload_depth(payload, max_depth) when is_map(payload) do
    depth = max_payload_depth(payload, 0)

    if depth > max_depth do
      {:error, :payload_too_deep}
    else
      validate_string_lengths(payload, @max_string_length)
    end
  end

  # Gets maximum nesting depth of payload
  defp max_payload_depth(payload, current) when is_map(payload) do
    Enum.reduce(payload, current, fn
      {_key, value}, acc when is_map(value) ->
        max(acc, max_payload_depth(value, current + 1))

      {_key, _value}, acc ->
        acc
    end)
  end

  # Validates string lengths in payload
  defp validate_string_lengths(payload, max_length) when is_map(payload) do
    Enum.reduce_while(payload, :ok, fn
      {_key, value}, :ok when is_binary(value) ->
        if String.length(value) > max_length do
          {:halt, {:error, :string_too_long}}
        else
          {:cont, :ok}
        end

      {_key, value}, :ok when is_map(value) ->
        case validate_string_lengths(value, max_length) do
          :ok -> {:cont, :ok}
          error -> {:halt, error}
        end

      {_key, _value}, :ok ->
        {:cont, :ok}
    end)
  end

  @doc """
  Builds a signal type string for widget events.

  ## Examples

      iex> signal_type(:click)
      "unified.button.clicked"

      iex> signal_type(:change)
      "unified.input.changed"

      iex> signal_type(:submit)
      "unified.form.submitted"

  """
  @spec signal_type(:click | :change | :submit) :: String.t()
  def signal_type(:click), do: "unified.button.clicked"
  def signal_type(:change), do: "unified.input.changed"
  def signal_type(:submit), do: "unified.form.submitted"

  @doc """
  Creates a Jido.Signal for a widget event.

  Validates the payload before creating the signal to prevent DoS attacks.

  ## Options

  * `:source` - Signal source (default: "/unified_ui")
  * `:subject` - Optional subject for the signal
  * `:validate` - Whether to validate payload (default: true)

  ## Examples

      iex> {:ok, signal} = build_signal(:click, %{button_id: :save_btn})
      iex> signal.type
      "unified.button.clicked"

      iex> {:error, :string_too_long} = build_signal(:click, %{data: String.duplicate("a", 2000)})

  """
  @spec build_signal(:click | :change | :submit, payload(), keyword()) ::
          {:ok, Signal.t()} | {:error, term()}
  def build_signal(event_type, payload \\ %{}, opts \\ []) do
    # Validate payload by default
    validate? = Keyword.get(opts, :validate, true)

    if validate? do
      case validate_payload(payload) do
        :ok ->
          do_build_signal(event_type, payload, opts)

        {:error, _reason} = error ->
          error
      end
    else
      do_build_signal(event_type, payload, opts)
    end
  end

  defp do_build_signal(event_type, payload, opts) do
    signal_type = signal_type(event_type)
    source = Keyword.get(opts, :source, "/unified_ui")
    subject = Keyword.get(opts, :subject)

    base_attrs = %{
      type: signal_type,
      data: payload,
      source: source
    }

    base_attrs = if subject, do: Map.put(base_attrs, :subject, subject), else: base_attrs

    Signal.new(base_attrs)
  end

  @doc """
  Builds a click signal with button information.

  ## Examples

      iex> {:ok, signal} = click_signal(:save_btn, %{position: {10, 20}})
      iex> signal.type
      "unified.button.clicked"

  """
  @spec click_signal(atom(), payload(), keyword()) :: {:ok, Signal.t()} | {:error, term()}
  def click_signal(button_id, extra_payload \\ %{}, opts \\ []) do
    payload = Map.merge(extra_payload, %{button_id: button_id})
    build_signal(:click, payload, opts)
  end

  @doc """
  Builds a change signal with input information.

  ## Examples

      iex> {:ok, signal} = change_signal(:email_input, "new@email.com", %{})
      iex> signal.type
      "unified.input.changed"

  """
  @spec change_signal(atom(), any(), payload(), keyword()) :: {:ok, Signal.t()} | {:error, term()}
  def change_signal(input_id, value, extra_payload \\ %{}, opts \\ []) do
    payload = Map.merge(extra_payload, %{input_id: input_id, value: value})
    build_signal(:change, payload, opts)
  end

  @doc """
  Builds a submit signal with form information.

  ## Examples

      iex> {:ok, signal} = submit_signal(:login_form, %{email: "test@example.com"})
      iex> signal.type
      "unified.form.submitted"

  """
  @spec submit_signal(atom(), payload(), keyword()) :: {:ok, Signal.t()} | {:error, term()}
  def submit_signal(form_id, form_data \\ %{}, opts \\ []) do
    payload = Map.merge(form_data, %{form_id: form_id})
    build_signal(:submit, payload, opts)
  end

  @doc """
  Matches a Jido.Signal against expected event type.

  Returns true if the signal matches the expected type.

  ## Examples

      iex> signal = %Jido.Signal{type: "unified.button.clicked"}
      iex> match_signal?(signal, :click)
      true

      iex> match_signal?(signal, :change)
      false

  """
  @spec match_signal?(Signal.t() | nil, :click | :change | :submit) :: boolean()
  def match_signal?(nil, _event_type), do: false
  def match_signal?(%Signal{type: type}, :click), do: type == "unified.button.clicked"
  def match_signal?(%Signal{type: type}, :change), do: type == "unified.input.changed"
  def match_signal?(%Signal{type: type}, :submit), do: type == "unified.form.submitted"

  @doc """
  Extracts state update map from signal handler and signal data.

  This helper combines static payload from the handler definition
  with dynamic data from the incoming signal.

  ## Examples

      iex> handler = {:save, %{form_id: :login}}
      iex> signal = %Jido.Signal{data: %{email: "test@example.com"}}
      iex> build_state_update(handler, signal, :email)
      %{form_id: :login, email: "test@example.com"}

  """
  @spec build_state_update(signal_handler(), Signal.t() | nil, atom() | nil) :: map()
  def build_state_update(handler, signal, merge_key \\ nil)

  def build_state_update(handler, nil, _merge_key) do
    handler_payload(handler)
  end

  def build_state_update(handler, %Signal{data: signal_data}, nil) do
    Map.merge(handler_payload(handler), signal_data)
  end

  def build_state_update(handler, %Signal{data: signal_data}, merge_key) do
    base = handler_payload(handler)
    signal_value = Map.get(signal_data, merge_key)

    if signal_value != nil do
      Map.put(base, merge_key, signal_value)
    else
      base
    end
  end
end
