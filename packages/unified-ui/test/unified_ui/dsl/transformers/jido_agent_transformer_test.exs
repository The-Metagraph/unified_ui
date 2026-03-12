defmodule UnifiedUi.Dsl.Transformers.JidoAgentTransformerTest do
  use ExUnit.Case, async: false

  alias Jido.Signal
  alias UnifiedUi.Agent

  describe "transformer registration" do
    test "jido agent transformer is registered in DSL extension" do
      assert UnifiedUi.Dsl.Transformers.JidoAgentTransformer in UnifiedUi.Dsl.Extension.transformers()
    end
  end

  describe "generated helpers" do
    test "module exposes generated Jido agent integration helpers" do
      module = compile_fixture(base_fixture_body())

      assert function_exported?(module, :agent_init, 1)
      assert function_exported?(module, :handle_signal, 2)
      assert function_exported?(module, :start_component, 2)
      assert function_exported?(module, :stop_component, 1)
      assert function_exported?(module, :signal_component, 2)
    end

    test "agent_init/1 delegates to init/1" do
      module = compile_fixture(base_fixture_body())
      assert %{} = module.agent_init([])
    end

    test "handle_signal/2 routes click signal using DSL-generated routing" do
      module = compile_fixture(base_fixture_body())
      state = module.init([])

      signal =
        build_signal!("unified.button.clicked", %{
          widget_id: :increment_button,
          action: :increment
        })

      assert %{count: 1} = module.handle_signal(state, signal)
    end
  end

  describe "agent runtime integration" do
    test "start_component/2 and signal_component/2 integrate with UnifiedUi.Agent runtime" do
      module = compile_fixture(base_fixture_body())
      component_id = :"dsl_agent_transformer_#{System.unique_integer([:positive])}"

      assert {:ok, _pid} = module.start_component(component_id)
      on_exit(fn -> module.stop_component(component_id) end)

      assert {:ok, %{}} = Agent.current_state(component_id)

      signal =
        build_signal!("unified.button.clicked", %{
          widget_id: :increment_button,
          action: :increment
        })

      assert :ok = module.signal_component(component_id, signal)
      Process.sleep(20)

      assert {:ok, %{count: 1}} = Agent.current_state(component_id)
    end
  end

  defp base_fixture_body do
    """
    vbox do
      id :root
      text "Counter", id: :counter_label
      button "Increment", id: :increment_button, on_click: {:increment, %{count: 1}}
    end
    """
  end

  defp compile_fixture(body) do
    module = unique_fixture_module()

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      #{body}
    end
    """

    Code.compile_string(source)
    module
  end

  defp unique_fixture_module do
    Module.concat([
      UnifiedUi,
      JidoAgentTransformerFixture,
      :"M#{System.unique_integer([:positive])}"
    ])
  end

  defp build_signal!(type, data) do
    {:ok, signal} = Signal.new(type: type, data: data, source: "/unified_ui/test")
    signal
  end
end
