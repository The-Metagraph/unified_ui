defmodule LiveUi.Demo do
  @moduledoc """
  Package-local example workbench for `live_ui`.
  """

  alias LiveUi.Demo.{Catalog, Screen, Server}

  @type view :: :home | :example
  @default_host "127.0.0.1"
  @default_port 4040

  @spec screen() :: module()
  def screen, do: Screen

  @spec default_host() :: String.t()
  def default_host, do: @default_host

  @spec default_port() :: pos_integer()
  def default_port, do: @default_port

  @spec catalog() :: map()
  def catalog do
    %{
      categories: Enum.map(Catalog.categories(), &Catalog.category_info/1),
      total_examples: Catalog.total_example_count(),
      path_counts: Catalog.path_counts()
    }
  end

  @spec screen_assigns(keyword()) :: {:ok, map()} | {:error, term()}
  def screen_assigns(opts \\ []) do
    initial_assigns(opts)
  end

  @spec path(keyword()) :: String.t()
  def path(opts \\ []) do
    base =
      case Keyword.get(opts, :example) do
        nil -> "/"
        example -> "/examples/" <> normalize_example_id(example)
      end

    case opts |> Keyword.get(:category) |> Catalog.normalize_category() do
      nil -> base
      category -> base <> "?category=" <> Atom.to_string(category)
    end
  end

  @spec serve(keyword()) :: {:ok, map()} | {:error, term()}
  def serve(opts \\ []) do
    host = Keyword.get(opts, :host, @default_host)
    port = Keyword.get(opts, :port, @default_port)
    launch_path = path(opts)

    case Server.start_link(host: host, port: port) do
      {:ok, server} ->
        {:ok,
         %{
           server: server,
           host: host,
           port: port,
           path: launch_path,
           url: Server.url(host: host, port: port, path: launch_path)
         }}

      other ->
        other
    end
  end

  @spec run(keyword()) :: {:ok, map()} | {:error, term()}
  def run(opts \\ []) do
    with {:ok, assigns} <- screen_assigns(opts),
         {:ok, runtime_state} <- LiveUi.Runtime.mount(Screen, assigns: assigns) do
      selected_example = Catalog.find_example(assigns.selected_example)

      {:ok,
       %{
         screen: Screen,
         view: assigns.view,
         selected_category: assigns.selected_category,
         selected_example: selected_example,
         categories: Enum.map(Catalog.categories(), &Catalog.category_info/1),
         examples: Catalog.category_examples(assigns.selected_category),
         total_examples: Catalog.total_example_count(),
         category_count: Catalog.category_count(),
         path_counts: Catalog.path_counts(),
         preview: maybe_preview(selected_example),
         html: render_runtime(runtime_state),
         event_routes: Map.keys(runtime_state.event_routes) |> Enum.sort()
       }}
    end
  end

  @spec html(keyword()) :: String.t()
  def html(opts \\ []) do
    {:ok, %{html: html}} = run(opts)
    html
  end

  defp normalize_example_id(example) do
    case Catalog.find_example(example) do
      %{id: id} -> to_string(id)
      _other -> to_string(example)
    end
  end

  defp initial_assigns(opts) do
    category =
      opts
      |> Keyword.get(:category)
      |> Catalog.normalize_category()
      |> Kernel.||(Catalog.default_category())

    case Keyword.get(opts, :example) do
      nil ->
        {:ok,
         %{
           view: :home,
           selected_category: category,
           selected_example: nil
         }}

      example_id ->
        with {:ok, example} <- Catalog.fetch_example(example_id) do
          {:ok,
           %{
             view: :example,
             selected_category: Catalog.primary_category(example.id) || category,
             selected_example: example.id
           }}
        end
    end
  end

  defp maybe_preview(nil), do: nil

  defp maybe_preview(example) do
    case Catalog.preview(example.id) do
      {:ok, preview} -> preview
      {:error, reason} -> %{mode: :error, reason: reason}
    end
  end

  defp render_runtime(runtime_state) do
    LiveUi.Runtime.component().render(%{
      id: "live-ui-demo-runtime",
      runtime_state: runtime_state
    })
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
