defmodule LiveUi.WidgetComponentsShellPrimitivesTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defp slot_text(slot, text) do
    %{__slot__: slot, inner_block: fn _, _ -> text end}
  end

  test "top_strip renders shell header with brand, context, and theme attrs" do
    html =
      render_component(&LiveUi.Widgets.Components.TopStrip.component/1, %{
        id: "top-strip",
        brand: "Ariston",
        context: "Workspace",
        theme: "dark",
        pane_open: false,
        inner_block: [slot_text(:inner_block, "nav-content")]
      })

    assert html =~ ~s(data-live-ui-shell-position="top")
    assert html =~ ~s(data-live-ui-theme="dark")
    assert html =~ "Ariston"
    assert html =~ "Workspace"
    assert html =~ "nav-content"
  end

  test "top_strip omits brand span when brand is empty" do
    html =
      render_component(&LiveUi.Widgets.Components.TopStrip.component/1, %{
        id: "strip-no-brand",
        brand: "",
        pane_open: false,
        inner_block: [slot_text(:inner_block, "")]
      })

    refute html =~ "data-live-ui-strip-brand"
  end

  test "mode_nav renders navigation with item labels and current state" do
    html =
      render_component(&LiveUi.Widgets.Components.ModeNav.component/1, %{
        id: "mode-nav",
        aria_label: "App modes",
        items: [
          %{value: "workspace", label: "Workspace", current?: true},
          %{value: "map", label: "Map", shortcut: "m"}
        ]
      })

    assert html =~ ~s(role="navigation")
    assert html =~ ~s(aria-label="App modes")
    assert html =~ ~s(data-live-ui-nav-value="workspace")
    assert html =~ ~s(aria-current="page")
    assert html =~ "Workspace"
    assert html =~ "Map"
    assert html =~ ~s(data-live-ui-nav-shortcut="m")
  end

  test "mode_nav item without current? has aria-current false" do
    html =
      render_component(&LiveUi.Widgets.Components.ModeNav.component/1, %{
        id: "mode-nav-2",
        items: [%{value: "docs", label: "Docs"}]
      })

    assert html =~ ~s(aria-current="false")
    refute html =~ ~s(aria-current="page")
  end

  test "sidebar_shell renders nav with collapsed data attribute" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarShell.component/1, %{
        id: "sidebar",
        collapsed: true,
        inner_block: [slot_text(:inner_block, "sections")]
      })

    assert html =~ ~s(data-live-ui-shell-position="side")
    assert html =~ ~s(data-live-ui-collapsed="true")
    assert html =~ ~s(aria-hidden="true")
    assert html =~ "sections"
  end

  test "sidebar_shell when expanded has aria-hidden false" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarShell.component/1, %{
        id: "sidebar-open",
        collapsed: false,
        inner_block: [slot_text(:inner_block, "")]
      })

    assert html =~ ~s(aria-hidden="false")
  end

  test "sidebar_section renders labeled section with action button" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarSection.component/1, %{
        id: "section",
        label: "Specs",
        action_label: "Add spec",
        action_glyph: "+",
        action_attrs: %{"phx-click" => "add_spec"},
        inner_block: [slot_text(:inner_block, "items")]
      })

    assert html =~ ~s(data-live-ui-shell-section)
    assert html =~ "Specs"
    assert html =~ ~s(aria-label="Add spec")
    assert html =~ "+"
    assert html =~ ~s(phx-click="add_spec")
    assert html =~ "items"
  end

  test "sidebar_section without action renders no action button" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarSection.component/1, %{
        id: "section-no-action",
        label: "Repos",
        inner_block: [slot_text(:inner_block, "")]
      })

    refute html =~ "data-live-ui-section-action"
  end

  test "sidebar_item renders selected item with aria-current page" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarItem.component/1, %{
        id: "item-selected",
        label: "metagraph",
        selected: true,
        inner_block: [slot_text(:inner_block, "")]
      })

    assert html =~ ~s(data-live-ui-shell-item)
    assert html =~ ~s(aria-current="page")
    assert html =~ "metagraph"
  end

  test "sidebar_item renders unselected item with aria-current false" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarItem.component/1, %{
        id: "item-unselected",
        label: "ariston-ui",
        selected: false,
        inner_block: [slot_text(:inner_block, "")]
      })

    assert html =~ ~s(aria-current="false")
    refute html =~ ~s(aria-current="page")
  end

  test "sidebar_item renders badge children in slot" do
    html =
      render_component(&LiveUi.Widgets.Components.SidebarItem.component/1, %{
        id: "item-with-badge",
        label: "inbox",
        selected: false,
        inner_block: [slot_text(:inner_block, "<span>3</span>")]
      })

    assert html =~ "inbox"
    assert html =~ "3"
  end

  test "unread_badge renders count with role status" do
    html =
      render_component(&LiveUi.Widgets.Components.UnreadBadge.component/1, %{
        id: "badge",
        count: 5,
        threshold: 99
      })

    assert html =~ ~s(role="status")
    assert html =~ ~s(data-live-ui-unread-count="5")
    assert html =~ ~s(aria-label="5 unread")
    assert html =~ "5"
  end

  test "unread_badge caps display at threshold" do
    html =
      render_component(&LiveUi.Widgets.Components.UnreadBadge.component/1, %{
        id: "badge-overflow",
        count: 150,
        threshold: 99
      })

    assert html =~ "99+"
    assert html =~ ~s(data-live-ui-unread-count="150")
  end

  test "unread_badge renders nothing when count is zero" do
    html =
      render_component(&LiveUi.Widgets.Components.UnreadBadge.component/1, %{
        id: "badge-zero",
        count: 0
      })

    refute html =~ ~s(role="status")
    refute html =~ "0"
  end

  test "command_palette renders overlay with open state and items" do
    html =
      render_component(&LiveUi.Widgets.Components.CommandPalette.component/1, %{
        id: "palette",
        open: true,
        items: [
          %{id: "goto-spec", label: "Go to spec", active: true},
          %{id: "new-doc", label: "New document", active: false}
        ],
        inner_block: [slot_text(:inner_block, "")]
      })

    assert html =~ ~s(role="dialog")
    assert html =~ ~s(aria-modal="true")
    assert html =~ ~s(aria-hidden="false")
    assert html =~ ~s(data-live-ui-palette-open="true")
    assert html =~ ~s(data-live-ui-palette-item="goto-spec")
    assert html =~ "Go to spec"
    assert html =~ "New document"
  end

  test "command_palette with open false has aria-hidden true" do
    html =
      render_component(&LiveUi.Widgets.Components.CommandPalette.component/1, %{
        id: "palette-closed",
        open: false,
        items: []
      })

    assert html =~ ~s(aria-hidden="true")
    assert html =~ ~s(data-live-ui-palette-open="false")
  end
end
