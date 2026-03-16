defmodule UnifiedExamples.DocumentationTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Documentation

  test "root suite docs and shared docs stay synchronized with the implemented catalog" do
    report = Documentation.report()

    assert report.valid?
    assert report.root.synchronized?
    assert report.shared.synchronized?
    assert report.root.missing_snippets == []
    assert report.root.missing_directories == []
    assert report.shared.missing_snippets == []
    assert report.shared.missing_directories == []
    assert report.paths.suite_index == Shared.suite_index_path()
  end

  test "documentation checks catch missing snippets and missing app references" do
    assert Documentation.summary(%{
             valid?: false,
             root: %{missing_snippets: ["shared default theme"], missing_directories: ["button"]},
             shared: %{
               missing_snippets: ["`UnifiedExamples.Shared.Template`"],
               missing_directories: ["overlay"]
             }
           }) =~ "root_missing_directories: button"
  end
end
