defmodule UnifiedExamples.TextInput do
  @moduledoc """
  Standalone text_input example-app entrypoint for the shared examples suite.
  """

  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.TextInput.Screen

  @spec screen_module() :: module()
  def screen_module, do: Screen

  @spec metadata() :: map()
  def metadata do
    screen_module().example_metadata()
    |> Map.merge(%{
      app: :unified_example_text_input,
      directory: "examples/text_input",
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
