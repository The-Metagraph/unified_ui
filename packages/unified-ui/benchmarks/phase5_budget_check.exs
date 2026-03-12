defmodule UnifiedUi.Benchmarks.Phase5BudgetCheck do
  @moduledoc false

  alias UnifiedUi.Adapters.Coordinator
  alias UnifiedUi.Adapters.Terminal
  alias UnifiedUi.Agent
  alias UnifiedUi.Dsl.Style, as: DslStyle
  alias UnifiedUi.Dsl.StyleResolver
  alias UnifiedUi.IUR.Builder
  alias UnifiedUi.Signals

  @switches [quick: :boolean]
  @platforms [:terminal, :desktop, :web]

  @quick_iterations %{
    compile: 8,
    compile_warmup: 20,
    iur: 120,
    render: 60,
    signal: 500,
    style: 600
  }

  @full_iterations %{
    compile: 20,
    compile_warmup: 30,
    iur: 300,
    render: 150,
    signal: 1_200,
    style: 1_500
  }

  # Runtime budgets are intentionally tolerant; compile now tracks product target.
  @budgets %{
    compile_100_widgets_ms: 100.0,
    iur_build_avg_us: 2_500.0,
    render_concurrent_avg_us: 1_200.0,
    terminal_frame_avg_us: 16_670.0,
    signal_roundtrip_avg_us: 20.0,
    style_resolve_avg_us: 40.0
  }

  def run(argv \\ System.argv()) do
    {opts, _remaining_args, invalid} = OptionParser.parse(argv, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise ArgumentError,
              "Unsupported options for benchmarks/phase5_budget_check.exs: #{inspect(invalid_opts)}"
    end

    quick? = opts[:quick] == true
    iterations = if quick?, do: @quick_iterations, else: @full_iterations

    IO.puts("== UnifiedUi Phase 5 Performance Budget Check ==")
    IO.puts("Mode: #{if(quick?, do: "quick", else: "full")}")

    compile_check = check_compile_time(iterations.compile, iterations.compile_warmup)

    dsl_state = build_large_dsl_state(160)
    iur_tree = Builder.build(dsl_state)
    style_state = build_style_state(40)

    {component_module, component_id, signal} = start_benchmark_component()

    runtime_checks =
      try do
        [
          check_iur_build(dsl_state, iterations.iur),
          check_render_concurrent(iur_tree, iterations.render),
          check_terminal_frame(iur_tree, iterations.render),
          check_signal_roundtrip(component_id, signal, iterations.signal),
          check_style_resolution(style_state, iterations.style)
        ]
      after
        _ = Agent.stop_component(component_id)
        unload_module(component_module)
      end

    checks = [compile_check | runtime_checks]

    IO.puts("")
    Enum.each(checks, &print_check_result/1)

    failures = Enum.filter(checks, fn check -> check.status == :fail end)

    if failures == [] do
      IO.puts("\nPerformance budget check passed.")
    else
      IO.puts("\nPerformance budget check failed: #{length(failures)} regression(s) detected.")
      System.halt(1)
    end
  end

  defp check_compile_time(iterations, warmup_count) do
    warm_compile_path(warmup_count)

    samples_ms = compile_samples_ms(iterations)

    if System.get_env("UNIFIED_UI_PERF_DEBUG") == "1" do
      IO.inspect(samples_ms, label: "dsl.compile.100_widgets.samples_ms")
    end

    elapsed_ms = median(samples_ms)

    evaluate(
      "dsl.compile.100_widgets",
      elapsed_ms,
      @budgets.compile_100_widgets_ms,
      "ms"
    )
  end

  defp check_iur_build(dsl_state, iterations) do
    avg_us = average_us(iterations, fn -> Builder.build(dsl_state) end)

    evaluate(
      "iur.build.large_ui.avg",
      avg_us,
      @budgets.iur_build_avg_us,
      "us"
    )
  end

  defp check_render_concurrent(iur_tree, iterations) do
    avg_us = average_us(iterations, fn -> Coordinator.concurrent_render(iur_tree, @platforms) end)

    evaluate(
      "render.concurrent.all_platforms.avg",
      avg_us,
      @budgets.render_concurrent_avg_us,
      "us"
    )
  end

  defp check_terminal_frame(iur_tree, iterations) do
    avg_us = average_us(iterations, fn -> Terminal.render(iur_tree) end)

    evaluate(
      "render.terminal.frame.avg",
      avg_us,
      @budgets.terminal_frame_avg_us,
      "us"
    )
  end

  defp check_signal_roundtrip(component_id, signal, iterations) do
    avg_us =
      average_us(iterations, fn ->
        :ok = Agent.signal_component(component_id, signal)
        {:ok, _state} = Agent.current_state(component_id)
      end)

    evaluate(
      "signals.dispatch.roundtrip.avg",
      avg_us,
      @budgets.signal_roundtrip_avg_us,
      "us"
    )
  end

  defp check_style_resolution(style_state, iterations) do
    avg_us =
      average_us(iterations, fn ->
        StyleResolver.resolve(style_state, :style_40, fg: :yellow, padding: 2)
      end)

    evaluate(
      "style.resolve.deep_inheritance.avg",
      avg_us,
      @budgets.style_resolve_avg_us,
      "us"
    )
  end

  defp evaluate(name, value, budget, unit) do
    %{
      name: name,
      value: value,
      budget: budget,
      unit: unit,
      status: if(value <= budget, do: :pass, else: :fail)
    }
  end

  defp print_check_result(check) do
    status = if(check.status == :pass, do: "PASS", else: "FAIL")
    value = Float.round(check.value, 2)
    budget = Float.round(check.budget, 2)

    IO.puts("#{status} #{check.name}: #{value} #{check.unit} (budget <= #{budget} #{check.unit})")
  end

  defp average_us(iterations, fun) when iterations > 0 do
    total_us =
      Enum.reduce(1..iterations, 0, fn _, acc ->
        {elapsed_us, _result} = :timer.tc(fun)
        acc + elapsed_us
      end)

    total_us / iterations
  end

  defp compile_dsl_module(widget_count) do
    module =
      Module.concat([
        UnifiedUi,
        Benchmarks,
        BudgetCompileFixture,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      vbox do
        id :root
        spacing 1

        for index <- 1..#{widget_count} do
          text "Widget \#{index}", id: :"widget_\#{index}"
        end
      end
    end
    """

    Code.compile_string(source)
    module
  end

  defp compile_samples_ms(iterations) when iterations > 0 do
    Enum.map(1..iterations, fn _ ->
      {elapsed_us, module} =
        :timer.tc(fn ->
          compile_dsl_module(100)
        end)

      unload_module(module)
      elapsed_us / 1_000.0
    end)
  end

  defp warm_compile_path(warmup_count) when warmup_count > 0 do
    Enum.each(1..warmup_count, fn _ ->
      warmup_module = compile_dsl_module(100)
      unload_module(warmup_module)
    end)
  end

  defp median(values) when is_list(values) and values != [] do
    sorted = Enum.sort(values)
    count = length(sorted)
    midpoint = div(count, 2)

    if rem(count, 2) == 0 do
      (Enum.at(sorted, midpoint - 1) + Enum.at(sorted, midpoint)) / 2.0
    else
      Enum.at(sorted, midpoint)
    end
  end

  defp build_large_dsl_state(widget_count) do
    children =
      for index <- 1..widget_count do
        if rem(index, 2) == 0 do
          %{
            name: :text,
            attrs: %{
              id: String.to_atom("text_#{index}"),
              content: "Item #{index}",
              style: :style_20
            }
          }
        else
          %{
            name: :button,
            attrs: %{
              id: String.to_atom("button_#{index}"),
              label: "Action #{index}",
              on_click: :noop,
              style: :style_20
            }
          }
        end
      end

    %{
      [:ui] => %{
        entities: [
          %{
            name: :vbox,
            attrs: %{id: :root, spacing: 1, style: :style_10},
            entities: children
          }
        ]
      },
      styles: %{entities: build_style_entities(40)},
      persist: %{module: __MODULE__}
    }
  end

  defp build_style_state(depth) do
    %{
      styles: %{entities: build_style_entities(depth)},
      persist: %{module: __MODULE__}
    }
  end

  defp build_style_entities(depth) do
    Enum.map(1..depth, fn index ->
      parent = if index == 1, do: nil, else: String.to_atom("style_#{index - 1}")

      struct(DslStyle,
        name: String.to_atom("style_#{index}"),
        extends: parent,
        attributes: [
          fg: color_for(index),
          padding: rem(index, 4),
          attrs: attrs_for(index)
        ],
        __meta__: []
      )
    end)
  end

  defp color_for(index) do
    Enum.at([:white, :cyan, :green, :yellow, :magenta, :blue], rem(index, 6))
  end

  defp attrs_for(index) do
    if rem(index, 2) == 0, do: [:bold], else: [:underline]
  end

  defp start_benchmark_component do
    module = compile_component_module()
    component_id = String.to_atom("budget_component_#{System.unique_integer([:positive])}")

    case Agent.start_component(module, component_id, platforms: []) do
      {:ok, _pid} ->
        signal = Signals.create!(:click, %{widget_id: :increment_button, action: :increment})
        {module, component_id, signal}

      {:error, reason} ->
        unload_module(module)
        raise "Unable to start budget component: #{inspect(reason)}"
    end
  end

  defp compile_component_module do
    module =
      Module.concat([
        UnifiedUi,
        Benchmarks,
        BudgetSignalFixture,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      vbox do
        id :root
        spacing 1
        text "Signal Budget", id: :title
        button "Increment", id: :increment_button, on_click: :increment
      end

      @impl true
      def init(_opts), do: %{count: 0}

      @impl true
      def update(state, %{type: "unified.button.clicked", data: %{action: :increment}}) do
        %{state | count: state.count + 1}
      end

      @impl true
      def update(state, _signal), do: state
    end
    """

    Code.compile_string(source)
    module
  end

  defp unload_module(module) when is_atom(module) do
    _ = :code.purge(module)
    _ = :code.delete(module)
    :ok
  end
end

UnifiedUi.Benchmarks.Phase5BudgetCheck.run(System.argv())
