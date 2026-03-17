defmodule UnifiedExamples.Demo.Categories do
  @moduledoc """
  Stable category registry for the aggregate demo application.
  """

  alias UnifiedExamples.Demo.Categories.{
    DataAndFeedback,
    FormsAndInput,
    FoundationalContent,
    LayoutAndDisplay,
    NavigationAndSelection,
    OverlaysAndOperational,
    SignalLab
  }

  @type category_id ::
          :foundational_content
          | :forms_and_input
          | :layout_and_display
          | :navigation_and_selection
          | :data_and_feedback
          | :overlays_and_operational
          | :signal_lab

  @type entry :: %{
          id: category_id(),
          label: String.t(),
          order: pos_integer(),
          summary: String.t(),
          fragment_module: module()
        }

  @entries [
    %{
      id: :foundational_content,
      label: "Foundational Content",
      order: 1,
      summary: "Baseline copy, imagery, spacing, and primary action controls.",
      fragment_module: FoundationalContent
    },
    %{
      id: :forms_and_input,
      label: "Forms and Input",
      order: 2,
      summary: "Structured data entry, field composition, and input-focused review flows.",
      fragment_module: FormsAndInput
    },
    %{
      id: :layout_and_display,
      label: "Layout and Display",
      order: 3,
      summary: "Spatial composition, display primitives, and container-oriented layout review.",
      fragment_module: LayoutAndDisplay
    },
    %{
      id: :navigation_and_selection,
      label: "Navigation and Selection",
      order: 4,
      summary: "Menus, tabs, lists, and selection-oriented navigation controls.",
      fragment_module: NavigationAndSelection
    },
    %{
      id: :data_and_feedback,
      label: "Data and Feedback",
      order: 5,
      summary: "Data presentation, progress cues, and reviewer-facing feedback states.",
      fragment_module: DataAndFeedback
    },
    %{
      id: :overlays_and_operational,
      label: "Overlays and Operational",
      order: 6,
      summary: "Overlay surfaces, operational widgets, and runtime-monitoring presentations.",
      fragment_module: OverlaysAndOperational
    },
    %{
      id: :signal_lab,
      label: "Signal Lab",
      order: 7,
      summary:
        "Cross-control interaction stories where authored signals visibly change other surfaces.",
      fragment_module: SignalLab
    }
  ]

  @spec entries() :: [entry()]
  def entries, do: @entries

  @spec ids() :: [category_id()]
  def ids, do: Enum.map(entries(), & &1.id)

  @spec count() :: pos_integer()
  def count, do: length(@entries)

  @spec default_id() :: category_id()
  def default_id, do: hd(@entries).id

  @spec entry!(category_id()) :: entry()
  def entry!(id) when is_atom(id) do
    Enum.find(entries(), &(&1.id == id)) ||
      raise ArgumentError, "unknown demo category: #{inspect(id)}"
  end

  @spec tab_items() :: keyword(String.t())
  def tab_items do
    for entry <- entries(), into: [], do: {entry.id, entry.label}
  end

  @spec review_registry() :: [map()]
  def review_registry do
    Enum.map(entries(), fn entry ->
      %{
        id: entry.id,
        label: entry.label,
        order: entry.order,
        summary: entry.summary,
        fragment_module: entry.fragment_module
      }
    end)
  end
end
