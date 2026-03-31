defmodule LiveUi.Demo.Server.Layouts do
  @moduledoc false

  use Phoenix.Component

  alias LiveUi.Stylesheet

  def root(var!(assigns)) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title><%= @page_title || "LiveUi Demo" %></title>
        <style><%= Phoenix.HTML.raw(Stylesheet.css()) %></style>
        <style><%= Phoenix.HTML.raw(css()) %></style>
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

  defp css do
    ~S"""
    :root {
      --example-background: hsl(0 0% 4%);
      --example-foreground: hsl(0 0% 91%);
      --example-surface: hsl(0 0% 7%);
      --example-muted: hsl(0 0% 40%);
      --example-border: hsl(0 0% 16%);
      --example-border-strong: hsl(0 0% 23%);
      --example-primary: hsl(152 100% 50%);
      --example-primary-strong: hsl(152 100% 42%);
      --example-cyan: hsl(192 100% 50%);
      --example-yellow: hsl(43 100% 50%);
      --example-shadow: 0 20px 60px hsl(0 0% 0% / 0.45);
      --example-font: "IBM Plex Mono", "SFMono-Regular", "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
      --gap-sm: 0.55rem;
      --gap-md: 0.85rem;
      --gap-lg: 1rem;
      --gap-xl: 1.35rem;
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

    .example-app-shell {
      position: relative;
      z-index: 1;
      width: min(74rem, calc(100% - 2rem));
      margin: 0 auto;
      padding: 2.5rem 0 4rem;
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
      --live-ui-theme-surface-base: hsl(0 0% 10%);
      --live-ui-theme-surface-panel: hsl(0 0% 12%);
      --live-ui-theme-foreground: var(--example-foreground);
      --live-ui-theme-foreground-muted: hsl(0 0% 80%);
      --live-ui-theme-border-muted: var(--example-border);
      --live-ui-theme-border-strong: var(--example-border-strong);
      --live-ui-theme-accent: var(--example-primary);
      --live-ui-theme-accent-strong: var(--example-primary-strong);
      --live-ui-theme-accent-soft: hsl(152 100% 50% / 0.08);
      --live-ui-theme-success: var(--example-primary);
      --live-ui-theme-warning: var(--example-yellow);
      --live-ui-theme-critical: hsl(0 82% 60%);
      --live-ui-shadow-action: 0 14px 34px hsl(152 100% 50% / 0.18);
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

    .example-app-widget,
    .live-ui-demo-metrics span {
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
      max-width: 70ch;
      color: hsl(0 0% 91% / 0.82);
      line-height: 1.7;
      font-size: 0.98rem;
    }

    .example-app-notes {
      color: var(--example-muted);
    }

    .live-ui-demo-status {
      color: hsl(0 0% 91% / 0.88);
    }

    .live-ui-demo-metrics {
      display: flex;
      flex-wrap: wrap;
      gap: 0.75rem;
      margin-top: 1rem;
    }

    .live-ui-demo-sidebar-group {
      display: grid;
      gap: 0.7rem;
    }

    .live-ui-demo-overview-list {
      display: grid;
      gap: 0.55rem;
    }

    [data-live-ui-demo-story="true"] {
      margin-bottom: 1rem;
      border: 1px solid hsl(152 100% 50% / 0.18);
      border-radius: 14px;
      padding: 1rem;
      background:
        linear-gradient(180deg, hsl(152 100% 50% / 0.08) 0%, hsl(0 0% 8% / 0.98) 100%);
    }

    [data-live-ui-signal-preview="true"] {
      border: 1px solid hsl(192 100% 50% / 0.18);
      border-radius: 14px;
      padding: 1rem;
      background:
        linear-gradient(180deg, hsl(192 100% 50% / 0.06) 0%, hsl(0 0% 9% / 0.98) 100%);
    }

    [data-live-ui-demo-story="true"] h2,
    [data-live-ui-signal-preview="true"] h2 {
      margin: 0 0 0.75rem;
      font-size: 0.8rem;
      letter-spacing: 0.12em;
      text-transform: uppercase;
    }

    [data-live-ui-demo-story="true"] h2 {
      color: var(--example-primary);
    }

    [data-live-ui-signal-preview="true"] h2 {
      color: var(--example-cyan);
    }

    [data-live-ui-signal-status="true"],
    [data-live-ui-signal-empty="true"],
    [data-live-ui-demo-status="true"],
    [data-live-ui-demo-empty="true"],
    [data-live-ui-demo-outcome="true"],
    [data-live-ui-demo-payload="true"] {
      margin: 0.4rem 0 0;
      color: hsl(0 0% 91% / 0.78);
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
    [data-live-ui-runtime-event-error="true"],
    [data-live-ui-demo-error="true"],
    pre {
      margin: 0.85rem 0 0;
      padding: 0.8rem 0.9rem;
      overflow-x: auto;
      border: 1px solid var(--example-border);
      border-radius: 12px;
      background: hsl(0 0% 5%);
      color: hsl(0 0% 84%);
      font-size: 0.82rem;
      line-height: 1.55;
      box-sizing: border-box;
    }

    @media (min-width: 980px) {
      .live-ui-demo-row {
        flex-wrap: nowrap;
      }

      .live-ui-demo-row > :first-child {
        flex: 0 0 18rem;
      }

      .live-ui-demo-row > :last-child {
        flex: 1 1 auto;
        min-width: 0;
      }
    }

    @media (max-width: 720px) {
      .example-app-shell {
        width: min(100% - 1rem, 74rem);
        padding: 1rem 0 2rem;
      }

      .example-app-header,
      .example-app-runtime,
      .live-ui-box.live-ui-box-panel,
      .live-ui-screen-shell {
        border-radius: 14px;
      }

      .example-app-header,
      .example-app-runtime {
        padding: 1rem;
      }

      [data-live-ui-widget="grid"][data-live-ui-columns="2"],
      [data-live-ui-widget="grid"][data-live-ui-columns="3"] {
        grid-template-columns: 1fr;
      }
    }
    """
  end
end
