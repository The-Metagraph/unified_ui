defmodule LiveUi.Runtime.BrowserBridge do
  @moduledoc """
  Bounded browser-bridge placeholders for hooks and channel integration.
  """

  @type hook :: atom()

  @spec normalize_hooks([hook()]) :: [hook()]
  def normalize_hooks(hooks) when is_list(hooks) do
    Enum.uniq(hooks)
  end

  @spec authoritative?() :: boolean()
  def authoritative?, do: false
end
