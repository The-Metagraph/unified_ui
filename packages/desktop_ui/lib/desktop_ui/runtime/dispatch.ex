defmodule DesktopUi.Runtime.Dispatch do
  @moduledoc """
  Input dispatch scaffold for the shared SDL2 runtime loop.
  """

  @spec scaffold() :: map()
  def scaffold do
    %{
      status: :ready,
      families: [:pointer, :keyboard, :focus, :window],
      boundary_mode: :placeholder_ready
    }
  end
end
