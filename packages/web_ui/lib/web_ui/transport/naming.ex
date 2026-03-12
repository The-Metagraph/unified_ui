defmodule WebUi.Transport.Naming do
  @moduledoc """
  Canonical websocket topic and event naming policy.
  """

  alias WebUi.TypedError

  @default_topic "webui:runtime:v1"
  @session_topic_regex ~r/^webui:runtime:session:[A-Za-z0-9_-]+:v1$/

  @client_events [
    "runtime.event.send.v1",
    "runtime.event.ping.v1"
  ]

  @server_events [
    "runtime.event.recv.v1",
    "runtime.event.error.v1",
    "runtime.event.pong.v1"
  ]

  @spec default_topic() :: String.t()
  def default_topic, do: @default_topic

  @spec client_events() :: [String.t()]
  def client_events, do: @client_events

  @spec server_events() :: [String.t()]
  def server_events, do: @server_events

  @spec validate_topic(String.t()) :: :ok | {:error, TypedError.t()}
  def validate_topic(topic) when is_binary(topic) do
    if topic == @default_topic or topic =~ @session_topic_regex do
      :ok
    else
      {:error,
       TypedError.new(
         "transport.invalid_topic",
         "protocol",
         false,
         %{topic: topic, allowed: [@default_topic, "webui:runtime:session:<session_id>:v1"]}
       )}
    end
  end

  def validate_topic(_topic) do
    {:error,
     TypedError.new(
       "transport.invalid_topic",
       "protocol",
       false,
       %{reason: "topic must be a string"}
     )}
  end

  @spec validate_client_event_name(String.t()) :: :ok | {:error, TypedError.t()}
  def validate_client_event_name(event_name) when is_binary(event_name) do
    validate_event_name(event_name, @client_events, "transport.unknown_client_event")
  end

  def validate_client_event_name(_event_name) do
    {:error,
     TypedError.new(
       "transport.unknown_client_event",
       "protocol",
       false,
       %{reason: "event_name must be a string"}
     )}
  end

  @spec validate_server_event_name(String.t()) :: :ok | {:error, TypedError.t()}
  def validate_server_event_name(event_name) when is_binary(event_name) do
    validate_event_name(event_name, @server_events, "transport.unknown_server_event")
  end

  def validate_server_event_name(_event_name) do
    {:error,
     TypedError.new(
       "transport.unknown_server_event",
       "protocol",
       false,
       %{reason: "event_name must be a string"}
     )}
  end

  defp validate_event_name(event_name, allowed, error_code) do
    if event_name in allowed do
      :ok
    else
      {:error,
       TypedError.new(
         error_code,
         "protocol",
         false,
         %{event_name: event_name, allowed: allowed}
       )}
    end
  end
end
