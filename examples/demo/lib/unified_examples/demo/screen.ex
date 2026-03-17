defmodule UnifiedExamples.Demo.Screen do
  @moduledoc """
  Phase 1 scaffold screen for the aggregate examples demo application.
  """

  use UnifiedUi.Dsl

  @example_metadata %{
    id: :demo_example_screen,
    root_id: :demo_example_screen_root,
    title: "Examples Demo Application",
    summary: "Aggregate category-oriented control demo scaffold",
    notes:
      "Phase 1 establishes the standalone app, launch contract, and authored root screen for the aggregate demo.",
    widget: :demo,
    theme_id: nil,
    interaction_demo: %{
      mode: :placeholder,
      family: :select,
      source: :demo_shell,
      trigger_label: nil,
      idle_prompt:
        "Later phases will turn this scaffold into the tabbed aggregate review surface.",
      outcome:
        "The aggregate demo scaffold should already boot as a standalone LiveView app before category tabs and signal stories are added."
    }
  }

  @spec example_metadata() :: map()
  def example_metadata, do: @example_metadata

  @spec example_interaction_demo() :: map()
  def example_interaction_demo, do: @example_metadata.interaction_demo

  @spec default_theme_id() :: nil
  def default_theme_id, do: nil

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: %{}

  identity do
    id(:demo_example_screen)
    title("Examples Demo Application")
    description("Aggregate category-oriented control demo scaffold")
    authored_ref([:examples, :demo, :demo_example_screen])
    tags([:example, :demo, :aggregate_demo])
  end

  composition do
    root(:demo_example_screen_root)
    mode(:screen)
    summary("Aggregate demo application scaffold")

    box :demo_example_screen_shell do
      summary("Phase 1 demo shell")

      text :demo_example_screen_title do
        value("Examples Demo Application")
        variant(:headline)
      end

      text :demo_example_screen_summary do
        value("Aggregate category-oriented control demo scaffold")
        variant(:body)
      end

      box :demo_example_screen_panel do
        summary("Root demo panel scaffold")
        variant(:panel)

        text :demo_example_screen_status do
          value("Standalone Phoenix LiveView scaffold is active.")
          variant(:body)
        end

        text :demo_example_screen_next_step do
          value("Later phases will add the category registry, tabbed galleries, and signal lab.")
          variant(:body)
        end
      end
    end
  end
end
