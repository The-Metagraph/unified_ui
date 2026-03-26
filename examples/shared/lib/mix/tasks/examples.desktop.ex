defmodule Mix.Tasks.Examples.Desktop do
  use Mix.Task

  @shortdoc "Runs a unified example with native desktop rendering"

  @moduledoc """
  Runs a unified example using the desktop_ui native renderer.

      mix examples.desktop button
      mix examples.desktop text --linger-ms 5000
      mix examples.desktop grid --platform linux

  This compiles the example to IUR and renders it natively using SDL3.
  The Phoenix backend is not started - this is pure native rendering.
  """

  alias UnifiedExamples.Shared.Loader
  alias UnifiedUi.Compiler
  alias DesktopUi.Sdl3.{RenderPlan, VisibleRunner}

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} =
      OptionParser.parse(args,
        switches: [linger_ms: :integer, platform: :string]
      )

    linger_ms = Keyword.get(opts, :linger_ms, :infinity)
    platform = Keyword.get(opts, :platform, "macos")  # Default to macOS for now

    case positional do
      [directory] ->
        run_desktop_example(directory, platform, linger_ms)

      _ ->
        Mix.raise("usage: mix examples.desktop DIRECTORY [--linger-ms MILLISECONDS] [--platform auto|linux|macos|windows]")
    end
  end

  defp run_desktop_example(directory, platform, linger_ms) do
    Mix.shell().info("Loading example: #{directory}")

    with {:ok, loaded} <- Loader.load(directory) do
      Mix.shell().info("Compiling to IUR...")
      {:ok, iur_element} = Compiler.iur(loaded.screen)

      Mix.shell().info("Mounting desktop runtime...")
      {:ok, runtime_state} = DesktopUi.Runtime.mount_iur(iur_element, platform_target: parse_platform(platform))

      Mix.shell().info("Building render plan...")
      {:ok, render_plan} = RenderPlan.build(runtime_state)

      actual_linger = if linger_ms == :infinity, do: 5000, else: linger_ms
      Mix.shell().info("Running SDL3 window (linger: #{actual_linger}ms)...")

      case VisibleRunner.run(render_plan, linger_ms: actual_linger) do
        {:ok, result} ->
          Mix.shell().info("Window closed successfully")
          {:ok, result}

        {:error, reason} ->
          Mix.raise("Failed to run SDL3 window: #{inspect(reason)}")
      end
    else
      {:error, reason} ->
        Mix.raise("Failed to run example: #{inspect(reason)}")
    end
  end

  defp parse_platform("auto"), do: :macos  # TODO: detect dynamically, cached module issue
  defp parse_platform("linux"), do: :linux
  defp parse_platform("macos"), do: :macos
  defp parse_platform("windows"), do: :windows
  defp parse_platform(other), do: other
end
