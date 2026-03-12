defmodule UnifiedUi.Signals do
  @moduledoc """
  Signal helpers and utilities for UnifiedUi.

  This module provides helper functions for working with Jido.Signal,
  including standard signal type definitions and convenience functions
  for creating common UI signals.

  ## Standard Signal Types

  The following standard signal types are pre-defined:

  | Name | Type | Description |
  |------|------|-------------|
  | `:click` | `"unified.button.clicked"` | Button/element clicked |
  | `:change` | `"unified.input.changed"` | Input value changed |
  | `:submit` | `"unified.form.submitted"` | Form submitted |
  | `:focus` | `"unified.element.focused"` | Element gained focus |
  | `:blur` | `"unified.element.blurred"` | Element lost focus |
  | `:select` | `"unified.item.selected"` | Item selected |

  ## Creating Signals

  Create a Jido.Signal directly or use the helper functions:

      # Create directly with Jido.Signal
      {:ok, signal} = Jido.Signal.new(
        type: "unified.button.clicked",
        data: %{button_id: :my_btn},
        source: "/unified_ui"
      )

      # Or use the helper
      {:ok, signal} = UnifiedUi.Signals.create(:click, %{button_id: :my_btn})

  ## Signal Naming Convention

  Signal types follow the JidoSignal pattern:
  ```
  <domain>.<entity>.<action>[.<qualifier>]
  ```

  For UnifiedUi signals, use `"unified"` as the domain:
  - `"unified.button.clicked"`
  - `"unified.input.changed"`
  - `"unified.form.submitted"`
  """

  alias Jido.Signal

  @typedoc "Signal name atom."
  @type signal_name :: atom()

  @typedoc "Signal type string (JidoSignal format)."
  @type signal_type :: String.t()

  @typedoc "Signal payload data."
  @type payload :: map()

  @doc """
  Returns the list of standard signal names.

  ## Examples

      iex> UnifiedUi.Signals.standard_signals()
      [:click, :change, :submit, :focus, :blur, :select]
  """
  @spec standard_signals() :: [signal_name()]
  def standard_signals, do: [:click, :change, :submit, :focus, :blur, :select]

  @doc """
  Gets the signal type string for a standard signal name.

  ## Examples

      iex> UnifiedUi.Signals.signal_type(:click)
      "unified.button.clicked"

      iex> UnifiedUi.Signals.signal_type(:unknown)
      {:error, :unknown_signal}
  """
  @spec signal_type(signal_name()) :: signal_type() | {:error, atom()}
  def signal_type(:click), do: "unified.button.clicked"
  def signal_type(:change), do: "unified.input.changed"
  def signal_type(:submit), do: "unified.form.submitted"
  def signal_type(:focus), do: "unified.element.focused"
  def signal_type(:blur), do: "unified.element.blurred"
  def signal_type(:select), do: "unified.item.selected"
  def signal_type(_name), do: {:error, :unknown_signal}

  @doc """
  Creates a Jido.Signal from a standard signal name with payload.

  ## Options

  * `:source` - Override the default source (default: "/unified_ui")
  * `:subject` - Optional subject for the signal
  * `:id` - Custom signal ID (default: auto-generated UUID)

  ## Examples

      iex> {:ok, signal} = UnifiedUi.Signals.create(:click, %{button_id: :my_btn})
      iex> signal.type
      "unified.button.clicked"
      iex> signal.data
      %{button_id: :my_btn}

      iex> {:ok, signal} = UnifiedUi.Signals.create(
      ...>   :submit,
      ...>   %{form_id: :login_form},
      ...>   source: "/my/app"
      ...> )
      iex> signal.type
      "unified.form.submitted"
      iex> signal.source
      "/my/app"
      iex> signal.data
      %{form_id: :login_form}

      iex> UnifiedUi.Signals.create(:unknown, %{})
      {:error, :unknown_signal}

  For custom signal types, use `Jido.Signal.new/1` directly:

      {:ok, signal} = Jido.Signal.new(
        type: "myapp.custom.event",
        data: %{value: 123},
        source: "/my/app"
      )
  """
  @spec create(signal_name() | signal_type(), payload(), keyword()) ::
          {:ok, Signal.t()} | {:error, term()}
  def create(name, payload \\ %{}, opts \\ [])

  def create(name, payload, opts) when is_atom(name) do
    case signal_type(name) do
      {:error, _} = error -> error
      type when is_binary(type) -> do_create(type, payload, opts)
    end
  end

  def create(type, payload, opts) when is_binary(type) do
    do_create(type, payload, opts)
  end

  @doc """
  Creates a signal, raising on error.

  ## Examples

      iex> signal = UnifiedUi.Signals.create!(:click, %{button_id: :my_btn})
      iex> signal.type
      "unified.button.clicked"

      iex> UnifiedUi.Signals.create!(:unknown, %{})
      ** (UnifiedUi.Errors.InvalidSignalError) Invalid signal name: :unknown

  Will raise `UnifiedUi.Errors.InvalidSignalError` if the signal name is invalid.
  """
  @spec create!(signal_name() | signal_type(), payload(), keyword()) :: Signal.t()
  def create!(name, payload \\ %{}, opts \\ [])

  def create!(name, payload, opts) when is_atom(name) do
    case create(name, payload, opts) do
      {:ok, signal} ->
        signal

      {:error, _reason} ->
        raise UnifiedUi.Errors.InvalidSignalError, signal_name: name
    end
  end

  def create!(type, payload, opts) when is_binary(type) do
    case create(type, payload, opts) do
      {:ok, signal} ->
        signal

      {:error, _reason} ->
        raise UnifiedUi.Errors.InvalidSignalError, signal_type: type
    end
  end

  defp do_create(type, payload, opts) do
    source = Keyword.get(opts, :source, "/unified_ui")
    subject = Keyword.get(opts, :subject)
    custom_id = Keyword.get(opts, :id)

    base_attrs = %{
      type: type,
      data: payload,
      source: source
    }

    base_attrs =
      if subject, do: Map.put(base_attrs, :subject, subject), else: base_attrs

    base_attrs =
      if custom_id, do: Map.put(base_attrs, :id, custom_id), else: base_attrs

    Signal.new(base_attrs)
  end

  @doc """
  Validates if the given signal type string is valid.

  Valid types follow the format "domain.entity.action".

  ## Examples

      iex> UnifiedUi.Signals.valid_type("unified.button.clicked")
      :ok

      iex> UnifiedUi.Signals.valid_type("invalid")
      {:error, :invalid_type_format}
  """
  @spec valid_type(String.t() | any()) :: :ok | {:error, atom()}
  def valid_type(type) when is_binary(type) do
    case String.split(type, ".") do
      parts when length(parts) >= 3 ->
        if Enum.all?(parts, &valid_signal_part?/1) do
          :ok
        else
          {:error, :invalid_type_format}
        end

      _ ->
        {:error, :invalid_type_format}
    end
  end

  def valid_type(_), do: {:error, :invalid_type_format}

  # Validates that a signal type part (between dots) is valid
  defp valid_signal_part?(part) do
    String.length(part) > 0 and Regex.match?(~r/^[a-z][a-z0-9_]*$/, part)
  end
end
