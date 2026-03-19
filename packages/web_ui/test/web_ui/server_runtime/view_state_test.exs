defmodule WebUi.ServerRuntime.ViewStateTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.ViewState
  alias WebUi.Widgets.Foundational.{Text, Button}

  describe "from_widget/2" do
    test "creates view state from a single widget" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Hello"})

      assert view_state.root.type == "text"
      assert view_state.root.props.value == "Hello"
      assert view_state.root.widget_module == WebUi.Widgets.Foundational.Text
      assert is_binary(view_state.root.id)
      assert view_state.version == "1.0.0"
      assert is_binary(view_state.checksum)
    end

    test "creates deterministic widget IDs" do
      assert {:ok, view_state1} = ViewState.from_widget(Text, %{value: "Hello"})
      assert {:ok, view_state2} = ViewState.from_widget(Text, %{value: "Hello"})

      assert view_state1.root.id == view_state2.root.id
    end

    test "creates different IDs for different props" do
      assert {:ok, view_state1} = ViewState.from_widget(Text, %{value: "Hello"})
      assert {:ok, view_state2} = ViewState.from_widget(Text, %{value: "World"})

      assert view_state1.root.id != view_state2.root.id
    end

    test "includes base styles for widget type" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Test"})

      assert view_state.root.styles.font_weight == :normal
    end

    test "generates checksum for view state" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Test"})

      assert 32 == String.length(view_state.checksum)
    end
  end

  describe "to_frontend_map/1" do
    test "converts view state to frontend-compatible map" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Hello"})

      frontend_map = ViewState.to_frontend_map(view_state)

      assert Map.has_key?(frontend_map, :root)
      assert Map.has_key?(frontend_map, :widgets)
      assert frontend_map.version == "1.0.0"

      assert frontend_map.root.id == view_state.root.id
      assert frontend_map.root.type == "text"
      assert frontend_map.root.props.value == "Hello"
    end

    test "includes styles in frontend map" do
      assert {:ok, view_state} = ViewState.from_widget(Button, %{label: "Click"})

      frontend_map = ViewState.to_frontend_map(view_state)

      assert frontend_map.root.styles.cursor == :pointer
    end
  end

  describe "get_widget/2" do
    test "retrieves widget by ID" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Test"})

      assert {:ok, widget} = ViewState.get_widget(view_state, view_state.root.id)
      assert widget.type == "text"
    end

    test "returns error for non-existent widget" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Test"})

      assert :error = ViewState.get_widget(view_state, "non_existent_id")
    end
  end

  describe "update_widget_props/3" do
    test "updates widget props and generates new checksum" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Old"})

      assert {:ok, updated_state} =
               ViewState.update_widget_props(view_state, view_state.root.id, %{value: "New"})

      assert updated_state.widgets[view_state.root.id].props.value == "New"
      assert updated_state.checksum != view_state.checksum
    end

    test "returns error for non-existent widget ID" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Test"})

      assert :error = ViewState.update_widget_props(view_state, "bad_id", %{value: "New"})
    end
  end

  describe "base styles for widget types" do
    test "button has cursor pointer style" do
      assert {:ok, view_state} = ViewState.from_widget(Button, %{label: "Click"})
      assert view_state.root.styles.cursor == :pointer
    end

    test "text has font weight normal" do
      assert {:ok, view_state} = ViewState.from_widget(Text, %{value: "Text"})
      assert view_state.root.styles.font_weight == :normal
    end
  end
end
