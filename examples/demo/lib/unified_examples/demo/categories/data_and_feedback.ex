defmodule UnifiedExamples.Demo.Categories.DataAndFeedback do
  @moduledoc """
  Data and feedback gallery for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Fixtures
  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()

  @example_directories [
    "table",
    "tree_view",
    "markdown_viewer",
    "log_viewer",
    "status",
    "progress",
    "gauge",
    "inline_feedback",
    "sparkline",
    "bar_chart",
    "line_chart"
  ]

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  identity do
    id(:data_and_feedback)
    title("Data and Feedback")
    description("Data presentation, progress cues, and reviewer-facing feedback states.")
    authored_ref([:examples, :demo, :categories, :data_and_feedback])
    tags([:example, :demo, :category_fragment, :data_and_feedback])
  end

  shared_theme_definition()

  composition do
    root(:data_and_feedback_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Data and feedback gallery")

    box :data_feedback_intro do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :data_feedback_title do
        value("Data and Feedback Gallery")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :data_feedback_summary do
        value(
          "Review dense data surfaces and feedback indicators together so the shell stays comparable while the information load increases."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end
    end

    grid :data_feedback_gallery_grid do
      columns(2)
      gap(:md)

      box :data_feedback_tabular_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :data_feedback_tabular_title do
          value("Tabular and hierarchical data")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :data_feedback_tabular_copy do
          value(
            "Compare how rows, hierarchy, and empty-state handling communicate structure before any reviewer inspects the source."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        table :data_feedback_table do
          table_columns(Fixtures.operations_table_columns())
          table_rows(Fixtures.operations_table_rows())
          empty_state("No services available")
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        tree_view :data_feedback_tree do
          tree_nodes(Fixtures.service_tree_nodes())
          expanded?(true)
          empty_state("No service topology available")
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :data_feedback_document_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :data_feedback_document_title do
          value("Narrative and log surfaces")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :data_feedback_document_copy do
          value(
            "Review whether long-form content and event streams stay readable without breaking the shared panel rhythm."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        markdown_viewer :data_feedback_markdown do
          source(Fixtures.incident_markdown())
          presentation(:rendered)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        log_viewer :data_feedback_log do
          log_entries(Fixtures.event_log_entries())
          show_timestamps?(true)
          wrap?(true)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :data_feedback_status_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :data_feedback_status_title do
          value("Feedback state surfaces")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :data_feedback_status_copy do
          value(
            "Review which indicators feel glanceable and whether severity, state, and progress remain easy to compare together."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        status :data_feedback_status do
          value(Fixtures.status_snapshot().text)
          severity(Fixtures.status_snapshot().severity)
          status(Fixtures.status_snapshot().status)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        progress :data_feedback_progress do
          current(Fixtures.progress_snapshot().current)
          maximum(Fixtures.progress_snapshot().total)
          label(Fixtures.progress_snapshot().label)
          severity(Fixtures.progress_snapshot().severity)
          status(Fixtures.progress_snapshot().status)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        gauge :data_feedback_gauge do
          current(Fixtures.gauge_snapshot().current)
          minimum(Fixtures.gauge_snapshot().minimum)
          maximum(Fixtures.gauge_snapshot().maximum)
          label(Fixtures.gauge_snapshot().label)
          severity(Fixtures.gauge_snapshot().severity)
          status(Fixtures.gauge_snapshot().status)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        inline_feedback :data_feedback_inline do
          title(Fixtures.inline_feedback_snapshot().title)
          message(Fixtures.inline_feedback_snapshot().message)
          severity(Fixtures.inline_feedback_snapshot().severity)
          status(Fixtures.inline_feedback_snapshot().status)
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end

      box :data_feedback_chart_panel do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        text :data_feedback_chart_title do
          value("Trend and chart surfaces")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :data_feedback_chart_copy do
          value(
            "Review whether trend cues stay interpretable across sparkline, categorical, and time-series charts in one shared card."
          )

          theme_ref(@default_theme_id)
          style_refs([:example_notes])
          tone(:muted)
          variant(:body)
        end

        sparkline :data_feedback_sparkline do
          points(Fixtures.sparkline_points())
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        bar_chart :data_feedback_bar_chart do
          series(Fixtures.bar_chart_series())
          x_label("Service")
          y_label("Requests")
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end

        line_chart :data_feedback_line_chart do
          series(Fixtures.line_chart_series())
          x_label("Time")
          y_label("Errors")
          theme_ref(@default_theme_id)
          tone(:surface)
          variant(:quiet)
        end
      end
    end
  end
end
