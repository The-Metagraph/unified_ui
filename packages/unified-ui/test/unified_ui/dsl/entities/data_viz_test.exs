defmodule UnifiedUi.Dsl.Entities.DataVizTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.DataViz

  describe "gauge_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DataViz.gauge_entity()

      assert entity.name == :gauge
      assert entity.target == UnifiedIUR.Widgets.Gauge
      assert entity.args == [:id, :value]
    end

    test "has correct schema definition" do
      entity = DataViz.gauge_entity()

      # Required fields - use Keyword.get
      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert id_schema[:type] == :atom
      assert id_schema[:required] == true

      value_schema = Keyword.get(entity.schema, :value)
      assert value_schema != nil
      assert value_schema[:type] == :integer
      assert value_schema[:required] == true

      # Optional fields with defaults
      min_schema = Keyword.get(entity.schema, :min)
      assert min_schema != nil
      assert min_schema[:default] == 0

      max_schema = Keyword.get(entity.schema, :max)
      assert max_schema != nil
      assert max_schema[:default] == 100

      # Optional fields without defaults
      label_schema = Keyword.get(entity.schema, :label)
      assert label_schema != nil
      assert label_schema[:required] == false

      assert Keyword.get(entity.schema, :width) != nil
      assert Keyword.get(entity.schema, :height) != nil

      color_zones_schema = Keyword.get(entity.schema, :color_zones)
      assert color_zones_schema != nil
      assert color_zones_schema[:type] == :keyword_list
    end
  end

  describe "sparkline_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DataViz.sparkline_entity()

      assert entity.name == :sparkline
      assert entity.target == UnifiedIUR.Widgets.Sparkline
      assert entity.args == [:id, :data]
    end

    test "has correct schema definition" do
      entity = DataViz.sparkline_entity()

      # Required fields
      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert id_schema[:type] == :atom
      assert id_schema[:required] == true

      data_schema = Keyword.get(entity.schema, :data)
      assert data_schema != nil
      assert data_schema[:type] == {:list, :integer}
      assert data_schema[:required] == true

      # Optional fields with defaults
      show_dots_schema = Keyword.get(entity.schema, :show_dots)
      assert show_dots_schema != nil
      assert show_dots_schema[:default] == false

      show_area_schema = Keyword.get(entity.schema, :show_area)
      assert show_area_schema != nil
      assert show_area_schema[:default] == false

      # Optional fields without defaults
      assert Keyword.get(entity.schema, :width) != nil
      assert Keyword.get(entity.schema, :height) != nil
      assert Keyword.get(entity.schema, :color) != nil
    end
  end

  describe "bar_chart_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DataViz.bar_chart_entity()

      assert entity.name == :bar_chart
      assert entity.target == UnifiedIUR.Widgets.BarChart
      assert entity.args == [:id, :data]
    end

    test "has correct schema definition" do
      entity = DataViz.bar_chart_entity()

      # Required fields
      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert id_schema[:type] == :atom
      assert id_schema[:required] == true

      data_schema = Keyword.get(entity.schema, :data)
      assert data_schema != nil
      assert data_schema[:type] == {:list, {:tuple, [:string, :integer]}}
      assert data_schema[:required] == true

      # Optional fields with defaults
      orientation_schema = Keyword.get(entity.schema, :orientation)
      assert orientation_schema != nil
      assert orientation_schema[:type] == {:one_of, [:horizontal, :vertical]}
      assert orientation_schema[:default] == :horizontal

      show_labels_schema = Keyword.get(entity.schema, :show_labels)
      assert show_labels_schema != nil
      assert show_labels_schema[:default] == true

      # Optional fields without defaults
      assert Keyword.get(entity.schema, :width) != nil
      assert Keyword.get(entity.schema, :height) != nil
    end
  end

  describe "line_chart_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DataViz.line_chart_entity()

      assert entity.name == :line_chart
      assert entity.target == UnifiedIUR.Widgets.LineChart
      assert entity.args == [:id, :data]
    end

    test "has correct schema definition" do
      entity = DataViz.line_chart_entity()

      # Required fields
      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert id_schema[:type] == :atom
      assert id_schema[:required] == true

      data_schema = Keyword.get(entity.schema, :data)
      assert data_schema != nil
      assert data_schema[:type] == {:list, {:tuple, [:string, :integer]}}
      assert data_schema[:required] == true

      # Optional fields with defaults
      show_dots_schema = Keyword.get(entity.schema, :show_dots)
      assert show_dots_schema != nil
      assert show_dots_schema[:default] == true

      show_area_schema = Keyword.get(entity.schema, :show_area)
      assert show_area_schema != nil
      assert show_area_schema[:default] == false

      # Optional fields without defaults
      assert Keyword.get(entity.schema, :width) != nil
      assert Keyword.get(entity.schema, :height) != nil
    end
  end

  describe "entity documentation" do
    test "gauge_entity has proper documentation" do
      entity = DataViz.gauge_entity()

      assert entity.describe != ""
      assert is_binary(entity.describe)
      assert String.contains?(entity.describe, "gauge")
    end

    test "sparkline_entity has proper documentation" do
      entity = DataViz.sparkline_entity()

      assert entity.describe != ""
      assert is_binary(entity.describe)
      assert String.contains?(entity.describe, "sparkline")
    end

    test "bar_chart_entity has proper documentation" do
      entity = DataViz.bar_chart_entity()

      assert entity.describe != ""
      assert is_binary(entity.describe)
      assert String.contains?(entity.describe, "bar chart")
    end

    test "line_chart_entity has proper documentation" do
      entity = DataViz.line_chart_entity()

      assert entity.describe != ""
      assert is_binary(entity.describe)
      assert String.contains?(entity.describe, "line chart")
    end
  end
end
