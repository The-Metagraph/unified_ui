defmodule WebUi.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/pcharbon70/unified_ui"

  def project do
    [
      app: :web_ui,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description: "Phoenix + Elm runtime library for the unified ecosystem.",
      deps: deps(),
      docs: docs(),
      package: package(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jido_signal, "~> 2.0"},
      {:phoenix, "~> 1.8"},
      {:phoenix_html, "~> 4.1"},
      {:unified_iur, path: "../unified_iur"}
    ]
  end

  defp docs do
    [
      main: "WebUi",
      extras: [
        "README.md",
        "guides/runtime_backbone.md",
        "guides/phoenix_elm_split.md",
        "guides/canonical_rendering_and_transport.md",
        "guides/maintainer_workflows.md"
      ],
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

  defp aliases do
    [
      # Frontend asset aliases for Elm compilation
      "assets.build": &build_assets/1,
      "assets.watch": &watch_assets/1,
      "assets.deploy": &deploy_assets/1
    ]
  end

  # Elm asset compilation helpers
  defp build_assets(_) do
    Mix.shell().cmd("cd assets && npm install && npm run build")
  end

  defp watch_assets(_) do
    Mix.shell().cmd("cd assets && npm run watch")
  end

  defp deploy_assets(_) do
    Mix.shell().cmd("cd assets && npm install && npm run build")
  end
end
