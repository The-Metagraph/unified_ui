defmodule WebUi.Frontend.Error do
  @moduledoc """
  Structured errors for the frontend-side `web_ui` runtime scaffold.
  """

  @enforce_keys [:code, :message]
  defstruct [:code, :message, details: %{}]

  @type t :: %__MODULE__{
          code: atom(),
          message: String.t(),
          details: map()
        }

  @spec new(atom(), String.t(), map()) :: t()
  def new(code, message, details \\ %{}) when is_atom(code) and is_binary(message) do
    %__MODULE__{code: code, message: message, details: Map.new(details)}
  end

  @spec invalid_hydration_payload(term()) :: t()
  def invalid_hydration_payload(payload) do
    new(:invalid_hydration_payload, "hydration payload is missing required frontend keys", %{
      value: inspect(payload)
    })
  end

  @spec invalid_local_state(term()) :: t()
  def invalid_local_state(local_state) do
    new(:invalid_local_state, "frontend local state must remain a map", %{
      value: inspect(local_state)
    })
  end

  @spec invalid_outbound_message(term()) :: t()
  def invalid_outbound_message(message) do
    new(:invalid_outbound_message, "outbound frontend message must contain event and payload", %{
      value: inspect(message)
    })
  end
end
