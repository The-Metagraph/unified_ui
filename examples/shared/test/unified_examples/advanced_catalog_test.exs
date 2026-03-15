defmodule UnifiedExamples.AdvancedCatalogTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  test "tracks the full advanced example catalog as display, overlay, and operational families" do
    assert Catalog.advanced_families() == [:display, :overlay, :operational]

    assert Catalog.advanced_directories() == [
             "alert_dialog",
             "canvas",
             "cluster_dashboard",
             "context_menu",
             "dialog",
             "overlay",
             "process_monitor",
             "scroll_bar",
             "split_pane",
             "stream_widget",
             "supervision_tree_viewer",
             "toast",
             "viewport"
           ]

    assert Enum.map(Catalog.advanced_entries(), & &1.directory) == [
             "viewport",
             "scroll_bar",
             "split_pane",
             "canvas",
             "overlay",
             "dialog",
             "alert_dialog",
             "context_menu",
             "toast",
             "stream_widget",
             "process_monitor",
             "supervision_tree_viewer",
             "cluster_dashboard"
           ]
  end

  test "fails the review sweep if any advanced example directory is missing" do
    assert Shared.advanced_catalog_directories() == Catalog.advanced_directories()
    assert Shared.advanced_app_directories() == Catalog.advanced_directories()
    assert Shared.missing_advanced_directories() == []

    assert Enum.all?(Catalog.advanced_directories(), fn directory ->
             Shared.suite_root()
             |> Path.join(directory)
             |> File.dir?()
           end)
  end
end
