defmodule LiveUi.Live.EventRouter do
  @moduledoc """
  Shared validation path for standard LiveView events and hook-emitted payloads.
  """

  alias Jido.Signal
  alias LiveUi.ConfigurationError
  alias LiveUi.Signals.Encoder

  @spec normalize(String.t() | atom(), map(), map()) ::
          {:ok, Signal.t()} | {:error, ConfigurationError.t()}
  def normalize(event_name, payload, runtime_context \\ %{}) do
    Encoder.encode(event_name, payload, runtime_context)
  end
end
