defmodule WebUi.Server do
  @moduledoc """
  Package-facing Phoenix-side runtime entrypoints.
  """

  @spec runtime() :: module()
  def runtime, do: WebUi.ServerRuntime

  @spec modules() :: [module()]
  def modules, do: WebUi.ServerRuntime.modules()
end
