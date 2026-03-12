defmodule UnifiedUi.Benchmarks.Phase5Baseline do
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
  @quick_benchee [warmup: 0.1, time: 0.2, memory_time: 0.1]
  @full_benchee [warmup: 1, time: 2, memory_time: 1]

  def run(argv \\ System.argv()) do
    {opts, _remaining_args, invalid} = OptionParser.parse(argv, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise ArgumentError,
              "Unsupported options for benchmarks/phase5_baseline.exs: #{inspect(invalid_opts)}"
    end

    quick? = opts[:quick] == true

    IO.puts("== UnifiedUi Phase 5 Baseline Profiling ==")
    IO.puts("Mode: #{if(quick?, do: "quick", else: "full")}")

    profile_dsl_compile(100)

    if not quick? do
      profile_dsl_compile(200)
    end

    dsl_state = build_large_dsl_state(160)
    iur_tree = Builder.build(dsl_state)
    style_state = build_style_state(40)

    {component_module, component_id, signal} = start_benchmark_component()

    try do
      Benchee.run(
        %{
          "iur.build.large_ui" => fn ->
            Builder.build(dsl_state)
          end,
          "render.concurrent.all_platforms" => fn ->
            Coordinator.concurrent_render(iur_tree, @platforms)
          end,
          "render.terminal.frame" => fn ->
            Terminal.render(iur_tree)
          end,
          "signals.dispatch.roundtrip" => fn ->
            dispatch_roundtrip(component_id, signal)
          end,
          "style.resolve.deep_inheritance" => fn ->
            StyleResolver.resolve(style_state, :style_40, fg: :yellow, padding: 2)
          end
        },
        benchee_options(quick?)
      )
    after
      _ = Agent.stop_component(component_id)
      unload_module(component_module)
    end
  end

  defp benchee_options(quick?) do
    base = if quick?, do: @quick_benchee, else: @full_benchee

    Keyword.merge(
      [
        parallel: 1,
        print: [benchmarking: true, fast_warning: false],
        formatters: [{Benchee.Formatters.Console, comparison: false, extended_statistics: false}]
      ],
      base
    )
  end

  defp profile_dsl_compile(widget_count) do
    {elapsed_us, module} =
      :timer.tc(fn ->
        compile_dsl_module(widget_count)
      end)

    elapsed_ms = Float.round(elapsed_us / 1_000, 2)
    IO.puts("DSL compile profile (#{widget_count} widgets): #{elapsed_ms} ms")

    unload_module(module)
  end

  defp compile_dsl_module(widget_count) do
    module =
      Module.concat([
        UnifiedUi,
        Benchmarks,
        DslCompileFixture,
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
      styles: %{
        entities: build_style_entities(40)
      },
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
    component_id = String.to_atom("bench_component_#{System.unique_integer([:positive])}")

    case Agent.start_component(module, component_id, platforms: []) do
      {:ok, _pid} ->
        signal = Signals.create!(:click, %{widget_id: :increment_button, action: :increment})
        {module, component_id, signal}

      {:error, reason} ->
        unload_module(module)
        raise "Unable to start benchmark component: #{inspect(reason)}"
    end
  end

  defp compile_component_module do
    module =
      Module.concat([
        UnifiedUi,
        Benchmarks,
        SignalFixture,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      vbox do
        id :root
        spacing 1
        text "Signal Benchmark", id: :title
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

  defp dispatch_roundtrip(component_id, signal) do
    :ok = Agent.signal_component(component_id, signal)
    {:ok, _state} = Agent.current_state(component_id)
    :ok
  end

  defp unload_module(module) when is_atom(module) do
    _ = :code.purge(module)
    _ = :code.delete(module)
    :ok
  end
end

UnifiedUi.Benchmarks.Phase5Baseline.run(System.argv())
