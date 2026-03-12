defmodule UnifiedUi.Integration.Phase5Test do
  @moduledoc """
  Focused integration tests for Phase 5 production-readiness scenarios.

  Covered sections:
  - 5.8.1: complete application flow from DSL module to rendered output
  - 5.8.2: multi-platform concurrent rendering
  - 5.8.3: signal communication across component update cycle
  - 5.8.4: state persistence and recovery pattern
  - 5.8.5: error handling and recovery behavior
  - 5.8.6: performance behavior under load
  - 5.8.7: memory stability over extended runtime
  - 5.8.8: hot code reloading behavior
  - 5.8.9: extension loading and unloading behavior
  - 5.8.14: upgrade compatibility from previous state shape
  """

  use ExUnit.Case, async: false

  alias UnifiedIUR.Layouts.VBox
  alias UnifiedIUR.Widgets.{Button, Text}
  alias UnifiedUi.Adapters.Coordinator
  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Agent
  alias UnifiedUi.Signals

  test "5.8.1 complete application flow: DSL module produces rendered UI state" do
    counter_screen = compile_counter_screen_module()
    component_id = :phase5_complete_app_flow

    assert {:ok, _pid} =
             Agent.start_component(counter_screen, component_id, platforms: [:terminal])

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
    end)

    assert {:ok, %{count: 0}} = Agent.current_state(component_id)

    assert {:ok, %VBox{id: :root, children: children}} = Agent.current_iur(component_id)
    assert Enum.any?(children, &match?(%Text{id: :title}, &1))
    assert Enum.any?(children, &match?(%Button{id: :increment_button}, &1))

    assert {:ok, render_results} = Agent.render_results(component_id)
    assert {:ok, terminal_state} = Map.fetch!(render_results, :terminal)
    assert {:ok, _render_tree} = State.get_root(terminal_state)
  end

  test "5.8.2 and 5.8.3 multi-platform rendering and signal dispatch work together" do
    counter_screen = compile_counter_screen_module()
    component_id = :phase5_multi_platform_signals

    assert {:ok, _pid} =
             Agent.start_component(counter_screen, component_id,
               platforms: [:terminal, :desktop, :web]
             )

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
    end)

    increment_signal =
      Signals.create!(:click, %{widget_id: :increment_button, action: :increment})

    assert :ok = Agent.signal_component(component_id, increment_signal)
    Process.sleep(25)

    assert {:ok, %{count: 1}} = Agent.current_state(component_id)

    assert {:ok, iur} = Agent.current_iur(component_id)

    assert {:ok, concurrent_results} =
             Coordinator.concurrent_render(iur, [:terminal, :desktop, :web])

    assert Enum.all?([:terminal, :desktop, :web], fn platform ->
             match?({:ok, _}, Map.fetch!(concurrent_results, platform))
           end)
  end

  test "5.8.4 and 5.8.5 state persistence pattern and recovery from invalid input" do
    counter_screen = compile_counter_screen_module()
    component_id = :phase5_persistence_and_recovery
    missing_component_id = :phase5_missing_component

    assert {:ok, _pid} =
             Agent.start_component(counter_screen, component_id, platforms: [:terminal])

    assert :ok =
             Agent.signal_component(
               component_id,
               Signals.create!(:click, %{widget_id: :increment_button, action: :increment})
             )

    Process.sleep(25)
    assert {:ok, persisted_state} = Agent.current_state(component_id)
    assert persisted_state == %{count: 1}

    assert :ok = Agent.stop_component(component_id)

    assert {:ok, _pid} =
             Agent.start_component(counter_screen, component_id, persisted_state: persisted_state)

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
    end)

    assert {:ok, %{count: 1}} = Agent.current_state(component_id)
    assert {:error, :not_found} = Agent.signal_component(missing_component_id, %{type: "invalid"})

    assert :ok = Agent.signal_component(component_id, %{type: "invalid.signal", data: %{}})
    Process.sleep(25)
    assert {:ok, %{count: 1}} = Agent.current_state(component_id)

    assert :ok =
             Agent.signal_component(
               component_id,
               Signals.create!(:click, %{widget_id: :increment_button, action: :increment})
             )

    Process.sleep(25)
    assert {:ok, %{count: 2}} = Agent.current_state(component_id)
  end

  test "5.8.6 performance under load remains within an acceptable envelope" do
    counter_screen = compile_counter_screen_module()
    component_id = :phase5_performance_under_load
    signal_count = 400
    threshold_ms = 4_000

    assert {:ok, _pid} =
             Agent.start_component(counter_screen, component_id, platforms: [:terminal])

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
    end)

    signal = Signals.create!(:click, %{widget_id: :increment_button, action: :increment})
    started_at_ms = System.monotonic_time(:millisecond)

    Enum.each(1..signal_count, fn _ ->
      assert :ok = Agent.signal_component(component_id, signal)
    end)

    assert :ok = wait_for_count(component_id, signal_count, 300, 20)

    elapsed_ms = System.monotonic_time(:millisecond) - started_at_ms
    assert elapsed_ms < threshold_ms
  end

  test "5.8.7 memory usage over sustained updates stays bounded" do
    counter_screen = compile_counter_screen_module()
    component_id = :phase5_memory_stability
    signal_count = 1_200
    max_total_growth_bytes = 120 * 1024 * 1024
    max_process_growth_bytes = 8 * 1024 * 1024

    assert {:ok, _pid} =
             Agent.start_component(counter_screen, component_id, platforms: [:terminal])

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
    end)

    assert {:ok, pid} = Agent.whereis(component_id)
    baseline_total_memory = :erlang.memory(:total)
    baseline_process_memory = process_memory(pid)

    signal = Signals.create!(:click, %{widget_id: :increment_button, action: :increment})

    Enum.each(1..signal_count, fn _ ->
      assert :ok = Agent.signal_component(component_id, signal)
    end)

    assert :ok = wait_for_count(component_id, signal_count, 400, 20)

    :erlang.garbage_collect(pid)
    Process.sleep(25)

    total_growth = non_negative_growth(:erlang.memory(:total), baseline_total_memory)
    process_growth = non_negative_growth(process_memory(pid), baseline_process_memory)

    assert total_growth < max_total_growth_bytes
    assert process_growth < max_process_growth_bytes
  end

  test "5.8.9 runtime extension modules can be loaded and unloaded" do
    modules = compile_runtime_extension_modules()
    extension_module = modules.extension
    widget_module = modules.widget
    renderer_module = modules.renderer

    assert Code.ensure_loaded?(extension_module)
    assert Code.ensure_loaded?(widget_module)
    assert Code.ensure_loaded?(renderer_module)

    assert %{widget: ^widget_module, renderer: ^renderer_module} = extension_module.components()

    widget = struct(widget_module, id: :temp, value: 41)
    assert {:ok, renderer_state} = renderer_module.render(widget)
    assert {:ok, _render_tree} = State.get_root(renderer_state)

    Enum.each([renderer_module, widget_module, extension_module], fn module ->
      _ = :code.purge(module)
      _ = :code.delete(module)

      assert :code.is_loaded(module) == false
    end)
  end

  test "5.8.8 hot code reloading updates component behavior without restart" do
    module =
      Module.concat([
        UnifiedUi,
        Integration,
        Phase5HotReloadScreen,
        :"M#{System.unique_integer([:positive])}"
      ])

    compile_hot_reload_module(module, 1)

    component_id = :phase5_hot_reload_runtime
    assert {:ok, _pid} = Agent.start_component(module, component_id, platforms: [:terminal])

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
      _ = :code.purge(module)
      _ = :code.delete(module)
    end)

    assert {:ok, pid} = Agent.whereis(component_id)
    signal = Signals.create!(:click, %{widget_id: :increment_button, action: :increment})

    assert :ok = Agent.signal_component(component_id, signal)
    assert :ok = wait_for_count(component_id, 1, 100, 15)
    assert {:ok, %{count: 1}} = Agent.current_state(component_id)

    compile_hot_reload_module(module, 10)

    assert :ok = Agent.signal_component(component_id, signal)
    assert :ok = wait_for_count(component_id, 11, 100, 15)
    assert {:ok, %{count: 11}} = Agent.current_state(component_id)
    assert Process.alive?(pid)
  end

  test "5.8.14 persisted legacy state upgrades to current runtime format" do
    module = compile_upgrade_compatible_module()
    component_id = :phase5_upgrade_compatibility
    legacy_state = %{counter: 7}

    assert {:ok, _pid} =
             Agent.start_component(module, component_id,
               persisted_state: legacy_state,
               platforms: [:terminal]
             )

    on_exit(fn ->
      _ = Agent.stop_component(component_id)
      _ = :code.purge(module)
      _ = :code.delete(module)
    end)

    assert {:ok, %{count: 7, upgraded_from: :v0}} = Agent.current_state(component_id)

    assert :ok =
             Agent.signal_component(
               component_id,
               Signals.create!(:click, %{widget_id: :increment_button, action: :increment})
             )

    assert :ok = wait_for_count(component_id, 8, 100, 15)
    assert {:ok, %{count: 8, upgraded_from: :v0}} = Agent.current_state(component_id)
  end

  defp compile_counter_screen_module do
    module =
      Module.concat([
        UnifiedUi,
        Integration,
        Phase5CounterScreen,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      vbox do
        id :root
        spacing 1
        text "Phase 5 Counter", id: :title
        button "Increment", id: :increment_button, on_click: :increment
        button "Reset", id: :reset_button, on_click: :reset
      end

      @impl true
      def init(opts) do
        case Keyword.get(opts, :persisted_state) do
          %{} = persisted -> persisted
          _ -> %{count: 0}
        end
      end

      @impl true
      def update(state, %{type: "unified.button.clicked", data: %{action: :increment}}) do
        %{state | count: state.count + 1}
      end

      def update(_state, %{type: "unified.button.clicked", data: %{action: :reset}}) do
        %{count: 0}
      end

      def update(state, _signal), do: state
    end
    """

    Code.compile_string(source)
    module
  end

  defp compile_hot_reload_module(module, increment_step) when is_integer(increment_step) do
    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      vbox do
        id :root
        spacing 1
        text "Hot Reload Counter", id: :title
        button "Increment", id: :increment_button, on_click: :increment
      end

      def init(_opts), do: %{count: 0}

      def update(state, %{type: "unified.button.clicked", data: %{action: :increment}}) do
        %{state | count: state.count + #{increment_step}}
      end

      def update(state, _signal), do: state
    end
    """

    Code.compile_string(source)
    module
  end

  defp compile_upgrade_compatible_module do
    module =
      Module.concat([
        UnifiedUi,
        Integration,
        Phase5UpgradeScreen,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      vbox do
        id :root
        text "Upgrade Compatibility", id: :title
        button "Increment", id: :increment_button, on_click: :increment
      end

      def init(opts) do
        case Keyword.get(opts, :persisted_state) do
          %{count: count} when is_integer(count) ->
            %{count: count, upgraded_from: :current}

          %{counter: count} when is_integer(count) ->
            %{count: count, upgraded_from: :v0}

          _ ->
            %{count: 0, upgraded_from: :fresh}
        end
      end

      def update(state, %{type: "unified.button.clicked", data: %{action: :increment}}) do
        %{state | count: state.count + 1}
      end

      def update(state, _signal), do: state
    end
    """

    Code.compile_string(source)
    module
  end

  defp compile_runtime_extension_modules do
    extension_module =
      Module.concat([
        UnifiedUi,
        Integration,
        RuntimeExtension,
        :"M#{System.unique_integer([:positive])}"
      ])

    widget_module = Module.concat([extension_module, Widgets, TempBadge])
    renderer_module = Module.concat([extension_module, Renderers, Terminal])

    source = """
    defmodule #{inspect(extension_module)} do
      def components do
        %{
          widget: #{inspect(widget_module)},
          renderer: #{inspect(renderer_module)}
        }
      end
    end

    defmodule #{inspect(widget_module)} do
      defstruct [:id, :value, visible: true]
    end

    defmodule #{inspect(renderer_module)} do
      @behaviour UnifiedUi.Renderer

      alias #{inspect(widget_module)}, as: TempBadge
      alias UnifiedIUR.Widgets.Text
      alias UnifiedUi.Adapters.State
      alias UnifiedUi.Adapters.Terminal

      def render(iur_tree, opts \\\\ []) do
        renderer_state = State.new(:terminal, config: opts)
        {:ok, State.put_root(renderer_state, convert_iur(iur_tree))}
      end

      def update(iur_tree, renderer_state, _opts \\\\ []) do
        {:ok, State.put_root(renderer_state, convert_iur(iur_tree))}
      end

      def destroy(_renderer_state), do: :ok

      defp convert_iur(%TempBadge{value: value}) do
        %Text{content: "Temp: \#{inspect(value)}"}
        |> Terminal.convert_iur()
      end

      defp convert_iur(other), do: Terminal.convert_iur(other)
    end
    """

    Code.compile_string(source)

    %{
      extension: extension_module,
      widget: widget_module,
      renderer: renderer_module
    }
  end

  defp wait_for_count(component_id, expected_count, attempts, interval_ms) do
    case Agent.current_state(component_id) do
      {:ok, %{count: count}} when count >= expected_count ->
        :ok

      {:ok, %{count: _count}} when attempts > 0 ->
        Process.sleep(interval_ms)
        wait_for_count(component_id, expected_count, attempts - 1, interval_ms)

      {:ok, state} ->
        {:error, {:unexpected_state, state}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp process_memory(pid) do
    case Process.info(pid, :memory) do
      {:memory, bytes} -> bytes
      _ -> 0
    end
  end

  defp non_negative_growth(current, baseline) when is_integer(current) and is_integer(baseline) do
    max(current - baseline, 0)
  end
end
