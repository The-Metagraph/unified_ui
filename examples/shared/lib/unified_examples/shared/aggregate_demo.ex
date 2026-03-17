defmodule UnifiedExamples.Shared.AggregateDemo do
  @moduledoc """
  Shared launch descriptor support for the aggregate examples demo app.
  """

  @demo_root Path.expand("../../../../demo", __DIR__)
  @demo_directory "demo"
  @required_category_ids [
    :foundational_content,
    :forms_and_input,
    :layout_and_display,
    :navigation_and_selection,
    :data_and_feedback,
    :overlays_and_operational,
    :signal_lab
  ]
  @required_signal_lab_story_ids [
    :action_to_feedback,
    :input_to_preview,
    :selection_to_filter,
    :toggle_to_visibility_or_enabled_state
  ]
  @metadata_start_marker "__UNIFIED_EXAMPLES_DEMO_METADATA_START__"
  @metadata_end_marker "__UNIFIED_EXAMPLES_DEMO_METADATA_END__"
  @catalog_entry %{
    directory: @demo_directory,
    widget: :demo,
    family: :aggregate_demo,
    phase: :overview,
    shell: :tabbed,
    purpose: :aggregate_demo,
    summary:
      "Category-oriented review shell that complements the focused per-widget example apps."
  }

  @spec catalog_entry() :: map()
  def catalog_entry, do: @catalog_entry

  @spec directory() :: String.t()
  def directory, do: @demo_directory

  @spec required_category_ids() :: [atom()]
  def required_category_ids, do: @required_category_ids

  @spec required_signal_lab_story_ids() :: [atom()]
  def required_signal_lab_story_ids, do: @required_signal_lab_story_ids

  @spec catalog_line() :: String.t()
  def catalog_line do
    entry = catalog_entry()

    [
      entry.directory,
      "widget=#{entry.widget}",
      "family=#{entry.family}",
      "phase=#{entry.phase}",
      "shell=#{entry.shell}",
      "purpose=#{entry.purpose}"
    ]
    |> Enum.join("\t")
  end

  @spec review_metadata() :: {:ok, map()} | {:error, term()}
  def review_metadata do
    expression = """
    UnifiedExamples.Demo.review_metadata()
    |> :erlang.term_to_binary()
    |> Base.encode64()
    |> then(&IO.puts("#{@metadata_start_marker}" <> &1 <> "#{@metadata_end_marker}"))
    """

    case System.cmd("mix", ["run", "--no-start", "-e", expression],
           cd: @demo_root,
           env: [{"MIX_ENV", "dev"}],
           stderr_to_stdout: true
         ) do
      {encoded, 0} ->
        with [_, payload] <-
               Regex.run(
                 ~r/#{@metadata_start_marker}(.*?)#{@metadata_end_marker}/s,
                 encoded
               ) do
          metadata =
            payload
            |> Base.decode64!()
            |> :erlang.binary_to_term()

          {:ok, metadata}
        else
          _ -> {:error, {:demo_review_metadata_unparseable, encoded}}
        end

      {output, status} ->
        {:error, {:demo_review_metadata_failed, status, output}}
    end
  end

  @spec launch_descriptor(keyword()) :: map()
  def launch_descriptor(opts \\ []) do
    port = Keyword.get(opts, :port, default_port())
    path = "/"
    url = "http://127.0.0.1:#{port}#{path}"

    %{
      directory: @demo_directory,
      cwd: @demo_root,
      argv: ["mix", "phx.server"],
      env: [{"PORT", Integer.to_string(port)}],
      path: path,
      url: url,
      command: "cd #{@demo_root} && PORT=#{port} mix phx.server"
    }
  end

  defp default_port do
    System.get_env("PORT", "4000")
    |> String.to_integer()
  rescue
    ArgumentError -> 4000
  end
end
