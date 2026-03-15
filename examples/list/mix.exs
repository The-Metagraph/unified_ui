defmodule UnifiedExamples.List.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/pcharbon70/unified_ui"

  def project do
    [
      app: :unified_example_list,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description: "Standalone list example app for the unified example suite.",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:unified_examples_shared, path: "../shared"},
      {:unified_ui, path: "../../packages/unified-ui"},
      {:unified_iur, path: "../../packages/unified_iur"},
      {:live_ui, path: "../../packages/live_ui"}
    ]
  end

  defp docs do
    [
      main: "UnifiedExamples.List",
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
