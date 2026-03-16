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
                  --example-background: hsl(0 0% 4%);
                  --example-foreground: hsl(0 0% 91%);
                  --example-surface: hsl(0 0% 7%);
                  --example-elevated: hsl(0 0% 10%);
                  --example-muted: hsl(0 0% 40%);
                  --example-border: hsl(0 0% 16%);
                  --example-border-strong: hsl(0 0% 23%);
                  --example-primary: hsl(152 100% 50%);
                  --example-primary-strong: hsl(152 100% 42%);
                  --example-cyan: hsl(192 100% 50%);
                  --example-yellow: hsl(43 100% 50%);
                  --example-red: hsl(0 73% 71%);
                  --example-shadow: 0 20px 60px hsl(0 0% 0% / 0.45);
                  --example-font: "IBM Plex Mono", "SFMono-Regular", "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
                }

                html {
                  scroll-behavior: smooth;
                }

                body.unified-example-shell {
                  margin: 0;
                  min-height: 100vh;
                  color: var(--example-foreground);
                  background:
                    radial-gradient(circle at top, hsl(152 100% 50% / 0.09), transparent 30%),
                    radial-gradient(circle at 85% 15%, hsl(192 100% 50% / 0.1), transparent 24%),
                    linear-gradient(180deg, hsl(0 0% 5%) 0%, var(--example-background) 100%);
                  font-family: var(--example-font);
                }

                body.unified-example-shell::before {
                  content: "";
                  position: fixed;
                  inset: 0;
                  pointer-events: none;
                  background-image:
                    linear-gradient(hsl(0 0% 100% / 0.028) 1px, transparent 1px),
                    linear-gradient(90deg, hsl(0 0% 100% / 0.028) 1px, transparent 1px);
                  background-size: 36px 36px;
                  mask-image: linear-gradient(180deg, hsl(0 0% 0% / 0.45), transparent 80%);
                }

                ::selection {
                  background: hsl(152 100% 50% / 0.28);
                }

                .example-app-shell {
                  position: relative;
                  z-index: 1;
                  width: min(72rem, calc(100% - 2rem));
                  margin: 0 auto;
                  padding: 3rem 0 4rem;
                  display: grid;
                  gap: 1.5rem;
                }

                .example-app-header,
                .example-app-runtime {
                  border: 1px solid var(--example-border);
                  border-radius: 18px;
                  background:
                    linear-gradient(180deg, hsl(0 0% 11% / 0.96) 0%, hsl(0 0% 7% / 0.98) 100%);
                  box-shadow: var(--example-shadow);
                }

                .example-app-header {
                  padding: 1.5rem 1.5rem 1.35rem;
                }

                .example-app-runtime {
                  padding: 1.25rem;
                  backdrop-filter: blur(14px);
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

                .example-app-header-top {
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                  gap: 1rem;
                  margin-bottom: 0.85rem;
                  flex-wrap: wrap;
                }

                .example-app-kicker {
                  margin: 0;
                  color: var(--example-primary);
                  text-transform: uppercase;
                  letter-spacing: 0.16em;
                  font-size: 0.72rem;
                  font-weight: 700;
                }

                .example-app-widget {
                  display: inline-flex;
                  align-items: center;
                  border: 1px solid hsl(192 100% 50% / 0.3);
                  border-radius: 999px;
                  padding: 0.3rem 0.7rem;
                  color: var(--example-cyan);
                  background: hsl(192 100% 50% / 0.08);
                  font-size: 0.72rem;
                  letter-spacing: 0.08em;
                  text-transform: uppercase;
                }

                .example-app-title {
                  margin: 0;
                  font-size: clamp(1.5rem, 3vw, 2.3rem);
                  line-height: 1.08;
                  letter-spacing: -0.03em;
                }

                .example-app-summary,
                .example-app-notes {
                  margin: 0.65rem 0 0;
                  max-width: 68ch;
                  color: hsl(0 0% 91% / 0.82);
                  line-height: 1.7;
                  font-size: 0.98rem;
                }

                .example-app-notes {
                  color: var(--example-muted);
                }

                #button_example_screen_root-runtime-surface,
                [id$="-runtime-surface"] {
                  min-width: 0;
                }

                [data-live-ui-runtime="screen"] {
                  display: grid;
                  gap: 1rem;
                }

                .live-ui-box {
                  box-sizing: border-box;
                }

                .live-ui-box.live-ui-box-panel,
                .live-ui-screen-shell {
                  display: flex;
                  flex-direction: column;
                  gap: 1rem;
                  border: 1px solid var(--example-border);
                  border-radius: 16px;
                  background:
                    linear-gradient(180deg, hsl(0 0% 12% / 0.98) 0%, hsl(0 0% 10% / 0.98) 100%);
                  box-shadow: inset 0 1px 0 hsl(0 0% 100% / 0.04);
                }

                .live-ui-box.live-ui-box-panel {
                  padding: 1.2rem;
                }

                .live-ui-text {
                  color: var(--example-foreground);
                  line-height: 1.6;
                }

                .live-ui-text[data-live-ui-variant="headline"] {
                  color: var(--example-primary);
                  font-size: 1.2rem;
                  font-weight: 700;
                  letter-spacing: -0.02em;
                }

                .live-ui-text[data-live-ui-tone="muted"] {
                  color: var(--example-muted);
                }

                .live-ui-button {
                  appearance: none;
                  border-radius: 12px;
                  border: 1px solid var(--example-border-strong);
                  padding: 0.8rem 1.15rem;
                  min-height: 2.8rem;
                  display: inline-flex;
                  align-items: center;
                  justify-content: center;
                  gap: 0.5rem;
                  font: inherit;
                  font-size: 0.92rem;
                  font-weight: 700;
                  letter-spacing: 0.02em;
                  transition:
                    transform 120ms ease,
                    box-shadow 160ms ease,
                    filter 160ms ease,
                    border-color 160ms ease;
                }

                .live-ui-button:hover {
                  transform: translateY(-1px);
                }

                .live-ui-button:focus-visible {
                  outline: 2px solid hsl(192 100% 50% / 0.9);
                  outline-offset: 2px;
                }

                .live-ui-button.live-ui-button-solid {
                  color: hsl(0 0% 4%);
                  background: linear-gradient(
                    180deg,
                    hsl(152 100% 50% / 0.98) 0%,
                    hsl(152 100% 42% / 0.92) 100%
                  );
                  border-color: hsl(152 100% 50% / 0.45);
                  box-shadow:
                    inset 0 1px 0 hsl(0 0% 100% / 0.22),
                    0 14px 34px hsl(152 100% 50% / 0.18);
                }

                .live-ui-button.live-ui-button-solid:hover {
                  filter: brightness(1.04);
                  box-shadow:
                    inset 0 1px 0 hsl(0 0% 100% / 0.26),
                    0 18px 42px hsl(152 100% 50% / 0.24);
                }

                .live-ui-button.live-ui-button-quiet {
                  color: var(--example-primary);
                  background: hsl(152 100% 50% / 0.08);
                  border-color: hsl(152 100% 50% / 0.22);
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
                  margin: 0;
                  color: hsl(0 0% 91% / 0.78);
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

                @media (max-width: 720px) {
                  .example-app-shell {
                    width: min(100% - 1rem, 72rem);
                    padding: 1rem 0 2rem;
                  }

                  .example-app-header,
                  .example-app-runtime,
                  .live-ui-box.live-ui-box-panel {
                    border-radius: 14px;
                  }

                  .example-app-header,
                  .example-app-runtime {
                    padding: 1rem;
                  }
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
              <div class="example-app-header-top">
                <p class="example-app-kicker">jido_run inspired live_ui example</p>
                <span class="example-app-widget"><%= widget_label(@metadata.widget) %></span>
              </div>
              <h1 class="example-app-title"><%= @metadata.title %></h1>
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

        plug(Plug.Static,
          at: "/vendor/phoenix",
          from: {:phoenix, "priv/static"},
          gzip: false,
          only: ~w(phoenix.js)
        )

        plug(Plug.Static,
          at: "/vendor/live_view",
          from: {:phoenix_live_view, "priv/static"},
          gzip: false,
          only: ~w(phoenix_live_view.js)
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
