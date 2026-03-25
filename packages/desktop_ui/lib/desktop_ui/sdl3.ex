defmodule DesktopUi.Sdl3 do
  @moduledoc """
  SDL3-native adapter boundary for `desktop_ui`.
  """

  alias DesktopUi.Sdl3.{App, Lifecycle, RenderPlan, Renderer, Window}

  @type validation_state :: :app_handoff_ready

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      App,
      Lifecycle,
      Window,
      RenderPlan,
      Renderer
    ]
  end

  @spec adapter_scope() :: [atom()]
  def adapter_scope do
    [
      :app_lifecycle,
      :runtime_handoff,
      :window_registry,
      :render_plan,
      :renderer_presentation,
      :callback_dispatch,
      :shutdown_contract
    ]
  end

  @spec foundation() :: map()
  def foundation do
    %{
      runtime_foundation: :sdl3,
      binding: :sdl,
      lifecycle_model: :callback_oriented,
      first_backend: :renderer
    }
  end

  @spec validation_state() :: validation_state()
  def validation_state, do: :app_handoff_ready
end
