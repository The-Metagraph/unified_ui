defmodule UnifiedExamples.Shared.App do
  @moduledoc """
  Shared boilerplate for standalone example-app entrypoints.
  """

  defmacro __using__(opts) do
    app = Keyword.fetch!(opts, :app)
    directory = Keyword.fetch!(opts, :directory)
    purpose = Keyword.get(opts, :purpose, :widget_proof)

    quote bind_quoted: [app: app, directory: directory, purpose: purpose] do
      alias UnifiedExamples.Shared.Runtime
      @example_app app
      @example_directory directory
      @example_purpose purpose

      @spec screen_module() :: module()
      def screen_module, do: Module.concat(__MODULE__, Screen)

      @spec metadata() :: map()
      def metadata do
        screen_module().example_metadata()
        |> Map.merge(%{
          app: @example_app,
          directory: @example_directory,
          purpose: @example_purpose
        })
      end

      @spec boot(keyword()) :: {:ok, LiveUi.Runtime.State.t()} | {:error, term()}
      def boot(opts \\ []) do
        Runtime.mount(screen_module(), opts)
      end

      @spec component_assigns(keyword()) :: {:ok, map()} | {:error, term()}
      def component_assigns(opts \\ []) do
        Runtime.component_assigns(screen_module(), opts)
      end

      @spec render_html(keyword()) :: {:ok, String.t()} | {:error, term()}
      def render_html(opts \\ []) do
        Runtime.render_html(screen_module(), opts)
      end
    end
  end
end
