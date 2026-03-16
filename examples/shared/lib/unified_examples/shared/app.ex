defmodule UnifiedExamples.Shared.App do
  @moduledoc """
  Shared boilerplate for standalone example-app entrypoints.
  """

  defmacro __using__(opts) do
    app = Keyword.fetch!(opts, :app)
    directory = Keyword.fetch!(opts, :directory)
    purpose = Keyword.get(opts, :purpose, :widget_proof)

    quote bind_quoted: [app: app, directory: directory, purpose: purpose] do
      alias UnifiedExamples.Shared.Runtime

      parent_module = __MODULE__
      example_application_module = Module.concat(parent_module, Application)
      example_endpoint_module = Module.concat(parent_module, Endpoint)
      example_router_module = Module.concat(parent_module, Router)
      example_layouts_module = Module.concat(parent_module, Layouts)
      example_live_module = Module.concat(parent_module, Live)
      example_pubsub_server = Module.concat(parent_module, PubSub)

      @example_app app
      @example_directory directory
      @example_purpose purpose
      @example_application_module Module.concat(__MODULE__, Application)
      @example_endpoint_module Module.concat(__MODULE__, Endpoint)
      @example_router_module Module.concat(__MODULE__, Router)
      @example_layouts_module Module.concat(__MODULE__, Layouts)
      @example_live_module Module.concat(__MODULE__, Live)
      @example_pubsub_server Module.concat(__MODULE__, PubSub)

      @spec screen_module() :: module()
      def screen_module, do: Module.concat(__MODULE__, Screen)

      @spec application_module() :: module()
      def application_module, do: @example_application_module

      @spec endpoint_module() :: module()
      def endpoint_module, do: @example_endpoint_module

      @spec router_module() :: module()
      def router_module, do: @example_router_module

      @spec layouts_module() :: module()
      def layouts_module, do: @example_layouts_module

      @spec live_module() :: module()
      def live_module, do: @example_live_module

      @spec pubsub_server() :: module()
      def pubsub_server, do: @example_pubsub_server

      @spec metadata() :: map()
      def metadata do
        screen_module().example_metadata()
        |> Map.merge(%{
          app: @example_app,
          directory: @example_directory,
          purpose: @example_purpose
        })
      end

      @spec boot(keyword()) :: {:ok, LiveUi.Runtime.State.t()} | {:error, term()}
      def boot(opts \\ []) do
        Runtime.mount(screen_module(), opts)
      end

      @spec component_assigns(keyword()) :: {:ok, map()} | {:error, term()}
      def component_assigns(opts \\ []) do
        Runtime.component_assigns(screen_module(), opts)
      end

      @spec render_html(keyword()) :: {:ok, String.t()} | {:error, term()}
      def render_html(opts \\ []) do
        Runtime.render_html(screen_module(), opts)
      end

      @spec launch_path() :: String.t()
      def launch_path, do: "/"

      @spec launch_port() :: pos_integer()
      def launch_port do
        endpoint_config()
        |> Keyword.get(:http, [])
        |> Keyword.get(:port, default_launch_port())
      end

      @spec launch_url() :: String.t()
      def launch_url do
        "http://127.0.0.1:#{launch_port()}#{launch_path()}"
      end

      @spec endpoint_config() :: keyword()
      def endpoint_config do
        Application.get_env(@example_app, @example_endpoint_module, [])
      end

      defp default_launch_port do
        System.get_env("PORT", "4000")
        |> String.to_integer()
      rescue
        ArgumentError -> 4000
      end

      defmodule Layouts do
        @moduledoc false
        use Phoenix.Component

        def root(var!(assigns)) do
          ~H"""
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title><%= @page_title || "Unified Example" %></title>
            </head>
            <body>
              <%= @inner_content %>
            </body>
          </html>
          """
        end
      end

      defmodule Live do
        @moduledoc false
        use Phoenix.LiveView

        @app_module parent_module

        @impl true
        def mount(_params, _session, socket) do
          metadata = @app_module.metadata()

          case @app_module.component_assigns() do
            {:ok, component_assigns} ->
              {:ok,
               socket
               |> assign(component_assigns)
               |> assign(:metadata, metadata)
               |> assign(:page_title, metadata.title)
               |> assign(:runtime_error, nil)}

            {:error, reason} ->
              {:ok,
               socket
               |> assign(:id, "#{metadata.id}-runtime")
               |> assign(:runtime_state, nil)
               |> assign(:metadata, metadata)
               |> assign(:page_title, metadata.title)
               |> assign(:runtime_error, reason)}
          end
        end

        @impl true
        def render(var!(assigns)) do
          ~H"""
          <main
            id={"#{@metadata.root_id}-liveview-app"}
            data-example-directory={@metadata.directory}
            data-example-widget={@metadata.widget}
            data-example-launch={@metadata.app}
          >
            <header>
              <h1><%= @metadata.title %></h1>
              <p><%= @metadata.summary %></p>
              <p :if={@metadata.notes}><%= @metadata.notes %></p>
            </header>

            <section id={"#{@metadata.root_id}-runtime-surface"}>
              <%= if @runtime_state do %>
                <.live_component
                  module={LiveUi.Runtime.component()}
                  id={@id}
                  runtime_state={@runtime_state}
                />
              <% else %>
                <pre data-example-runtime-error="true"><%= inspect(@runtime_error) %></pre>
              <% end %>
            </section>
          </main>
          """
        end
      end

      defmodule Router do
        @moduledoc false
        use Phoenix.Router

        import Phoenix.LiveView.Router

        @layouts Module.concat(parent_module, "Layouts")
        @live Module.concat(parent_module, "Live")

        pipeline :browser do
          plug :accepts, ["html"]
          plug :fetch_session
          plug :fetch_live_flash
          plug :put_root_layout, html: {@layouts, :root}
          plug :protect_from_forgery
          plug :put_secure_browser_headers
        end

        scope "/" do
          pipe_through :browser

          live "/", @live, :show, as: :example
        end
      end

      defmodule Endpoint do
        @moduledoc false
        use Phoenix.Endpoint, otp_app: app

        @router Module.concat(parent_module, "Router")

        @session_options [
          store: :cookie,
          key: "_#{app}_key",
          signing_salt: "unified-example-session"
        ]

        socket "/live", Phoenix.LiveView.Socket,
          websocket: [connect_info: [session: @session_options]]

        plug Plug.Static,
          at: "/",
          from: app,
          gzip: false,
          only: ~w()

        plug Plug.RequestId
        plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

        plug Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Phoenix.json_library()

        plug Plug.MethodOverride
        plug Plug.Head
        plug Plug.Session, @session_options
        plug @router
      end

      defmodule Application do
        @moduledoc false
        use Elixir.Application

        @endpoint Module.concat(parent_module, "Endpoint")
        @pubsub Module.concat(parent_module, "PubSub")

        @impl true
        def start(_type, _args) do
          children = [
            {Phoenix.PubSub, name: @pubsub},
            @endpoint
          ]

          Supervisor.start_link(children,
            strategy: :one_for_one,
            name: Module.concat(@endpoint, Supervisor)
          )
        end

        @impl true
        def config_change(changed, _new, removed) do
          @endpoint.config_change(changed, removed)
          :ok
        end
      end
    end
  end
end
