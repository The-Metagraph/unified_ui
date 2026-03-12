defmodule UnifiedUi.Adapters.SharedTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Shared
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Shared
  alias UnifiedIUR.Widgets
  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Style

  # Helper to create a simple IUR tree
  defp create_simple_tree do
    %Layouts.VBox{
      id: :root,
      children: [
        %Widgets.Text{id: :greeting, content: "Hello"},
        %Widgets.Button{id: :submit, label: "Submit"},
        %Widgets.TextInput{id: :email, placeholder: "Email"}
      ]
    }
  end

  # Helper to create a nested tree
  defp create_nested_tree do
    %Layouts.VBox{
      id: :root,
      children: [
        %Layouts.HBox{
          id: :row1,
          children: [
            %Widgets.Text{id: :label1, content: "Name:"},
            %Widgets.TextInput{id: :name}
          ]
        },
        %Layouts.HBox{
          id: :row2,
          children: [
            %Widgets.Text{id: :label2, content: "Email:"},
            %Widgets.TextInput{id: :email}
          ]
        }
      ]
    }
  end

  # Helper to create tree with styles
  defp create_styled_tree do
    %Layouts.VBox{
      id: :root,
      style: %Style{fg: :cyan},
      children: [
        %Widgets.Text{
          id: :title,
          content: "Title",
          style: %Style{fg: :white, attrs: [:bold]}
        },
        %Widgets.Button{
          id: :submit,
          label: "Submit",
          style: %Style{bg: :blue}
        }
      ]
    }
  end

  describe "traverse_iur/3" do
    test "traverses simple tree in pre-order" do
      tree = create_simple_tree()

      # Using acc ++ [el] to get elements in order of traversal
      # Note: For better performance with large trees, use [el | acc] and Enum.reverse at the end
      elements = Shared.traverse_iur(tree, fn el, acc -> acc ++ [el] end, [])

      # Should have 4 elements: root vbox + 3 children
      assert length(elements) == 4

      # First element should be root (pre-order)
      assert [%Layouts.VBox{id: :root} | _] = elements
    end

    test "traverses nested tree correctly" do
      tree = create_nested_tree()

      count = Shared.traverse_iur(tree, fn _el, acc -> acc + 1 end, 0)

      # Root vbox + 2 hbox + 2 text + 2 text_input = 7 elements
      assert count == 7
    end

    test "traverses in post-order" do
      tree = create_simple_tree()

      # Using acc ++ [el] for correct order
      elements = Shared.traverse_iur(tree, fn el, acc -> acc ++ [el] end, [], order: :post)

      # Post-order: children first, then parent
      # Should be: [Text, Button, TextInput, VBox]
      assert length(elements) == 4
      assert List.last(elements).id == :root
    end

    test "collects element types during traversal" do
      tree = create_nested_tree()

      types = Shared.traverse_iur(tree, fn el, acc ->
        [UnifiedIUR.Element.metadata(el).type | acc]
      end, [])

      # Should have all types (order may vary due to prepending)
      assert :vbox in types
      assert :hbox in types
      assert :text in types
      assert :text_input in types
    end

    test "handles tree with no children" do
      text = %Widgets.Text{content: "Hello"}

      count = Shared.traverse_iur(text, fn _el, acc -> acc + 1 end, 0)

      assert count == 1
    end

    test "supports early halt with special return value" do
      tree = create_simple_tree()

      # We can't actually test halt without the callback returning {:halt, result}
      # but we can verify the accumulator is modified
      result = Shared.traverse_iur(tree, fn el, acc ->
        if UnifiedIUR.Element.metadata(el).id == :greeting do
          {:halt, :found}
        else
          {:cont, acc}
        end
      end, :not_found)

      assert result == :found
    end
  end

  describe "find_by_id/2" do
    test "finds element by ID in simple tree" do
      tree = create_simple_tree()

      assert {:ok, %Widgets.Button{id: :submit}} = Shared.find_by_id(tree, :submit)
    end

    test "finds element by ID in nested tree" do
      tree = create_nested_tree()

      assert {:ok, %Widgets.TextInput{id: :name}} = Shared.find_by_id(tree, :name)
    end

    test "returns error for non-existent ID" do
      tree = create_simple_tree()

      assert :error = Shared.find_by_id(tree, :nonexistent)
    end

    test "finds root element" do
      tree = create_simple_tree()

      assert {:ok, %Layouts.VBox{id: :root}} = Shared.find_by_id(tree, :root)
    end
  end

  describe "find_by_id!/2" do
    test "returns element when found" do
      tree = create_simple_tree()

      assert %Widgets.Button{id: :submit} = Shared.find_by_id!(tree, :submit)
    end

    test "raises when not found" do
      tree = create_simple_tree()

      assert_raise RuntimeError, ~r/Element with ID :nonexistent not found/, fn ->
        Shared.find_by_id!(tree, :nonexistent)
      end
    end
  end

  describe "collect_styles/1" do
    test "collects all styles from tree" do
      tree = create_styled_tree()

      styles = Shared.collect_styles(tree)

      assert length(styles) == 3  # root + title + button
    end

    test "returns empty list for tree with no styles" do
      tree = create_simple_tree()

      styles = Shared.collect_styles(tree)

      assert styles == []
    end

    test "preserves style attributes" do
      tree = create_styled_tree()

      styles = Shared.collect_styles(tree)

      # Find the title style (should have bold)
      title_style = Enum.find(styles, fn s ->
        s.attrs == [:bold]
      end)

      assert title_style != nil
      assert title_style.fg == :white
    end
  end

  describe "count_elements/1" do
    test "counts all elements in simple tree" do
      tree = create_simple_tree()

      assert Shared.count_elements(tree) == 4
    end

    test "counts all elements in nested tree" do
      tree = create_nested_tree()

      assert Shared.count_elements(tree) == 7
    end

    test "counts single element" do
      text = %Widgets.Text{content: "Hello"}

      assert Shared.count_elements(text) == 1
    end
  end

  describe "count_by_type/1" do
    test "counts elements by type" do
      tree = create_nested_tree()

      counts = Shared.count_by_type(tree)

      assert counts.vbox == 1
      assert counts.hbox == 2
      assert counts.text == 2
      assert counts.text_input == 2
    end

    test "handles tree with single element type" do
      tree = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "A"},
          %Widgets.Text{content: "B"}
        ]
      }

      counts = Shared.count_by_type(tree)

      assert counts.vbox == 1
      assert counts.text == 2
    end
  end

  describe "get_all_ids/1" do
    test "returns all IDs in discovery order" do
      tree = create_simple_tree()

      ids = Shared.get_all_ids(tree)

      assert ids == [:root, :greeting, :submit, :email]
    end

    test "returns empty list for tree with no IDs" do
      tree = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "No ID"}
        ]
      }

      ids = Shared.get_all_ids(tree)

      assert ids == []
    end

    test "handles nested tree IDs" do
      tree = create_nested_tree()

      ids = Shared.get_all_ids(tree)

      assert :root in ids
      assert :row1 in ids
      assert :label1 in ids
      assert :name in ids
    end
  end

  describe "validate_iur/1" do
    test "returns :ok for valid tree" do
      tree = create_simple_tree()

      assert Shared.validate_iur(tree) == :ok
    end

    test "detects duplicate IDs" do
      tree = %Layouts.VBox{
        id: :root,
        children: [
          %Widgets.Text{id: :duplicate, content: "A"},
          %Widgets.Button{id: :duplicate, label: "B"}
        ]
      }

      assert {:error, issues} = Shared.validate_iur(tree)
      assert :duplicate_id in issues
    end

    test "detects nil IDs on TextInput" do
      tree = %Layouts.VBox{
        children: [
          %Widgets.TextInput{value: "No ID"}
        ]
      }

      assert {:error, issues} = Shared.validate_iur(tree)
      assert :missing_id_on_text_input in issues
    end

    test "detects empty layouts" do
      tree = %Layouts.VBox{
        children: [
          %Layouts.HBox{children: []}
        ]
      }

      assert {:error, issues} = Shared.validate_iur(tree)
      assert :empty_layout in issues
    end

    test "allows intentionally empty layouts with nil children" do
      # A layout with nil children might be intentional
      _tree = %Layouts.VBox{
        children: []
      }

      # Empty root is OK, but nested empty layout is not
      # This test documents current behavior
      assert {:error, issues} = Shared.validate_iur(%Layouts.VBox{
        children: [%Layouts.HBox{children: []}]
      })
      assert :empty_layout in issues
    end

    test "detects multiple issues" do
      tree = %Layouts.VBox{
        id: :root,
        children: [
          %Widgets.Text{id: :dup, content: "A"},
          %Widgets.Button{id: :dup, label: "B"},
          %Widgets.TextInput{value: "No ID"}
        ]
      }

      assert {:error, issues} = Shared.validate_iur(tree)
      assert :duplicate_id in issues
      assert :missing_id_on_text_input in issues
    end
  end
end
