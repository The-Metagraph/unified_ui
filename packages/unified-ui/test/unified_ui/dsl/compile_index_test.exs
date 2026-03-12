defmodule UnifiedUi.Dsl.CompileIndexTest do
  use ExUnit.Case, async: true

  alias Spark.Dsl.Transformer
  alias UnifiedUi.Dsl.CompileIndex
  alias UnifiedUi.Dsl.Transformers.PrecomputeTransformer

  describe "build/1" do
    test "collects section entities and flattens nested children" do
      nested_child = %{name: :text, attrs: %{id: :child_text}}

      widget = %{
        name: :button,
        attrs: %{id: :save_btn, on_click: :save},
        entities: [nested_child]
      }

      layout = %{name: :vbox, attrs: %{id: :root_layout}, entities: [widget]}
      state = %{attrs: [count: 0]}
      style = %{name: :primary, attrs: [fg: :green]}

      dsl_state = %{
        :widgets => %{entities: [widget]},
        :layouts => %{entities: [layout]},
        :styles => %{entities: [style]},
        [:ui] => %{entities: [layout]},
        [:ui, :state] => %{entities: [state]}
      }

      index = CompileIndex.build(dsl_state)

      assert index.widgets == [widget]
      assert index.layouts == [layout]
      assert index.ui == [layout]
      assert index.styles == [style]
      assert index.state == [state]

      assert layout in index.flat
      assert widget in index.flat
      assert nested_child in index.flat
    end

    test "falls back to nested ui map for state entities" do
      state = %{attrs: [count: 1, ready: true]}

      dsl_state = %{
        ui: %{
          entities: [%{name: :vbox, attrs: %{id: :root}}],
          state: %{entities: [state]}
        }
      }

      index = CompileIndex.build(dsl_state)

      assert index.state == [state]
      assert [%{name: :vbox}] = index.ui
    end

    test "collects state entities embedded directly in ui entities" do
      state_entity = %UnifiedUi.Dsl.State{attrs: [count: 2, ready: false]}
      layout = %{name: :vbox, attrs: %{id: :root}}

      dsl_state = %{
        [:ui] => %{entities: [state_entity, layout]}
      }

      index = CompileIndex.build(dsl_state)

      assert index.state == [state_entity]
      assert index.ui == [state_entity, layout]
    end
  end

  describe "persist/1 and get/1" do
    test "stores and retrieves compile index from dsl persist data" do
      dsl_state = %{
        widgets: %{entities: [%{name: :button, attrs: %{id: :save_btn}}]}
      }

      indexed_dsl_state = CompileIndex.persist(dsl_state)

      expected_index = CompileIndex.build(dsl_state)

      assert Transformer.get_persisted(indexed_dsl_state, :unified_ui_compile_index) ==
               expected_index

      assert CompileIndex.get(indexed_dsl_state) == expected_index
    end
  end

  describe "view_state/1" do
    test "returns compact state for builder with ui and styles entities" do
      layout = %{name: :vbox, attrs: %{id: :root}}
      style = %{name: :primary, attrs: [fg: :cyan]}

      dsl_state = %{
        :styles => %{entities: [style]},
        [:ui] => %{entities: [layout]}
      }

      view_state = CompileIndex.view_state(dsl_state)

      assert %{entities: [^layout]} = view_state[:ui]
      assert %{entities: [^layout]} = view_state[[:ui]]
      assert %{entities: [^style]} = view_state[:styles]
    end
  end

  describe "runtime_view_state/1" do
    test "builds runtime state from module entities and cache can be invalidated" do
      module =
        Module.concat([
          UnifiedUi,
          Dsl,
          CompileIndexRuntimeFixture,
          :"M#{System.unique_integer([:positive])}"
        ])

      source = """
      defmodule #{inspect(module)} do
        @behaviour UnifiedUi.ElmArchitecture
        use UnifiedUi.Dsl

        vbox do
          id :root
          text "Hello", id: :greeting
        end

        @impl true
        def init(_opts), do: %{}

        @impl true
        def update(state, _signal), do: state
      end
      """

      Code.compile_string(source)

      runtime_state = CompileIndex.runtime_view_state(module)

      assert %{entities: [layout]} = runtime_state[:ui]
      assert %UnifiedIUR.Layouts.VBox{id: :root} = layout
      assert runtime_state[[:ui]] == runtime_state[:ui]
      assert runtime_state[:styles] == %{entities: []}
      assert runtime_state[:persist] == %{module: module}

      assert CompileIndex.runtime_view_state(module) == runtime_state

      assert :ok == CompileIndex.invalidate_runtime_view_state(module)
      assert CompileIndex.runtime_view_state(module) == runtime_state

      :ok = CompileIndex.invalidate_runtime_view_state(module)
      _ = :code.purge(module)
      _ = :code.delete(module)
    end

    test "ignores invalid runtime cache invalidation input" do
      assert :ok == CompileIndex.invalidate_runtime_view_state(nil)
      assert :ok == CompileIndex.invalidate_runtime_view_state(:not_a_loaded_module)
    end
  end

  describe "PrecomputeTransformer" do
    test "persists compile index during transformer pass" do
      dsl_state = %{
        :widgets => %{entities: [%{name: :button, attrs: %{id: :save_btn}}]},
        [:ui] => %{entities: [%{name: :vbox, attrs: %{id: :root}}]}
      }

      assert {:ok, indexed_dsl_state} = PrecomputeTransformer.transform(dsl_state)

      assert %{} = Transformer.get_persisted(indexed_dsl_state, :unified_ui_compile_index)
      assert CompileIndex.get(indexed_dsl_state) == CompileIndex.build(dsl_state)
    end
  end
end
