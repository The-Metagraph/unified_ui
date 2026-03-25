defmodule DesktopUi.Sdl3.NativeBuild do
  @moduledoc """
  Build-path metadata for the optional compiled SDL3 native host.
  """

  @host_name "desktop_ui_sdl3_host"

  @spec contract() :: map()
  def contract do
    %{
      source_root: source_root(),
      output_root: output_root(),
      executable_name: executable_name(),
      executable_path: executable_path(),
      dependency_detection: [:env_override, :pkg_config, :homebrew_prefix],
      first_target: :visible_window_host,
      fallback_backend: :elixir_host
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :native_build_surface_ready

  @spec package_root() :: String.t()
  def package_root do
    Path.expand("../../..", __DIR__)
  end

  @spec source_root() :: String.t()
  def source_root do
    Path.join(package_root(), "native/desktop_ui_sdl3_host")
  end

  @spec output_root() :: String.t()
  def output_root do
    Path.join(package_root(), "priv/native")
  end

  @spec executable_name() :: String.t()
  def executable_name do
    case :os.type() do
      {:win32, _} -> "#{@host_name}.exe"
      _other -> @host_name
    end
  end

  @spec executable_path() :: String.t()
  def executable_path do
    Path.join(output_root(), executable_name())
  end

  @spec source_files() :: [String.t()]
  def source_files do
    [
      Path.join(source_root(), "src/main.c")
    ]
  end

  @spec build_recipe(keyword()) :: map()
  def build_recipe(opts \\ []) do
    %{
      executable: executable_path(),
      source_root: source_root(),
      source_files: source_files(),
      output_root: output_root(),
      compiler: Keyword.get(opts, :compiler, "cc"),
      library_resolution: [:pkg_config, :homebrew_prefix],
      validation_state: validation_state()
    }
  end
end
