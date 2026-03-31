defmodule LiveUi.OverlayWidgetsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "overlay widgets render trigger, visibility, and placement semantics" do
    html =
      Phoenix.HTML.raw("""
      #{render_component(&LiveUi.Widgets.Dialog.render/1, %{id: "dialog", title: "Confirm", trigger: "open-settings", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Dialog body" end}]})}
      #{render_component(&LiveUi.Widgets.AlertDialog.render/1, %{id: "alert", title: "Delete", severity: "critical", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Alert body" end}]})}
      #{render_component(&LiveUi.Widgets.ContextMenu.render/1, %{id: "context", placement: "right-start", anchor: %{x: 12, y: 24}, items: [%{id: "rename", label: "Rename"}]})}
      #{render_component(&LiveUi.Widgets.Toast.render/1, %{id: "toast", severity: "success", placement: "bottom-end", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Saved" end}]})}
      """)
      |> Phoenix.HTML.safe_to_string()

    assert html =~ "data-live-ui-widget=\"dialog\""
    assert html =~ "data-live-ui-widget=\"alert-dialog\""
    assert html =~ "data-live-ui-widget=\"context-menu\""
    assert html =~ "data-live-ui-widget=\"toast\""
    assert html =~ "open-settings"
    assert html =~ "Saved"
  end

  test "overlay surfaces realize browser-visible scrim and panel styling" do
    html =
      Phoenix.HTML.raw("""
      #{render_component(&LiveUi.Widgets.OverlaySurface.render/1, %{id: "overlay", background_fill: "scrim", base: [%{__slot__: :base, inner_block: fn _, _ -> "Base" end}], overlay: [%{__slot__: :overlay, inner_block: fn _, _ -> render_component(&LiveUi.Widgets.Dialog.render/1, %{id: "dialog", size: "lg", title: "Confirm", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Dialog body" end}]}) end}]})}
      #{render_component(&LiveUi.Widgets.AlertDialog.render/1, %{id: "alert", severity: "critical", title: "Delete", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Alert body" end}]})}
      """)
      |> Phoenix.HTML.safe_to_string()

    assert html =~ "--live-ui-overlay-scrim: hsl(222 47% 11% / 0.76)"
    assert html =~ "--live-ui-width: 40rem"
    assert html =~ "--live-ui-padding: 1.5rem"
    assert html =~ "--live-ui-border-color: var(--live-ui-theme-critical)"
    assert html =~ "--live-ui-background: color-mix"
  end

  test "overlay widgets are registered in the native widget surface" do
    metadata = Enum.map(LiveUi.Widgets.overlay_modules(), &LiveUi.Component.metadata/1)

    assert Enum.any?(metadata, &(&1.name == :dialog and &1.family == :overlay))
    assert Enum.any?(metadata, &(&1.name == :toast and &1.family == :overlay))
  end
end
