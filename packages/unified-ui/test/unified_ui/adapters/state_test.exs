defmodule UnifiedUi.Adapters.StateTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.State
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.State.StateError

  describe "new/2" do
    test "creates new state for terminal platform" do
      state = State.new(:terminal)

      assert state.platform == :terminal
      assert state.version == 1
      assert state.widgets == %{}
      assert state.root == nil
    end

    test "creates new state with opts" do
      root_pid = self()
      state = State.new(:desktop, root: root_pid, config: [title: "Test"])

      assert state.platform == :desktop
      assert state.root == root_pid
      assert state.config == [title: "Test"]
    end

    test "creates new state with initial widgets" do
      widget = self()
      state = State.new(:web, widgets: %{button: widget})

      assert State.get_widget(state, :button) == {:ok, widget}
    end
  end

  describe "root management" do
    setup do
      {:ok, state: State.new(:terminal)}
    end

    test "put_root/2 sets root widget", %{state: state} do
      root_pid = self()
      updated = State.put_root(state, root_pid)

      assert updated.root == root_pid
    end

    test "get_root/1 returns root when set", %{state: state} do
      root_pid = self()
      state = State.put_root(state, root_pid)

      assert {:ok, ^root_pid} = State.get_root(state)
    end

    test "get_root/1 returns error when not set", %{state: state} do
      assert :error = State.get_root(state)
    end

    test "get_root!/1 returns root when set", %{state: state} do
      root_pid = self()
      state = State.put_root(state, root_pid)

      assert State.get_root!(state) == root_pid
    end

    test "get_root!/1 raises when not set", %{state: state} do
      assert_raise StateError, "No root widget set in renderer state", fn ->
        State.get_root!(state)
      end
    end
  end

  describe "widget management" do
    setup do
      {:ok, state: State.new(:terminal)}
    end

    test "put_widget/3 registers a widget", %{state: state} do
      button_pid = self()
      updated = State.put_widget(state, :submit_button, button_pid)

      assert updated.widgets == %{submit_button: button_pid}
    end

    test "get_widget/2 returns registered widget", %{state: state} do
      button_pid = self()
      state = State.put_widget(state, :submit_button, button_pid)

      assert {:ok, ^button_pid} = State.get_widget(state, :submit_button)
    end

    test "get_widget/2 returns error for unregistered widget", %{state: state} do
      assert :error = State.get_widget(state, :nonexistent)
    end

    test "get_widget!/2 returns widget or raises", %{state: state} do
      button_pid = self()
      state = State.put_widget(state, :submit_button, button_pid)

      assert State.get_widget!(state, :submit_button) == button_pid

      assert_raise StateError, "No widget found for ID :nonexistent", fn ->
        State.get_widget!(state, :nonexistent)
      end
    end

    test "delete_widget/2 removes widget from registry", %{state: state} do
      button_pid = self()
      state = State.put_widget(state, :submit_button, button_pid)
      updated = State.delete_widget(state, :submit_button)

      refute Map.has_key?(updated.widgets, :submit_button)
      assert :error = State.get_widget(updated, :submit_button)
    end

    test "has_widget?/2 checks widget existence", %{state: state} do
      button_pid = self()
      state = State.put_widget(state, :submit_button, button_pid)

      assert State.has_widget?(state, :submit_button)
      refute State.has_widget?(state, :nonexistent)
    end

    test "widget_ids/1 returns all widget IDs", %{state: state} do
      state =
        state
        |> State.put_widget(:button1, self())
        |> State.put_widget(:button2, self())

      ids = State.widget_ids(state)

      assert :button1 in ids
      assert :button2 in ids
      assert length(ids) == 2
    end

    test "widget_count/1 returns number of widgets", %{state: state} do
      assert State.widget_count(state) == 0

      state =
        state
        |> State.put_widget(:button1, self())
        |> State.put_widget(:button2, self())

      assert State.widget_count(state) == 2
    end

    test "all_widgets/1 returns all widget references", %{state: state} do
      pid1 = self()
      pid2 = spawn(fn -> :timer.sleep(1000) end)

      state =
        state
        |> State.put_widget(:button1, pid1)
        |> State.put_widget(:button2, pid2)

      widgets = State.all_widgets(state)

      assert pid1 in widgets
      assert pid2 in widgets
      assert length(widgets) == 2
    end
  end

  describe "version management" do
    setup do
      {:ok, state: State.new(:terminal)}
    end

    test "bump_version/1 increments version", %{state: state} do
      assert state.version == 1

      updated = State.bump_version(state)
      assert updated.version == 2

      updated = State.bump_version(updated)
      assert updated.version == 3
    end
  end

  describe "config management" do
    setup do
      {:ok, state: State.new(:terminal, config: [window_title: "Test"])}
    end

    test "get_config/3 returns config value", %{state: state} do
      assert State.get_config(state, :window_title) == "Test"
    end

    test "get_config/3 returns default when not found", %{state: state} do
      assert State.get_config(state, :nonexistent, :default) == :default
    end

    test "get_config/3 returns nil as default", %{state: state} do
      assert State.get_config(state, :nonexistent) == nil
    end

    test "put_config/3 sets config value", %{state: state} do
      updated = State.put_config(state, :window_size, {80, 24})

      assert State.get_config(updated, :window_size) == {80, 24}
    end

    test "put_config/3 preserves existing config", %{state: state} do
      updated = State.put_config(state, :window_size, {80, 24})

      assert State.get_config(updated, :window_title) == "Test"
    end
  end

  describe "metadata management" do
    setup do
      {:ok, state: State.new(:terminal, metadata: %{last_render: 100})}
    end

    test "get_metadata/3 returns metadata value", %{state: state} do
      assert State.get_metadata(state, :last_render) == 100
    end

    test "get_metadata/3 returns default when not found", %{state: state} do
      assert State.get_metadata(state, :nonexistent, :default) == :default
    end

    test "put_metadata/3 sets metadata value", %{state: state} do
      updated = State.put_metadata(state, :last_update, 200)

      assert State.get_metadata(updated, :last_update) == 200
    end

    test "put_metadata/3 preserves existing metadata", %{state: state} do
      updated = State.put_metadata(state, :last_update, 200)

      assert State.get_metadata(updated, :last_render) == 100
    end
  end

  describe "to_map/1" do
    test "returns widget map" do
      pid1 = self()
      pid2 = spawn(fn -> :timer.sleep(1000) end)

      state =
        State.new(:terminal)
        |> State.put_widget(:button1, pid1)
        |> State.put_widget(:button2, pid2)

      widget_map = State.to_map(state)

      assert widget_map.button1 == pid1
      assert widget_map.button2 == pid2
      assert map_size(widget_map) == 2
    end
  end

  describe "platform?/2" do
    setup do
      {:ok, state: State.new(:terminal)}
    end

    test "returns true for matching platform", %{state: state} do
      assert State.platform?(state, :terminal)
    end

    test "returns false for different platform", %{state: state} do
      refute State.platform?(state, :desktop)
      refute State.platform?(state, :web)
    end
  end

  describe "StateError exception" do
    test "exception can be raised with reason: :no_root_widget" do
      assert_raise StateError, "No root widget set in renderer state", fn ->
        raise StateError, reason: :no_root_widget
      end
    end

    test "exception can be raised with reason: :widget_not_found and id" do
      assert_raise StateError, "No widget found for ID :my_button", fn ->
        raise StateError, reason: :widget_not_found, id: :my_button
      end
    end

    test "exception can be raised with reason: :widget_not_found without id" do
      assert_raise StateError, "No widget found for ID nil", fn ->
        raise StateError, reason: :widget_not_found
      end
    end

    test "exception has structured fields" do
      exception = StateError.exception(reason: :widget_not_found, id: :test_widget)

      assert exception.reason == :widget_not_found
      assert exception.id == :test_widget
      assert is_binary(exception.message)
    end

    test "exception message/1 returns the message" do
      exception = StateError.exception(reason: :no_root_widget)

      assert StateError.message(exception) == "No root widget set in renderer state"
    end
  end
end
