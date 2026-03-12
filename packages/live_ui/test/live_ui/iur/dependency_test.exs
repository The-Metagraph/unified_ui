defmodule LiveUi.IUR.DependencyTest do
  use ExUnit.Case, async: true

  alias LiveUi.IUR.Dependency

  test "accepts complete canonical schema markers" do
    assert :ok =
             Dependency.validate_markers(%{
               "schema" => "unified_iur",
               "source" => "unified-ui",
               "version" => "1.0.0",
               "kind" => "button"
             })

    assert Dependency.markers_present?(%{"schema" => "unified_iur"})
  end

  test "rejects incomplete marker sets" do
    assert {:error, error} =
             Dependency.validate_markers(%{"schema" => "unified_iur", "kind" => "button"})

    assert error.message =~ "incomplete"
  end

  test "does not treat ordinary widget source props as schema markers" do
    assert :ok = Dependency.validate_markers(%{"kind" => "log_viewer", "source" => "app.log"})
    refute Dependency.markers_present?(%{"kind" => "log_viewer", "source" => "app.log"})
  end

  test "rejects unsupported schema names" do
    assert {:error, error} =
             Dependency.validate_markers(%{
               "schema" => "other_schema",
               "source" => "unified-ui",
               "version" => "1.0.0"
             })

    assert error.message =~ "unsupported"
  end
end
