defmodule UnifiedExamples.Demo.Screen do
  @moduledoc """
  Phase 1 scaffold screen for the aggregate examples demo application.
  """

  use UnifiedUi.Dsl
  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()

  @example_metadata %{
    id: :demo_example_screen,
    root_id: :demo_example_screen_root,
    title: "Examples Demo Application",
    summary: "Aggregate category-oriented control demo scaffold",
    notes:
      "Phase 1 establishes the standalone app, launch contract, and authored root screen for the aggregate demo.",
    widget: :demo,
    theme_id: @default_theme_id,
    interaction_demo: %{
      mode: :shared_trigger,
      family: :navigation,
      source: :shared_trigger,
      source_label: "Shared interaction trigger",
      trigger_label: "Preview the aggregate demo shell",
      idle_prompt:
        "Use the shared trigger to review how the aggregate demo will present category tabs and shared styling.",
      outcome:
        "The aggregate demo scaffold should already look and feel like part of the shared example suite before category tabs and signal stories are added.",
      target_surface: "Aggregate demo scaffold shell",
      reviewer_hint:
        "The aggregate demo should already reuse the shared button-example theme and panel language during Phase 1."
    }
  }

  @spec example_metadata() :: map()
  def example_metadata, do: @example_metadata

  @spec example_interaction_demo() :: map()
  def example_interaction_demo, do: @example_metadata.interaction_demo

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  identity do
    id(:demo_example_screen)
    title("Examples Demo Application")
    description("Aggregate category-oriented control demo scaffold")
    authored_ref([:examples, :demo, :demo_example_screen])
    tags([:example, :demo, :aggregate_demo])
  end

  shared_theme_definition()

  composition do
    root(:demo_example_screen_root)
    mode(:screen)
    summary("Aggregate demo application scaffold")

    box :demo_example_screen_shell do
      theme_ref(@default_theme_id)
      style_refs([:example_shell])
      tone(:surface)
      variant(:panel)
      summary("Phase 1 demo shell")

      text :demo_example_screen_title do
        value("Examples Demo Application")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :demo_example_screen_summary do
        value("Aggregate category-oriented control demo scaffold")
        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      box :demo_example_screen_panel do
        summary("Root demo panel scaffold")
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :demo_example_screen_status do
          value("Standalone Phoenix LiveView scaffold is active.")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :demo_example_screen_shell_note do
          value(
            "This root shell now uses the same shared theme and style profile as the current button example."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end

        text :demo_example_screen_next_step do
          value("Later phases will add the category registry, tabbed galleries, and signal lab.")
          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end
      end

      button :demo_example_theme_preview_trigger do
        label("Preview the aggregate demo shell")
        theme_ref(@default_theme_id)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:solid)
      end
    end
  end
end
