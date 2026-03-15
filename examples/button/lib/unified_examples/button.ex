defmodule UnifiedExamples.Button do
  @moduledoc """
  Standalone button example-app entrypoint for the shared examples suite.
  """

  alias UnifiedExamples.Button.Screen
  alias UnifiedExamples.Shared.Runtime

  @spec screen_module() :: module()
  def screen_module, do: Screen

  @spec metadata() :: map()
  def metadata do
    screen_module().example_metadata()
    |> Map.merge(%{
      app: :unified_example_button,
      directory: "examples/button",
      purpose: :widget_proof
    })
  end

  @spec boot(keyword()) :: {:ok, LiveUi.Runtime.State.t()} | {:error, term()}
  def boot(opts \\ []) do
    Runtime.mount(screen_module(), opts)
  end

  @spec render_html(keyword()) :: {:ok, String.t()} | {:error, term()}
  def render_html(opts \\ []) do
    Runtime.render_html(screen_module(), opts)
  end
end
