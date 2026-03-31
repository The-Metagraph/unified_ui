defmodule LiveUi.Phase9IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedIUR.{Container, Layout, Token}
  alias UnifiedIUR.Widgets.Foundational

  test "maintained styled continuity pairs stay browser-style aligned" do
    assert {:ok, continuity} = LiveUi.Examples.StyledContinuityComparison.compare()

    assert continuity.profile.browser_style.aligned?
    assert continuity.profile.continuity.browser_style_aligned?
    assert continuity.profile.diagnostics == []
    assert continuity.profile.native.browser_style.realized_fields != []
    assert continuity.profile.canonical.browser_style.entry_reports != []

    assert continuity.operations.browser_style.aligned?
    assert continuity.operations.continuity.browser_style_aligned?
    assert continuity.operations.diagnostics == []
    assert continuity.operations.native.browser_style.realized_fields != []
    assert continuity.operations.canonical.browser_style.entry_reports != []
  end

  test "style and artifact exports expose browser-realized output for review" do
    assert {:ok, style_output} = LiveUi.Export.example(:native_styled_profile, :style)
    assert style_output =~ "browser_style"
    assert style_output =~ "native_browser_style_nodes"
    assert style_output =~ "realized_entry_ids"

    assert {:ok, artifact_output} = LiveUi.Export.example(:native_styled_profile, :artifact)
    assert artifact_output =~ "browser_style_nodes"
    assert artifact_output =~ "html"
    assert artifact_output =~ "canonical"
  end

  test "inspection keeps unsupported ignored and unresolved style inputs reviewable" do
    assert {:ok, snapshot} = LiveUi.Tooling.inspect_canonical(diagnostic_element())

    assert "text.blink?" in snapshot.browser_style.unsupported_fields
    assert "state_variants.hovered" in snapshot.browser_style.ignored_fields
    assert "missing.panel" in snapshot.browser_style.unresolved_token_refs
    assert "status" in snapshot.browser_style.unsupported_entry_ids
    assert "status" in snapshot.browser_style.unresolved_reference_entry_ids

    node = Enum.find(snapshot.browser_style_nodes, &(&1.id == "status"))

    assert node.mode == "mixed"
    assert "--live-ui-foreground" in node.css_var_keys
  end

  test "demo workbench surfaces browser-style details for reviewed examples" do
    assert {:ok, demo} = LiveUi.Demo.run(example: :canonical_styled_profile)

    assert demo.view == :example
    assert demo.preview.mode == :html
    assert demo.preview.browser_style.realized_fields != []
    assert demo.preview.browser_style_nodes != []
    assert demo.html =~ "Browser Style Surface"
    assert demo.html =~ "Browser style nodes"
  end

  defp diagnostic_element do
    Container.box(
      [
        Layout.column([
          Foundational.text("Needs review",
            id: "status",
            style: %{
              foreground: "#10b981",
              text: %{blink?: true},
              state_variants: %{hovered: %{foreground: "#f97316"}}
            },
            theme: %{id: :live_ui, token_refs: [Token.ref([:missing, :panel])]}
          )
        ])
      ],
      id: "styled-screen",
      theme: %{id: :live_ui, variant: :panel}
    )
  end
end
