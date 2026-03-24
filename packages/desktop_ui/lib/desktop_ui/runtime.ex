defmodule DesktopUi.Runtime do
  @moduledoc """
  Shared runtime entrypoint for native and canonical `desktop_ui` screens.
  """

  alias DesktopUi.Renderer
  alias DesktopUi.Runtime.{Boot, Error, EventLoop, Shutdown, State}
  alias UnifiedIUR.Element

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      Boot,
      EventLoop,
      DesktopUi.Runtime.Poller,
      DesktopUi.Runtime.Realization,
      DesktopUi.Runtime.Redraw,
      DesktopUi.Runtime.Dispatch,
      DesktopUi.Runtime.Frame,
      DesktopUi.Runtime.Window,
      DesktopUi.Runtime.Screen,
      DesktopUi.Runtime.State,
      DesktopUi.Runtime.Shutdown,
      DesktopUi.Runtime.Error
    ]
  end

  @spec capabilities() :: [atom()]
  def capabilities do
    [
      :native_mount,
      :renderer_mount,
      :shared_sdl_runtime,
      :window_registry,
      :redraw_scheduling,
      :foundational_layout_realization,
      :binding_indexing,
      :event_targeting,
      :event_polling_scaffold,
      :frame_coordination,
      :focus_callback_placeholders,
      :shortcut_callback_placeholders,
      :window_lifecycle_callbacks,
      :platform_adapter_registration,
      :deterministic_runtime_errors
    ]
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      shared_runtime_foundation: :sdl2,
      shared_runtime_binding: :sdl,
      shared_runtime_for_native_and_canonical: true,
      platform_variation_bounded: true,
      renderer_boot_path_present: true,
      package_application_takeover: false
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :runtime_backbone_ready

  @spec accepts() :: module()
  def accepts, do: Element

  @spec mount_native_screen(map(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_native_screen(screen, opts \\ []) when is_map(screen) do
    Boot.prepare_native_screen(screen, opts)
  end

  @spec mount_iur_screen(Element.t(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_iur_screen(%Element{} = element, opts \\ []) do
    with {:ok, rendered_root} <- Renderer.render(element, opts) do
      Boot.prepare_rendered_screen(rendered_root, opts)
    else
      {:error, %DesktopUi.Renderer.Error{} = error} ->
        {:error, Error.new(error.reason, error.details, :renderer_boot)}
    end
  end

  @spec shutdown(State.t()) :: {:ok, State.t()} | {:error, Error.t()}
  def shutdown(%State{} = runtime_state) do
    Shutdown.stop(runtime_state)
  end
end
