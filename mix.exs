defmodule Unified.MixProject do
  use Mix.Project

  def project do
    [
      app: :unified,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:spec_led_ex,
       github: "specleddev/specled_ex", branch: "main", only: [:dev, :test], runtime: false}
    ]
  end
end
