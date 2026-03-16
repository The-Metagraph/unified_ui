defmodule UnifiedExamples.Shared.Loader do
  @moduledoc """
  Shared loader for standalone example-app source modules.
  """

  alias Config.Reader
  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog

  @type loaded_app :: %{
          entry: Catalog.entry(),
          directory: String.t(),
          app: module(),
          screen: module(),
          app_root: String.t(),
          config_path: String.t(),
          source_files: [String.t()]
        }

  @spec load(String.t() | atom()) :: {:ok, loaded_app()}
  def load(directory) do
    entry = Catalog.entry!(directory)
    app_root = Path.join(Shared.suite_root(), entry.directory)
    source_files = Catalog.source_files(entry.directory)
    Enum.each(source_files, &require_once/1)

    {:ok,
     %{
       entry: entry,
       directory: entry.directory,
       app: Catalog.app_module(entry.directory),
       screen: Catalog.screen_module(entry.directory),
       app_root: app_root,
       config_path: Path.join(app_root, "config/config.exs"),
       source_files: source_files
     }}
  end

  @spec load_config(String.t() | atom() | loaded_app()) :: :ok
  def load_config(%{config_path: config_path}) do
    {config, _imports} = Reader.read_imports!(config_path, env: Mix.env(), target: Mix.target())

    Application.put_all_env(config)

    :ok
  end

  def load_config(directory) do
    with {:ok, loaded} <- load(directory) do
      load_config(loaded)
    end
  end

  defp require_once(path) do
    unless Enum.any?(Code.required_files(), &(&1 == path)) do
      Code.require_file(path)
    end
  end
end
