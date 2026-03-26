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
  @smoke_start_marker "__UNIFIED_EXAMPLES_DEMO_SMOKE_START__"
  @smoke_end_marker "__UNIFIED_EXAMPLES_DEMO_SMOKE_END__"
  @metadata_cache_key {__MODULE__, :review_metadata}
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
    case :persistent_term.get(@metadata_cache_key, :missing) do
      {:ok, metadata} ->
        {:ok, metadata}

      :missing ->
        load_review_metadata()
    end
  end

  @spec category_example_directories() :: %{optional(atom()) => [String.t()]}
  def category_example_directories do
    with {:ok, metadata} <- review_metadata() do
      Map.get(metadata, :category_example_directories, %{})
    else
      _ -> %{}
    end
  end

  @spec category_ids_for(String.t() | atom()) :: [atom()]
  def category_ids_for(directory) do
    directory = normalize_directory(directory)

    category_example_directories()
    |> Enum.flat_map(fn {category_id, directories} ->
      if directory in directories, do: [category_id], else: []
    end)
    |> Enum.sort()
  end

  @spec category_labels_for(String.t() | atom()) :: [String.t()]
  def category_labels_for(directory) do
    directory = normalize_directory(directory)

    with {:ok, metadata} <- review_metadata() do
      metadata
      |> Map.get(:category_registry, [])
      |> Enum.flat_map(fn entry ->
        if directory in entry.example_directories, do: [entry.label], else: []
      end)
    else
      _ -> []
    end
  end

  defp load_review_metadata do
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

          :persistent_term.put(@metadata_cache_key, {:ok, metadata})
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

  @spec smoke_launch(keyword()) :: {:ok, map()} | {:error, term()}
  def smoke_launch(opts \\ []) do
    descriptor = launch_descriptor(opts)
    port = Keyword.get(opts, :port, default_port())

    expression = """
    launch = UnifiedExamples.Demo.launch_descriptor(port: #{port})

    Application.put_env(
      :unified_example_demo,
      UnifiedExamples.Demo.Endpoint,
      Keyword.put(UnifiedExamples.Demo.endpoint_config(), :server, false)
    )

    case Application.ensure_all_started(:unified_example_demo) do
      {:ok, _started} ->
        try do
          conn =
            Plug.Test.conn(:get, launch.url)
            |> Plug.Conn.put_req_header("accept", "text/html")
            |> UnifiedExamples.Demo.Endpoint.call(UnifiedExamples.Demo.Endpoint.init([]))

          result = %{
            directory: "demo",
            status: conn.status,
            path: launch.path,
            url: launch.url,
            body: conn.resp_body,
            launch_command: launch.command
          }

          result
          |> :erlang.term_to_binary()
          |> Base.encode64()
          |> then(&IO.puts("#{@smoke_start_marker}" <> &1 <> "#{@smoke_end_marker}"))
        after
          Application.stop(:unified_example_demo)
          Application.stop(:phoenix_live_view)
          Application.stop(:phoenix)
          Application.stop(:phoenix_pubsub)
          Application.stop(:plug_cowboy)
          Application.stop(:cowboy_telemetry)
          Application.stop(:cowboy)
          Application.stop(:plug)
          Application.stop(:telemetry)
        end

      {:error, reason} ->
        IO.puts("aggregate demo smoke launch failed: " <> inspect(reason))
        System.halt(1)
    end
    """

    case System.cmd("mix", ["run", "--no-start", "-e", expression],
           cd: @demo_root,
           env: [{"MIX_ENV", "dev"}, {"PORT", Integer.to_string(port)}],
           stderr_to_stdout: true
         ) do
      {output, 0} ->
        with [_, payload] <- Regex.run(~r/#{@smoke_start_marker}(.*?)#{@smoke_end_marker}/s, output) do
          payload
          |> Base.decode64!()
          |> :erlang.binary_to_term()
          |> then(&{:ok, &1})
        else
          _ -> {:error, {:aggregate_demo_smoke_unparseable, descriptor.url, output}}
        end

      {output, status} ->
        {:error, {:aggregate_demo_smoke_failed, status, descriptor.url, output}}
    end
  end

  defp default_port do
    System.get_env("PORT", "5000")
    |> String.to_integer()
  rescue
    ArgumentError -> 5000
  end

  defp normalize_directory(directory) when is_atom(directory), do: Atom.to_string(directory)
  defp normalize_directory(directory) when is_binary(directory), do: directory
end
