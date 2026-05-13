defmodule DesktopUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint for `desktop_ui`.
  """

  alias DesktopUi.Renderer.Error
  alias DesktopUi.Renderer.Mapper
  alias UnifiedIUR.Element

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [
      :accept_canonical_iur,
      :foundational_canonical_mapping,
      :advanced_canonical_mapping,
      :reuse_native_runtime_model,
      :shared_runtime_realization,
      :layered_meaning_preservation
    ]
  end

  @doc """
  Canonical IUR widget kinds supported by the desktop_ui renderer.
  Each kind has native widget mapping, draw kind handling, and SDL3 rendering
  implementation or retained-widget fallback.
  """
  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      # Foundational (13)
      :badge,
      :button,
      :command,
      :content,
      :hero,
      :icon,
      :image,
      :label,
      :link,
      :separator,
      :spacer,
      :text,
      :toggle,
      # Input (10)
      :checkbox,
      :date_input,
      :file_input,
      :numeric_input,
      :pick_list,
      :radio_group,
      :select,
      :slider,
      :text_input,
      :time_input,
      # Navigation (4)
      :breadcrumbs,
      :list,
      :menu,
      :tabs,
      # Data (7)
      :inspector,
      :info_list,
      :key_value,
      :markdown_viewer,
      :stat,
      :table,
      :tree_view,
      # Feedback (6)
      :alert_dialog,
      :dialog,
      :inline_feedback,
      :progress,
      :status,
      :toast,
      # Operational (7)
      :cluster_dashboard,
      :command_palette,
      :log_viewer,
      :process_monitor,
      :stream_widget,
      :supervision_tree_viewer,
      :window_command,
      # Visualization (5)
      :bar_chart,
      :canvas,
      :gauge,
      :line_chart,
      :sparkline,
      :timeline,
      # Promoted portable semantic widgets (8)
      :disclosure,
      :kicker,
      :avatar,
      :presence_dot,
      :segmented_button_group,
      :list_item_multi_column,
      :artifact_row,
      :sticky_header,
      # Promoted portable workflow/document widgets (9)
      :pipeline_stepper_horizontal,
      :segmented_progress_bar,
      :workflow_stage_list_vertical,
      :meter_thin,
      :slide_over_panel,
      :event_callout,
      :redline_inline,
      :code_block_syntax_highlighted,
      :chat_composer,
      # Promoted form and collection constructs (2)
      :host_form_shell,
      :repeated_collection,
      # Layout & Structure (3)
      :column,
      :row,
      :stack,
      # Container (1)
      :window
    ]
  end

  @spec validation_state() :: atom()
  def validation_state, do: :advanced_mapper_ready

  @spec render(Element.t(), keyword()) :: {:ok, DesktopUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, _opts \\ []) do
    Mapper.map(element)
  end
end
