defmodule TerminalUi.Runtime do
  @moduledoc """
  Shared runtime entrypoint placeholder for native and canonical `terminal_ui`
  screens.
  """

  @spec modules() :: [module()]
  def modules, do: []

  @spec assumptions() :: map()
  def assumptions do
    %{
      term_ui_backed: true,
      shared_runtime_for_native_and_canonical: true,
      capability_aware: true
    }
  end
end
