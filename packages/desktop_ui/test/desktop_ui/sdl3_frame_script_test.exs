defmodule DesktopUi.Sdl3FrameScriptTest do
  use ExUnit.Case, async: true

  alias DesktopUi.Sdl3.{FrameScript, RenderPlan}

  test "frame scripts preserve window and draw operation semantics for visible runners" do
    {:ok, state} =
      DesktopUi.Runtime.mount_native_screen(DesktopUi.Examples.native_foundational_screen(),
        platform_target: :linux
      )

    assert {:ok, %RenderPlan{} = plan} = RenderPlan.build(state)
    assert {:ok, script} = FrameScript.encode(plan)

    assert script =~ "DESKTOP_UI_SDL3_FRAME"
    assert script =~ "WINDOW\twindow_id=window%3Aworkspace-foundation"
    assert script =~ "DRAW\twindow_id=window%3Aworkspace-foundation"
    assert script =~ "draw_kind=window_chrome"
    assert script =~ "units=logical"
  end
end
