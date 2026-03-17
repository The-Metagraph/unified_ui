defmodule UnifiedExamples.Shared.Documentation do
  @moduledoc """
  Documentation checks for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.AppReadme
  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  @root_required_snippets [
    "standalone Phoenix LiveView app",
    "shared authoring template",
    "shared default theme",
    "shared default style profile",
    "`examples/catalog.tsv`",
    "`examples/shared/`",
    "`mix examples.list`",
    "`mix examples.launch <directory> --dry-run`",
    "`mix examples.preview <directory>`",
    "`mix examples.validate --strict`",
    "`mix phx.server`",
    "`UnifiedUi` DSL -> canonical `UnifiedIUR` -> `LiveUi` rendering",
    "meaningful authored interaction"
  ]

  @demo_required_snippets [
    "aggregate category-oriented review surface",
    "Signal Lab",
    "same shared theme and style baseline as the current button example",
    "`mix examples.launch demo --dry-run`",
    "`mix phx.server`",
    "Use the aggregate demo when you want a category-level overview",
    "add a new representative control or signal-lab story"
  ]

  @shared_required_snippets [
    "`UnifiedExamples.Shared.Template`",
    "`:example_suite_default`",
    "`:example_shell`",
    "`:example_panel`",
    "`:example_form_shell`",
    "`example_panel/1`",
    "`example_form_panel/1`",
    "`mix examples.launch <directory> --smoke-test`",
    "`mix phx.server`",
    "`mix examples.report`",
    "`UnifiedExamples.Shared.Documentation.report/0`",
    "`UnifiedExamples.Shared.Tooling.smoke_launch/2`",
    "source-driven interaction storytelling",
    "target-driven interaction storytelling"
  ]

  @spec paths() :: %{shared_readme: String.t(), suite_index: String.t(), demo_readme: String.t()}
  def paths do
    %{
      suite_index: Shared.suite_index_path(),
      shared_readme: Path.join(Shared.shared_root(), "README.md"),
      demo_readme: Path.join([Shared.suite_root(), "demo", "README.md"])
    }
  end

  @spec report() :: map()
  def report do
    %{
      suite_index: suite_index_path,
      shared_readme: shared_readme_path,
      demo_readme: demo_readme_path
    } = paths()

    suite_index = File.read!(suite_index_path)
    shared_readme = File.read!(shared_readme_path)
    demo_readme = File.read!(demo_readme_path)

    root_missing_directories = missing_directories(suite_index)

    root = %{
      path: suite_index_path,
      missing_snippets: missing_snippets(suite_index, @root_required_snippets),
      missing_directories: root_missing_directories
    }

    shared = %{
      path: shared_readme_path,
      missing_snippets: missing_snippets(shared_readme, @shared_required_snippets),
      missing_directories: []
    }

    aggregate_demo = %{
      path: demo_readme_path,
      missing_snippets: missing_snippets(demo_readme, @demo_required_snippets),
      synchronized?: missing_snippets(demo_readme, @demo_required_snippets) == []
    }

    app_readmes = AppReadme.report()

    %{
      paths: paths(),
      root:
        Map.put(
          root,
          :synchronized?,
          root.missing_snippets == [] and root_missing_directories == []
        ),
      shared:
        Map.put(
          shared,
          :synchronized?,
          shared.missing_snippets == []
        ),
      aggregate_demo: aggregate_demo,
      app_readmes: app_readmes,
      valid?:
        root.missing_snippets == [] and root_missing_directories == [] and
          shared.missing_snippets == [] and aggregate_demo.synchronized? and
          app_readmes.synchronized?
    }
  end

  @spec summary(map()) :: String.t()
  def summary(report) do
    [
      "Example suite documentation",
      "valid?: #{report.valid?}",
      "root_missing_snippets: #{Enum.join(report.root.missing_snippets, ", ")}",
      "root_missing_directories: #{Enum.join(report.root.missing_directories, ", ")}",
      "shared_missing_snippets: #{Enum.join(report.shared.missing_snippets, ", ")}",
      "shared_missing_directories: #{Enum.join(report.shared.missing_directories, ", ")}",
      "demo_missing_snippets: #{Enum.join(report.aggregate_demo.missing_snippets, ", ")}",
      "app_readme_mismatches: #{Enum.join(report.app_readmes.mismatched_directories, ", ")}"
    ]
    |> Enum.join("\n")
  end

  defp missing_directories(contents) do
    Catalog.directories()
    |> Enum.reject(&(contents =~ "`#{&1}/`"))
  end

  defp missing_snippets(contents, required_snippets) do
    Enum.reject(required_snippets, &(contents =~ &1))
  end
end
