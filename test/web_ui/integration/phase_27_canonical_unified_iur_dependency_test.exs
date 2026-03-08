defmodule WebUi.Integration.Phase27CanonicalUnifiedIurDependencyTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets
  alias WebUi.Iur.Dependency
  alias WebUi.Iur.Interpreter
  alias WebUi.TypedError

  @moduletag :conformance

  defp canonical_struct_input do
    %Layouts.VBox{
      id: :profile_root,
      spacing: 1,
      children: [
        %Widgets.Button{id: :save_button, label: "Save", on_click: :save},
        %Widgets.TextInput{
          id: :name_input,
          value: "",
          on_change: %{value: "Ada", action: "name_changed"},
          on_submit: {:submit_profile, %{source: "profile_form"}}
        }
      ]
    }
  end

  defp canonical_map_input do
    %{
      type: :vbox,
      id: :profile_root,
      spacing: 1,
      schema: "unified_iur",
      schema_source: "pcharbon70/unified_iur",
      schema_version: Dependency.dependency_version(),
      children: [
        %{
          type: :button,
          id: :save_button,
          label: "Save",
          on_click: :save,
          disabled: false,
          visible: true
        },
        %{
          type: :text_input,
          id: :name_input,
          value: "",
          placeholder: nil,
          input_type: nil,
          disabled: nil,
          visible: true,
          on_change: %{value: "Ada", action: "name_changed"},
          on_submit: {:submit_profile, %{source: "profile_form"}}
        }
      ]
    }
  end

  test "SCN-032 equivalent canonical Unified-IUR inputs normalize deterministically" do
    assert {:ok, interpreted_struct} = Interpreter.interpret(canonical_struct_input())
    assert {:ok, interpreted_map} = Interpreter.interpret(canonical_map_input())

    assert interpreted_struct.root == interpreted_map.root
    assert interpreted_struct.widgets == interpreted_map.widgets
    assert interpreted_struct.signals == interpreted_map.signals
    assert interpreted_struct.events == interpreted_map.events
  end

  test "SCN-032 unsupported schema/source markers fail closed with typed validation errors" do
    invalid_source_input =
      canonical_map_input()
      |> Map.put(:schema_source, "unknown/repo")

    assert {:error, %TypedError{} = source_error} =
             Interpreter.interpret(invalid_source_input, correlation_id: "corr-scn-032-source")

    assert source_error.error_code == "iur.interpreter.unsupported_schema_source"
    assert source_error.correlation_id == "corr-scn-032-source"

    invalid_version_input =
      canonical_map_input()
      |> Map.put(:schema_version, "0.0.0")

    assert {:error, %TypedError{} = version_error} =
             Interpreter.interpret(invalid_version_input, correlation_id: "corr-scn-032-version")

    assert version_error.error_code == "iur.interpreter.unsupported_schema_version"
    assert version_error.correlation_id == "corr-scn-032-version"
  end

  test "SCN-032 repeated equivalent canonical interpretation flows produce equivalent traces" do
    flow_trace = fn ->
      assert {:ok, interpreted} = Interpreter.interpret(canonical_struct_input())

      %{
        root: interpreted.root,
        widgets: interpreted.widgets,
        signals: interpreted.signals,
        events: interpreted.events
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
