defmodule LiveUi.WidgetComponentsContentFormTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defp slot_text(slot, text) do
    %{__slot__: slot, inner_block: fn _, _ -> text end}
  end

  test "content identity components render accessible safe native output" do
    heading =
      render_component(&LiveUi.Widgets.Components.InlineRichTextHeading.component/1, %{
        id: "heading",
        level: "h2",
        segments: [%{type: :text, value: "Safe <script>alert(1)</script>"}]
      })

    avatar =
      render_component(&LiveUi.Widgets.Components.Avatar.component/1, %{
        id: "avatar",
        initials: "PC",
        label: "Pascal Charbonneau",
        size: "small"
      })

    presence =
      render_component(&LiveUi.Widgets.Components.PresenceDot.component/1, %{
        id: "presence",
        presence: "active"
      })

    disclosure =
      render_component(&LiveUi.Widgets.Components.Disclosure.component/1, %{
        id: "details",
        summary: "More",
        open: true,
        inner_block: [slot_text(:inner_block, "Expanded body")]
      })

    assert heading =~ "role=\"heading\""
    assert heading =~ "aria-level=\"2\""
    assert heading =~ "Safe &lt;script&gt;alert(1)&lt;/script&gt;"
    refute heading =~ "<script>"

    assert avatar =~ "role=\"img\""
    assert avatar =~ "aria-label=\"Pascal Charbonneau\""
    assert avatar =~ "data-live-ui-avatar-size=\"small\""

    assert presence =~ "role=\"status\""
    assert presence =~ "aria-label=\"Presence active\""

    assert disclosure =~ "open"
    assert disclosure =~ "data-live-ui-open=\"true\""
    assert disclosure =~ "Expanded body"
  end

  test "form control components preserve native event hooks and state" do
    segmented =
      render_component(&LiveUi.Widgets.Components.SegmentedButtonGroup.component/1, %{
        id: "filter",
        label: "Status",
        active_value: "open",
        option_attrs: %{"phx-click" => "select_status"},
        options: [
          %{value: "all", label: "All"},
          %{value: "open", label: "Open", attrs: %{"phx-value-value" => "open"}}
        ]
      })

    form =
      render_component(&LiveUi.Widgets.Components.RuntimeFormShell.component/1, %{
        id: "runtime-form",
        fields: [
          %{name: "title", type: "text", label: "Title", attrs: %{"required" => "required"}}
        ],
        submit_label: "Save",
        validation_state: "invalid",
        host_adapter_hints: %{live_ui: %{adapter: :phoenix_form}},
        form_attrs: %{"phx-submit" => "save", "phx-change" => "validate"}
      })

    composer =
      render_component(&LiveUi.Widgets.Components.ChatComposer.component/1, %{
        id: "composer",
        name: "message",
        value: "Draft",
        placeholder: "Reply",
        disabled: true,
        input_attrs: %{"phx-change" => "draft"},
        send_attrs: %{"phx-click" => "send"},
        tools: [slot_text(:tools, "Attach")]
      })

    assert segmented =~ "role=\"group\""
    assert segmented =~ "aria-pressed=\"true\""
    assert segmented =~ "phx-click=\"select_status\""
    assert segmented =~ "phx-value-value=\"open\""

    assert form =~ "data-live-ui-host-adapter=\"phoenix_form\""
    assert form =~ "data-live-ui-validation-state=\"invalid\""
    assert form =~ "phx-submit=\"save\""
    assert form =~ "phx-change=\"validate\""
    assert form =~ "required=\"required\""

    assert composer =~ "name=\"message\""
    assert composer =~ "Draft"
    assert composer =~ "disabled"
    assert composer =~ "phx-change=\"draft\""
    assert composer =~ "phx-click=\"send\""
    assert composer =~ "Attach"
  end
end
