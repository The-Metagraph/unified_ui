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
      "screen: #{inspect(metadata.screen_module)}",
      "widgets: #{Enum.join(inspection.widgets, ", ")}",
      "html_bytes: #{byte_size(html)}"
    ]
    |> Enum.join("\n")
  end
end
