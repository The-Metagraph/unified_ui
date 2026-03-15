defmodule UnifiedUi.Dsl.Entities do
  @moduledoc """
  Baseline registry of canonical authored construct families.
  """

  @construct_families %{
    widgets: [
      :foundational_visual,
      :input,
      :navigation,
      :feedback,
      :data,
      :operational
    ],
    layouts: [:container, :row, :column, :grid, :stack, :split, :viewport],
    layers: [:overlay, :absolute, :modal, :toast, :menu, :canvas],
    styles: [:typography, :color, :spacing, :sizing, :alignment, :border, :visibility],
    themes: [:theme, :variant, :token, :semantic_role],
    signals: [:interaction, :binding, :payload_mapping, :target_intent]
  }

  @spec construct_families() :: %{atom() => [atom()]}
  def construct_families do
    @construct_families
  end

  @spec categories() :: [atom()]
  def categories do
    Map.keys(@construct_families)
  end
end
