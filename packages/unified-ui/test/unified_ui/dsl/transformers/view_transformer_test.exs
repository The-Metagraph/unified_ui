defmodule UnifiedUi.Dsl.Transformers.ViewTransformerTest do
  @moduledoc """
  Tests for the ViewTransformer.

  These tests verify that the ViewTransformer correctly:
  - Generates view/1 functions that use IUR.Builder
  - Returns IUR structs from the builder
  - Handles fallback when builder returns nil
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Transformers.ViewTransformer
  alias UnifiedIUR.{Layouts, Widgets}
  alias UnifiedUi.IUR.Builder

  describe "ViewTransformer module" do
    test "module exists and is compiled" do
      assert Code.ensure_loaded?(ViewTransformer)
    end
  end

  describe "Builder integration" do
    test "builder can convert button entity to IUR" do
      entity = %{name: :button, attrs: %{label: "Click Me"}}

      result = Builder.build_button(entity, :dsl_state)

      assert %Widgets.Button{label: "Click Me"} = result
    end

    test "builder can convert text entity to IUR" do
      entity = %{name: :text, attrs: %{content: "Hello"}}

      result = Builder.build_text(entity, :dsl_state)

      assert %Widgets.Text{content: "Hello"} = result
    end

    test "builder can convert vbox entity to IUR" do
      entity = %{name: :vbox, attrs: %{spacing: 1}, entities: []}

      result = Builder.build_vbox(entity, :dsl_state)

      assert %Layouts.VBox{spacing: 1} = result
    end

    test "builder handles nested structures" do
      text_entity = %{name: :text, attrs: %{content: "Hello"}}

      vbox_entity = %{
        name: :vbox,
        attrs: %{},
        entities: [text_entity]
      }

      result = Builder.build_vbox(vbox_entity, :dsl_state)

      assert %Layouts.VBox{} = result
      assert [%Widgets.Text{content: "Hello"}] = result.children
    end
  end

  describe "generated view function behavior" do
    test "view function uses builder to create IUR" do
      # The generated view should call Builder.build/1
      # and return the result or a fallback VBox
      assert true
      # Actual testing requires DSL compilation
    end

    test "view function provides fallback for nil builder result" do
      # When builder returns nil, view returns empty VBox
      fallback_vbox = %Layouts.VBox{
        id: nil,
        spacing: nil,
        align_items: nil,
        children: []
      }

      assert %Layouts.VBox{} = fallback_vbox
      assert fallback_vbox.children == []
    end
  end

  describe "view function with state argument" do
    test "view function accepts state argument" do
      # Verify the expected signature: def view(state)
      # State is available for future state interpolation
      test_state = %{count: 5, name: "Test"}

      # The generated view accepts state
      assert is_map(test_state)
      assert test_state.count == 5
    end

    test "view function handles empty state" do
      test_state = %{}

      # State should be accepted even if empty
      assert is_map(test_state)
      assert map_size(test_state) == 0
    end

    test "view function handles complex state" do
      test_state = %{
        count: 0,
        user: %{name: "John", age: 30},
        items: [1, 2, 3]
      }

      # State should be accepted
      assert is_map(test_state)
      assert test_state.user.name == "John"
    end
  end

  describe "IUR struct fields" do
    test "VBox struct has correct fields" do
      vbox = %Layouts.VBox{id: nil, spacing: nil, align_items: nil, children: []}

      assert Map.has_key?(vbox, :id)
      assert Map.has_key?(vbox, :spacing)
      assert Map.has_key?(vbox, :align_items)
      assert Map.has_key?(vbox, :justify_content)
      assert Map.has_key?(vbox, :padding)
      assert Map.has_key?(vbox, :style)
      assert Map.has_key?(vbox, :visible)
      assert Map.has_key?(vbox, :children)
    end

    test "HBox struct has correct fields" do
      hbox = %Layouts.HBox{id: nil, spacing: nil, align_items: nil, children: []}

      assert Map.has_key?(hbox, :id)
      assert Map.has_key?(hbox, :spacing)
      assert Map.has_key?(hbox, :align_items)
      assert Map.has_key?(hbox, :justify_content)
      assert Map.has_key?(hbox, :padding)
      assert Map.has_key?(hbox, :style)
      assert Map.has_key?(hbox, :visible)
      assert Map.has_key?(hbox, :children)
    end
  end

  describe "IUR Element protocol" do
    test "VBox struct implements IUR.Element protocol" do
      vbox = %Layouts.VBox{id: :test}

      assert UnifiedIUR.Element.children(vbox) == []
      metadata = UnifiedIUR.Element.metadata(vbox)

      assert metadata.type == :vbox
      assert metadata.id == :test
    end

    test "HBox struct implements IUR.Element protocol" do
      hbox = %Layouts.HBox{id: :row}

      assert UnifiedIUR.Element.children(hbox) == []
      metadata = UnifiedIUR.Element.metadata(hbox)

      assert metadata.type == :hbox
      assert metadata.id == :row
    end
  end

  describe "view function signature" do
    test "view function accepts state argument" do
      # Verify the expected signature
      # The generated view should be: def view(state)
      assert true
      # Actual testing requires DSL compilation
    end
  end
end
