defmodule WebUi.ServerRuntime.Channel do
  @moduledoc """
  Phoenix channel for web_ui browser-server communication.

  This module provides the channel interface that the Elm frontend
  uses to send events and receive state updates from the server.
  """

  @type channel_name :: atom()

  @type message_envelope :: %{
          type: String.t(),
          payload: map(),
          version: String.t() | nil,
          timestamp: DateTime.t()
        }

  @type event_update :: %{
          type: :state_update | :event_result,
          assigns: map(),
          checksum: String.t()
        }

  @spec channel_name() :: channel_name()
  def channel_name, do: :web_ui

  @doc """
  Creates a message envelope for client-to-server communication.
  """
  @spec envelope(String.t(), map(), keyword()) :: message_envelope()
  def envelope(type, payload, opts \\ []) do
    %{
      type: type,
      payload: payload,
      version: Keyword.get(opts, :version),
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Creates a state update for server-to-client communication.
  """
  @spec state_update(map(), String.t()) :: event_update()
  def state_update(assigns, checksum) do
    %{
      type: :state_update,
      assigns: assigns,
      checksum: checksum
    }
  end

  @doc """
  Creates an event result for server-to-client communication.
  """
  @spec event_result(map(), String.t(), atom() | nil) :: event_update()
  def event_result(assigns, checksum, status \\ :ok) do
    %{
      type: :event_result,
      assigns: assigns,
      checksum: checksum,
      status: status
    }
  end

  @doc """
  Validates a message envelope from the frontend.
  """
  @spec validate_envelope(message_envelope()) :: :ok | {:error, atom()}
  def validate_envelope(%{type: type, payload: payload})
      when is_binary(type) and is_map(payload) do
    :ok
  end

  def validate_envelope(_), do: {:error, :invalid_envelope}

  @doc """
  Extracts the event type from a message envelope.
  """
  @spec event_type(message_envelope()) :: {:ok, String.t()} | {:error, atom()}
  def event_type(%{type: type}) when is_binary(type), do: {:ok, type}
  def event_type(_), do: {:error, :missing_event_type}

  @doc """
  Extracts the payload from a message envelope.
  """
  @spec payload(message_envelope()) :: {:ok, map()} | {:error, atom()}
  def payload(%{payload: payload}) when is_map(payload), do: {:ok, payload}
  def payload(_), do: {:error, :missing_payload}
end
