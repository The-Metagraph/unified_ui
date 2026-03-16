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
    app_root = Path.join(Shared.suite_root(), entry.directory)
    app_module = Catalog.app_module(entry.directory)
    screen_module = Catalog.screen_module(entry.directory)
    source_files = Catalog.source_files(entry.directory)

    bootstrap_config(entry.directory, app_module)
    require_module(screen_module, Enum.at(source_files, 0))
    require_module(app_module, Enum.at(source_files, 1))

    {:ok,
     %{
       entry: entry,
       directory: entry.directory,
       app: app_module,
       screen: screen_module,
       app_root: app_root,
       source_files: source_files
     }}
  end

  @spec load_config(String.t() | atom() | loaded_app()) :: :ok
  def load_config(%{directory: directory, app: app_module}) do
    bootstrap_config(directory, app_module)
    :ok
  end

  def load_config(directory) do
    with {:ok, loaded} <- load(directory) do
      load_config(loaded)
    end
  end

  defp require_module(module, path) do
    unless Code.ensure_loaded?(module) do
      Code.require_file(path)
    end
  end

  defp bootstrap_config(directory, app_module) do
    app = example_app_name(directory)
    endpoint = Module.concat(app_module, Endpoint)
    pubsub_server = Module.concat(app_module, PubSub)

    Application.put_env(:phoenix, :json_library, Jason)

    Application.put_env(app, endpoint,
      url: [host: "127.0.0.1"],
      http: [ip: {127, 0, 0, 1}, port: default_port()],
      server: false,
      secret_key_base: String.duplicate("0123456789abcdef", 4),
      live_view: [signing_salt: "unifiedexamples"],
      pubsub_server: pubsub_server,
      check_origin: false,
      debug_errors: true,
      code_reloader: false
    )
  end

  defp example_app_name(directory) do
    directory
    |> to_string()
    |> then(&String.to_atom("unified_example_#{&1}"))
  end

  defp default_port do
    System.get_env("PORT", "4000")
    |> String.to_integer()
  rescue
    ArgumentError -> 4000
  end
end
