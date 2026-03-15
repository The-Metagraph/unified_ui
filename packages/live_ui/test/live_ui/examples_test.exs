defmodule LiveUi.ExamplesTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  alias Jido.Signal

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

    assert Enum.any?(
             catalog,
             &(&1.id == :native_boundary and &1.comparable_to == :canonical_boundary)
           )

    assert Enum.any?(
             catalog,
             &(&1.id == :canonical_boundary and &1.comparable_to == :native_boundary)
           )

    assert Enum.any?(catalog, &(&1.id == :boundary_transport_compare and &1.path == :mixed))
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

  test "transport examples keep local, native-boundary, and canonical-boundary flows visible" do
    assert {:ok, native_local} =
             LiveUi.Transport.translate_native(
               LiveUi.Examples.NativeBoundaryScreen.local_event_example()
             )

    assert native_local.signal == nil

    assert {:ok, native_boundary} =
             LiveUi.Transport.translate_native(
               LiveUi.Examples.NativeBoundaryScreen.boundary_event_example()
             )

    assert %Signal{} = native_boundary.signal

    assert {:ok, canonical_boundary} = LiveUi.Examples.CanonicalBoundaryProfile.translation()
    assert %Signal{} = canonical_boundary.signal

    assert {:ok, comparison} = LiveUi.Examples.MixedBoundaryTransport.compare_paths()

    assert comparison.native_local.signal == nil
    assert comparison.native_boundary.runtime_event == "rename"
    assert comparison.runtime_action.runtime_event == "rename"
  end

  test "tooling exposes maintained example metadata" do
    example_ids = Enum.map(LiveUi.Tooling.examples(), & &1.id)

    assert :native_display in example_ids
    assert :canonical_display in example_ids
    assert :boundary_transport_compare in example_ids
  end
end
