defmodule UnifiedExamples.Demo do
  @moduledoc """
  Aggregate demo-app entrypoint for the unified examples suite.
  """

  alias UnifiedExamples.Demo.Categories

  @app_root Path.expand("../..", __DIR__)

  use UnifiedExamples.Shared.App,
    app: :unified_example_demo,
    directory: "examples/demo",
    purpose: :aggregate_demo

  @spec category_registry() :: [map()]
  def category_registry, do: Categories.review_registry()

  @spec active_category_id() :: atom()
  def active_category_id, do: Categories.default_id()

  @spec review_summary() :: String.t()
  def review_summary do
    "Review #{Categories.count()} ordered control categories through one shared shell before the full tab galleries arrive."
  end

  @spec launch_descriptor(keyword()) :: map()
  def launch_descriptor(opts \\ []) do
    port = Keyword.get(opts, :port, launch_port())

    %{
      directory: "demo",
      cwd: @app_root,
      argv: ["mix", "phx.server"],
      env: [{"PORT", Integer.to_string(port)}],
      path: launch_path(),
      url: "http://127.0.0.1:#{port}#{launch_path()}",
      command: "cd #{@app_root} && PORT=#{port} mix phx.server"
    }
  end

  @spec review_metadata() :: map()
  def review_metadata do
    metadata()
    |> Map.take([
      :id,
      :root_id,
      :title,
      :summary,
      :notes,
      :widget,
      :theme_id,
      :directory,
      :purpose,
      :active_category_id,
      :category_count,
      :category_ids,
      :category_registry,
      :interaction_demo,
      :review_summary,
      :launch_path,
      :launch_url,
      :launch_command
    ])
    |> Map.merge(%{
      app_root: @app_root,
      browser_runnable?: true
    })
  end

  @spec decorate_metadata(map()) :: map()
  def decorate_metadata(metadata) do
    launch = launch_descriptor()

    Map.merge(metadata, %{
      active_category_id: active_category_id(),
      category_count: Categories.count(),
      category_ids: Categories.ids(),
      category_registry: category_registry(),
      review_summary: review_summary(),
      launch_path: launch.path,
      launch_url: launch.url,
      launch_command: launch.command
    })
  end
end
