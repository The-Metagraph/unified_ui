defmodule UnifiedUi.SignalBus do
  @moduledoc """
  PubSub-backed signal bus for high-fanout signal broadcasts.

  This module wraps `Phoenix.PubSub` behind a small API used by
  `UnifiedUi.Adapters.Coordinator` when broadcasting normalized signals.
  """

  alias Jido.Signal

  @default_pubsub_name UnifiedUi.PubSub
  @default_topic "unified_ui:signals"
  @message_tag :unified_ui_signal

  @type topic :: String.t()
  @type bus_message :: {:unified_ui_signal, Signal.t()}

  @doc """
  Returns the default signal topic used for broadcasts.
  """
  @spec default_topic() :: topic()
  def default_topic, do: @default_topic

  @doc """
  Returns the configured PubSub process name.
  """
  @spec pubsub_name() :: atom()
  def pubsub_name do
    Application.get_env(:unified_ui, :signal_pubsub_name, @default_pubsub_name)
  end

  @doc """
  Subscribes the current process to a signal topic.
  """
  @spec subscribe(topic()) :: :ok | {:error, term()}
  def subscribe(topic \\ @default_topic)

  def subscribe(topic) when is_binary(topic) do
    with :ok <- ensure_pubsub_ready() do
      Phoenix.PubSub.subscribe(pubsub_name(), topic)
    end
  end

  def subscribe(_topic), do: {:error, :invalid_topic}

  @doc """
  Unsubscribes the current process from a signal topic.
  """
  @spec unsubscribe(topic()) :: :ok | {:error, term()}
  def unsubscribe(topic \\ @default_topic)

  def unsubscribe(topic) when is_binary(topic) do
    with :ok <- ensure_pubsub_ready() do
      Phoenix.PubSub.unsubscribe(pubsub_name(), topic)
    end
  end

  def unsubscribe(_topic), do: {:error, :invalid_topic}

  @doc """
  Broadcasts a signal to all subscribers of the topic.

  Subscribers receive messages in the format:
  `{:unified_ui_signal, %Jido.Signal{...}}`.
  """
  @spec broadcast(Signal.t(), topic()) :: :ok | {:error, term()}
  def broadcast(signal, topic \\ @default_topic)

  def broadcast(%Signal{} = signal, topic) when is_binary(topic) do
    with :ok <- ensure_pubsub_ready() do
      Phoenix.PubSub.broadcast(pubsub_name(), topic, {@message_tag, signal})
    end
  end

  def broadcast(%Signal{}, _topic), do: {:error, :invalid_topic}
  def broadcast(_signal, _topic), do: {:error, :invalid_signal}

  defp ensure_pubsub_ready do
    with :ok <- ensure_pubsub_module_loaded() do
      ensure_pubsub_started()
    end
  end

  defp ensure_pubsub_module_loaded do
    case Code.ensure_loaded(Phoenix.PubSub) do
      {:module, _} -> :ok
      _ -> {:error, :pubsub_unavailable}
    end
  rescue
    _ -> {:error, :pubsub_unavailable}
  end

  defp ensure_pubsub_started do
    if Process.whereis(pubsub_name()) do
      :ok
    else
      {:error, :pubsub_not_started}
    end
  end
end
