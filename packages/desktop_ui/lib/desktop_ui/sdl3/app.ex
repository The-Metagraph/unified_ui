defmodule DesktopUi.Sdl3.App do
  @moduledoc """
  SDL3-facing application ownership and runtime handoff helpers.
  """

  alias DesktopUi.Runtime
  alias DesktopUi.Runtime.State
  alias DesktopUi.Sdl3.{Lifecycle, RenderPlan, Window}
  alias UnifiedIUR.Element

  @type boot_request :: map()

  @spec callback_names() :: [Lifecycle.callback_name()]
  def callback_names, do: Lifecycle.callback_names()

  @spec lifecycle_contract() :: map()
  def lifecycle_contract do
    %{
      foundation: :sdl3,
      lifecycle: Lifecycle.contract(),
      package_application_takeover: false
    }
  end

  @spec handoff_contract() :: map()
  def handoff_contract do
    %{
      direct_native_and_canonical_share_runtime: true,
      runtime_handoff_shape: [:runtime, :windows, :frame_request, :lifecycle, :diagnostics],
      frame_backend: :sdl_renderer,
      logical_units_preserved: true
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :app_handoff_ready

  @spec boot_native_screen(map(), keyword()) :: {:ok, boot_request()} | {:error, term()}
  def boot_native_screen(screen, opts \\ []) when is_map(screen) do
    with {:ok, runtime_state} <- Runtime.mount_native_screen(screen, opts) do
      {:ok, boot_request(runtime_state, opts)}
    end
  end

  @spec boot_iur_screen(Element.t(), keyword()) :: {:ok, boot_request()} | {:error, term()}
  def boot_iur_screen(%Element{} = element, opts \\ []) do
    with {:ok, runtime_state} <- Runtime.mount_iur_screen(element, opts) do
      {:ok, boot_request(runtime_state, opts)}
    end
  end

  @spec boot_request(State.t(), keyword()) :: boot_request()
  def boot_request(%State{} = runtime_state, opts \\ []) do
    boot_request = runtime_handoff(runtime_state, opts)

    lifecycle =
      Lifecycle.scaffold()
      |> Lifecycle.begin_boot(%{
        runtime_id: boot_request.runtime.runtime_id,
        screen_id: boot_request.runtime.screen_id,
        platform_target: boot_request.runtime.platform_target
      })
      |> Lifecycle.record_callback(:app_init, :ready)
      |> Lifecycle.ready()

    %{
      foundation: :sdl3,
      binding: :sdl,
      runtime: boot_request.runtime,
      windows: boot_request.windows,
      frame_request: boot_request.frame_request,
      lifecycle: lifecycle,
      diagnostics: boot_request.diagnostics,
      validation_state: validation_state()
    }
  end

  @spec runtime_handoff(State.t(), keyword()) :: map()
  def runtime_handoff(%State{} = runtime_state, _opts \\ []) do
    {:ok, windows} = Window.registry(runtime_state)
    {:ok, render_plan} = RenderPlan.build(runtime_state)

    %{
      runtime: %{
        runtime_id: runtime_state.runtime_id,
        screen_id: runtime_state.screen_id,
        source_kind: runtime_state.source_kind,
        platform_target: runtime_state.platform_target,
        validation_state: runtime_state.validation_state,
        direct_native_and_canonical_share_runtime: true
      },
      windows: windows,
      frame_request: %{
        runtime_id: runtime_state.runtime_id,
        screen_id: runtime_state.screen_id,
        primary_window_id: windows.primary_id,
        redraw_status: runtime_state.redraw.status,
        redraw_reason: runtime_state.redraw.pending_reason || :initial_present,
        presentation: %{
          backend: :sdl_renderer,
          logical_units: :desktop_ui_layout,
          render_target: runtime_state.realization.mode,
          theme: runtime_state.realization.theme,
          render_plan: render_plan
        },
        validation_state: :render_plan_ready
      },
      diagnostics: %{
        screen_title: runtime_state.title,
        widget_count: runtime_state.screen.composition.widget_count,
        window_count: runtime_state.screen.composition.window_count,
        focus_targets: runtime_state.focus.order,
        event_loop_state: runtime_state.event_loop.routing_state,
        render_plan_validation_state: render_plan.presentation.validation_state
      }
    }
  end
end
