defmodule UnifiedIUR.ValidateTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Element, Interaction, Style, Validate}

  defmodule LiveUi.NativeButton do
    defstruct [:id]
  end

  test "accepts canonical normalized attachment shapes" do
    element =
      Element.new(:widget, :button,
        id: "save-button",
        attributes: %{
          content: %{text: "Save"},
          style: Style.new(%{foreground: :accent}),
          interactions: [Interaction.click(intent: :save_profile)],
          bindings: [Binding.new(%{name: :profile, path: [:profile]})]
        },
        children: []
      )

    assert :ok = Validate.element(element)
  end

  test "rejects malformed attachment types with typed validation errors" do
    element =
      Element.new(:widget, :button,
        id: "save-button",
        attributes: %{
          style: %{foreground: :accent},
          interactions: [%{family: :click}]
        },
        children: []
      )

    assert {:error, errors} = Validate.element(element)

    assert Enum.any?(errors, &(&1.code == :invalid_style_attachment))
    assert Enum.any?(errors, &(&1.code == :invalid_interaction_attachment))
  end

  test "rejects runtime-local structs embedded in canonical values" do
    element =
      Element.new(:widget, :content,
        id: "native-wrapper",
        attributes: %{
          extra: %{native: %LiveUi.NativeButton{id: "button-1"}}
        },
        children: []
      )

    assert {:error, [error]} = Validate.element(element)
    assert error.code == :runtime_local_escape_hatch
  end
end
