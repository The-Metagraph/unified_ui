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

      @spec example_interaction_demo() :: map()
      def example_interaction_demo, do: screen_module().example_interaction_demo()

      @spec boot(keyword()) :: {:ok, LiveUi.Runtime.State.t()} | {:error, term()}
      def boot(opts \\ []) do
        Runtime.mount(screen_module(), runtime_opts(opts))
      end

      @spec component_assigns(keyword()) :: {:ok, map()} | {:error, term()}
      def component_assigns(opts \\ []) do
        Runtime.component_assigns(screen_module(), runtime_opts(opts))
      end

      @spec render_html(keyword()) :: {:ok, String.t()} | {:error, term()}
      def render_html(opts \\ []) do
        Runtime.render_html(screen_module(), runtime_opts(opts))
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

      defp runtime_opts(opts) do
        shared_assigns = %{
          example_metadata: metadata(),
          example_interaction_demo: example_interaction_demo()
        }

        Keyword.update(opts, :assigns, shared_assigns, &Map.merge(shared_assigns, &1))
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
              <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
              <title><%= @page_title || "Unified Example" %></title>
              <style>
                :root {
                  --example-background: hsl(0 0% 5%);
                  --example-foreground: hsl(0 0% 92%);
                  --example-surface: hsl(0 0% 9%);
                  --example-surface-elevated: hsl(0 0% 12%);
                  --example-border: hsl(0 0% 18%);
                  --example-muted: hsl(0 0% 58%);
                  --example-primary: hsl(152 100% 50%);
                  --example-cyan: hsl(192 100% 50%);
                  --example-yellow: hsl(43 100% 50%);
                  --example-shadow: 0 24px 64px hsl(0 0% 0% / 0.35);
                  --example-font: "IBM Plex Mono", "SFMono-Regular", "SF Mono", Consolas, monospace;
                }

                body.unified-example-shell {
                  margin: 0;
                  min-height: 100vh;
                  color: var(--example-foreground);
                  background:
                    radial-gradient(circle at top, hsl(152 100% 50% / 0.08), transparent 24%),
                    linear-gradient(180deg, hsl(0 0% 7%) 0%, var(--example-background) 100%);
                  font-family: var(--example-font);
                }

                .example-app-shell {
                  width: min(72rem, calc(100% - 2rem));
                  margin: 0 auto;
                  padding: 2rem 0 3rem;
                  display: grid;
                  gap: 1.5rem;
                }

                .example-app-header,
                .example-app-runtime {
                  border: 1px solid var(--example-border);
                  border-radius: 18px;
                  background: linear-gradient(
                    180deg,
                    hsl(0 0% 11% / 0.98) 0%,
                    hsl(0 0% 8% / 0.98) 100%
                  );
                  box-shadow: var(--example-shadow);
                }

                .example-app-header {
                  padding: 1.5rem;
                }

                .example-app-runtime {
                  padding: 1.25rem;
                }

                [data-live-ui-runtime="screen"][data-example-demo-active="true"] {
                  border-radius: 16px;
                  box-shadow:
                    inset 0 0 0 1px hsl(152 100% 50% / 0.25),
                    0 0 0 1px hsl(152 100% 50% / 0.18);
                }

                [data-live-ui-runtime="screen"][data-example-demo-active="true"] [data-live-ui-widget] {
                  box-shadow: 0 0 0 1px hsl(152 100% 50% / 0.18);
                }

                .example-app-kicker {
                  margin: 0 0 0.75rem;
                  color: var(--example-primary);
                  text-transform: uppercase;
                  letter-spacing: 0.14em;
                  font-size: 0.74rem;
                  font-weight: 700;
                }

                .example-app-widget {
                  display: inline-flex;
                  align-items: center;
                  margin-bottom: 0.85rem;
                  padding: 0.28rem 0.72rem;
                  border: 1px solid hsl(192 100% 50% / 0.25);
                  border-radius: 999px;
                  color: var(--example-cyan);
                  background: hsl(192 100% 50% / 0.08);
                  font-size: 0.72rem;
                  letter-spacing: 0.08em;
                  text-transform: uppercase;
                }

                .example-app-title {
                  margin: 0;
                  font-size: clamp(1.55rem, 3vw, 2.3rem);
                  line-height: 1.08;
                }

                .example-app-summary,
                .example-app-notes {
                  margin: 0.65rem 0 0;
                  color: hsl(0 0% 92% / 0.85);
                  line-height: 1.65;
                }

                .example-app-notes {
                  color: var(--example-muted);
                }

                [data-live-ui-signal-preview="true"] {
                  border: 1px solid hsl(192 100% 50% / 0.18);
                  border-radius: 14px;
                  padding: 1rem;
                  background:
                    linear-gradient(180deg, hsl(192 100% 50% / 0.06) 0%, hsl(0 0% 9% / 0.98) 100%);
                }

                [data-live-ui-demo-story="true"] {
                  margin-bottom: 1rem;
                  border: 1px solid hsl(152 100% 50% / 0.18);
                  border-radius: 14px;
                  padding: 1rem;
                  background:
                    linear-gradient(180deg, hsl(152 100% 50% / 0.08) 0%, hsl(0 0% 8% / 0.98) 100%);
                }

                [data-live-ui-demo-story="true"] h2 {
                  margin: 0 0 0.75rem;
                  font-size: 0.8rem;
                  letter-spacing: 0.12em;
                  text-transform: uppercase;
                  color: var(--example-primary);
                }

                [data-live-ui-signal-preview="true"] h2 {
                  margin: 0 0 0.75rem;
                  font-size: 0.8rem;
                  letter-spacing: 0.12em;
                  text-transform: uppercase;
                  color: var(--example-cyan);
                }

                [data-live-ui-signal-status="true"],
                [data-live-ui-signal-empty="true"],
                [data-live-ui-demo-status="true"],
                [data-live-ui-demo-empty="true"],
                [data-live-ui-demo-outcome="true"],
                [data-live-ui-demo-payload="true"] {
                  margin: 0.4rem 0 0;
                  line-height: 1.6;
                }

                [data-live-ui-signal-type="true"] {
                  margin: 0.75rem 0 0.35rem;
                  color: var(--example-primary);
                  font-weight: 700;
                }

                [data-live-ui-runtime-event="true"] {
                  margin: 0;
                  color: var(--example-yellow);
                }

                [data-live-ui-signal-payload="true"],
                [data-live-ui-signal-translation="true"],
                [data-live-ui-runtime-event-error="true"] {
                  margin: 0.85rem 0 0;
                  padding: 0.8rem 0.9rem;
                  overflow-x: auto;
                  border: 1px solid var(--example-border);
                  border-radius: 12px;
                  background: hsl(0 0% 5%);
                  color: hsl(0 0% 84%);
                  font-size: 0.82rem;
                  line-height: 1.55;
                }
              </style>
            </head>
            <body class="unified-example-shell">
              <%= @inner_content %>
              <script src="/vendor/phoenix/phoenix.js"></script>
              <script src="/vendor/live_view/phoenix_live_view.js"></script>
              <script>
                if (!window.liveSocket) {
                  const csrfToken = document
                    .querySelector("meta[name='csrf-token']")
                    ?.getAttribute("content")

                  if (window.Phoenix?.Socket && window.LiveView?.LiveSocket && csrfToken) {
                    const liveSocket = new window.LiveView.LiveSocket(
                      "/live",
                      window.Phoenix.Socket,
                      {params: {_csrf_token: csrfToken}}
                    )

                    liveSocket.connect()
                    window.liveSocket = liveSocket
                  }
                }
              </script>
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
            class="example-app-shell"
            data-example-directory={@metadata.directory}
            data-example-widget={@metadata.widget}
            data-example-launch={@metadata.app}
            data-example-interaction-family={@metadata.interaction_demo.family}
          >
            <header class="example-app-header">
              <p class="example-app-kicker">Meaningful live_ui example</p>
              <span class="example-app-widget"><%= widget_label(@metadata.widget) %></span>
              <h1><%= @metadata.title %></h1>
              <p class="example-app-summary"><%= @metadata.summary %></p>
              <p :if={@metadata.notes} class="example-app-notes"><%= @metadata.notes %></p>
            </header>

            <section id={"#{@metadata.root_id}-runtime-surface"} class="example-app-runtime">
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

        defp widget_label(widget) do
          widget
          |> to_string()
          |> String.replace("_", " ")
          |> String.upcase()
        end
      end

      defmodule Router do
        @moduledoc false
        use Phoenix.Router

        import Phoenix.LiveView.Router

        @layouts Module.concat(parent_module, "Layouts")
        @live Module.concat(parent_module, "Live")

        pipeline :browser do
          plug(:accepts, ["html"])
          plug(:fetch_session)
          plug(:fetch_live_flash)
          plug(:put_root_layout, html: {@layouts, :root})
          plug(:protect_from_forgery)
          plug(:put_secure_browser_headers)
        end

        scope "/" do
          pipe_through(:browser)

          live("/", @live, :show, as: :example)
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

        socket("/live", Phoenix.LiveView.Socket,
          websocket: [connect_info: [session: @session_options]]
        )

        plug(Plug.Static,
          at: "/",
          from: app,
          gzip: false,
          only: ~w()
        )

        plug(Plug.RequestId)
        plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

        plug(Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Phoenix.json_library()
        )

        plug(Plug.MethodOverride)
        plug(Plug.Head)
        plug(Plug.Session, @session_options)
        plug(@router)
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
