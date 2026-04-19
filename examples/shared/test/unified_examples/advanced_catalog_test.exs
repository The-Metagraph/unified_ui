defmodule UnifiedExamples.AdvancedCatalogTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  @phase_entries Catalog.by_phase(4)
  @suite_root Shared.suite_root()

  test "tracks the full advanced example catalog as the complete phase 4 slice" do
    phase_directories = Enum.map(@phase_entries, & &1.directory)

    assert Catalog.advanced_families() == [:display, :overlay, :operational]

    assert Catalog.advanced_directories() == Enum.sort(phase_directories)
    assert Enum.map(Catalog.advanced_entries(), & &1.directory) == phase_directories
    assert Enum.all?(Catalog.advanced_entries(), &(&1.phase == 4))
  end

  test "fails the review sweep if any advanced example app skeleton is missing" do
    assert Shared.advanced_catalog_directories() == Catalog.advanced_directories()
    assert Shared.advanced_app_directories() == Catalog.advanced_directories()
    assert Shared.missing_advanced_directories() == []

    assert Enum.all?(Catalog.advanced_directories(), fn directory ->
             app_root = Path.join(@suite_root, directory)

             File.dir?(app_root) and
               File.exists?(Path.join(app_root, "README.md")) and
               File.exists?(Path.join(app_root, "mix.exs")) and
               File.exists?(Path.join(app_root, "config/config.exs")) and
               File.dir?(Path.join(app_root, "lib")) and
               File.dir?(Path.join(app_root, "test")) and
               Enum.all?(Catalog.source_files(directory), &File.exists?/1)
           end)
  end
end
