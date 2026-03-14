defmodule UnifiedIUR.WidgetsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets
  alias UnifiedIUR.Widgets.{Data, Feedback, Foundational, Input, Navigation}

  test "exposes the foundational widget constructor family" do
    assert %{
             foundational: Foundational,
             input: Input,
             navigation: Navigation,
             data: Data,
             feedback: Feedback
           } = Widgets.modules()

    assert [:text, :label, :icon, :image, :button, :link, :separator, :spacer, :content] ==
             Widgets.foundational_kinds()

    assert Widgets.foundational_kinds() == Foundational.kinds()
    assert [:menu, :tabs] == Widgets.navigation_kinds()
    assert Widgets.navigation_kinds() == Navigation.kinds()
    assert [:list, :table, :tree_view] == Widgets.data_view_kinds()
    assert Widgets.data_view_kinds() == Data.kinds()
    assert [:status, :progress, :gauge, :inline_feedback] == Widgets.feedback_kinds()
    assert Widgets.feedback_kinds() == Feedback.kinds()
  end
end
