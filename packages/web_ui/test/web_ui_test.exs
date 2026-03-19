defmodule WebUiTest do
  use ExUnit.Case

  doctest WebUi

  test "package_areas returns expected areas" do
    areas = WebUi.package_areas()

    assert :widgets in areas
    assert :server_runtime in areas
    assert :frontend_runtime in areas
    assert :renderer in areas
    assert :transport in areas
    assert :tooling in areas
  end

  test "info returns package summary" do
    info = WebUi.info()

    assert info.package == :web_ui
    assert info.runtime == :phoenix_elm_split
    assert is_list(info.areas)
  end

  test "reference returns package reference" do
    ref = WebUi.reference()

    assert is_map(ref.widgets)
    assert is_map(ref.server_runtime)
    assert is_map(ref.frontend_runtime)
    assert is_map(ref.renderer)
    assert is_map(ref.transport)
    assert is_map(ref.tooling)
  end
end
