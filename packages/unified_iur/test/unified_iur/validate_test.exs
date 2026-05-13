defmodule UnifiedIUR.ValidateTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Element, Interaction, Style, Validate}
  alias UnifiedIUR.Widgets.{Semantic, Workflow}

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

  test "rejects promoted widgets missing canonical required fields" do
    element =
      Element.new(:widget, :artifact_row,
        id: "artifact-row",
        attributes: %{artifact: %{title: "artifact.tar"}},
        children: []
      )

    assert {:error, [error]} = Validate.element(element)
    assert error.code == :missing_required_widget_field
    assert error.path == [:attributes, :artifact, :value]
  end

  test "rejects invalid promoted widget state combinations" do
    segmented =
      Semantic.segmented_button_group([compact: "Compact"],
        id: "view-modes",
        selection_mode: :none,
        active_item: :compact
      )

    meter = Workflow.meter_thin(120, id: "health-meter", maximum: 100)

    assert {:error, segmented_errors} = Validate.element(segmented)
    assert Enum.any?(segmented_errors, &(&1.code == :invalid_widget_state))

    assert {:error, meter_errors} = Validate.element(meter)
    assert Enum.any?(meter_errors, &(&1.code == :invalid_widget_state))
  end

  test "rejects opaque payloads in promoted widget attributes" do
    element =
      Element.new(:widget, :event_callout,
        id: "bad-callout",
        attributes: %{
          callout: %{
            message: "Build completed",
            on_acknowledge: fn -> :ok end
          }
        },
        children: []
      )

    assert {:error, [error]} = Validate.element(element)
    assert error.code == :unsupported_opaque_payload
    assert error.path == [:attributes, :callout, :on_acknowledge]
  end
end
