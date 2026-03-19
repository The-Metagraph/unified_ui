defmodule WebUi.Reference do
  @moduledoc """
  Package reference surfaces for web_ui.

  Provides helpers for discovering and understanding the package's
  widget families, runtime modules, and integration points.
  """

  @doc """
  Returns the package reference map describing all public modules and their responsibilities.
  """
  @spec package_reference() :: map()
  def package_reference do
    %{
      widgets: %{
        description: "Native widget modules for direct web_ui use",
        modules: widget_modules()
      },
      server_runtime: %{
        description: "Phoenix server-side runtime entrypoints",
        modules: server_runtime_modules()
      },
      frontend_runtime: %{
        description: "Elm client-side runtime modules",
        modules: frontend_runtime_modules()
      },
      renderer: %{
        description: "Canonical IUR to Phoenix + Elm rendering",
        modules: renderer_modules()
      },
      transport: %{
        description: "Signal transport and browser bridge",
        modules: transport_modules()
      },
      tooling: %{
        description: "Development and maintenance helpers",
        modules: tooling_modules()
      }
    }
  end

  @doc """
  Lists all registered widget families.
  """
  @spec widget_families() :: [atom()]
  def widget_families do
    # This would query the registry in a full implementation
    [:content, :form, :input, :display, :overlay, :operational]
  end

  @doc """
  Returns runtime assumptions for web_ui.
  """
  @spec runtime_assumptions() :: map()
  def runtime_assumptions do
    %{
      server_authoritative: true,
      frontend_projection: true,
      state_sync: :checksum_based,
      transport: :phoenix_channels,
      rendering: :split_phoenix_elm
    }
  end

  @doc """
  Returns browser bridge entry points.
  """
  @spec bridge_entry_points() :: map()
  def bridge_entry_points do
    %{
      server: [
        {WebUi.ServerRuntime.BrowserBridge, :init},
        {WebUi.ServerRuntime.Channel, :channel_name}
      ],
      frontend: [
        {WebUi.FrontendRuntime.Bridge, :outbound},
        {WebUi.FrontendRuntime.Boot, :prepare_hydration}
      ]
    }
  end

  @doc """
  Returns transport integration points.
  """
  @spec transport_integrations() :: map()
  def transport_integrations do
    %{
      phoenix_channels: WebUi.ServerRuntime.Channel,
      browser_bridge: WebUi.ServerRuntime.BrowserBridge,
      frontend_bridge: WebUi.FrontendRuntime.Bridge
    }
  end

  @doc """
  Returns package validation state.
  """
  @spec validation_state() :: map()
  def validation_state do
    %{
      package_loaded: Code.ensure_loaded?(WebUi),
      registry_available: Code.ensure_loaded?(WebUi.Widgets.Native.Registry),
      runtime_available: Code.ensure_loaded?(WebUi.ServerRuntime.State),
      frontend_available: Code.ensure_loaded?(WebUi.FrontendRuntime.Boot)
    }
  end

  # Private helpers

  defp widget_modules do
    [
      {WebUi.Widgets, "Native widget namespace"},
      {WebUi.Widgets.Native.Widget, "Native widget behavior"},
      {WebUi.Widgets.Native.Registry, "Widget registration and lookup"},
      {WebUi.Widgets.Native.Composition, "Widget composition helpers"}
    ]
  end

  defp server_runtime_modules do
    [
      {WebUi.ServerRuntime, "Server runtime namespace"},
      {WebUi.ServerRuntime.State, "Server-authoritative runtime state"},
      {WebUi.ServerRuntime.Error, "Runtime error contract"},
      {WebUi.ServerRuntime.FrontendSync, "Frontend synchronization"},
      {WebUi.ServerRuntime.Channel, "Phoenix channel communication"},
      {WebUi.ServerRuntime.BrowserBridge, "Browser bridge coordination"},
      {WebUi.ServerRuntime.Diagnostics, "Runtime diagnostics"}
    ]
  end

  defp frontend_runtime_modules do
    [
      {WebUi.FrontendRuntime, "Frontend runtime namespace"},
      {WebUi.FrontendRuntime.Boot, "Frontend boot process"},
      {WebUi.FrontendRuntime.Bridge, "Frontend bridge boundary"},
      {WebUi.FrontendRuntime.Diagnostics, "Frontend diagnostics"}
    ]
  end

  defp renderer_modules do
    [
      {WebUi.Renderer, "Canonical IUR rendering namespace"}
    ]
  end

  defp transport_modules do
    [
      {WebUi.Transport, "Signal transport namespace"}
    ]
  end

  defp tooling_modules do
    [
      {WebUi.Tooling, "Development and maintenance helpers"}
    ]
  end
end
