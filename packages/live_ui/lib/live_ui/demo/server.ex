defmodule LiveUi.Demo.Server do
  @moduledoc """
  Minimal Phoenix host for running the package-local `live_ui` demo in a browser.
  """

  use Supervisor

  alias LiveUi.Demo.Server.Endpoint

  @pubsub __MODULE__.PubSub
  @secret_key_base "live_ui_demo_server_secret_key_base_live_ui_demo_server_secret_key_base"
  @signing_salt "live-ui-demo-signing-salt"

  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @spec init(keyword()) :: {:ok, {:supervisor.sup_flags(), [Supervisor.child_spec()]}}
  def init(opts) do
    configure_endpoint(opts)

    children = [
      {Phoenix.PubSub, name: @pubsub},
      Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec url(keyword()) :: String.t()
  def url(opts \\ []) do
    host = Keyword.get(opts, :host, LiveUi.Demo.default_host())
    port = Keyword.get(opts, :port, LiveUi.Demo.default_port())
    path = Keyword.get(opts, :path, "/")

    "http://#{host}:#{port}" <> normalize_path(path)
  end

  @spec pubsub() :: module()
  def pubsub, do: @pubsub

  defp configure_endpoint(opts) do
    host = Keyword.get(opts, :host, LiveUi.Demo.default_host())
    port = Keyword.get(opts, :port, LiveUi.Demo.default_port())

    Application.put_env(:live_ui, Endpoint,
      check_origin: false,
      code_reloader: false,
      debug_errors: false,
      http: [ip: bind_ip(host), port: port],
      live_view: [signing_salt: @signing_salt],
      pubsub_server: @pubsub,
      render_errors: [formats: [html: Phoenix.Controller], layout: false],
      root: Path.expand("../..", __DIR__),
      secret_key_base: @secret_key_base,
      server: true,
      url: [host: host, port: port]
    )
  end

  defp bind_ip("127.0.0.1"), do: {127, 0, 0, 1}
  defp bind_ip("localhost"), do: {127, 0, 0, 1}
  defp bind_ip(_other), do: {0, 0, 0, 0}

  defp normalize_path("/" <> _rest = path), do: path
  defp normalize_path(path), do: "/" <> path
end
