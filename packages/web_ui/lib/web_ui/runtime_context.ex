defmodule WebUi.RuntimeContext do
  @moduledoc """
  Runtime context validation and normalization helpers.
  """

  alias WebUi.TypedError

  @required_fields [:correlation_id, :request_id]
  @optional_fields [:session_id, :client_id, :user_id, :trace_id]

  @type t :: %{
          required(:correlation_id) => String.t(),
          required(:request_id) => String.t(),
          optional(:session_id) => String.t() | nil,
          optional(:client_id) => String.t() | nil,
          optional(:user_id) => String.t() | nil,
          optional(:trace_id) => String.t() | nil
        }

  @spec validate(map()) :: {:ok, t()} | {:error, TypedError.t()}
  def validate(context) when is_map(context) do
    missing =
      @required_fields
      |> Enum.filter(fn key ->
        case fetch_any(context, key) do
          value when is_binary(value) and value != "" -> false
          _ -> true
        end
      end)

    case missing do
      [] ->
        {:ok,
         %{
           correlation_id: fetch_any(context, :correlation_id),
           request_id: fetch_any(context, :request_id),
           session_id: fetch_any(context, :session_id),
           client_id: fetch_any(context, :client_id),
           user_id: fetch_any(context, :user_id),
           trace_id: fetch_any(context, :trace_id)
         }}

      _ ->
        {:error,
         TypedError.new(
           "runtime_context.missing_required_fields",
           "validation",
           false,
           %{missing_fields: missing},
           fetch_any(context, :correlation_id) || "unknown"
         )}
    end
  end

  def validate(_context) do
    {:error,
     TypedError.new(
       "runtime_context.invalid_shape",
       "validation",
       false,
       %{reason: "runtime context must be a map"},
       "unknown"
     )}
  end

  @spec required_fields() :: [atom()]
  def required_fields, do: @required_fields

  @spec optional_fields() :: [atom()]
  def optional_fields, do: @optional_fields

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
