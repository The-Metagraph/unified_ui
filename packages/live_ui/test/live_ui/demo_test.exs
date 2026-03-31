defmodule LiveUi.DemoTest do
  use ExUnit.Case, async: true

  test "home workbench renders the package-local demo shell" do
    assert {:ok, demo} = LiveUi.Demo.run()

    assert demo.screen == LiveUi.Demo.Screen
    assert demo.view == :home
    assert demo.selected_category == :native
    assert demo.selected_example == nil
    assert demo.total_examples > 0
    assert demo.html =~ "Live UI Workbench"
    assert demo.html =~ ~s(data-live-ui-widget="screen-shell")
  end

  test "native example workbench renders a preview through the shared runtime" do
    assert {:ok, demo} = LiveUi.Demo.run(example: :native_styled_profile)

    assert demo.view == :example
    assert demo.selected_example.id == :native_styled_profile
    assert demo.selected_example.title == "Native Styled Profile"
    assert demo.preview.mode == :html
    assert demo.preview.html =~ "profile-shell"
    assert Enum.any?(demo.preview.widgets, &(&1.widget == "button"))
  end

  test "mixed example workbench renders a comparison report" do
    assert {:ok, demo} = LiveUi.Demo.run(example: :styled_continuity_compare)

    assert demo.selected_example.id == :styled_continuity_compare
    assert demo.preview.mode == :report
    assert demo.preview.report =~ "profile"
    assert demo.preview.report =~ "runtime_action"
  end
end
