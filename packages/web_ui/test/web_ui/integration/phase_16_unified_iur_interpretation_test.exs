defmodule WebUi.Integration.Phase16UnifiedIurInterpretationTest do
  use ExUnit.Case, async: true

  alias WebUi.Iur.Interpreter
  alias WebUi.TypedError

  @moduletag :conformance

  test "SCN-021 equivalent IUR inputs normalize deterministically" do
    atom_input = %{
      type: :vbox,
      id: :profile_root,
      children: [
        %{type: :button, id: :save_button, label: "Save", on_click: :save},
        %{
          type: :text_input,
          id: :name_input,
          value: "",
          on_change: %{value: "Ada", action: "name_changed"},
          on_submit: {:submit_profile, %{source: "profile_form"}}
        }
      ]
    }

    string_input = %{
      "type" => "vbox",
      "id" => "profile_root",
      "children" => [
        %{"type" => "button", "id" => "save_button", "label" => "Save", "on_click" => "save"},
        %{
          "type" => "text_input",
          "id" => "name_input",
          "value" => "",
          "on_change" => %{"value" => "Ada", "action" => "name_changed"},
          "on_submit" => %{"action" => "submit_profile", "source" => "profile_form"}
        }
      ]
    }

    assert {:ok, interpreted_a} = Interpreter.interpret(atom_input)
    assert {:ok, interpreted_b} = Interpreter.interpret(string_input)

    assert interpreted_a.root == interpreted_b.root
    assert interpreted_a.widgets == interpreted_b.widgets
    assert interpreted_a.signals == interpreted_b.signals
    assert interpreted_a.events == interpreted_b.events
  end

  test "SCN-021 extracts canonical button and text-input events from IUR signals" do
    iur = %{
      type: :hbox,
      id: :toolbar,
      children: [
        %{type: :button, id: :run_button, on_click: %{action: "run"}},
        %{
          type: :text_input,
          id: :query_input,
          on_change: %{value: "status:ok", action: "filter_changed"}
        },
        %{type: :text_input, id: :query_input, on_submit: %{action: "run_query"}}
      ]
    }

    assert {:ok, interpreted} = Interpreter.interpret(iur)

    assert Enum.map(interpreted.events, & &1.type) == [
             "unified.button.clicked",
             "unified.input.changed",
             "unified.form.submitted"
           ]

    assert Enum.at(interpreted.events, 0).data.action == "run"
    assert Enum.at(interpreted.events, 1).data.value == "status:ok"
    assert Enum.at(interpreted.events, 1).data.widget_id == "query_input"
    assert Enum.at(interpreted.events, 2).data.action == "run_query"
    assert Enum.at(interpreted.events, 2).data.form_id == "query_input"
  end

  test "SCN-021 malformed descriptors fail closed with typed validation errors" do
    malformed = %{
      type: :vbox,
      id: :bad_root,
      children: %{type: :button, id: :save_button}
    }

    assert {:error, %TypedError{} = error} =
             Interpreter.interpret(malformed, correlation_id: "corr-scn-021")

    assert error.error_code == "iur.interpreter.invalid_children"
    assert error.correlation_id == "corr-scn-021"
  end
end
