defmodule DesktopUi.Tooling do
  @moduledoc """
  Maintainer-facing tooling surface placeholder for `desktop_ui`.
  """

  @spec documentation_surface() :: [String.t()]
  def documentation_surface do
    [
      "README.md",
      "guides/runtime_backbone.md",
      "guides/maintainer_workflows.md"
    ]
  end

  @spec workflows() :: [atom()]
  def workflows do
    [:runtime_review, :platform_review, :package_validation]
  end

  @spec mix_tasks() :: [String.t()]
  def mix_tasks do
    ["mix test", "mix spec.plancheck desktop_ui"]
  end
end
