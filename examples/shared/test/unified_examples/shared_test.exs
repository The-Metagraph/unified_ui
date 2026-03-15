defmodule UnifiedExamples.SharedTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  test "exposes the shared dependency contract for standalone example apps" do
    assert Shared.dependency_apps() == [:unified_ui, :unified_iur, :live_ui]

    assert Shared.local_package_paths() == %{
             unified_ui: Path.expand("../../packages/unified-ui", Shared.shared_root()),
             unified_iur: Path.expand("../../packages/unified_iur", Shared.shared_root()),
             live_ui: Path.expand("../../packages/live_ui", Shared.shared_root())
           }
  end

  test "compiles independently against the local package dependencies" do
    assert Code.ensure_loaded?(UnifiedUi)
    assert Code.ensure_loaded?(UnifiedIUR)
    assert Code.ensure_loaded?(LiveUi)
  end

  test "can enumerate the current standalone app directories without runtime services" do
    shared_root = Path.expand("../..", __DIR__)

    assert Shared.shared_root() == shared_root
    assert Shared.suite_root() == Path.expand("..", shared_root)
    assert Shared.app_directories() == Catalog.directories()
  end

  test "exposes the implemented example catalog for review tooling" do
    assert Shared.catalog_directories() == Catalog.directories()

    assert Shared.catalog_entries()
           |> Enum.map(& &1.directory)
           |> Enum.sort() == Catalog.directories()

    assert Shared.catalog_by_family()
           |> Map.new(fn {family, entries} -> {family, Enum.map(entries, & &1.directory)} end) ==
             %{
               content: [
                 "button",
                 "text",
                 "icon",
                 "image",
                 "label",
                 "link",
                 "separator",
                 "spacer"
               ],
               data: ["list", "table", "tree_view", "markdown_viewer", "log_viewer"],
               forms: ["field", "field_group", "form_builder"],
               input: [
                 "text_input",
                 "checkbox",
                 "date_input",
                 "file_input",
                 "numeric_input",
                 "pick_list",
                 "radio_group",
                 "select",
                 "time_input",
                 "toggle"
               ],
               layout: ["box", "content", "row", "column", "grid"],
               navigation: ["menu", "tabs", "command_palette"]
             }
  end
end
