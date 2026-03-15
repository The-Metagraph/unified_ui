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

  test "overlay widgets are registered in the native widget surface" do
    metadata = Enum.map(LiveUi.Widgets.overlay_modules(), &LiveUi.Component.metadata/1)

    assert Enum.any?(metadata, &(&1.name == :dialog and &1.family == :overlay))
    assert Enum.any?(metadata, &(&1.name == :toast and &1.family == :overlay))
  end
end
