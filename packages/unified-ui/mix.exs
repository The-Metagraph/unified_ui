defmodule UnifiedUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :unified_ui,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: test_coverage()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {UnifiedUi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:spark, "~> 1.0"},
      {:jido, git: "https://github.com/agentjido/jido.git", tag: "v2.0.0"},
      {:jido_signal, "~> 2.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:term_ui, github: "pcharbon70/term_ui", branch: "multi-renderer"},
      {:unified_iur, path: "../unified_iur"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.3", only: :dev, runtime: false},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:stream_data, "~> 1.0", only: :test}
    ]
  end

  defp description do
    """
    A Spark-powered DSL for building multi-platform user interfaces in Elixir.

    Provides declarative UI definitions that compile to terminal, desktop, and web platforms.
    """
  end

  defp package do
    [
      name: "unified_ui",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/pcharbon70/unified-ui",
        "HexDocs" => "https://hexdocs.pm/unified_ui",
        "Changelog" => "https://github.com/pcharbon70/unified-ui/blob/main/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/pcharbon70/unified-ui",
      source_ref: "v#{Mix.Project.config()[:version]}",
      extras: [
        "README.md",
        "guides/getting-started.md",
        "guides/widget-reference.md",
        "guides/dsl-reference.md",
        "guides/layout-system.md",
        "guides/styling-and-theming.md",
        "guides/signals-and-events.md",
        "guides/platform-guides.md",
        "guides/platforms/terminal.md",
        "guides/platforms/desktop.md",
        "guides/platforms/web.md",
        "guides/dashboard-tutorial.md",
        "guides/troubleshooting.md",
        "guides/extensions.md"
      ],
      groups_for_extras: [
        Guides: ["guides/*.md", "guides/platforms/*.md"]
      ]
    ]
  end

  defp test_coverage do
    [
      summary: [threshold: 80],
      ignore_modules: [
        ~r/^UnifiedUi\.Dsl\.Extension(\.|$)/,
        ~r/^UnifiedUi\.(Update|View)TransformerFixture(\.|$)/
      ]
    ]
  end
end
