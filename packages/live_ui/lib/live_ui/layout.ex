defmodule LiveUi.Layout do
  @moduledoc """
  Reference surface for foundational native layout primitives.
  """

  @modules [
    LiveUi.Layout.Row,
    LiveUi.Layout.Column,
    LiveUi.Layout.Grid
  ]

  @spec modules() :: [module()]
  def modules do
    @modules
  end
end
