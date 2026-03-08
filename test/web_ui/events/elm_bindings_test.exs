defmodule WebUi.Events.ElmBindingsTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.ElmBindings
  alias WebUi.TypedError

  test "standard Html bindings produce canonical widget events" do
    assert {:ok, click_event} = ElmBindings.on_click("save_button", "button", %{action: "save"})
    assert click_event.type == "unified.button.clicked"
    assert click_event.widget_id == "save_button"
    assert click_event.data.action == "save"
    assert click_event.meta.binding == "Html.Events.onClick"

    assert {:ok, input_event} =
             ElmBindings.on_input("email_input", "text_input", "person@example.com")

    assert input_event.type == "unified.input.changed"
    assert input_event.data.value == "person@example.com"
    assert input_event.data.input_id == "email_input"

    assert {:ok, focus_event} = ElmBindings.on_focus("search_input", "text_input")
    assert focus_event.type == "unified.element.focused"
    assert focus_event.data.widget_id == "search_input"

    assert {:ok, blur_event} = ElmBindings.on_blur("search_input", "text_input")
    assert blur_event.type == "unified.element.blurred"
    assert blur_event.data.widget_id == "search_input"
  end

  test "submit binding carries Elm-compatible prevent-default semantics" do
    assert {:ok, submit_event} = ElmBindings.on_submit("login_form", "form")
    assert submit_event.type == "unified.form.submitted"
    assert submit_event.data.form_id == "login_form"
    assert submit_event.meta.binding == "Html.Events.onSubmit"
    assert submit_event.meta.prevent_default == true
  end

  test "decoder helpers map keyboard and pointer payloads to canonical events" do
    assert {:ok, action_event} =
             ElmBindings.decode_action_key(
               "table_1",
               "table",
               %{"key" => "Enter", "code" => "Enter", "ctrlKey" => true},
               %{target_id: "row-4"}
             )

    assert action_event.type == "unified.action.requested"
    assert action_event.data.action == "Enter"
    assert action_event.data.code == "Enter"
    assert action_event.data.ctrl_key == true
    assert action_event.data.target_id == "row-4"

    assert {:ok, pointer_event} =
             ElmBindings.decode_canvas_pointer(
               "chart_canvas",
               %{"clientX" => 32, "clientY" => 64, "type" => "move", "pointerId" => "p-1"}
             )

    assert pointer_event.type == "unified.canvas.pointer.changed"
    assert pointer_event.data.x == 32
    assert pointer_event.data.y == 64
    assert pointer_event.data.phase == "move"
    assert pointer_event.data.pointer_id == "p-1"
  end

  test "resize binding maps Browser.Events.onResize to viewport resized events" do
    assert {:ok, event} = ElmBindings.on_resize("main_viewport", "viewport", 144, 55)
    assert event.type == "unified.viewport.resized"
    assert event.data.width == 144
    assert event.data.height == 55
    assert event.meta.binding == "Browser.Events.onResize"
  end

  test "subscription generation and reconciliation are deterministic" do
    desired =
      ElmBindings.subscription_specs("main_viewport", "viewport",
        resize: true,
        keyboard_actions: true,
        canvas_pointer: true
      )

    current = [List.first(desired)]

    transition_a = ElmBindings.reconcile_subscriptions(current, desired)

    transition_b =
      ElmBindings.reconcile_subscriptions(Enum.reverse(current), Enum.reverse(desired))

    assert transition_a == transition_b
    assert length(transition_a.subscribe) == 2
    assert transition_a.unsubscribe == []

    assert Enum.map(transition_a.active, & &1.subscription_id) ==
             Enum.sort(Enum.map(desired, & &1.subscription_id))
  end

  test "extended bindings produce canonical menu/table/tabs/tree events" do
    assert {:ok, menu_event} = ElmBindings.on_menu_action("main_menu", "menu_item", "open_file")
    assert menu_event.type == "unified.menu.action_selected"
    assert menu_event.data.action_id == "open_file"

    assert {:ok, row_event} = ElmBindings.on_table_row_select("orders_table", "table", 3)
    assert row_event.type == "unified.table.row_selected"
    assert row_event.data.row_index == 3

    assert {:ok, sort_event} = ElmBindings.on_table_sort("orders_table", "table", "price", "DESC")
    assert sort_event.type == "unified.table.sorted"
    assert sort_event.data.column == "price"
    assert sort_event.data.direction == "desc"

    assert {:ok, tab_event} = ElmBindings.on_tab_change("main_tabs", "tabs", "overview")
    assert tab_event.type == "unified.tab.changed"
    assert tab_event.data.tab_id == "overview"

    assert {:ok, tree_select_event} =
             ElmBindings.on_tree_node_select("nav_tree", "tree_view", "node-1")

    assert tree_select_event.type == "unified.tree.node_selected"
    assert tree_select_event.data.node_id == "node-1"

    assert {:ok, tree_toggle_event} =
             ElmBindings.on_tree_node_toggle("nav_tree", "tree_view", "node-1", true)

    assert tree_toggle_event.type == "unified.tree.node_toggled"
    assert tree_toggle_event.data.node_id == "node-1"
    assert tree_toggle_event.data.expanded == true
  end

  test "invalid decoder payloads fail with typed errors" do
    assert {:error, %TypedError{} = key_error} =
             ElmBindings.decode_action_key("table_1", "table", %{})

    assert key_error.error_code == "elm_bindings.invalid_key_event"

    assert {:error, %TypedError{} = pointer_error} =
             ElmBindings.decode_canvas_pointer("canvas_1", %{"x" => 10})

    assert pointer_error.error_code == "elm_bindings.invalid_pointer_event"

    assert {:error, %TypedError{} = menu_error} =
             ElmBindings.on_menu_action("main_menu", "menu_item", "")

    assert menu_error.error_code == "elm_bindings.invalid_menu_action"

    assert {:error, %TypedError{} = row_error} =
             ElmBindings.on_table_row_select("orders_table", "table", -1)

    assert row_error.error_code == "elm_bindings.invalid_row_select_payload"

    assert {:error, %TypedError{} = sort_error} =
             ElmBindings.on_table_sort("orders_table", "table", "price", "sideways")

    assert sort_error.error_code == "elm_bindings.invalid_sort_payload"

    assert {:error, %TypedError{} = tab_error} =
             ElmBindings.on_tab_change("main_tabs", "tabs", "")

    assert tab_error.error_code == "elm_bindings.invalid_tab_change_payload"

    assert {:error, %TypedError{} = tree_select_error} =
             ElmBindings.on_tree_node_select("nav_tree", "tree_view", "")

    assert tree_select_error.error_code == "elm_bindings.invalid_tree_select_payload"

    assert {:error, %TypedError{} = tree_toggle_error} =
             ElmBindings.on_tree_node_toggle("nav_tree", "tree_view", "node-1", "yes")

    assert tree_toggle_error.error_code == "elm_bindings.invalid_tree_toggle_payload"
  end
end
