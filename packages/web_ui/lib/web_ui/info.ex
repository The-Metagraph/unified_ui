defmodule WebUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: :web_ui,
      namespace: WebUi,
      package_areas: WebUi.package_areas(),
      validation_state: WebUi.Runtime.validation_state(),
      tooling: %{
        workflows: WebUi.Tooling.workflows(),
        mix_tasks: WebUi.Tooling.mix_tasks()
      },
      documentation: WebUi.Tooling.documentation_surface()
    }
  end

  @spec renderer_summary() :: map()
  def renderer_summary do
    %{
      accepts: WebUi.Renderer.accepts(),
      supported_kinds: WebUi.Renderer.supported_kinds(),
      responsibilities: WebUi.Renderer.responsibilities()
    }
  end
end
