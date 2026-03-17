defmodule UnifiedExamples.Demo.Categories.SignalLab do
  @moduledoc """
  Placeholder fragment for the signal-lab review tab.
  """

  use UnifiedExamples.Demo.CategoryFragment,
    id: :signal_lab,
    title: "Signal Lab",
    summary:
      "Cross-control interaction stories where authored signals visibly change other surfaces.",
    note:
      "Phase 1 reserves this fragment boundary so the dedicated signal-reactivity stories can be added without destabilizing the category registry."
end
