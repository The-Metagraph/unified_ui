defmodule UnifiedExamples.SuiteIndexTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  test "root suite index documents the shared template and discovery surfaces" do
    readme = File.read!(Shared.suite_index_path())

    assert readme =~ "shared authoring template"
    assert readme =~ "`examples/catalog.tsv`"
    assert readme =~ "`examples/shared/`"

    Enum.each(Catalog.by_phase(4), fn entry ->
      assert readme =~ "`#{entry.directory}/`"
    end)
  end

  test "root catalog manifest stays synchronized with the catalog module" do
    assert File.read!(Shared.catalog_manifest_path()) == Shared.catalog_manifest()
    assert Shared.catalog_manifest() == Catalog.tsv()
  end
end
