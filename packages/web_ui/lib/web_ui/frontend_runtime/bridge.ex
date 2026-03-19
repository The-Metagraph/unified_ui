defmodule WebUi.FrontendRuntime.Bridge do
  @moduledoc """
  Frontend bridge boundary for state hydration and server communication.

  This module defines the contract between the Elm frontend and
  Phoenix server, handling serialization and validation.
  """

  @type outbound_message :: %{
          type: String.t(),
          payload: map(),
          timestamp: String.t()
        }

  @type inbound_message :: %{
          type: :state_update | :event_result,
          data: map(),
          checksum: String.t()
        }

  @doc """
  Creates an outbound message from Elm to the server.
  """
  @spec outbound(String.t(), map()) :: outbound_message()
  def outbound(type, payload) when is_binary(type) and is_map(payload) do
    %{
      type: type,
      payload: payload,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  @doc """
  Validates an outbound message structure.
  """
  @spec validate_outbound(map()) :: :ok | {:error, atom()}
  def validate_outbound(%{type: type, payload: payload})
      when is_binary(type) and is_map(payload) do
    :ok
  end

  def validate_outbound(_), do: {:error, :invalid_outbound_message}

  @doc """
  Serializes an outbound message for transmission.
  """
  @spec serialize_outbound(outbound_message()) :: {:ok, String.t()} | {:error, atom()}
  def serialize_outbound(message) do
    case Jason.encode(message) do
      {:ok, json} -> {:ok, json}
      {:error, _} -> {:error, :serialization_failed}
    end
  end

  @doc """
  Deserializes an inbound message from the server.
  """
  @spec deserialize_inbound(String.t()) :: {:ok, inbound_message()} | {:error, atom()}
  def deserialize_inbound(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, %{"type" => type_string, "data" => data, "checksum" => checksum}}
      when type_string in ["state_update", "event_result"] ->
        type = String.to_existing_atom(type_string)

        {:ok,
         %{
           type: type,
           data: data,
           checksum: checksum
         }}

      _ ->
        {:error, :invalid_inbound_message}
    end
  end

  @doc """
  Creates an inbound message from server state.
  """
  @spec inbound_from_state(map(), String.t(), atom()) :: inbound_message()
  def inbound_from_state(assigns, checksum, type \\ :state_update) do
    %{
      type: type,
      data: assigns,
      checksum: checksum
    }
  end

  @doc """
  Validates checksum consistency between frontend and server.
  """
  @spec validate_checksum(String.t(), String.t()) :: :ok | {:error, :checksum_mismatch}
  def validate_checksum(expected, actual) when expected == actual, do: :ok
  def validate_checksum(_, _), do: {:error, :checksum_mismatch}
end
