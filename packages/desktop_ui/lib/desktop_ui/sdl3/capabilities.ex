defmodule DesktopUi.Sdl3.Capabilities do
  @moduledoc """
  Capability discovery for compiled SDL3 host support and fallback selection.
  """

  alias DesktopUi.Sdl3.NativeBuild

  @sdl_packages [sdl3: "sdl3", sdl3_ttf: "sdl3_ttf", sdl3_image: "sdl3_image"]

  @type probe_opts :: keyword()

  @spec contract() :: map()
  def contract do
    %{
      discovery_sources: [:env_override, :built_executable, :pkg_config, :homebrew_prefix],
      preferred_backend: :compiled_sdl3_host,
      fallback_backend: :elixir_host,
      required_toolchains: [:cc],
      optional_tooling: [:pkg_config, :brew]
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :capability_detection_ready

  @spec detect(probe_opts()) :: map()
  def detect(opts \\ []) do
    toolchains = detect_toolchains(opts)
    built_executable = detect_built_executable(opts)
    libraries = detect_libraries(toolchains, opts)
    build = detect_build(toolchains, libraries, built_executable)

    %{
      toolchains: toolchains,
      libraries: libraries,
      build: build,
      backend: %{
        preferred: :compiled_sdl3_host,
        fallback: :elixir_host,
        recommended: backend_recommendation(build),
        available: backend_availability(build),
        validation_state: validation_state()
      }
    }
  end

  @spec recommended_backend(probe_opts()) :: atom()
  def recommended_backend(opts) when is_list(opts) do
    opts |> detect() |> get_in([:backend, :recommended])
  end

  @spec built_executable_path(probe_opts()) :: String.t() | nil
  def built_executable_path(opts \\ []) do
    opts |> detect_built_executable() |> Map.get(:path)
  end

  @spec compiled_host_available?(probe_opts()) :: boolean()
  def compiled_host_available?(opts \\ []) do
    opts |> detect_built_executable() |> Map.get(:available?, false)
  end

  defp detect_toolchains(opts) do
    %{
      cc: executable_probe("cc", opts),
      pkg_config: executable_probe("pkg-config", opts),
      brew: executable_probe("brew", opts)
    }
  end

  defp detect_built_executable(opts) do
    env = env_map(opts)
    override = Map.get(env, "DESKTOP_UI_SDL3_HOST")
    override_available? = is_binary(override) and file_exists?(override, opts)

    compiled_path = NativeBuild.executable_path()
    compiled_available? = file_exists?(compiled_path, opts)

    %{
      override_path: override,
      override_available?: override_available?,
      compiled_path: compiled_path,
      compiled_available?: compiled_available?,
      path: if(override_available?, do: override, else: compiled_path),
      available?: override_available? or compiled_available?
    }
  end

  defp detect_libraries(toolchains, opts) do
    brew_prefixes = detect_homebrew_prefixes(toolchains, opts)

    Map.new(@sdl_packages, fn {key, package_name} ->
      {key, library_probe(package_name, key, toolchains, brew_prefixes, opts)}
    end)
  end

  defp detect_homebrew_prefixes(toolchains, opts) do
    if toolchains.brew.available? do
      Map.new(@sdl_packages, fn {key, package_name} ->
        {key, homebrew_prefix(package_name, opts)}
      end)
    else
      %{}
    end
  end

  defp detect_build(toolchains, libraries, built_executable) do
    required_packages = [:sdl3]
    companion_packages = [:sdl3_ttf, :sdl3_image]

    all_required_available? =
      Enum.all?(required_packages, &get_in(libraries, [&1, :available?]))

    companion_available =
      Enum.filter(companion_packages, &get_in(libraries, [&1, :available?]))

    %{
      native_build_surface: NativeBuild.contract(),
      toolchain_ready?: toolchains.cc.available?,
      required_libraries_ready?: all_required_available?,
      companion_libraries_ready: companion_available,
      executable_present?: built_executable.available?,
      executable_path: built_executable.path,
      buildable?: toolchains.cc.available? and all_required_available?,
      validation_state: NativeBuild.validation_state()
    }
  end

  defp backend_recommendation(%{executable_present?: true}), do: :compiled_sdl3_host
  defp backend_recommendation(_build), do: :elixir_host

  defp backend_availability(%{executable_present?: true}),
    do: [:compiled_sdl3_host, :elixir_host]

  defp backend_availability(_build), do: [:elixir_host]

  defp library_probe(package_name, key, toolchains, brew_prefixes, opts) do
    pkg_config_result = pkg_config_probe(package_name, toolchains, opts)
    brew_prefix = Map.get(brew_prefixes, key)

    cond do
      pkg_config_result.available? ->
        Map.put(pkg_config_result, :source, :pkg_config)

      is_binary(brew_prefix) ->
        %{
          package: package_name,
          available?: true,
          source: :homebrew_prefix,
          prefix: brew_prefix
        }

      true ->
        %{
          package: package_name,
          available?: false,
          source: :missing,
          prefix: nil
        }
    end
  end

  defp pkg_config_probe(package_name, toolchains, opts) do
    if toolchains.pkg_config.available? do
      case run_cmd(toolchains.pkg_config.path, ["--exists", package_name], opts) do
        {_, 0} ->
          {prefix_output, _} =
            run_cmd(toolchains.pkg_config.path, ["--variable=prefix", package_name], opts)

          %{
            package: package_name,
            available?: true,
            prefix: String.trim(prefix_output)
          }

        _other ->
          %{package: package_name, available?: false, prefix: nil}
      end
    else
      %{package: package_name, available?: false, prefix: nil}
    end
  end

  defp homebrew_prefix(package_name, opts) do
    brew_path = executable_probe("brew", opts).path

    case run_cmd(brew_path, ["--prefix", package_name], opts) do
      {output, 0} ->
        case String.trim(output) do
          "" -> nil
          trimmed -> trimmed
        end

      _other ->
        nil
    end
  end

  defp executable_probe(name, opts) do
    path = find_executable(name, opts)

    %{
      name: String.to_atom(String.replace(name, "-", "_")),
      path: path,
      available?: is_binary(path)
    }
  end

  defp env_map(opts) do
    opts
    |> Keyword.get(:env, System.get_env())
    |> Enum.into(%{})
  end

  defp find_executable(name, opts) do
    finder = Keyword.get(opts, :find_executable, &System.find_executable/1)
    finder.(name)
  end

  defp run_cmd(nil, _args, _opts), do: {"", 127}

  defp run_cmd(executable, args, opts) do
    runner = Keyword.get(opts, :run_cmd, &System.cmd/3)
    runner.(executable, args, stderr_to_stdout: true)
  rescue
    _error -> {"", 127}
  end

  defp file_exists?(path, opts) do
    checker = Keyword.get(opts, :file_exists?, &File.exists?/1)
    checker.(path)
  end
end
