defmodule UnifiedUi.Dsl.Entities.MonitoringTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Monitoring
  alias UnifiedUi.Widgets.{LogViewer, ProcessMonitor, StreamWidget}

  describe "log_viewer_entity/0" do
    test "returns a valid log_viewer entity definition" do
      entity = Monitoring.log_viewer_entity()

      assert %Spark.Dsl.Entity{name: :log_viewer} = entity
      assert entity.target == LogViewer
      assert entity.args == [:id]
      assert Keyword.has_key?(entity.schema, :source)
      assert Keyword.has_key?(entity.schema, :lines)
      assert Keyword.has_key?(entity.schema, :auto_scroll)
      assert Keyword.has_key?(entity.schema, :filter)
      assert Keyword.has_key?(entity.schema, :refresh_interval)
    end
  end

  describe "stream_widget_entity/0" do
    test "returns a valid stream_widget entity definition" do
      entity = Monitoring.stream_widget_entity()

      assert %Spark.Dsl.Entity{name: :stream_widget} = entity
      assert entity.target == StreamWidget
      assert entity.args == [:id, :producer]
      assert Keyword.has_key?(entity.schema, :transform)
      assert Keyword.has_key?(entity.schema, :buffer_size)
      assert Keyword.has_key?(entity.schema, :on_item)
      assert Keyword.has_key?(entity.schema, :refresh_interval)
    end
  end

  describe "process_monitor_entity/0" do
    test "returns a valid process_monitor entity definition" do
      entity = Monitoring.process_monitor_entity()

      assert %Spark.Dsl.Entity{name: :process_monitor} = entity
      assert entity.target == ProcessMonitor
      assert entity.args == [:id]
      assert Keyword.has_key?(entity.schema, :node)
      assert Keyword.has_key?(entity.schema, :refresh_interval)
      assert Keyword.has_key?(entity.schema, :sort_by)
      assert Keyword.has_key?(entity.schema, :on_process_select)
    end
  end

  describe "monitoring widget metadata" do
    test "monitoring widgets expose refresh metadata via UnifiedIUR.Element" do
      log_viewer = %LogViewer{id: :logs, lines: 200, refresh_interval: 500}
      stream_widget = %StreamWidget{id: :events, producer: :producer, refresh_interval: 250}
      process_monitor = %ProcessMonitor{id: :procs, refresh_interval: 750, sort_by: :reductions}

      assert %{type: :log_viewer, auto_refresh: true, refresh_interval: 500} =
               UnifiedIUR.Element.metadata(log_viewer)

      assert %{type: :stream_widget, auto_refresh: true, refresh_interval: 250} =
               UnifiedIUR.Element.metadata(stream_widget)

      assert %{type: :process_monitor, auto_refresh: true, refresh_interval: 750} =
               UnifiedIUR.Element.metadata(process_monitor)
    end
  end
end
