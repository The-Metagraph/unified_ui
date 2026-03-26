defmodule DesktopUi.Sdl3.VisibleRunner do
  @moduledoc """
  Compiled SDL3 visible-window runner backed by frame-script export.
  """

  alias DesktopUi.Runtime.Error
  alias DesktopUi.Sdl3.{Capabilities, FrameScript, NativeBuild, RenderPlan}

  @type execution_result :: map()

  @spec contract() :: map()
  def contract do
    %{
      execution_target: :compiled_visible_window,
      backend: :compiled_sdl3_host,
      input_format: FrameScript.contract().format,
      output_window: :native_sdl3_window,
      linger_control: :bounded_timeout_or_manual_quit,
      placeholder_drawing: true,
      native_resource_realization: [:sdl3_ttf, :sdl3_image, :fallback]
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :visible_window_runner_ready

  @spec run(RenderPlan.t(), keyword()) :: {:ok, execution_result()} | {:error, Error.t()}
  def run(%RenderPlan{} = plan, opts \\ []) do
    capabilities = Keyword.get(opts, :capabilities, Capabilities.detect())

    if capabilities.build.visible_runner_ready? do
      run_visible_plan(plan, capabilities, opts)
    else
      {:error,
       Error.new(
         :compiled_visible_runner_not_ready,
         %{capabilities: capabilities.build},
         :sdl3_visible_runner
       )}
    end
  end

  defp run_visible_plan(%RenderPlan{} = plan, capabilities, opts) do
    script_path = Keyword.get(opts, :frame_script_path, temp_script_path(plan))
    linger_ms = Keyword.get(opts, :linger_ms, 1_500)
    cleanup? = Keyword.get(opts, :cleanup?, true)
    executable = capabilities.build.executable_path || NativeBuild.executable_path()
    args = ["--frame-script", script_path, "--linger-ms", Integer.to_string(linger_ms)]

    with :ok <- ensure_script_root(script_path),
         {:ok, _path} <- FrameScript.write(plan, script_path),
         {:ok, output, status} <- run_native_host(executable, args, opts) do
      if cleanup? do
        File.rm(script_path)
      end

      {:ok,
       %{
         status: if(status == 0, do: :ok, else: :error),
         backend: :compiled_sdl3_host,
         execution_mode: :visible_window,
         visible_window?: true,
         presented_frame?: status == 0,
         executable: executable,
         args: args,
         linger_ms: linger_ms,
         frame_script_path: script_path,
         frame_script_removed?: cleanup?,
         exit_status: status,
         output: String.trim(output),
         render_plan: render_plan_summary(plan),
         resource_realization: %{
           text: DesktopUi.Sdl3.Text.native_support(capabilities),
           images: DesktopUi.Sdl3.Images.native_support(capabilities)
         },
         capabilities: %{
           launch_ready?: get_in(capabilities, [:build, :launch_ready?]) || false,
           visible_runner_ready?: get_in(capabilities, [:build, :visible_runner_ready?]) || false,
           native_text_ready?: get_in(capabilities, [:build, :native_text_ready?]) || false,
           native_image_ready?: get_in(capabilities, [:build, :native_image_ready?]) || false,
           executable_probe: get_in(capabilities, [:build, :executable_probe]) || %{}
         },
         validation_state: validation_state()
       }}
    else
      {:error, %Error{} = error} ->
        {:error, error}

      {:error, reason} ->
        {:error,
         Error.new(
           :visible_frame_script_write_failed,
           %{reason: inspect(reason), path: script_path},
           :sdl3_visible_runner
         )}
    end
  end

  defp ensure_script_root(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p()
  end

  defp run_native_host(executable, args, opts) do
    runner = Keyword.get(opts, :run_cmd, &System.cmd/3)

    {output, status} = runner.(executable, args, stderr_to_stdout: true)
    {:ok, output, status}
  rescue
    error ->
      {:error,
       Error.new(
         :compiled_visible_runner_execution_failed,
         %{error: inspect(error), executable: executable, args: args},
         :sdl3_visible_runner
       )}
  end

  defp render_plan_summary(%RenderPlan{} = plan) do
    %{
      runtime_id: plan.runtime_id,
      screen_id: plan.screen_id,
      window_count: length(plan.windows),
      window_ids: Enum.map(plan.windows, & &1.window_id),
      logical_units: plan.presentation.logical_units,
      draw_operation_count: plan.diagnostics.draw_operation_count,
      validation_state: plan.presentation.validation_state
    }
  end

  defp temp_script_path(%RenderPlan{} = plan) do
    Path.join(
      System.tmp_dir!(),
      "desktop_ui_#{plan.screen_id}_#{System.unique_integer([:positive])}.frame"
    )
  end
end
