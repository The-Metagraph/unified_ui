defmodule UnifiedExamples.Phase5IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.AggregateDemo
  alias UnifiedExamples.Shared.AppReadme
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Validation

  @moduletag timeout: 180_000

  test "aggregate demo is discoverable through the shared suite index and launcher" do
    assert Tooling.catalog_report() =~ "Aggregate review surfaces"
    assert Tooling.catalog_report() =~ AggregateDemo.catalog_line()

    assert {:ok, demo} = Tooling.review_metadata("demo")

    assert demo.purpose == :aggregate_demo
    assert demo.category_ids == AggregateDemo.required_category_ids()

    launch = Tooling.launch_descriptor("demo", port: 43_123)

    assert launch.directory == "demo"
    assert launch.path == "/"
    assert launch.url == "http://127.0.0.1:43123/"
    assert launch.command =~ "PORT=43123 mix phx.server"
  end

  test "suite validation keeps aggregate demo tabs stories and shared styling aligned" do
    report = Validation.report()

    assert report.valid?
    assert report.catalog.aggregate_demo_present?
    assert report.aggregate_demo.issues == []
    assert report.release.gates.aggregate_demo_continuity.passed?

    drift_issues =
      Validation.validate_aggregate_demo_review_metadata(%{
        directory: "demo",
        theme_id: :rogue_theme,
        default_theme_id: :rogue_theme,
        uses_shared_template: false,
        browser_runnable?: false,
        dev_server_enabled?: false,
        launch_path: "/rogue",
        launch_command: "mix test",
        category_ids: [:foundational_content],
        category_count: 1,
        category_registry: [%{id: :foundational_content, example_count: 0}],
        linked_example_directories: [],
        signal_lab_contract: %{valid?: false, story_ids: [:action_to_feedback]}
      })

    drift_codes = Enum.map(drift_issues, & &1.code)

    assert :shared_template_divergence in drift_codes
    assert :category_registry_mismatch in drift_codes
    assert :signal_lab_story_inventory_mismatch in drift_codes
  end

  test "focused examples stay cross linked back to the aggregate demo review surface" do
    assert {:ok, demo} = Tooling.review_metadata("demo")
    assert {:ok, button} = Tooling.review_metadata("button")
    assert {:ok, text_input} = Tooling.review_metadata("text_input")

    assert button.aggregate_demo_directory == "demo"
    assert button.aggregate_demo_categories == [:foundational_content, :signal_lab]
    assert button.aggregate_demo_category_labels == ["Foundational Content", "Signal Lab"]
    assert button.traceability.aggregate_demo.category_ids == [:foundational_content, :signal_lab]

    assert text_input.aggregate_demo_categories == [:forms_and_input, :signal_lab]
    assert text_input.aggregate_demo_category_labels == ["Forms and Input", "Signal Lab"]

    assert "button" in demo.linked_example_directories
    assert "text_input" in demo.linked_example_directories
    assert "button" in demo.category_example_directories.foundational_content
    assert "button" in demo.category_example_directories.signal_lab
    assert "text_input" in demo.category_example_directories.forms_and_input
    assert "text_input" in demo.category_example_directories.signal_lab

    button_readme = AppReadme.expected_contents("button")
    text_input_readme = AppReadme.expected_contents("text_input")

    assert button_readme =~ "## Aggregate Demo"
    assert button_readme =~ "examples/demo/"
    assert button_readme =~ "Foundational Content, Signal Lab"

    assert text_input_readme =~ "## Aggregate Demo"
    assert text_input_readme =~ "examples/demo/"
    assert text_input_readme =~ "Forms and Input, Signal Lab"
  end
end
