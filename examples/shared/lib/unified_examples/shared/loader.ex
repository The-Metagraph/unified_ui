defmodule UnifiedExamples.Shared.Loader do
  @moduledoc """
  Shared loader for standalone example-app source modules.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  @type loaded_app :: %{
          entry: Catalog.entry(),
          directory: String.t(),
          app: module(),
          screen: module(),
          app_root: String.t(),
          source_files: [String.t()]
        }

  @spec load(String.t() | atom()) :: {:ok, loaded_app()}
  def load(directory) do
    entry = Catalog.entry!(directory)
    source_files = Catalog.source_files(entry.directory)
    Enum.each(source_files, &require_once/1)

    {:ok,
     %{
       entry: entry,
       directory: entry.directory,
       app: Catalog.app_module(entry.directory),
       screen: Catalog.screen_module(entry.directory),
       app_root: Path.join(Shared.suite_root(), entry.directory),
       source_files: source_files
     }}
  end

  defp require_once(path) do
    unless Enum.any?(Code.required_files(), &(&1 == path)) do
      Code.require_file(path)
    end
  end
end
