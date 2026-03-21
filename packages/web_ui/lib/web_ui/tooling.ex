defmodule WebUi.Tooling do
  @moduledoc """
  Package tooling and inspection helpers for the `web_ui` scaffold.
  """

  @spec workflows() :: [atom()]
  def workflows do
    [:package_tests, :reference_inspection, :canonical_render_smoke, :transport_round_trip]
  end

  @spec preview_surfaces() :: [module()]
  def preview_surfaces do
    [WebUi.Reference, WebUi.Info, WebUi.Style, WebUi.Theme, WebUi.Examples]
  end

  @spec mix_tasks() :: [String.t()]
  def mix_tasks do
    ["mix deps.get", "mix test", "mix docs"]
  end

  @spec documentation_surface() :: [String.t()]
  def documentation_surface do
    [
      "README.md",
      "guides/runtime_backbone.md",
      "guides/native_runtime_and_examples.md",
      "guides/canonical_rendering_and_transport.md",
      "guides/maintainer_workflows.md"
    ]
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      workflows: workflows(),
      package_areas: WebUi.package_areas(),
      runtime_validation: WebUi.Runtime.validation_state()
    }
  end
end
