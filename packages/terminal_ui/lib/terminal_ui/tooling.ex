defmodule TerminalUi.Tooling do
  @moduledoc """
  Maintainer workflow surface for `terminal_ui`.
  """

  @spec workflows() :: [atom()]
  def workflows do
    [:package_checks, :runtime_review, :capability_review]
  end

  @spec documentation_surface() :: [String.t()]
  def documentation_surface do
    [
      "README.md",
      "guides/runtime_backbone.md",
      "guides/maintainer_workflows.md"
    ]
  end
end
