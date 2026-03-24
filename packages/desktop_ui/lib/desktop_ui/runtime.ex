defmodule DesktopUi.Runtime do
  @moduledoc """
  Shared runtime entrypoint placeholder for native and canonical `desktop_ui`
  screens.
  """

  alias UnifiedIUR.Element

  @spec modules() :: [module()]
  def modules do
    [__MODULE__]
  end

  @spec capabilities() :: [atom()]
  def capabilities do
    [
      :native_mount,
      :renderer_mount,
      :shared_sdl_runtime,
      :window_registry,
      :redraw_scheduling,
      :platform_adapter_registration
    ]
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      shared_runtime_foundation: :sdl2,
      shared_runtime_for_native_and_canonical: true,
      platform_variation_bounded: true,
      renderer_boot_path_present: true
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :scaffold_ready

  @spec accepts() :: module()
  def accepts, do: Element
end
