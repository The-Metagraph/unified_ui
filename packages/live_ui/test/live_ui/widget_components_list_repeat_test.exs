defmodule LiveUi.WidgetComponentsListRepeatTest do
  @moduledoc """
  Stage-4 verification for the `:list_repeat` composition-behavior widget.

  Wave AshUI-3.9.1a. Confirms all four stages of the canonical-widget pipeline
  are in place for `:list_repeat`:

    1. Catalog entry  — `unified_ui/widget_components.ex` L164 (family: :composition_behavior)
    2. IUR constructor — `unified_iur/widgets/components.ex` `list_repeat/2`
    3. Renderer clause — `live_ui/renderer.ex` L1470 (delegates to Phoenix.Component)
    4. Phoenix.Component — `LiveUi.Widgets.Components.ListRepeat` (this file's subject)

  Related: ariston-ui PR #388 `:list_repeat` wrapper Element pattern.
  """

  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.Widgets.Components
  alias UnifiedIUR.Widgets.Foundational

  # ---------------------------------------------------------------------------
  # Stage-4: Phoenix.Component direct rendering
  # ---------------------------------------------------------------------------

  describe "LiveUi.Widgets.Components.ListRepeat (Phoenix.Component)" do
    test "renders structural container with canonical widget-boundary attribute" do
      html =
        render_component(&LiveUi.Widgets.Components.ListRepeat.component/1, %{
          id: "list-repeat-test",
          repeat: %{binding_id: :artifacts, row_count: 3}
        })

      assert html =~ ~s(data-live-ui-widget-boundary="list_repeat")
    end

    test "emits data-live-ui-repeat-binding from repeat.binding_id" do
      html =
        render_component(&LiveUi.Widgets.Components.ListRepeat.component/1, %{
          id: "repeat-binding-test",
          repeat: %{binding_id: :proposals, row_count: 2}
        })

      assert html =~ ~s(data-live-ui-repeat-binding="proposals")
    end

    test "emits data-live-ui-repeat-row-count from repeat.row_count" do
      html =
        render_component(&LiveUi.Widgets.Components.ListRepeat.component/1, %{
          id: "repeat-rowcount-test",
          repeat: %{binding_id: :items, row_count: 7}
        })

      assert html =~ ~s(data-live-ui-repeat-row-count="7")
    end

    test "zero row_count is a valid state" do
      html =
        render_component(&LiveUi.Widgets.Components.ListRepeat.component/1, %{
          id: "repeat-empty-test",
          repeat: %{binding_id: :items, row_count: 0}
        })

      assert html =~ ~s(data-live-ui-repeat-row-count="0")
    end

    test "renders inner_block children (already-hydrated rows pass through)" do
      html =
        render_component(
          &LiveUi.Widgets.Components.ListRepeat.component/1,
          %{
            id: "repeat-children-test",
            repeat: %{binding_id: :rows, row_count: 1},
            inner_block: [
              %{
                __slot__: :inner_block,
                inner_block: fn _, _ -> Phoenix.HTML.raw(~s(<div id="child-row">Row</div>)) end
              }
            ]
          }
        )

      assert html =~ ~s(id="child-row")
      assert html =~ "Row"
    end

    test "composition_behavior family is set in component attrs" do
      html =
        render_component(&LiveUi.Widgets.Components.ListRepeat.component/1, %{
          id: "repeat-family-test",
          repeat: %{binding_id: :items, row_count: 0}
        })

      # The attribute is data-live-ui-component-family (not widget-family)
      assert html =~ ~s(data-live-ui-component-family="composition_behavior")
    end
  end

  # ---------------------------------------------------------------------------
  # Stage-3 integration: renderer clause delegates to Phoenix.Component
  # ---------------------------------------------------------------------------

  describe "LiveUi.Renderer :list_repeat clause" do
    test "renderer produces canonical boundaries and repeat attributes via IUR element" do
      element =
        Components.list_repeat(nil,
          id: "renderer-repeat",
          repeat_binding: :specs,
          hydrated?: true,
          row_count: 4
        )

      html =
        render_component(&LiveUi.Renderer.render/1, %{
          element: element,
          event_target: "#runtime-host"
        })

      assert html =~ ~s(data-live-ui-widget-boundary="list_repeat")
      assert html =~ ~s(data-live-ui-repeat-binding="specs")
      assert html =~ ~s(data-live-ui-repeat-row-count="4")
    end

    test "renderer passes already-hydrated child elements through without modification" do
      child = Foundational.text("Row content", id: "row-text")

      element =
        Components.list_repeat(nil,
          id: "renderer-children",
          repeat_binding: :rows,
          hydrated?: true,
          row_count: 1,
          children: [child]
        )

      html =
        render_component(&LiveUi.Renderer.render/1, %{
          element: element,
          event_target: "#runtime-host"
        })

      assert html =~ ~s(data-live-ui-widget-boundary="list_repeat")
      assert html =~ "Row content"
    end
  end

  # ---------------------------------------------------------------------------
  # Catalog registration
  # ---------------------------------------------------------------------------

  describe "catalog registration (Stage-1 + Stage-4 linkage)" do
    test "components contracts maps :list_repeat to LiveUi.Widgets.Components.ListRepeat" do
      contracts = LiveUi.Widgets.Components.contracts()
      entry = Map.fetch!(contracts, :list_repeat)

      assert entry.module == LiveUi.Widgets.Components.ListRepeat
      assert entry.family == :composition_behavior
      assert :inner_block in entry.slots
      assert :repeat in entry.assigns
    end

    test "composition_behavior_modules includes ListRepeat" do
      assert LiveUi.Widgets.Components.ListRepeat in
               LiveUi.Widgets.Components.composition_behavior_modules()
    end
  end
end
