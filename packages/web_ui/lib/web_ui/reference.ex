defmodule WebUi.Reference do
  @moduledoc """
  Reference helpers for package capabilities and boundaries.
  """

  @spec widget_families() :: [WebUi.Widgets.family()]
  def widget_families do
    WebUi.Widgets.families()
  end

  @spec widget_contract() :: map()
  def widget_contract do
    WebUi.Widget.contract()
  end

  @spec runtime_modules() :: [module()]
  def runtime_modules do
    WebUi.Runtime.modules()
  end

  @spec transport_integration_points() :: [atom()]
  def transport_integration_points do
    WebUi.Transport.integration_points()
  end

  @spec responsibilities() :: map()
  def responsibilities do
    %{
      direct_native: [:native_widgets, :phoenix_server_runtime, :elm_frontend_runtime],
      display_systems: WebUi.Layout.responsibilities(),
      layering: WebUi.Layer.responsibilities(),
      canonical_signals: WebUi.Signals.responsibilities(),
      canonical_renderer: WebUi.Renderer.responsibilities()
    }
  end

  @spec runtime_assumptions() :: map()
  def runtime_assumptions do
    WebUi.Runtime.assumptions()
  end

  @spec browser_bridge_boundaries() :: [atom()]
  def browser_bridge_boundaries do
    [:hydration_envelope, :event_envelope, :acknowledgement]
  end

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: WebUi,
      widgets: %{
        families: widget_families(),
        kinds: WebUi.Widgets.kinds(),
        modules: WebUi.Widgets.modules(),
        contract: widget_contract(),
        validation_state: WebUi.Widgets.validation_state()
      },
      layout: %{
        kinds: WebUi.Layout.kinds(),
        modules: WebUi.Layout.modules(),
        responsibilities: WebUi.Layout.responsibilities()
      },
      layer: %{
        kinds: WebUi.Layer.kinds(),
        modules: WebUi.Layer.modules(),
        responsibilities: WebUi.Layer.responsibilities()
      },
      runtime: %{
        capabilities: WebUi.Runtime.capabilities(),
        modules: runtime_modules(),
        assumptions: runtime_assumptions(),
        bridge_boundaries: browser_bridge_boundaries(),
        frontend_capabilities: WebUi.FrontendRuntime.capabilities()
      },
      renderer: %{
        accepts: WebUi.Renderer.accepts(),
        supported_kinds: WebUi.Renderer.supported_kinds(),
        responsibilities: WebUi.Renderer.responsibilities()
      },
      signals: %{
        families: WebUi.Signals.families(),
        local_default_families: WebUi.Signals.local_default_families(),
        boundary_crossing_families: WebUi.Signals.boundary_crossing_families(),
        responsibilities: WebUi.Signals.responsibilities()
      },
      transport: %{
        modes: WebUi.Transport.modes(),
        integration_points: transport_integration_points(),
        families: WebUi.Transport.families()
      },
      tooling: %{
        workflows: WebUi.Tooling.workflows(),
        preview_surfaces: WebUi.Tooling.preview_surfaces(),
        documentation: WebUi.Tooling.documentation_surface()
      },
      examples: Map.keys(WebUi.Examples.comparison_examples()),
      responsibilities: responsibilities()
    }
  end
end
