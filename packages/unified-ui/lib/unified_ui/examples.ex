defmodule UnifiedUi.Examples do
  @moduledoc """
  Maintained reference modules for baseline `UnifiedUi` authored workflows.
  """

  alias UnifiedUi.Examples.{FoundationalScreen, OverlayWorkspace, ProfileForm}

  @catalog [
    %{
      id: :foundational_screen,
      category: :foundational,
      module: FoundationalScreen,
      constructs: [:foundational_visual, :layout],
      summary: "Minimal screen showing foundational widgets and baseline layouts."
    },
    %{
      id: :profile_form,
      category: :form_workflow,
      module: ProfileForm,
      constructs: [:input, :navigation, :forms],
      summary: "Baseline form workflow with grouped fields, tabs, and command actions."
    },
    %{
      id: :overlay_workspace,
      category: :advanced_flow,
      module: OverlayWorkspace,
      constructs: [:overlay, :display, :layout],
      summary: "Advanced overlay and split-pane workflow with contextual actions."
    }
  ]

  @spec modules() :: [module()]
  def modules do
    Enum.map(@catalog, & &1.module)
  end

  @spec catalog() :: [map()]
  def catalog do
    @catalog
  end
end
