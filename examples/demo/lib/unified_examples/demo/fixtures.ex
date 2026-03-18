defmodule UnifiedExamples.Demo.Fixtures do
  @moduledoc """
  Stable fixture and responsive-layout contract for the aggregate demo app.
  """

  @category_example_directories %{
    foundational_content: [
      "text",
      "label",
      "icon",
      "image",
      "button",
      "link",
      "separator",
      "spacer",
      "content"
    ],
    forms_and_input: [
      "form_builder",
      "field_group",
      "field",
      "text_input",
      "numeric_input",
      "checkbox",
      "radio_group",
      "select",
      "pick_list",
      "date_input",
      "time_input",
      "file_input",
      "toggle"
    ],
    layout_and_display: [
      "box",
      "row",
      "column",
      "grid",
      "viewport",
      "scroll_bar",
      "split_pane",
      "canvas"
    ],
    navigation_and_selection: ["menu", "tabs", "list", "command_palette"],
    data_and_feedback: [
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
    ],
    overlays_and_operational: [
      "overlay",
      "dialog",
      "alert_dialog",
      "context_menu",
      "toast",
      "stream_widget",
      "process_monitor",
      "supervision_tree_viewer",
      "cluster_dashboard"
    ],
    signal_lab: ["button", "text_input", "select", "toggle"]
  }

  @signal_lab_targets %{
    action_to_feedback: %{
      idle_feedback: "Waiting for action signal.",
      idle_note: "Trigger the action control to acknowledge this story visibly."
    },
    input_to_preview: %{
      idle_preview: "Start typing to update the preview.",
      idle_summary: "No change signal captured yet."
    },
    selection_to_filter: %{
      idle_filter_label: "Showing all linked examples.",
      idle_summary: "No selection signal captured yet."
    },
    toggle_to_visibility_or_enabled_state: %{
      idle_target_label: "Protected follow-up action",
      idle_target_note: "Toggle the source control to enable this follow-up action."
    }
  }

  @responsive_layout %{
    desktop_two_column_min_width: 980,
    compact_single_column_max_width: 979,
    dense_stack_max_width: 720,
    tab_wrap_enabled?: true,
    linked_examples_stack_below: 720
  }

  @spec category_example_directories() :: %{atom() => [String.t()]}
  def category_example_directories, do: @category_example_directories

  @spec signal_lab_targets() :: %{atom() => map()}
  def signal_lab_targets, do: @signal_lab_targets

  @spec responsive_layout() :: map()
  def responsive_layout, do: @responsive_layout

  @spec contract_summary() :: map()
  def contract_summary do
    %{
      category_example_directories: @category_example_directories,
      category_counts:
        Map.new(@category_example_directories, fn {category_id, directories} ->
          {category_id, length(directories)}
        end),
      signal_lab_targets: @signal_lab_targets,
      responsive_layout: @responsive_layout,
      digest: digest()
    }
  end

  @spec digest() :: String.t()
  def digest do
    [@category_example_directories, @signal_lab_targets, @responsive_layout]
    |> :erlang.term_to_binary()
    |> Base.encode16(case: :lower)
  end
end
