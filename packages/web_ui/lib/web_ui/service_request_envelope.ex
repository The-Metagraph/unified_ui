defmodule WebUi.ServiceRequestEnvelope do
  @moduledoc """
  Typed request envelope for runtime authority dispatch.
  """

  alias WebUi.RuntimeContext
  alias WebUi.TypedError

  @enforce_keys [:service, :operation, :context, :payload]
  defstruct [:service, :operation, :context, :headers, :payload, :metadata]

  @type t :: %__MODULE__{
          service: String.t(),
          operation: String.t(),
          context: RuntimeContext.t(),
          headers: map() | nil,
          payload: map(),
          metadata: map() | nil
        }

  @spec new(String.t(), String.t(), map(), map(), keyword()) :: {:ok, t()} | {:error, TypedError.t()}
  def new(service, operation, context, payload, opts \\ [])

  def new(service, operation, context, payload, opts)
      when is_binary(service) and is_binary(operation) and is_map(context) and is_map(payload) and
             is_list(opts) do
    with :ok <- validate_name(service, :service, context),
         :ok <- validate_name(operation, :operation, context),
         {:ok, runtime_context} <- RuntimeContext.validate(context) do
      {:ok,
       %__MODULE__{
         service: service,
         operation: operation,
         context: runtime_context,
         headers: Keyword.get(opts, :headers, %{}),
         payload: payload,
         metadata: Keyword.get(opts, :metadata, %{})
       }}
    end
  end

  def new(_service, _operation, _context, _payload, _opts) do
    {:error,
     TypedError.new(
       "service_request.invalid_shape",
       "validation",
       false,
       %{reason: "service, operation must be strings and context/payload must be maps"},
       "unknown"
     )}
  end

  @spec from_event(String.t(), String.t(), map(), map(), keyword()) :: {:ok, t()} | {:error, TypedError.t()}
  def from_event(service, operation, event_envelope, context, opts \\ [])

  def from_event(service, operation, event_envelope, context, opts)
      when is_binary(service) and is_binary(operation) and is_map(event_envelope) and is_map(context) do
    payload = %{
      event: event_envelope,
      data: fetch_any(event_envelope, :data) || %{}
    }

    metadata = %{
      event_type: fetch_any(event_envelope, :type),
      event_source: fetch_any(event_envelope, :source),
      event_id: fetch_any(event_envelope, :id)
    }

    merged_opts = Keyword.put(opts, :metadata, Map.merge(metadata, Keyword.get(opts, :metadata, %{})))

    new(service, operation, context, payload, merged_opts)
  end

  def from_event(_service, _operation, _event_envelope, _context, _opts) do
    {:error,
     TypedError.new(
       "service_request.invalid_event_shape",
       "validation",
       false,
       %{reason: "event envelope must be a map"},
       "unknown"
     )}
  end

  defp validate_name(value, field, context) do
    if String.trim(value) == "" do
      {:error,
       TypedError.new(
         "service_request.invalid_#{field}",
         "validation",
         false,
         %{field: field},
         fetch_any(context, :correlation_id) || "unknown"
       )}
    else
      :ok
    end
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
