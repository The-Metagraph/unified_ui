defmodule WebUi.Frontend do
  @moduledoc """
  Package-facing Elm-side runtime entrypoints.
  """

  @spec runtime() :: module()
  def runtime, do: WebUi.FrontendRuntime

  @spec modules() :: [module()]
  def modules, do: WebUi.FrontendRuntime.modules()
end
