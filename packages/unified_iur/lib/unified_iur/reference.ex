defmodule UnifiedIUR.Reference do
  @moduledoc """
  Package-facing reference helpers for the canonical module areas exposed by
  `UnifiedIUR`.
  """

  @spec module_areas() :: %{UnifiedIUR.module_area() => module()}
  def module_areas do
    UnifiedIUR.module_areas()
  end
end
