defmodule WebUi.MixProject do
  use Mix.Project

  @unified_iur_ref "6da558536a59f98ade5691f57e3739c4bedda8bb"

  def project do
    [
      app: :web_ui,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:unified_iur, git: "https://github.com/pcharbon70/unified_iur.git", ref: @unified_iur_ref},
      {:spec_led_ex,
       github: "specleddev/specled_ex", branch: "main", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      conformance: ["test --only conformance"],
      "assets.setup": ["cmd --cd assets npm install"],
      "assets.build": ["cmd --cd assets npm run build"],
      "assets.css.watch": ["cmd --cd assets npm run watch:css"]
    ]
  end
end
