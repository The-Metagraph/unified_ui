defmodule DesktopUi.Platform.Adapter do
  @moduledoc """
  Behaviour for platform adapters that plug into the shared SDL2 runtime.
  """

  @callback summary() :: map()
  @callback capabilities() :: [atom()]
  @callback callbacks() :: [atom()]
end
