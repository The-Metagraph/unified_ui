defmodule UnifiedExamples.Shared.Tooling do
  @moduledoc """
  Discovery, preview, and run tooling for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Loader
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Traceability

  @type loaded_app :: Loader.loaded_app()
  @type launch_descriptor :: %{
          directory: String.t(),
          cwd: String.t(),
          argv: [String.t()],
          env: [{String.t(), String.t()}],
          path: String.t(),
          url: String.t(),
          application_module: module(),
          endpoint_module: module(),
          router_module: module(),
          live_module: module(),
          command: String.t()
        }
  @type smoke_result :: %{
          directory: String.t(),
          status: non_neg_integer(),
          path: String.t(),
          url: String.t(),
          body: String.t(),
          launch_command: String.t()
        }
  @type run_descriptor :: %{
          directory: String.t(),
          cwd: String.t(),
          argv: [String.t()],
          command: String.t()
        }

  @spec catalog_report() :: String.t()
  def catalog_report do
    [
      "Example suite catalog",
      "",
      Enum.map_join(Catalog.entries(), "\n", fn entry ->
        "#{entry.directory}\twidget=#{entry.widget}\tfamily=#{entry.family}\tphase=#{entry.phase}\tshell=#{entry.shell_kind}"
      end)
    ]
    |> Enum.join("\n")
  end

  @spec review_metadata(String.t() | atom()) :: {:ok, map()}
  def review_metadata(directory) do
    with {:ok, loaded} <- Loader.load(directory) do
      Loader.load_config(loaded)
      {:ok, build_review_metadata(loaded)}
    end
  end

  @spec preview(String.t() | atom(), :report | :html | :metadata | :inspection) ::
          {:ok, String.t() | map()} | {:error, term()}
  def preview(directory, format \\ :report) do
    with {:ok, loaded} <- Loader.load(directory),
         {:ok, inspection} <- Runtime.inspect(loaded.screen),
         {:ok, html} <- loaded.app.render_html() do
      metadata = build_review_metadata(loaded)

      output =
        case format do
          :report ->
            preview_report(metadata, inspection, html)

          :html ->
            html

          :metadata ->
            metadata

          :inspection ->
            inspection
        end

      {:ok, output}
    end
  end

  @spec run_descriptor(String.t() | atom(), [String.t()]) :: run_descriptor()
  def run_descriptor(directory, mix_args \\ ["test"]) when is_list(mix_args) and mix_args != [] do
    with {:ok, loaded} <- Loader.load(directory) do
      argv = ["mix" | mix_args]

      %{
        directory: loaded.directory,
        cwd: loaded.app_root,
        argv: argv,
        command: "cd #{loaded.app_root} && #{Enum.join(argv, " ")}"
      }
    end
  end

  @spec launch_descriptor(String.t() | atom(), keyword()) :: launch_descriptor()
  def launch_descriptor(directory, opts \\ []) do
    with {:ok, loaded} <- Loader.load(directory) do
      Loader.load_config(loaded)
      build_launch_descriptor(loaded, opts)
    end
  end

  @spec smoke_launch(String.t() | atom(), keyword()) :: {:ok, smoke_result()} | {:error, term()}
  def smoke_launch(directory, opts \\ []) do
    with {:ok, loaded} <- Loader.load(directory) do
      Loader.load_config(loaded)
      launch = build_launch_descriptor(loaded, opts)

      with_started_app(loaded, fn ->
        conn =
          Plug.Test.conn(:get, launch.url)
          |> Plug.Conn.put_req_header("accept", "text/html")
          |> launch.endpoint_module.call(launch.endpoint_module.init([]))

        {:ok,
         %{
           directory: loaded.directory,
           status: conn.status,
           path: launch.path,
           url: launch.url,
           body: conn.resp_body,
           launch_command: launch.command
         }}
      end)
    end
  end

  @spec run(String.t() | atom(), [String.t()]) :: {:ok, String.t()} | {:error, term()}
  def run(directory, mix_args \\ ["test"]) do
    descriptor = run_descriptor(directory, mix_args)
    [program | args] = descriptor.argv
    {output, status} = System.cmd(program, args, cd: descriptor.cwd, stderr_to_stdout: true)

    case status do
      0 -> {:ok, output}
      _ -> {:error, %{status: status, output: output, descriptor: descriptor}}
    end
  end

  defp build_review_metadata(
         %{entry: entry, app: app, screen: screen, app_root: app_root} = loaded
       ) do
    metadata = app.metadata()
    launch = build_launch_descriptor(loaded, [])
    phoenix_runtime = build_phoenix_runtime(loaded, launch)

    Map.merge(metadata, %{
      directory: entry.directory,
      suite_directory: metadata.directory,
      primary_subject: entry.widget,
      family: entry.family,
      phase: entry.phase,
      shell_kind: entry.shell_kind,
      app_root: app_root,
      app_module: app,
      screen_module: screen,
      source_files: loaded.source_files,
      style_profile: screen.shared_style_profile(),
      uses_shared_template: screen.shared_style_profile() == Template.default_style_profile(),
      default_theme_id: screen.default_theme_id(),
      browser_runnable?: phoenix_runtime.browser_runnable?,
      launch_command: launch.command,
      launch_argv: launch.argv,
      launch_env: launch.env,
      launch_path: launch.path,
      launch_url: launch.url,
      launch_port: app.launch_port(),
      application_module: launch.application_module,
      endpoint_module: launch.endpoint_module,
      router_module: launch.router_module,
      live_module: launch.live_module,
      pubsub_server: app.pubsub_server(),
      endpoint_config: app.endpoint_config(),
      runtime_contract: phoenix_runtime,
      traceability:
        Traceability.traceability_for(entry.directory, app, screen, loaded.source_files)
    })
  end

  defp preview_report(metadata, inspection, html) do
    [
      "Example preview",
      "directory: #{metadata.directory}",
      "widget: #{metadata.widget}",
      "family: #{metadata.family}",
      "phase: #{metadata.phase}",
      "theme: #{metadata.theme_id}",
      "browser_runnable?: #{metadata.browser_runnable?}",
      "launch_path: #{metadata.launch_path}",
      "launch_url: #{metadata.launch_url}",
      "launch_command: #{metadata.launch_command}",
      "screen: #{inspect(metadata.screen_module)}",
      "widgets: #{Enum.join(inspection.widgets, ", ")}",
      "html_bytes: #{byte_size(html)}"
    ]
    |> Enum.join("\n")
  end

  defp build_launch_descriptor(loaded, opts) do
    port = Keyword.get(opts, :port, loaded.app.launch_port())
    argv = ["phx.server"]
    env = [{"PORT", Integer.to_string(port)}]
    path = loaded.app.launch_path()
    url = "http://127.0.0.1:#{port}#{path}"

    %{
      directory: loaded.directory,
      cwd: loaded.app_root,
      argv: ["mix" | argv],
      env: env,
      path: path,
      url: url,
      application_module: loaded.app.application_module(),
      endpoint_module: loaded.app.endpoint_module(),
      router_module: loaded.app.router_module(),
      live_module: loaded.app.live_module(),
      command: "cd #{loaded.app_root} && PORT=#{port} mix phx.server"
    }
  end

  defp build_phoenix_runtime(loaded, launch) do
    %{
      browser_runnable?: phoenix_baseline?(loaded.app, launch),
      application_module: launch.application_module,
      endpoint_module: launch.endpoint_module,
      router_module: launch.router_module,
      live_module: launch.live_module,
      pubsub_server: loaded.app.pubsub_server(),
      launch_path: launch.path,
      launch_url: launch.url,
      launch_command: launch.command
    }
  end

  defp phoenix_baseline?(app, launch) do
    Enum.all?([
      Code.ensure_loaded?(launch.application_module),
      Code.ensure_loaded?(launch.endpoint_module),
      Code.ensure_loaded?(launch.router_module),
      Code.ensure_loaded?(launch.live_module),
      function_exported?(app, :launch_path, 0),
      function_exported?(app, :launch_url, 0),
      function_exported?(app, :endpoint_config, 0)
    ])
  end

  defp with_started_app(loaded, fun) do
    supervisor_name = Module.concat(loaded.app.endpoint_module(), Supervisor)

    case Process.whereis(supervisor_name) do
      nil ->
        case loaded.app.application_module().start(:normal, []) do
          {:ok, pid} ->
            try do
              fun.()
            after
              if Process.alive?(pid) do
                Supervisor.stop(pid, :normal, 5_000)
              end
            end

          {:error, {:already_started, _pid}} ->
            fun.()

          {:error, reason} ->
            {:error, reason}
        end

      _pid ->
        fun.()
    end
  end
end
