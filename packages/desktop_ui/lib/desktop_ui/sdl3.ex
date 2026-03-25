defmodule DesktopUi.Sdl3 do
  @moduledoc """
  SDL3-native adapter boundary for `desktop_ui`.
  """

  alias DesktopUi.Sdl3.{
    App,
    Capabilities,
    Events,
    FrameEncoder,
    Host,
    Images,
    Lifecycle,
    NativeBuild,
    NativeHost,
    PortHost,
    Protocol,
    RenderPlan,
    Renderer,
    Text,
    Window
  }

  @type validation_state :: :app_handoff_ready

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      App,
      Capabilities,
      FrameEncoder,
      Host,
      NativeBuild,
      PortHost,
      Protocol,
      NativeHost,
      Lifecycle,
      Window,
      RenderPlan,
      Renderer,
      Events,
      Text,
      Images
    ]
  end

  @spec adapter_scope() :: [atom()]
  def adapter_scope do
    [
      :app_lifecycle,
      :runtime_handoff,
      :window_registry,
      :render_plan,
      :frame_encoding,
      :renderer_presentation,
      :host_process,
      :native_build,
      :capability_detection,
      :native_host_execution,
      :framed_protocol,
      :port_transport,
      :event_normalization,
      :text_resources,
      :image_resources,
      :callback_dispatch,
      :shutdown_contract
    ]
  end

  @spec foundation() :: map()
  def foundation do
    %{
      runtime_foundation: :sdl3,
      binding: :sdl,
      host_transport: :port,
      protocol_framing: :desktop_ui_sdl3_frame,
      host_execution: :external_process,
      preferred_host_backend: Capabilities.contract().preferred_backend,
      fallback_host_backend: Capabilities.contract().fallback_backend,
      lifecycle_model: :callback_oriented,
      first_backend: :renderer,
      frame_encoding: :host_protocol_payload
    }
  end

  @spec validation_state() :: validation_state()
  def validation_state, do: :app_handoff_ready
end
