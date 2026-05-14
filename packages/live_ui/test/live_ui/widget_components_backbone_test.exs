defmodule LiveUi.WidgetComponentsBackboneTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias LiveUi.Component
  alias LiveUi.Widgets.Components

  test "component registry covers the canonical widget-component catalog" do
    canonical_kinds = UnifiedIUR.Widgets.Components.kinds() |> Enum.sort()
    native_kinds = Components.contracts() |> Map.keys() |> Enum.sort()

    assert native_kinds == canonical_kinds
    assert LiveUi.Widgets.component_modules() == Components.modules()

    for module <- Components.modules() do
      assert module in LiveUi.Widgets.modules()
    end
  end

  test "component modules expose mountable boundaries and assign contracts" do
    for {kind, contract} <- Components.contracts() do
      metadata = Component.metadata(contract.module)

      assert metadata.name == kind
      assert metadata.family == :components
      assert metadata.mountable?
      assert metadata.runtime_boundary == :live_component
      assert metadata.component_module == Module.concat([contract.module, :Component])

      for assign <- contract.assigns do
        assert assign in metadata.assigns
      end

      assert metadata.slots == contract.slots
      assert metadata.events == contract.events
      assert metadata.local_state_keys == contract.local_state_keys
    end
  end

  test "component helper delegates to the shared LiveComponent boundary" do
    html =
      render_component(&LiveUi.Widgets.Components.InlineRichTextHeading.component/1, %{
        id: "heading",
        level: "h2",
        segments: [%{type: :text, value: "Canonical components"}]
      })

    assert html =~ "data-live-ui-widget-boundary=\"inline_rich_text_heading\""
    assert html =~ "data-live-ui-widget=\"inline_rich_text_heading\""
    assert html =~ "data-live-ui-component-family=\"content_identity\""
    assert html =~ "Canonical components"
  end
end
