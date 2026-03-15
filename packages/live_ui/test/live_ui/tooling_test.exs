defmodule LiveUi.ToolingTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Container, Layout}
  alias UnifiedIUR.Widgets.Foundational

  defmodule StyledInspectableScreen do
    use LiveUi.Screen, id: :styled_inspectable, title: "Styled Inspectable"

    @impl true
    def mount_defaults do
      %{message: "Ready"}
    end

    @impl true
    def render(assigns) do
      assigns =
        assigns
        |> Map.put(
          :shell_style,
          LiveUi.Style.component_assigns(:screen_shell,
            theme: LiveUi.Theme.default(),
            variant: :workspace,
            class: "native-shell"
          )
        )
        |> Map.put(
          :text_style,
          LiveUi.Style.component_assigns(:text,
            theme: LiveUi.Theme.default(),
            tone: :success,
            class: "native-status"
          )
        )

      ~H"""
      <LiveUi.Widgets.ScreenShell.render id="styled-screen" title={title()} {@shell_style}>
        <LiveUi.Widgets.Text.render id="status" content={@message} {@text_style} />
      </LiveUi.Widgets.ScreenShell.render>
      """
    end
  end

  defp canonical_element do
    Container.box(
      [
        Layout.column([
          Foundational.text("Ready",
            id: "status",
            style: %{emphasis: %{tone: :success}, extra: %{class: "native-status"}},
            theme: %{id: :live_ui}
          )
        ])
      ],
      id: "styled-screen",
      style: %{extra: %{class: "native-shell"}},
      theme: %{id: :live_ui, variant: :panel}
    )
  end

  test "tooling inspects native and canonical runtime output through one snapshot shape" do
    assert {:ok, native} = LiveUi.Tooling.inspect_native(StyledInspectableScreen)
    assert {:ok, canonical} = LiveUi.Tooling.inspect_canonical(canonical_element())

    assert native.path == :native
    assert canonical.path == :canonical
    assert "screen-shell" in native.widgets
    assert "text" in native.widgets
    assert "box" in canonical.widgets
    assert "text" in canonical.widgets
    assert "success" in native.tones
    assert "success" in canonical.tones
  end

  test "tooling compares native and canonical outputs and reports continuity diagnostics" do
    assert {:ok, report} =
             LiveUi.Tooling.compare_native_and_canonical(
               StyledInspectableScreen,
               canonical_element()
             )

    assert "text" in report.shared_widgets
    assert report.continuity.runtime_model_aligned?
    assert report.continuity.tone_overlap?
    assert report.native_only_widgets != []
    assert report.canonical_only_widgets != []
    assert Enum.any?(report.diagnostics, &(&1.reason == :native_only_behavior))
    assert Enum.any?(report.diagnostics, &(&1.reason == :canonical_only_behavior))
  end
end
