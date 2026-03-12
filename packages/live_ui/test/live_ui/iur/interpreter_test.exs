defmodule LiveUi.IUR.InterpreterTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Layouts, Widgets}
  alias LiveUi.IUR.Interpreter

  defmodule ExampleExtension do
    defstruct [:id, :kind, :label, :children, :on_click]
  end

  test "interprets canonical map payloads into normalized descriptor trees" do
    payload = %{
      "id" => "root",
      "kind" => "vbox",
      "props" => %{"style" => %{"gap" => 2}},
      "children" => [
        %{"id" => "copy", "kind" => "text", "text" => "Hello"},
        %{
          "id" => "button-1",
          "kind" => "button",
          "label" => "Increment",
          "on_click" => %{"intent" => "activate"}
        }
      ]
    }

    assert {:ok, descriptor} = Interpreter.interpret(payload)
    assert descriptor.id == "root"
    assert descriptor.kind == "vbox"
    assert descriptor.props["style"] == %{"gap" => 2}
    assert Enum.map(descriptor.children, & &1.kind) == ["text", "button"]

    button = Enum.at(descriptor.children, 1)
    assert button.props["label"] == "Increment"

    assert button.signal_bindings == [
             %{
               event: "on_click",
               widget_id: "button-1",
               widget_kind: "button",
               payload: %{"intent" => "activate"}
             }
           ]
  end

  test "accepts extension structs through the same traversal path" do
    payload = %ExampleExtension{
      id: "button-2",
      kind: :button,
      label: "Extension",
      on_click: %{intent: "activate"},
      children: []
    }

    assert {:ok, descriptor} = Interpreter.interpret(payload)
    assert descriptor.id == "button-2"
    assert descriptor.kind == "button"
    assert descriptor.props["label"] == "Extension"
    assert length(descriptor.signal_bindings) == 1
  end

  test "accepts canonical UnifiedIUR structs through the protocol traversal path" do
    payload =
      %Layouts.VBox{
        id: :root,
        spacing: 2,
        children: [
          %Widgets.Text{id: :copy, content: "Hello"},
          %Widgets.Button{id: :button_1, label: "Increment", on_click: :activate}
        ]
      }

    assert {:ok, descriptor} = Interpreter.interpret(payload)
    assert descriptor.id == "root"
    assert descriptor.kind == "vbox"
    assert descriptor.props["spacing"] == 2
    assert Enum.map(descriptor.children, & &1.kind) == ["text", "button"]

    assert Enum.at(descriptor.children, 1).signal_bindings == [
             %{
               event: "on_click",
               widget_id: "button_1",
               widget_kind: "button",
               payload: %{"intent" => "activate"}
             }
           ]
  end

  test "rejects unsupported node kinds explicitly" do
    assert {:error, error} =
             Interpreter.interpret(%{"id" => "bad-1", "kind" => "totally_unknown"})

    assert error.message =~ "unsupported"
  end
end
