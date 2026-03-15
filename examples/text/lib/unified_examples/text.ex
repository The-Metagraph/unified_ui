defmodule UnifiedExamples.Text do
  @moduledoc """
  Baseline standalone example-app entrypoint for the shared examples suite.
  """

  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Text.Screen

  @spec screen_module() :: module()
  def screen_module, do: Screen

  @spec metadata() :: map()
  def metadata do
    screen_module().example_metadata()
    |> Map.merge(%{
      app: :unified_example_text,
      directory: "examples/text",
      purpose: :baseline_skeleton
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
