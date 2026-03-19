defmodule UnifiedExamples.Demo.Screen do
  @moduledoc """
  Aggregate demo screen for the unified examples suite.
  Phase 6: Widget catalog with detail pages.
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
    notes: "Phase 6: Widget catalog with individual widget detail pages.",
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
      trigger_label: "Browse the widget catalog",
      idle_prompt: "Browse the widget catalog and explore individual components.",
      outcome: "The widget catalog allows interactive exploration of all UI components.",
      target_surface: "Aggregate demo scaffold shell",
      reviewer_hint: "The aggregate demo provides a widget catalog browser."
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
    summary("Aggregate demo application shell")

    box :demo_example_screen_shell do
      theme_ref(@default_theme_id)
      style_refs([:example_shell])
      tone(:surface)
      variant(:panel)
      summary("Phase 6 demo shell with widget catalog")

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
          value("Widget catalog with individual widget detail pages is active.")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :demo_example_screen_shell_note do
          value(
            "Browse widgets by category and click on any widget to see its detail page with events and attributes."
          )
          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end
      end

      box :demo_example_category_registry_panel do
        summary("Category registry and navigation")
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
            "The aggregate demo tracks #{Categories.count()} ordered review tabs and defaults to #{@active_category_entry.label}."
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
        label("Browse the widget catalog")
        interaction_refs([:preview_demo_shell])
        theme_ref(@default_theme_id)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:solid)
      end
    end
  end
end
