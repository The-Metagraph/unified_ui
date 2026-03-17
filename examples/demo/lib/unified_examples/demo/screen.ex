defmodule UnifiedExamples.Demo.Screen do
  @moduledoc """
  Phase 1 scaffold screen for the aggregate examples demo application.
  """

  use UnifiedUi.Dsl
  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Template

  @category_entries Categories.review_registry()
  @category_items Categories.tab_items()
  @active_category_id Categories.default_id()
  @active_category_entry Categories.entry!(@active_category_id)
  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()

  @example_metadata %{
    id: :demo_example_screen,
    root_id: :demo_example_screen_root,
    title: "Examples Demo Application",
    summary: "Aggregate category-oriented control demo scaffold",
    notes:
      "Phase 1 establishes the standalone app, launch contract, category registry, and authored root screen for the aggregate demo.",
    widget: :demo,
    theme_id: @default_theme_id,
    active_category_id: @active_category_id,
    category_count: Categories.count(),
    category_ids: Categories.ids(),
    category_registry: @category_entries,
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

  signals do
    namespace(:examples_demo)

    data_binding do
      id(:active_category_tab)
      path([:navigation, :active_category_tab])
      scope([:screen])
      default(@active_category_id)
    end

    interaction do
      id(:preview_demo_shell)
      family(:navigation)
      intent(:preview_demo_shell)
      source_context(element_id: :demo_example_theme_preview_trigger, scope: :screen)
      target_intent(binding: :active_category_tab, route: @active_category_id)
      payload_mapping(category: @active_category_id, review_surface: :aggregate_demo)
      binding_refs([:active_category_tab])
    end
  end

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
          value(
            "Later phases will add the full category galleries and signal-reactivity stories."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end
      end

      box :demo_example_category_registry_panel do
        summary("Ordered category registry preview")
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :demo_example_category_registry_title do
          value("Category Registry Backbone")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :demo_example_category_registry_summary do
          value(
            "The aggregate demo now tracks #{Categories.count()} ordered review tabs and defaults to #{@active_category_entry.label}."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end

        tabs :demo_example_category_tabs do
          items(@category_items)
          active_item(@active_category_id)
          interaction_refs([:preview_demo_shell])
          theme_ref(@default_theme_id)
          tone(:accent)
          variant(:solid)
        end

        text :demo_example_active_category_label do
          value("Active category: #{@active_category_entry.label}")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :demo_example_active_category_summary do
          value(@active_category_entry.summary)
          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end
      end

      button :demo_example_theme_preview_trigger do
        label("Preview the aggregate demo shell")
        interaction_refs([:preview_demo_shell])
        theme_ref(@default_theme_id)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:solid)
      end
    end
  end
end
