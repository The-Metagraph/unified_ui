defmodule LiveUi.ExamplesTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "example catalog keeps native and canonical foundational paths paired" do
    catalog = LiveUi.Examples.catalog()

    assert Enum.any?(
             catalog,
             &(&1.id == :native_display and &1.comparable_to == :canonical_display)
           )

    assert Enum.any?(catalog, &(&1.id == :canonical_form and &1.comparable_to == :native_form))

    assert Enum.any?(
             catalog,
             &(&1.id == :canonical_navigation and &1.comparable_to == :native_navigation)
           )
  end

  test "native and canonical examples render through their intended package paths" do
    native_html =
      render_component(&LiveUi.Examples.NativeFormScreen.render/1, %{name: "Pascal"})

    canonical_html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: LiveUi.Examples.CanonicalForm.element()
      })

    assert native_html =~ "data-live-ui-widget=\"form-builder\""
    assert canonical_html =~ "data-live-ui-widget=\"form-builder\""
    assert canonical_html =~ "Pascal"
  end

  test "tooling exposes maintained example metadata" do
    example_ids = Enum.map(LiveUi.Tooling.examples(), & &1.id)

    assert :native_display in example_ids
    assert :canonical_display in example_ids
  end
end
