defmodule LiveUi.ScreenMacroTest do
  use ExUnit.Case, async: true

  test "defines wrapper metadata and engine-owned callbacks for a valid source module" do
    module_name = unique_module_name("ValidWrapper")

    [{module, _bytecode}] =
      Code.compile_string("""
      defmodule #{module_name} do
        use LiveUi.Screen, source: LiveUi.TestSupport.CounterScreen
      end
      """)

    assert module.__live_ui_screen__() == %{source: LiveUi.TestSupport.CounterScreen}
    assert module.liveui_context(%{}, %{}, %Phoenix.LiveView.Socket{}) == %{}
    assert module.liveui_source_opts(%{}, %{}, %Phoenix.LiveView.Socket{}) == []
    assert function_exported?(module, :mount, 3)
    assert function_exported?(module, :handle_event, 3)
    assert function_exported?(module, :render, 1)
  end

  test "allows the narrow wrapper customization callbacks" do
    module_name = unique_module_name("CustomWrapper")

    [{module, _bytecode}] =
      Code.compile_string("""
      defmodule #{module_name} do
        use LiveUi.Screen, source: LiveUi.TestSupport.CounterScreen

        def liveui_context(_params, _session, _socket), do: %{scope: :custom}
        def liveui_source_opts(_params, _session, _socket), do: [count: 5]
      end
      """)

    assert module.liveui_context(%{}, %{}, %Phoenix.LiveView.Socket{}) == %{scope: :custom}
    assert module.liveui_source_opts(%{}, %{}, %Phoenix.LiveView.Socket{}) == [count: 5]
  end

  test "requires a source option" do
    assert_raise CompileError, ~r/requires a source: MyApp.SomeScreen option/, fn ->
      Code.compile_string("""
      defmodule #{unique_module_name("MissingSource")} do
        use LiveUi.Screen
      end
      """)
    end
  end

  test "rejects non-module source expressions" do
    assert_raise CompileError, ~r/source must be a module reference/, fn ->
      Code.compile_string("""
      defmodule #{unique_module_name("InvalidSource")} do
        use LiveUi.Screen, source: "counter"
      end
      """)
    end
  end

  test "rejects overriding engine-owned callbacks" do
    for {callback, args, body} <- [
          {"mount", "_params, _session, socket", "{:ok, socket}"},
          {"handle_event", "_event, _payload, socket", "{:noreply, socket}"},
          {"render", "assigns", "assigns"}
        ] do
      assert_raise CompileError, ~r/may not override #{callback}/, fn ->
        Code.compile_string("""
        defmodule #{unique_module_name("Override#{callback}")} do
          use LiveUi.Screen, source: LiveUi.TestSupport.CounterScreen

          def #{callback}(#{args}), do: #{body}
        end
        """)
      end
    end
  end

  defp unique_module_name(suffix) do
    "Elixir.LiveUi.ScreenMacroTest.#{suffix}#{System.unique_integer([:positive])}"
  end
end
