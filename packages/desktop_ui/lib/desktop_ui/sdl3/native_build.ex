defmodule DesktopUi.Sdl3.NativeBuild do
  @moduledoc """
  Build-path metadata for the optional compiled SDL3 native host.
  """

  alias DesktopUi.Sdl3.Capabilities

  @host_name "desktop_ui_sdl3_host"

  @spec contract() :: map()
  def contract do
    %{
      source_root: source_root(),
      output_root: output_root(),
      executable_name: executable_name(),
      executable_path: executable_path(),
      dependency_detection: [:env_override, :pkg_config, :homebrew_prefix],
      compiled_modes: [:protocol_host, :visible_frame_runner],
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

  @spec compile_plan(keyword()) :: map()
  def compile_plan(opts \\ []) do
    capabilities = Keyword.get(opts, :capabilities, Capabilities.detect())

    compiler =
      get_in(capabilities, [:toolchains, :cc, :path]) || Keyword.get(opts, :compiler, "cc")

    include_flags =
      capabilities
      |> library_prefixes()
      |> Enum.map(&"-I#{Path.join(&1, "include")}")

    library_search_flags =
      capabilities
      |> library_prefixes()
      |> Enum.map(&"-L#{Path.join(&1, "lib")}")

    link_flags =
      capabilities
      |> available_libraries()
      |> Enum.map(fn
        :sdl3 -> "-lSDL3"
        :sdl3_ttf -> "-lSDL3_ttf"
        :sdl3_image -> "-lSDL3_image"
      end)

    %{
      compiler: compiler,
      args:
        ["-std=c11", "-Wall", "-Wextra", "-O2"]
        |> Kernel.++(include_flags)
        |> Kernel.++(source_files())
        |> Kernel.++(["-o", executable_path()])
        |> Kernel.++(library_search_flags)
        |> Kernel.++(link_flags),
      output_root: output_root(),
      executable: executable_path(),
      buildable?: capabilities.build.buildable?,
      launch_ready?: capabilities.build.launch_ready?,
      validation_state: :native_compile_plan_ready
    }
  end

  defp library_prefixes(capabilities) do
    capabilities
    |> Map.get(:libraries, %{})
    |> Enum.flat_map(fn {_key, details} ->
      case Map.get(details, :prefix) do
        prefix when is_binary(prefix) and prefix != "" -> [prefix]
        _other -> []
      end
    end)
    |> Enum.uniq()
  end

  defp available_libraries(capabilities) do
    capabilities
    |> Map.get(:libraries, %{})
    |> Enum.flat_map(fn {key, details} ->
      if Map.get(details, :available?, false), do: [key], else: []
    end)
  end
end
