defmodule UnifiedIUR.WidgetsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets
  alias UnifiedIUR.Widgets.Foundational

  test "exposes the foundational widget constructor family" do
    assert %{foundational: Foundational} = Widgets.modules()

    assert [:text, :label, :icon, :image, :button, :link, :separator, :spacer, :content] ==
             Widgets.foundational_kinds()

    assert Widgets.foundational_kinds() == Foundational.kinds()
  end
end
