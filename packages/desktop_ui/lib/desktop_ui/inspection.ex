defmodule DesktopUi.Inspection do
  @moduledoc """
  Lightweight inspection placeholder for `desktop_ui`.
  """

  @spec helpers() :: [atom()]
  def helpers do
    [
      :package_overview,
      :shared_runtime_contract,
      :platform_contract,
      :transport_contract,
      :layering_contract,
      :validation_surface
    ]
  end

  @spec package_overview() :: map()
  def package_overview do
    %{
      runtime_foundation: :sdl2,
      runtime_binding: :sdl,
      platform_targets: DesktopUi.Platform.targets(),
      package_areas: DesktopUi.package_areas(),
      layout: %{
        kinds: DesktopUi.Layout.kinds(),
        validation_state: DesktopUi.Layout.validation_state()
      },
      layer: %{
        kinds: DesktopUi.Layer.kinds(),
        validation_state: DesktopUi.Layer.validation_state()
      },
      examples: %{
        native_ids: DesktopUi.Examples.native_ids(),
        canonical_ids: DesktopUi.Examples.canonical_ids(),
        comparison_ids: DesktopUi.Examples.comparison_ids()
      },
      transport: transport_contract(),
      shared_runtime_contract: shared_runtime_contract(),
      validation: validation_surface()
    }
  end

  @spec shared_runtime_contract() :: map()
  def shared_runtime_contract do
    %{
      assumptions: DesktopUi.Runtime.assumptions(),
      runtime_modules: DesktopUi.Runtime.modules(),
      platform_targets: DesktopUi.Platform.targets(),
      layout_kinds: DesktopUi.Layout.kinds(),
      layer_kinds: DesktopUi.Layer.kinds(),
      transport_modes: DesktopUi.Transport.modes(),
      direct_native_and_canonical_share_runtime: true
    }
  end

  @spec layering_contract() :: map()
  def layering_contract do
    %{
      layout: DesktopUi.Layout.validation_state(),
      layer: DesktopUi.Layer.validation_state(),
      multiwindow_runtime: true,
      advanced_display_shared_runtime: true
    }
  end

  @spec transport_contract() :: map()
  def transport_contract do
    %{
      modes: DesktopUi.Transport.modes(),
      families: DesktopUi.Transport.families(),
      input_families: DesktopUi.Transport.input_families(),
      local_default_families: DesktopUi.Transport.local_default_families(),
      boundary_crossing_families: DesktopUi.Transport.boundary_crossing_families(),
      diagnostics: DesktopUi.Transport.diagnostics(),
      no_platform_leakage_guarantee: true
    }
  end

  @spec validation_surface() :: map()
  def validation_surface do
    %{
      widgets: DesktopUi.Widgets.validation_state(),
      runtime: DesktopUi.Runtime.validation_state(),
      platform: DesktopUi.Platform.validation_state(),
      layout: DesktopUi.Layout.validation_state(),
      layer: DesktopUi.Layer.validation_state(),
      renderer: DesktopUi.Renderer.validation_state(),
      transport: DesktopUi.Transport.validation_state(),
      artifacts: DesktopUi.Artifacts.validation_state()
    }
  end
end
