defmodule UnifiedUi.Dsl.Entities.NavigationTest do
  @moduledoc """
  Tests for the navigation DSL entities.

  These tests verify that:
  - All navigation entities are defined correctly
  - Navigation entities create the correct target structs
  - Navigation options are validated properly
  - Required arguments are enforced
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Navigation, as: NavigationEntities
  alias UnifiedIUR.Widgets

  # ============================================================================
  # Menu Item Entity Tests
  # ============================================================================

  describe "menu_item_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.menu_item_entity()

      assert %Spark.Dsl.Entity{name: :menu_item} = entity
      assert entity.target == Widgets.MenuItem
    end

    test "has correct schema with required label" do
      entity = NavigationEntities.menu_item_entity()

      label_schema = Keyword.get(entity.schema, :label)
      assert label_schema != nil
      assert Keyword.get(label_schema, :required) == true
    end

    test "has optional id option" do
      entity = NavigationEntities.menu_item_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == false
    end

    test "has optional action option" do
      entity = NavigationEntities.menu_item_entity()

      action_schema = Keyword.get(entity.schema, :action)
      assert action_schema != nil
      assert Keyword.get(action_schema, :required) == false
    end

    test "has optional disabled option with default" do
      entity = NavigationEntities.menu_item_entity()

      disabled_schema = Keyword.get(entity.schema, :disabled)
      assert disabled_schema != nil
      assert Keyword.get(disabled_schema, :default) == false
    end

    test "has optional icon option" do
      entity = NavigationEntities.menu_item_entity()

      icon_schema = Keyword.get(entity.schema, :icon)
      assert icon_schema != nil
      assert Keyword.get(icon_schema, :required) == false
    end

    test "has optional shortcut option" do
      entity = NavigationEntities.menu_item_entity()

      shortcut_schema = Keyword.get(entity.schema, :shortcut)
      assert shortcut_schema != nil
      assert Keyword.get(shortcut_schema, :required) == false
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.menu_item_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end
  end

  # ============================================================================
  # Menu Entity Tests
  # ============================================================================

  describe "menu_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.menu_entity()

      assert %Spark.Dsl.Entity{name: :menu} = entity
      assert entity.target == Widgets.Menu
    end

    test "has correct schema with required id" do
      entity = NavigationEntities.menu_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true
    end

    test "has optional title option" do
      entity = NavigationEntities.menu_entity()

      title_schema = Keyword.get(entity.schema, :title)
      assert title_schema != nil
      assert Keyword.get(title_schema, :required) == false
    end

    test "has optional position option" do
      entity = NavigationEntities.menu_entity()

      position_schema = Keyword.get(entity.schema, :position)
      assert position_schema != nil
      assert Keyword.get(position_schema, :required) == false
      assert {:one_of, positions} = Keyword.get(position_schema, :type)
      assert :top in positions
      assert :bottom in positions
      assert :left in positions
      assert :right in positions
    end

    test "has optional style option" do
      entity = NavigationEntities.menu_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.menu_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "has items nested entities" do
      entity = NavigationEntities.menu_entity()

      assert is_list(entity.entities)
      assert Keyword.has_key?(entity.entities, :items)
      assert is_list(Keyword.get(entity.entities, :items))
    end
  end

  # ============================================================================
  # Context Menu Entity Tests
  # ============================================================================

  describe "context_menu_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.context_menu_entity()

      assert %Spark.Dsl.Entity{name: :context_menu} = entity
      assert entity.target == Widgets.ContextMenu
    end

    test "has correct schema with required id" do
      entity = NavigationEntities.context_menu_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true
    end

    test "has optional trigger_on option with default" do
      entity = NavigationEntities.context_menu_entity()

      trigger_on_schema = Keyword.get(entity.schema, :trigger_on)
      assert trigger_on_schema != nil
      assert Keyword.get(trigger_on_schema, :default) == :right_click
      assert {:one_of, triggers} = Keyword.get(trigger_on_schema, :type)
      assert :right_click in triggers
      assert :long_press in triggers
      assert :double_click in triggers
    end

    test "has optional style option" do
      entity = NavigationEntities.context_menu_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.context_menu_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "has items nested entities" do
      entity = NavigationEntities.context_menu_entity()

      assert is_list(entity.entities)
      assert Keyword.has_key?(entity.entities, :items)
      assert is_list(Keyword.get(entity.entities, :items))
    end
  end

  # ============================================================================
  # Tab Entity Tests
  # ============================================================================

  describe "tab_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.tab_entity()

      assert %Spark.Dsl.Entity{name: :tab} = entity
      assert entity.target == Widgets.Tab
    end

    test "has correct schema with required id and label" do
      entity = NavigationEntities.tab_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true

      label_schema = Keyword.get(entity.schema, :label)
      assert label_schema != nil
      assert Keyword.get(label_schema, :required) == true
    end

    test "has optional icon option" do
      entity = NavigationEntities.tab_entity()

      icon_schema = Keyword.get(entity.schema, :icon)
      assert icon_schema != nil
      assert Keyword.get(icon_schema, :required) == false
    end

    test "has optional disabled option with default" do
      entity = NavigationEntities.tab_entity()

      disabled_schema = Keyword.get(entity.schema, :disabled)
      assert disabled_schema != nil
      assert Keyword.get(disabled_schema, :default) == false
    end

    test "has optional closable option with default" do
      entity = NavigationEntities.tab_entity()

      closable_schema = Keyword.get(entity.schema, :closable)
      assert closable_schema != nil
      assert Keyword.get(closable_schema, :default) == false
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.tab_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end
  end

  # ============================================================================
  # Tabs Entity Tests
  # ============================================================================

  describe "tabs_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.tabs_entity()

      assert %Spark.Dsl.Entity{name: :tabs} = entity
      assert entity.target == Widgets.Tabs
    end

    test "has correct schema with required id" do
      entity = NavigationEntities.tabs_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true
    end

    test "has optional active_tab option" do
      entity = NavigationEntities.tabs_entity()

      active_tab_schema = Keyword.get(entity.schema, :active_tab)
      assert active_tab_schema != nil
      assert Keyword.get(active_tab_schema, :required) == false
    end

    test "has optional position option with default" do
      entity = NavigationEntities.tabs_entity()

      position_schema = Keyword.get(entity.schema, :position)
      assert position_schema != nil
      assert Keyword.get(position_schema, :default) == :top
      assert {:one_of, positions} = Keyword.get(position_schema, :type)
      assert :top in positions
      assert :bottom in positions
      assert :left in positions
      assert :right in positions
    end

    test "has optional on_change option" do
      entity = NavigationEntities.tabs_entity()

      on_change_schema = Keyword.get(entity.schema, :on_change)
      assert on_change_schema != nil
      assert Keyword.get(on_change_schema, :required) == false
    end

    test "has optional style option" do
      entity = NavigationEntities.tabs_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.tabs_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "has tabs nested entities" do
      entity = NavigationEntities.tabs_entity()

      assert is_list(entity.entities)
      assert Keyword.has_key?(entity.entities, :tabs)
      assert is_list(Keyword.get(entity.entities, :tabs))
    end
  end

  # ============================================================================
  # Tree Node Entity Tests
  # ============================================================================

  describe "tree_node_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.tree_node_entity()

      assert %Spark.Dsl.Entity{name: :tree_node} = entity
      assert entity.target == Widgets.TreeNode
    end

    test "has correct schema with required id and label" do
      entity = NavigationEntities.tree_node_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true

      label_schema = Keyword.get(entity.schema, :label)
      assert label_schema != nil
      assert Keyword.get(label_schema, :required) == true
    end

    test "has optional value option" do
      entity = NavigationEntities.tree_node_entity()

      value_schema = Keyword.get(entity.schema, :value)
      assert value_schema != nil
      assert Keyword.get(value_schema, :required) == false
    end

    test "has optional expanded option with default" do
      entity = NavigationEntities.tree_node_entity()

      expanded_schema = Keyword.get(entity.schema, :expanded)
      assert expanded_schema != nil
      assert Keyword.get(expanded_schema, :default) == false
    end

    test "has optional icon option" do
      entity = NavigationEntities.tree_node_entity()

      icon_schema = Keyword.get(entity.schema, :icon)
      assert icon_schema != nil
      assert Keyword.get(icon_schema, :required) == false
    end

    test "has optional icon_expanded option" do
      entity = NavigationEntities.tree_node_entity()

      icon_expanded_schema = Keyword.get(entity.schema, :icon_expanded)
      assert icon_expanded_schema != nil
      assert Keyword.get(icon_expanded_schema, :required) == false
    end

    test "has optional selectable option with default" do
      entity = NavigationEntities.tree_node_entity()

      selectable_schema = Keyword.get(entity.schema, :selectable)
      assert selectable_schema != nil
      assert Keyword.get(selectable_schema, :default) == true
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.tree_node_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end
  end

  # ============================================================================
  # Tree View Entity Tests
  # ============================================================================

  describe "tree_view_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = NavigationEntities.tree_view_entity()

      assert %Spark.Dsl.Entity{name: :tree_view} = entity
      assert entity.target == Widgets.TreeView
    end

    test "has correct schema with required id" do
      entity = NavigationEntities.tree_view_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true
    end

    test "has optional selected_node option" do
      entity = NavigationEntities.tree_view_entity()

      selected_node_schema = Keyword.get(entity.schema, :selected_node)
      assert selected_node_schema != nil
      assert Keyword.get(selected_node_schema, :required) == false
    end

    test "has optional expanded_nodes option" do
      entity = NavigationEntities.tree_view_entity()

      expanded_nodes_schema = Keyword.get(entity.schema, :expanded_nodes)
      assert expanded_nodes_schema != nil
      assert Keyword.get(expanded_nodes_schema, :required) == false
    end

    test "has optional on_select option" do
      entity = NavigationEntities.tree_view_entity()

      on_select_schema = Keyword.get(entity.schema, :on_select)
      assert on_select_schema != nil
      assert Keyword.get(on_select_schema, :required) == false
    end

    test "has optional on_toggle option" do
      entity = NavigationEntities.tree_view_entity()

      on_toggle_schema = Keyword.get(entity.schema, :on_toggle)
      assert on_toggle_schema != nil
      assert Keyword.get(on_toggle_schema, :required) == false
    end

    test "has optional show_root option with default" do
      entity = NavigationEntities.tree_view_entity()

      show_root_schema = Keyword.get(entity.schema, :show_root)
      assert show_root_schema != nil
      assert Keyword.get(show_root_schema, :default) == true
    end

    test "has optional style option" do
      entity = NavigationEntities.tree_view_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = NavigationEntities.tree_view_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "has root_nodes nested entities" do
      entity = NavigationEntities.tree_view_entity()

      assert is_list(entity.entities)
      assert Keyword.has_key?(entity.entities, :root_nodes)
      assert is_list(Keyword.get(entity.entities, :root_nodes))
    end
  end
end
