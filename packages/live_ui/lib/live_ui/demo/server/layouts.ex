defmodule LiveUi.Demo.Server.Layouts do
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
        <title><%= @page_title || "LiveUi Demo" %></title>
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
      gap: 1rem;
    }

    .live-ui-demo-browser-header-top {
      align-items: flex-start;
      justify-content: space-between;
      flex-wrap: wrap;
    }

    .live-ui-demo-browser-copy {
      flex: 1 1 24rem;
      min-width: 0;
    }

    .live-ui-demo-browser-kicker {
      color: var(--example-primary);
      text-transform: uppercase;
      letter-spacing: 0.16em;
      font-size: 0.72rem;
      font-weight: 700;
    }

    .live-ui-demo-browser-title {
      display: block;
      font-size: clamp(1.5rem, 3vw, 2.3rem);
      line-height: 1.08;
      letter-spacing: -0.03em;
    }

    .live-ui-demo-browser-summary,
    .live-ui-demo-browser-notes,
    .live-ui-demo-browser-status {
      display: block;
      max-width: 70ch;
      color: hsl(0 0% 91% / 0.82);
      line-height: 1.7;
      font-size: 0.98rem;
    }

    .live-ui-demo-browser-notes {
      color: var(--example-muted);
    }

    .live-ui-demo-browser-status {
      color: hsl(0 0% 91% / 0.88);
    }

    .live-ui-demo-sidebar-group {
      display: grid;
      gap: 0.7rem;
    }

    .live-ui-demo-category-tabs-title {
      color: var(--example-primary);
      font-size: 0.9rem;
      font-weight: 700;
      letter-spacing: 0.08em;
      text-transform: uppercase;
    }

    .live-ui-demo-category-tabs [role="tablist"] {
      display: flex;
      flex-wrap: wrap;
      gap: 0.65rem;
    }

    .live-ui-demo-category-tabs [role="tab"] {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-height: 2.45rem;
      padding: 0.6rem 0.9rem;
      border: 1px solid var(--example-border-strong);
      border-radius: 999px;
      background: hsl(0 0% 100% / 0.04);
      color: hsl(0 0% 91% / 0.78);
      text-decoration: none;
      font: inherit;
      font-size: 0.78rem;
      line-height: 1.2;
      cursor: pointer;
      transition:
        transform 120ms ease,
        border-color 160ms ease,
        background 160ms ease,
        color 160ms ease,
        box-shadow 160ms ease;
    }

    .live-ui-demo-category-tabs [role="tab"]:hover {
      transform: translateY(-1px);
      border-color: hsl(192 100% 50% / 0.28);
      color: hsl(0 0% 95%);
    }

    .live-ui-demo-category-tabs [role="tab"]:focus-visible {
      outline: 2px solid hsl(192 100% 50% / 0.9);
      outline-offset: 2px;
    }

    .live-ui-demo-category-tabs [role="tab"][aria-selected="true"] {
      color: hsl(0 0% 4%);
      background: linear-gradient(
        180deg,
        hsl(152 100% 50% / 0.98) 0%,
        hsl(152 100% 42% / 0.92) 100%
      );
      border-color: hsl(152 100% 50% / 0.45);
      box-shadow:
        inset 0 1px 0 hsl(0 0% 100% / 0.2),
        0 10px 26px hsl(152 100% 50% / 0.14);
    }

    .live-ui-demo-category-tabs [role="tab"][disabled] {
      opacity: 0.48;
      cursor: not-allowed;
      transform: none;
    }

    [data-live-ui-runtime="screen"] {
      display: grid;
      gap: 1rem;
    }

    [data-live-ui-widget="column"] {
      display: flex;
      flex-direction: column;
      min-width: 0;
    }

    [data-live-ui-widget="row"] {
      display: flex;
      flex-wrap: wrap;
      align-items: flex-start;
      min-width: 0;
    }

    [data-live-ui-widget="grid"] {
      display: grid;
      min-width: 0;
    }

    [data-live-ui-gap="sm"] {
      gap: var(--gap-sm);
    }

    [data-live-ui-gap="md"] {
      gap: var(--gap-md);
    }

    [data-live-ui-gap="lg"] {
      gap: var(--gap-lg);
    }

    [data-live-ui-gap="xl"] {
      gap: var(--gap-xl);
    }

    [data-live-ui-widget="grid"][data-live-ui-columns="2"] {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    [data-live-ui-widget="grid"][data-live-ui-columns="3"] {
      grid-template-columns: repeat(3, minmax(0, 1fr));
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

    .live-ui-screen-shell {
      padding: 1rem;
    }

    .live-ui-box.live-ui-box-panel {
      padding: 1.2rem;
    }

    .live-ui-text {
      color: var(--example-foreground);
      line-height: 1.6;
    }

    .live-ui-text[data-live-ui-tone="accent"],
    .live-ui-text[data-live-ui-tone="success"] {
      color: var(--example-primary);
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
      cursor: pointer;
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

    .live-ui-button.live-ui-button-quiet {
      color: var(--example-primary);
      background: hsl(152 100% 50% / 0.08);
      border-color: hsl(152 100% 50% / 0.22);
    }

    #live-ui-demo-sidebar .live-ui-demo-button {
      width: 100%;
      display: flex;
      justify-content: flex-start;
      text-align: left;
      box-sizing: border-box;
      text-decoration: none;
    }

    .live-ui-text-input {
      width: 100%;
      min-height: 2.8rem;
      border-radius: 12px;
      border: 1px solid var(--example-border-strong);
      padding: 0.7rem 0.85rem;
      font: inherit;
      color: var(--example-foreground);
      background: hsl(0 0% 100% / 0.04);
      box-sizing: border-box;
    }

    .live-ui-demo-interaction-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 1rem;
      align-items: stretch;
    }

    [data-live-ui-demo-story="true"] {
      margin-bottom: 1rem;
      border: 1px solid hsl(152 100% 50% / 0.18);
      border-radius: 14px;
      padding: 1rem;
      min-height: 6.75rem;
      background:
        linear-gradient(180deg, hsl(152 100% 50% / 0.08) 0%, hsl(0 0% 8% / 0.98) 100%);
    }

    [data-live-ui-signal-preview="true"] {
      border: 1px solid hsl(192 100% 50% / 0.18);
      border-radius: 14px;
      padding: 1rem;
      min-height: 6.75rem;
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

      .live-ui-box.live-ui-box-panel,
      .live-ui-screen-shell {
        border-radius: 14px;
      }

      [data-live-ui-widget="grid"][data-live-ui-columns="2"],
      [data-live-ui-widget="grid"][data-live-ui-columns="3"] {
        grid-template-columns: 1fr;
      }

      .live-ui-demo-interaction-grid {
        grid-template-columns: minmax(0, 1fr);
      }
    }
    """
  end
end
