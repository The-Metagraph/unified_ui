defmodule UnifiedExamples.Demo.Categories.OverlaysAndOperational do
  @moduledoc """
  Overlays and operational gallery for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Fixtures
  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()

  @example_directories [
    "overlay",
    "dialog",
    "alert_dialog",
    "context_menu",
    "toast",
    "stream_widget",
    "process_monitor",
    "supervision_tree_viewer",
    "cluster_dashboard"
  ]

  @dialog_snapshot Fixtures.dialog_snapshot()
  @alert_dialog_snapshot Fixtures.alert_dialog_snapshot()
  @toast_snapshot Fixtures.toast_snapshot()
  @overlay_snapshot Fixtures.overlay_snapshot()
  @process_snapshot Fixtures.process_monitor_snapshot()
  @cluster_snapshot Fixtures.cluster_dashboard_snapshot()
  @supervision_snapshot Fixtures.supervision_tree_snapshot()

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  identity do
    id(:overlays_and_operational)
    title("Overlays and Operational")
    description("Overlay surfaces, operational widgets, and runtime-monitoring presentations.")
    authored_ref([:examples, :demo, :categories, :overlays_and_operational])
    tags([:example, :demo, :category_fragment, :overlays_and_operational])
  end

  shared_theme_definition()

  composition do
    root(:overlays_and_operational_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Overlays and operational gallery")

    box :overlays_operational_intro do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :overlays_operational_title do
        value("Overlays and Operational Gallery")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :overlays_operational_summary do
        value(
          "Review layered context surfaces and operational monitoring widgets together so the shell stays readable even when the controls get more complex."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end
    end

    box :overlays_operational_overlay_story do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :overlays_operational_overlay_title do
        value("Layered context surfaces")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :overlays_operational_overlay_copy do
        value(
          "Review how dialog, alert, context menu, toast, and full overlay layers stack without losing the base workspace context."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end

      box :overlays_operational_base_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :overlays_operational_base_heading do
          value(@overlay_snapshot.base_title)
          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:surface)
          variant(:body)
        end
      end

      button :overlays_operational_alert_trigger do
        label(@alert_dialog_snapshot.trigger_label)
        theme_ref(@default_theme_id)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:solid)
      end

      button :overlays_operational_toast_trigger do
        label("Trigger sync notice")
        theme_ref(@default_theme_id)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:quiet)
      end

      box :overlays_operational_dialog_content do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :overlays_operational_dialog_copy do
          value(@dialog_snapshot.copy)
          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:surface)
          variant(:body)
        end
      end

      box :overlays_operational_context_target do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :overlays_operational_context_target_label do
          value("Service health actions")
          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:surface)
          variant(:body)
        end
      end
    end

    dialog :overlays_operational_dialog do
      title(@dialog_snapshot.title)
      content_ref(:overlays_operational_dialog_content)
      visible?(true)
      theme_ref(@default_theme_id)
      tone(:surface)
      variant(:quiet)
    end

    alert_dialog :overlays_operational_alert_dialog do
      title(@alert_dialog_snapshot.title)
      message(@alert_dialog_snapshot.message)
      trigger_ref(:overlays_operational_alert_trigger)
      visible?(true)
      confirm_intent(:confirm_escalation)
      dismiss_intent(:cancel_escalation)
      severity(@alert_dialog_snapshot.severity)
      theme_ref(@default_theme_id)
      tone(:surface)
      variant(:quiet)
    end

    context_menu :overlays_operational_context_menu do
      options(Fixtures.context_menu_options())
      target_ref(:overlays_operational_context_target)
      visible?(true)
      placement(:bottom_start)
      theme_ref(@default_theme_id)
      tone(:surface)
      variant(:quiet)
    end

    toast :overlays_operational_toast do
      title(@toast_snapshot.title)
      message(@toast_snapshot.message)
      severity(@toast_snapshot.severity)
      placement(@toast_snapshot.placement)
      trigger_ref(:overlays_operational_toast_trigger)
      visible?(true)
      theme_ref(@default_theme_id)
      tone(:surface)
      variant(:quiet)
    end

    overlay :overlays_operational_overlay do
      base_ref(:overlays_operational_base_panel)

      layer_refs([
        :overlays_operational_dialog,
        :overlays_operational_alert_dialog,
        :overlays_operational_context_menu,
        :overlays_operational_toast
      ])

      background_fill(@overlay_snapshot.background_fill)
      theme_ref(@default_theme_id)
      tone(:surface)
      variant(:quiet)
    end

    grid :overlays_operational_monitoring_grid do
      columns(2)
      gap(:md)

      box :overlays_operational_stream_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :overlays_operational_stream_title do
          value("Operational feeds")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :overlays_operational_stream_copy do
          value(
            "Review whether live stream and process-monitor surfaces make the current operations story easy to scan."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        stream_widget :overlays_operational_stream do
          entries(Fixtures.stream_widget_entries())
          ordering(:append_only)
          severity_field(:severity)
          timestamp_field(:timestamp)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        process_monitor :overlays_operational_process_monitor do
          processes(@process_snapshot.processes)
          sort_by(@process_snapshot.sort_by)
          severity(@process_snapshot.severity)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :overlays_operational_cluster_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :overlays_operational_cluster_title do
          value("Topology and cluster state")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :overlays_operational_cluster_copy do
          value(
            "Review whether the supervision tree and cluster dashboard keep hierarchical state understandable inside the shared shell."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        supervision_tree_viewer :overlays_operational_supervision_tree do
          topology(@supervision_snapshot.topology)
          expanded?(@supervision_snapshot.expanded?)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        cluster_dashboard :overlays_operational_cluster_dashboard do
          cluster_nodes(@cluster_snapshot.nodes)
          metrics(@cluster_snapshot.summary)
          severity(@cluster_snapshot.severity)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end
    end
  end
end
