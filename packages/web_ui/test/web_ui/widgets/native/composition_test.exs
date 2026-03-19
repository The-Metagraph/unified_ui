defmodule WebUi.Widgets.Native.CompositionTest do
  use ExUnit.Case

  alias WebUi.Widgets.Native.Composition

  defmodule MockWidget do
    defstruct [:id, :props, :state, :slots]
  end

  describe "slot/2" do
    test "creates an empty slot" do
      assert {:content, []} == Composition.slot(:content)
    end

    test "creates a slot with content" do
      widget = %MockWidget{id: :widget1}
      assert {:content, [widget]} == Composition.slot(:content, [widget])
    end
  end

  describe "add_to_slot/2" do
    test "adds a widget to a slot" do
      slot = Composition.slot(:content)
      widget = %MockWidget{id: :widget1}
      assert {:content, [widget]} == Composition.add_to_slot(slot, widget)
    end

    test "adds multiple widgets to a slot" do
      slot = Composition.slot(:content)
      widget1 = %MockWidget{id: :widget1}
      widget2 = %MockWidget{id: :widget2}

      slot = Composition.add_to_slot(slot, widget1)
      slot = Composition.add_to_slot(slot, widget2)

      assert {:content, [widget2, widget1]} == slot
    end
  end

  describe "merge_slots/1" do
    test "merges multiple slots into a map" do
      slot1 = Composition.slot(:content)
      slot2 = Composition.slot(:sidebar)

      slots = Composition.merge_slots([slot1, slot2])

      assert is_map(slots)
      assert Map.has_key?(slots, :content)
      assert Map.has_key?(slots, :sidebar)
    end

    test "handles empty list" do
      assert %{} == Composition.merge_slots([])
    end
  end

  describe "validate_required_slots/2" do
    test "validates when all required slots are present" do
      slots = %{content: [], sidebar: []}
      assert :ok = Composition.validate_required_slots(slots, [:content, :sidebar])
    end

    test "returns error when required slot is missing" do
      slots = %{content: []}
      assert {:error, {:sidebar, :missing}} = Composition.validate_required_slots(slots, [:content, :sidebar])
    end
  end

  describe "screen/2" do
    test "creates a screen with a root widget" do
      root = %MockWidget{id: :root}
      screen = Composition.screen(root)

      assert screen.root == root
      assert is_map(screen.slots)
      assert %DateTime{} = screen.created_at
    end

    test "creates a screen with slots" do
      root = %MockWidget{id: :root}
      slots = Composition.merge_slots([Composition.slot(:content)])
      screen = Composition.screen(root, slots)

      assert screen.root == root
      assert screen.slots == slots
    end
  end

  describe "find_widget/2" do
    setup do
      root = %MockWidget{id: :root}
      child1 = %MockWidget{id: :child1}
      child2 = %MockWidget{id: :child2}
      slots = %{content: [child1, child2]}
      screen = Composition.screen(root, slots)
      %{screen: screen}
    end

    test "finds the root widget", %{screen: screen} do
      assert {:ok, widget} = Composition.find_widget(screen, :root)
      assert widget.id == :root
    end

    test "finds a widget in slots", %{screen: screen} do
      assert {:ok, widget} = Composition.find_widget(screen, :child1)
      assert widget.id == :child1
    end

    test "returns error for non-existent widget", %{screen: screen} do
      assert {:error, :not_found} = Composition.find_widget(screen, :unknown)
    end
  end

  describe "list_widgets/1" do
    setup do
      root = %MockWidget{id: :root}
      child1 = %MockWidget{id: :child1}
      child2 = %MockWidget{id: :child2}
      slots = %{content: [child1, child2]}
      screen = Composition.screen(root, slots)
      %{screen: screen}
    end

    test "lists all widgets in the screen", %{screen: screen} do
      widgets = Composition.list_widgets(screen)
      assert length(widgets) == 3
      assert Enum.any?(widgets, fn w -> w.id == :root end)
      assert Enum.any?(widgets, fn w -> w.id == :child1 end)
      assert Enum.any?(widgets, fn w -> w.id == :child2 end)
    end
  end
end
