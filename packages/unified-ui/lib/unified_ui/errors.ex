defmodule UnifiedUi.Errors do
  @moduledoc """
  Custom error types for UnifiedUi.

  This module defines exception types used throughout the UnifiedUi library
  for consistent error handling and better debugging.

  ## Error Handling Strategy

  UnifiedUi follows Elixir conventions for error handling:

  * Use `{:ok, result}` and `{:error, reason}` tuples for expected failures
  * Raise exceptions for programmer errors or invalid arguments
  * Use custom exception types for domain-specific errors

  ## Usage

  For operations that may fail expectedly:
      case UnifiedUi.Signals.create(:name, payload) do
        {:ok, signal} -> # handle success
        {:error, reason} -> # handle error
      end

  For operations that should not fail in normal usage:
      signal = UnifiedUi.Signals.create!(:name, payload)

  ## Exception Types

  * `InvalidSignalError` - Raised when an invalid signal type is provided
  * `InvalidStyleError` - Raised when an invalid style attribute is provided
  * `DslError` - Raised for DSL-related errors
  """

  defmodule InvalidSignalError do
    @moduledoc """
    Exception raised when an invalid signal is provided.

    ## Fields

    * `:message` - Error message
    * `:signal_name` - The invalid signal name (atom or string)
    * `:signal_type` - The invalid signal type string (optional)

    ## Example

        raise UnifiedUi.Errors.InvalidSignalError,
          signal_name: :invalid,
          signal_type: "unified.invalid.action"
    """

    defexception [:message, :signal_name, :signal_type]

    @impl true
    @spec exception(keyword()) :: %__MODULE__{}
    def exception(opts) do
      signal_name = Keyword.get(opts, :signal_name)
      signal_type = Keyword.get(opts, :signal_type)

      message = build_message(signal_name, signal_type)

      %__MODULE__{
        message: message,
        signal_name: signal_name,
        signal_type: signal_type
      }
    end

    @impl true
    @spec message(%__MODULE__{}) :: String.t()
    def message(%__MODULE__{} = exception), do: exception.message

    defp build_message(nil, nil), do: "Invalid signal"

    defp build_message(signal_name, nil) when is_atom(signal_name) do
      "Invalid signal name: #{inspect(signal_name)}"
    end

    defp build_message(signal_name, signal_type)
         when is_atom(signal_name) and is_binary(signal_type) do
      "Invalid signal: #{inspect(signal_name)} (type: #{signal_type})"
    end

    defp build_message(signal_name, signal_type) do
      "Invalid signal: #{inspect(signal_name)} (type: #{inspect(signal_type)})"
    end
  end

  defmodule InvalidStyleError do
    @moduledoc """
    Exception raised when an invalid style attribute is provided.

    ## Fields

    * `:message` - Error message
    * `:style_field` - The invalid style field name
    * `:value` - The invalid value provided

    ## Example

        raise UnifiedUi.Errors.InvalidStyleError,
          style_field: :fg,
          value: :invalid_color
    """

    defexception [:message, :style_field, :value]

    @impl true
    @spec exception(keyword()) :: %__MODULE__{}
    def exception(opts) do
      style_field = Keyword.get(opts, :style_field)
      value = Keyword.get(opts, :value)

      message =
        case {style_field, value} do
          {nil, nil} -> "Invalid style attribute"
          {field, nil} -> "Invalid style field: #{inspect(field)}"
          {field, val} -> "Invalid style value for #{inspect(field)}: #{inspect(val)}"
        end

      %__MODULE__{
        message: message,
        style_field: style_field,
        value: value
      }
    end

    @impl true
    @spec message(%__MODULE__{}) :: String.t()
    def message(%__MODULE__{} = exception), do: exception.message
  end

  defmodule DslError do
    @moduledoc """
    Exception raised for DSL-related errors.

    ## Fields

    * `:message` - Error message
    * `:dsl_entity` - The DSL entity that caused the error (optional)
    * `:reason` - The specific reason for the error (optional)

    ## Example

        raise UnifiedUi.Errors.DslError,
          dsl_entity: :state,
          reason: "Invalid attribute type"
    """

    defexception [:message, :dsl_entity, :reason]

    @impl true
    @spec exception(keyword()) :: %__MODULE__{}
    def exception(opts) do
      dsl_entity = Keyword.get(opts, :dsl_entity)
      reason = Keyword.get(opts, :reason)

      message =
        case {dsl_entity, reason} do
          {nil, nil} -> "DSL error"
          {entity, nil} -> "DSL error in entity: #{inspect(entity)}"
          {entity, rsn} -> "DSL error in #{inspect(entity)}: #{rsn}"
          {nil, rsn} -> "DSL error: #{rsn}"
        end

      %__MODULE__{
        message: message,
        dsl_entity: dsl_entity,
        reason: reason
      }
    end

    @impl true
    @spec message(%__MODULE__{}) :: String.t()
    def message(%__MODULE__{} = exception), do: exception.message
  end

  @doc """
  Normalizes an error value into a consistent format.

  ## Examples

      iex> UnifiedUi.Errors.normalize({:error, :not_found})
      {:error, :not_found}

      iex> UnifiedUi.Errors.normalize(:not_found)
      {:error, :not_found}

      iex> match?({:error, %ArgumentError{}}, UnifiedUi.Errors.normalize(%ArgumentError{}))
      true
  """
  @spec normalize(term()) :: {:error, term()}
  def normalize({:error, _reason} = error), do: error
  def normalize(reason), do: {:error, reason}
end
