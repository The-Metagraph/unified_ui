defmodule LiveUi.Screen do
  @moduledoc """
  Macro for tiny manually authored wrapper LiveViews around screen modules.

  ## Example

      defmodule MyAppWeb.CounterLive do
        use LiveUi.Screen, source: MyApp.CounterScreen
      end

  The wrapper may optionally define:

  - `liveui_context/3`
  - `liveui_source_opts/3`

  It may not override the core LiveView lifecycle owned by the shared engine.
  """

  @type params :: map()
  @type session :: map()
  @type socket :: Phoenix.LiveView.Socket.t()

  @callback liveui_context(params(), session(), socket()) :: map()
  @callback liveui_source_opts(params(), session(), socket()) :: keyword()

  defmacro __using__(opts) do
    source_ast = Keyword.get(opts, :source)
    source_module = expand_source!(source_ast, __CALLER__)

    quote bind_quoted: [source_module: source_module] do
      use Phoenix.LiveView

      @behaviour LiveUi.Screen
      @before_compile LiveUi.Screen
      @live_ui_screen_source source_module

      @impl LiveUi.Screen
      def liveui_context(_params, _session, _socket), do: %{}

      @impl LiveUi.Screen
      def liveui_source_opts(_params, _session, _socket), do: []

      defoverridable liveui_context: 3, liveui_source_opts: 3

      def __live_ui_screen__ do
        %{source: @live_ui_screen_source}
      end
    end
  end

  defmacro __before_compile__(env) do
    invalid =
      env.module
      |> Module.definitions_in()
      |> Enum.filter(&(&1 in [{:mount, 3}, {:render, 1}, {:handle_event, 3}]))

    if invalid != [] do
      callbacks =
        invalid
        |> Enum.map_join(", ", fn {name, arity} -> "#{name}/#{arity}" end)

      raise CompileError,
        file: env.file,
        line: env.line,
        description:
          "#{inspect(env.module)} uses LiveUi.Screen and may not override #{callbacks}. " <>
            "Use liveui_context/3 or liveui_source_opts/3 for wrapper-specific customization."
    end

    quote do
      @impl true
      def mount(params, session, socket) do
        LiveUi.Live.Engine.mount(params, session, socket, __MODULE__)
      end

      @impl true
      def handle_event(event_name, payload, socket) do
        LiveUi.Live.Engine.handle_event(event_name, payload, socket, __MODULE__)
      end

      @impl true
      def render(assigns) do
        LiveUi.Live.Engine.render(assigns)
      end
    end
  end

  defp expand_source!(nil, env) do
    raise CompileError,
      file: env.file,
      line: env.line,
      description: "LiveUi.Screen requires a source: MyApp.SomeScreen option"
  end

  defp expand_source!(source_ast, env) do
    expanded_source = Macro.expand(source_ast, env)

    if LiveUi.Source.module_reference?(expanded_source) do
      expanded_source
    else
      raise CompileError,
        file: env.file,
        line: env.line,
        description:
          "LiveUi.Screen source must be a module reference, got: #{Macro.to_string(source_ast)}"
    end
  end
end
