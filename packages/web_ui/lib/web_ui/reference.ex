defmodule WebUi.Reference do
  @moduledoc """
  Reference helpers for the `web_ui` package scaffold.
  """

  @spec widget_families() :: [WebUi.Widget.family()]
  def widget_families do
    WebUi.Widgets.families()
  end

  @spec runtime_modules() :: [module()]
  def runtime_modules do
    WebUi.Runtime.modules()
  end

  @spec transport_integration_points() :: [atom()]
  def transport_integration_points do
    WebUi.Transport.responsibilities()
  end

  @spec responsibilities() :: map()
  def responsibilities do
    %{
      direct_native: [
        :native_widgets,
        :phoenix_server_runtime,
        :elm_frontend_runtime,
        :browser_bridge
      ],
      canonical_renderer: WebUi.Renderer.responsibilities()
    }
  end

  @spec runtime_assumptions() :: map()
  def runtime_assumptions do
    %{
      server: WebUi.Server.assumptions(),
      frontend: WebUi.Frontend.assumptions(),
      runtime: WebUi.Runtime.assumptions()
    }
  end

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: WebUi.package_identity(),
      widgets: %{
        families: widget_families(),
        kinds: WebUi.Widgets.kinds(),
        modules: WebUi.Widgets.modules(),
        responsibilities: WebUi.Widgets.responsibilities(),
        style_contract: WebUi.Widgets.style_contract(),
        metadata_contract: WebUi.Widgets.metadata_contract(),
        events_contract: WebUi.Widgets.events_contract()
      },
      runtime: %{
        sides: WebUi.Runtime.sides(),
        modules: runtime_modules(),
        browser_bridge: %{
          assets_root: WebUi.Frontend.assets_root(),
          entry_module: WebUi.Frontend.entry_module(),
          boot_contract: WebUi.Frontend.boot_contract()
        },
        assumptions: runtime_assumptions(),
        validation_state: WebUi.Runtime.validation_state()
      },
      renderer: %{
        responsibilities: WebUi.Renderer.responsibilities(),
        accepts: WebUi.Renderer.accepts(),
        modules: WebUi.Renderer.modules(),
        supported_kinds: WebUi.Renderer.supported_kinds(),
        validation_state: WebUi.Renderer.validation_state()
      },
      transport: %{
        responsibilities: WebUi.Transport.responsibilities(),
        integration_points: transport_integration_points()
      },
      responsibilities: responsibilities(),
      tooling: %{
        capabilities: WebUi.Tooling.capabilities()
      },
      module_areas: WebUi.module_areas()
    }
  end
end
