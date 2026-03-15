defmodule LiveUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  alias LiveUi.Component.Metadata

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: :live_ui,
      namespace: LiveUi,
      package_areas: LiveUi.package_areas(),
      validation_state: LiveUi.Runtime.validation_state()
    }
  end

  @spec widget_summary(module()) :: map()
  def widget_summary(widget_module) do
    %Metadata{} = metadata = LiveUi.Component.metadata(widget_module)

    %{
      module: metadata.module,
      family: metadata.family,
      name: metadata.name,
      assigns: metadata.assigns,
      slots: metadata.slots,
      style_hooks: metadata.style_hooks,
      events: metadata.events
    }
  end

  @spec screen_summary(module()) :: map()
  def screen_summary(screen_module) do
    definition = LiveUi.Screen.definition(screen_module)

    %{
      module: definition.module,
      id: definition.id,
      title: definition.title,
      mount_defaults: definition.mount_defaults,
      event_routes: definition.event_routes,
      bridge_hooks: definition.bridge_hooks,
      metadata: definition.metadata
    }
  end

  @spec renderer_summary() :: map()
  def renderer_summary do
    %{
      accepts: LiveUi.Renderer.accepts(),
      supported_kinds: LiveUi.Renderer.supported_kinds(),
      responsibilities: LiveUi.Renderer.responsibilities()
    }
  end
end
