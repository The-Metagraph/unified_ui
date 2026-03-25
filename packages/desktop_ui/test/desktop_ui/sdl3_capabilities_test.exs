defmodule DesktopUi.Sdl3CapabilitiesTest do
  use ExUnit.Case, async: true

  alias DesktopUi.Sdl3.{Capabilities, NativeBuild}

  test "native build surface exposes deterministic source and executable paths" do
    contract = NativeBuild.contract()
    recipe = NativeBuild.build_recipe()

    assert String.ends_with?(
             contract.source_root,
             "packages/desktop_ui/native/desktop_ui_sdl3_host"
           )

    assert String.ends_with?(contract.output_root, "packages/desktop_ui/priv/native")
    assert String.ends_with?(contract.executable_path, NativeBuild.executable_name())
    assert recipe.validation_state == :native_build_surface_ready
    assert Enum.any?(recipe.source_files, &String.ends_with?(&1, "src/main.c"))
  end

  test "capability detection recommends fallback host when no toolchain or executable is present" do
    result =
      Capabilities.detect(
        env: %{},
        find_executable: fn _ -> nil end,
        file_exists?: fn _ -> false end,
        run_cmd: fn _exe, _args, _opts -> {"", 127} end
      )

    assert result.backend.recommended == :elixir_host
    assert result.backend.available == [:elixir_host]
    refute result.build.buildable?
    refute result.build.executable_present?
    refute result.toolchains.cc.available?
    refute result.libraries.sdl3.available?
  end

  test "capability detection keeps fallback recommended when compiled host exists but is not launch ready" do
    result =
      Capabilities.detect(
        env: %{"DESKTOP_UI_SDL3_HOST" => "/tmp/desktop_ui_sdl3_host"},
        find_executable: fn
          "cc" -> "/usr/bin/cc"
          "pkg-config" -> "/usr/bin/pkg-config"
          _other -> nil
        end,
        file_exists?: fn
          "/tmp/desktop_ui_sdl3_host" -> true
          _other -> false
        end,
        run_cmd: fn
          "/tmp/desktop_ui_sdl3_host", ["--probe"], _opts ->
            {"{\"status\":\"build_ready\",\"launch_ready\":false,\"backend\":\"compiled_sdl3_host\"}\n",
             0}

          "/usr/bin/pkg-config", ["--exists", "sdl3"], _opts ->
            {"", 0}

          "/usr/bin/pkg-config", ["--variable=prefix", "sdl3"], _opts ->
            {"/opt/sdl3\n", 0}

          "/usr/bin/pkg-config", ["--exists", package], _opts
          when package in ["sdl3_ttf", "sdl3_image"] ->
            {"", 1}

          "/usr/bin/pkg-config", ["--variable=prefix", _package], _opts ->
            {"", 1}
        end
      )

    assert result.backend.recommended == :elixir_host
    assert result.backend.available == [:compiled_sdl3_host, :elixir_host]
    assert result.build.executable_present?
    assert result.build.executable_path == "/tmp/desktop_ui_sdl3_host"
    refute result.build.launch_ready?
    assert result.libraries.sdl3.available?
    refute result.libraries.sdl3_ttf.available?
    refute result.libraries.sdl3_image.available?
  end

  test "capability detection recommends compiled host once probe reports launch readiness" do
    result =
      Capabilities.detect(
        env: %{"DESKTOP_UI_SDL3_HOST" => "/tmp/desktop_ui_sdl3_host"},
        find_executable: fn
          "cc" -> "/usr/bin/cc"
          "pkg-config" -> "/usr/bin/pkg-config"
          _other -> nil
        end,
        file_exists?: fn
          "/tmp/desktop_ui_sdl3_host" -> true
          _other -> false
        end,
        run_cmd: fn
          "/tmp/desktop_ui_sdl3_host", ["--probe"], _opts ->
            {"{\"status\":\"protocol_ready\",\"launch_ready\":true,\"backend\":\"compiled_sdl3_host\"}\n",
             0}

          "/usr/bin/pkg-config", ["--exists", "sdl3"], _opts ->
            {"", 0}

          "/usr/bin/pkg-config", ["--variable=prefix", "sdl3"], _opts ->
            {"/opt/sdl3\n", 0}

          "/usr/bin/pkg-config", ["--exists", package], _opts
          when package in ["sdl3_ttf", "sdl3_image"] ->
            {"", 1}

          "/usr/bin/pkg-config", ["--variable=prefix", _package], _opts ->
            {"", 1}
        end
      )

    assert result.backend.recommended == :compiled_sdl3_host
    assert result.build.launch_ready?
  end
end
