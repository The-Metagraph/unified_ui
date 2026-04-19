defmodule UnifiedExamples.PickList.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/pcharbon70/unified_ui"

  def project do
    [
      app: :unified_example_pick_list,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description: "Standalone pick_list example app for the unified example suite.",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      mod: {application_module(), []},
      extra_applications: [:logger]
    ]
  end

  defp application_module do
    UnifiedExamples.PickList.Application
  end

  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_live_view, "~> 1.1"},
      {:plug_cowboy, "~> 2.7"},
      {:unified_ui, path: "../../packages/unified-ui"},
      {:unified_iur, path: "../../packages/unified_iur"},
      {:live_ui, path: "../../packages/live_ui"}
    ]
  end

  defp docs do
    [
      main: "UnifiedExamples.PickList",
      extras: ["README.md"],
      source_ref: "main",
      source_url: @source_url
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
