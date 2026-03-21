defmodule WebUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: :web_ui,
      namespace: WebUi,
      package_areas: WebUi.package_areas(),
      validation_state: WebUi.Runtime.validation_state(),
      bridge: bridge_summary(),
      tooling: %{
        workflows: WebUi.Tooling.workflows(),
        mix_tasks: WebUi.Tooling.mix_tasks()
      },
      documentation: WebUi.Tooling.documentation_surface()
    }
  end

  @spec renderer_summary() :: map()
  def renderer_summary do
    %{
      accepts: WebUi.Renderer.accepts(),
      supported_kinds: WebUi.Renderer.supported_kinds(),
      responsibilities: WebUi.Renderer.responsibilities()
    }
  end

  @spec widget_summary(WebUi.Widget.t()) :: map()
  def widget_summary(%WebUi.Widget{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      metadata: widget.metadata,
      state: widget.state,
      slots: widget.slots,
      slot_children:
        Map.new(widget.slot_children, fn {slot, children} -> {slot, length(children)} end),
      attribute_keys: Map.keys(widget.attributes),
      style_keys: Map.keys(widget.styles),
      event_keys: Map.keys(widget.events)
    }
  end

  @spec bridge_summary() :: map()
  def bridge_summary do
    %{
      boundaries: WebUi.Reference.browser_bridge_boundaries(),
      frontend_modules: WebUi.Frontend.modules(),
      server_modules: WebUi.Server.modules()
    }
  end
end
