defmodule UnifiedUi.Dsl.Transformers.ElmArchTest do
  use ExUnit.Case

  describe "ElmArchitecture behaviour" do
    test "behaviour defines required callbacks" do
      # Verify the behaviour module exists and has the right callbacks
      callbacks = UnifiedUi.ElmArchitecture.behaviour_info(:callbacks)
      assert {:init, 1} in callbacks
      assert {:update, 2} in callbacks
      assert {:view, 1} in callbacks
    end
  end

  describe "Transformer modules exist" do
    test "init_transformer module exists" do
      assert Code.ensure_loaded?(UnifiedUi.Dsl.Transformers.InitTransformer)
    end

    test "update_transformer module exists" do
      assert Code.ensure_loaded?(UnifiedUi.Dsl.Transformers.UpdateTransformer)
    end

    test "view_transformer module exists" do
      assert Code.ensure_loaded?(UnifiedUi.Dsl.Transformers.ViewTransformer)
    end
  end

  describe "Transformers are registered in DSL extension" do
    test "DSL extension module exists" do
      assert Code.ensure_loaded?(UnifiedUi.Dsl.Extension)
    end
  end

  describe "State entity struct exists" do
    test "UnifiedUi.Dsl.State struct exists" do
      state = %UnifiedUi.Dsl.State{attrs: [count: 0]}
      assert state.attrs == [count: 0]
    end
  end

  # Note: Full transformer testing requires DSL entities to be used
  # which will be added in Phase 2 with widget entities.
  # The transformer infrastructure is in place and will generate
  # init/1, update/2, and view/1 functions when DSL is used.
end
