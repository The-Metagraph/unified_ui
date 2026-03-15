defmodule LiveUi.StyleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "style resolution applies theme defaults and explicit overrides to native widgets" do
    theme = LiveUi.Theme.default()

    assigns =
      LiveUi.Style.component_assigns(:button,
        theme: theme,
        tone: :success,
        variant: :quiet,
        state: :active,
        class: "custom-button"
      )

    html =
      render_component(
        &LiveUi.Widgets.Button.render/1,
        %{
          id: "save",
          label: "Save"
        }
        |> Map.merge(assigns)
      )

    assert html =~ "data-live-ui-tone=\"success\""
    assert html =~ "data-live-ui-variant=\"quiet\""
    assert html =~ "data-live-ui-state=\"active\""
    assert html =~ "class=\"live-ui-button live-ui-button-quiet is-active custom-button\""
    assert html =~ "data-live-ui-theme=\"live_ui\""
  end

  test "style merging preserves parent continuity while allowing child overrides" do
    parent =
      LiveUi.Style.resolve(LiveUi.Theme.default(), :overlay_surface,
        variant: :modal,
        state: :active
      )

    child =
      LiveUi.Style.resolve(LiveUi.Theme.default(), :button,
        tone: :critical,
        class: "destructive"
      )

    merged = LiveUi.Style.merge(parent, child)

    assert merged.tone == "critical"
    assert merged.variant == "solid"
    assert merged.state == "active"
    assert merged.class =~ "live-ui-overlay-surface"
    assert merged.class =~ "live-ui-button"
    assert merged.class =~ "destructive"
  end

  test "style lowering can derive a native profile from canonical element attachments" do
    element =
      UnifiedIUR.Widgets.Foundational.button("Save",
        id: "save",
        style: %{
          emphasis: %{tone: :warning},
          extra: %{class: "canonical-warning"}
        },
        theme: %{id: :live_ui, variant: :quiet}
      )

    profile = LiveUi.Style.from_element(element)

    assert profile.component == :button
    assert profile.theme_id == :live_ui
    assert profile.tone == "warning"
    assert profile.variant == "quiet"
    assert profile.class =~ "live-ui-button"
    assert profile.class =~ "canonical-warning"
  end
end
