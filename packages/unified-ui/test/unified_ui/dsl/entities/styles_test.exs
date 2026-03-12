defmodule UnifiedUi.Dsl.Entities.StylesTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Styles

  test "style_entity/0 defines style schema and target" do
    entity = Styles.style_entity()

    assert entity.name == :style
    assert entity.target == UnifiedUi.Dsl.Style
    assert entity.args == [:name]

    assert Keyword.get(entity.schema[:name], :required) == true
    assert Keyword.get(entity.schema[:extends], :required) == false
    assert Keyword.get(entity.schema[:attributes], :default) == []
    assert entity.describe =~ "named style"
  end

  test "theme_entity/0 defines theme schema and target" do
    entity = Styles.theme_entity()

    assert entity.name == :theme
    assert entity.target == UnifiedUi.Dsl.Theme
    assert entity.args == [:name]

    assert Keyword.get(entity.schema[:name], :required) == true
    assert Keyword.get(entity.schema[:styles], :default) == []
    assert Keyword.get(entity.schema[:base_theme], :required) == false
    assert entity.describe =~ "named theme"
  end
end
