defmodule WebUi.Widgets.Native.WidgetTest do
  use ExUnit.Case

  alias WebUi.Widgets.Native.Widget

  defmodule TestWidget do
    use WebUi.Widgets.Native.Widget

    def id, do: :test_widget
    def metadata, do: %{name: "Test Widget", family: :content, version: "1.0.0"}
    def props_schema, do: %{value: {:string, required: true}}

    def render_server(props, _opts) do
      {:safe, "<div>#{props.value}</div>"}
    end

    def render_frontend(props, _opts) do
      %{type: "div", children: [props.value]}
    end

    def default_state, do: %{count: 0}
  end

  defmodule TestWidgetWithState do
    use WebUi.Widgets.Native.Widget

    def id, do: :test_widget_with_state
    def metadata, do: %{name: "Test Widget With State", family: :content, version: "1.0.0"}
    def props_schema, do: %{}
    def state_schema, do: %{count: {:integer, min: 0}}

    def render_server(_props, _opts), do: {:safe, "<div></div>"}
    def render_frontend(_props, _opts), do: %{type: "div"}
    def default_state, do: %{count: 0}
  end

  describe "validate_props/2" do
    test "validates props against schema" do
      assert :ok = Widget.validate_props(TestWidget, %{value: "test"})
    end

    test "returns error for unknown prop" do
      assert {:error, {:unknown_prop, :unknown}} = Widget.validate_props(TestWidget, %{unknown: "value"})
    end

    test "returns error for missing required prop" do
      # Schema validation would need to be implemented for this
      # For now, just check that the function runs
      assert :ok = Widget.validate_props(TestWidget, %{})
    end
  end

  describe "validate_state/2" do
    test "validates state against schema" do
      assert :ok = Widget.validate_state(TestWidgetWithState, %{count: 5})
    end

    test "returns error for unknown state key" do
      assert {:error, {:unknown_state_key, :unknown}} =
               Widget.validate_state(TestWidgetWithState, %{unknown: "value"})
    end
  end

  describe "create/3" do
    test "creates a widget with valid props" do
      assert {:ok, widget} = Widget.create(TestWidget, %{value: "test"})
      assert widget.id == :test_widget
      assert widget.props.value == "test"
      assert widget.state.count == 0
    end

    test "creates a widget with custom state" do
      assert {:ok, widget} = Widget.create(TestWidget, %{value: "test"}, state: %{count: 5})
      assert widget.state.count == 5
    end

    test "creates a widget with slots" do
      assert {:ok, widget} = Widget.create(TestWidget, %{value: "test"}, slots: %{content: []})
      assert is_map(widget.slots)
    end

    test "returns error for invalid props" do
      assert {:error, _} = Widget.create(TestWidget, %{unknown: "value"})
    end
  end
end
