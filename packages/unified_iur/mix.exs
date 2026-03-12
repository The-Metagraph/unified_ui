defmodule UnifiedIur.MixProject do
  use Mix.Project

  def project do
    [
      app: :unified_iur,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "UnifiedIUR",
      source_url: "https://github.com/your-org/unified_iur",
      homepage_url: "https://github.com/your-org/unified_iur",
      docs: [
        main: "UnifiedIUR",
        extras: ["README.md"]
      ]
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
      # Development and test dependencies only
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    UnifiedIUR - Intermediate UI Representation

    A pure data representation layer for user interfaces.

    UnifiedIUR provides simple, immutable data structures that represent
    UI elements without any rendering logic or platform dependencies.

    This allows platform libraries (TermUi, DesktopUi, WebUi) and the
    unified_ui DSL to share a common UI representation.
    """
  end

  defp package do
    [
      name: "unified_iur",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/your-org/unified_iur",
        "Changelog" => "https://github.com/your-org/unified_iur/blob/main/CHANGELOG.md"
      }
    ]
  end
end
