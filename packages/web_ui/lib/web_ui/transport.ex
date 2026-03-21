defmodule WebUi.Transport do
  @moduledoc """
  Transport helpers for native-local and canonical-boundary interactions.
  """

  alias Jido.Signal

  @type boundary :: :local | :boundary

  @spec modes() :: [atom()]
  def modes do
    [:native_local, :canonical_boundary]
  end

  @spec families() :: [atom()]
  def families do
    [:click, :change, :submit, :navigation]
  end

  @spec integration_points() :: [atom()]
  def integration_points do
    [:frontend_bridge, :server_runtime, :canonical_boundary]
  end

  @spec modules() :: [module()]
  def modules do
    [__MODULE__, WebUi.Transport.Signals, WebUi.Transport.Bridge]
  end

  @spec from_native_event(keyword() | map()) :: {:ok, map()} | {:error, term()}
  def from_native_event(attrs) do
    WebUi.Transport.Signals.from_native_event(attrs)
  end

  @spec to_server_message(Signal.t() | map()) :: {:ok, map()} | {:error, term()}
  def to_server_message(event) do
    WebUi.Transport.Signals.to_server_message(event)
  end
end
