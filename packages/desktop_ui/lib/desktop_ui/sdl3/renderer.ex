defmodule DesktopUi.Sdl3.Renderer do
  @moduledoc """
  SDL_Renderer-first presentation boundary for SDL3 render plans.
  """

  alias DesktopUi.Runtime.State
  alias DesktopUi.Sdl3.RenderPlan

  @spec contract() :: map()
  def contract do
    %{
      first_backend: :sdl_renderer,
      future_backend: :sdl_gpu,
      preserves_render_plan_semantics: true,
      placeholder_draw_operations_allowed: true
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :render_plan_ready

  @spec prepare_frame(State.t()) :: {:ok, RenderPlan.t()} | {:error, term()}
  def prepare_frame(%State{} = runtime_state) do
    RenderPlan.build(runtime_state)
  end

  @spec present(RenderPlan.t(), keyword()) :: {:ok, map()}
  def present(%RenderPlan{} = plan, _opts \\ []) do
    {:ok,
     %{
       backend: :sdl_renderer,
       window_count: length(plan.windows),
       presented_windows:
         Enum.map(plan.windows, fn window ->
           %{
             window_id: window.window_id,
             draw_operations: length(window.draw_operations),
             transient_layers: Enum.map(window.transient_layers, & &1.widget_id)
           }
         end),
       validation_state: validation_state()
     }}
  end
end
