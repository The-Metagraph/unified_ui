defmodule UnifiedExamples.Demo.Categories.NavigationAndSelection do
  @moduledoc """
  Navigation and selection gallery for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()
  @example_directories ["menu", "tabs", "list", "command_palette"]

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  identity do
    id(:navigation_and_selection)
    title("Navigation and Selection")
    description("Menus, tabs, lists, and selection-oriented navigation controls.")
    authored_ref([:examples, :demo, :categories, :navigation_and_selection])
    tags([:example, :demo, :category_fragment, :navigation_and_selection])
  end

  shared_theme_definition()

  composition do
    root(:navigation_and_selection_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Navigation and selection gallery")

    box :navigation_gallery_intro do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :navigation_gallery_title do
        value("Navigation and Selection Gallery")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :navigation_gallery_summary do
        value("Compare active, focused, and selected states through one shared review surface.")
        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      text :navigation_gallery_note do
        value(
          "Each panel highlights a different kind of selection meaning so reviewers can compare state cues quickly."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end
    end

    grid :navigation_gallery_grid do
      columns(2)
      gap(:md)

      box :navigation_menu_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :navigation_menu_title do
          value("Menu active state")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :navigation_menu_copy do
          value(
            "Review which destination is currently active and whether the vertical menu makes the navigation rail easy to scan."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        menu :navigation_primary_menu do
          items(overview: "Overview", incidents: "Incidents", releases: "Releases")
          active_item(:incidents)
          orientation(:vertical)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :navigation_tabs_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :navigation_tabs_title do
          value("Tabs selected state")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :navigation_tabs_copy do
          value(
            "Review how the selected tab communicates the active workspace view without adding extra shell chrome."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        tabs :navigation_primary_tabs do
          items(summary: "Summary", deploys: "Deploys", alerts: "Alerts")
          active_item(:deploys)
          orientation(:horizontal)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :navigation_list_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :navigation_list_title do
          value("List selection state")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :navigation_list_copy do
          value(
            "Review whether the selected list row, label, and description make the current focus obvious."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        list :navigation_primary_list do
          items([
            [
              id: :incident_1,
              label: "Database failover",
              description: "Primary cluster recovery in progress",
              selected?: true
            ],
            [
              id: :incident_2,
              label: "Queue backlog",
              description: "Background job latency elevated"
            ],
            [
              id: :incident_3,
              label: "Docs refresh",
              description: "Runbook update awaiting approval"
            ]
          ])

          selection_mode(:single)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :navigation_command_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :navigation_command_title do
          value("Command palette focus state")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :navigation_command_copy do
          value(
            "Review how the command palette frames quick actions and whether the focused command surface feels discoverable."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        command_palette :navigation_command_palette do
          items(
            open_incident: "Open incident",
            assign_owner: "Assign owner",
            resolve_incident: "Resolve incident"
          )

          label("Workspace commands")
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end
    end
  end
end
