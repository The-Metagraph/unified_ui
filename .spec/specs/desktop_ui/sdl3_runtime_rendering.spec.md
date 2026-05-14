# DesktopUi SDL3 Runtime And Native Rendering

This subject defines the SDL3-specific native display contract for
`desktop_ui`, including lifecycle ownership, retained rendering flow, window
mapping, scaling, and backend evolution boundaries.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Runtime](./runtime.spec.md)
- [DesktopUi Native Widgets](./native_widgets.spec.md)
- [DesktopUi Structure](./structure.spec.md)
- [DesktopUi Platform Artifacts](./platform_artifacts.spec.md)

```spec-meta
id: desktop_ui.sdl3_runtime_rendering
kind: runtime
status: active
summary: Target SDL3-native runtime and rendering contract for `desktop_ui`, including callback lifecycle ownership, SDL_Renderer-first display, retained widget rendering, widget-complete visible realization, DPI-aware logical sizing, and native window mapping.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/sdl3_runtime_rendering.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.sdl3_runtime_rendering.callback_lifecycle
  statement: The native desktop runtime shall use SDL3's callback-oriented application lifecycle as the package's primary runtime ownership model, coordinating initialization, event processing, frame iteration, and shutdown through one shared callback-driven runtime contract.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
  statement: Native widget display shall use SDL3's renderer API as the first concrete packaged rendering backend so the initial runtime favors a clear 2D UI presentation model over a GPU-first implementation burden.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
  statement: Future SDL3 GPU backend support may be introduced only behind an internal rendering boundary that preserves the same widget, layout, styling, interaction, and transport semantics already defined for the package.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
  statement: Widget layout, sizing, positioning, and interaction geometry shall be defined in logical units and resolved to physical pixels with SDL3 high-DPI awareness so display meaning remains stable across density differences.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
  statement: Native display shall flow through a retained widget tree with explicit layout, style resolution, render preparation, and presentation phases, while allowing bounded custom-draw escape hatches for specialized surfaces such as canvas-oriented widgets.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
  statement: The package shall establish an explicit SDL3-native adapter seam for lifecycle ownership, native-window coordination, render-plan presentation, event normalization, and text-image resource access before full widget-complete native rendering is required.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
  statement: After the SDL3 adapter seam and first presented frames exist, the compiled visible-window runtime shall realize the maintained native and canonical widget families through real SDL_Renderer drawing semantics rather than remaining limited to placeholder-only frame presentation.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.native_window_mapping
  statement: Top-level `desktop_ui` windows and multiwindow flows shall map to real SDL3 windows by default rather than being simulated as child surfaces inside one universal host window.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.in_window_layering
  statement: Overlays, popovers, context menus, dialogs, and similar transient layers shall remain in-window layered surfaces by default unless a later package subject explicitly promotes a specific layer role to native-window status.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.text_and_image_companions
  statement: The initial native text and image pipeline shall rely on SDL3 companion-library integration equivalent to SDL_ttf and SDL_image, while allowing future platform-native text or image backends if package semantics remain unchanged.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.native_resource_realization
  statement: The compiled visible-window runtime shall realize maintained text and image resources through native SDL3 companion-library-backed preparation, caching, and draw operations whenever those libraries are present, while surfacing bounded diagnostics and fallback behavior when they are absent.
  priority: must
  stability: stable

- id: desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  statement: The native runtime shall provide a keyboard-first desktop interaction contract together with richer pointer, wheel, hover, drag-initiation, and multiwindow focus coordination semantics across supported targets.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.sdl3_runtime_rendering.present_high_dpi_screen
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  given:
    - A native or canonical `desktop_ui` screen is shown on displays with different pixel densities
  when:
    - The runtime lays out and presents the screen through SDL3
  then:
    - The package preserves one logical layout model while resolving to different physical pixel densities underneath

- id: desktop_ui.sdl3_runtime_rendering.coordinate_multiwindow_layers
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  given:
    - A desktop flow uses multiple top-level windows together with overlays, popovers, or context menus
  when:
    - `desktop_ui` realizes that flow natively
  then:
    - Top-level windows map to native SDL3 windows while transient layered surfaces remain bounded within their owning window unless another subject explicitly says otherwise

- id: desktop_ui.sdl3_runtime_rendering.evolve_render_backend_without_semantic_drift
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  given:
    - Maintainers later explore an SDL3 GPU-backed rendering path
  when:
    - The package evolves its internal rendering backend
  then:
    - The change preserves retained widget semantics, canonical rendering meaning, native interaction behavior, and transport boundaries already defined for `desktop_ui`

- id: desktop_ui.sdl3_runtime_rendering.bootstrap_adapter_before_full_drawing
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  given:
    - Maintainers introduce the first SDL3-native implementation seam before every widget can draw completely
  when:
    - The package adds lifecycle, window, render-plan, event, and resource adapter modules
  then:
    - The package exposes one coherent native adapter boundary without overstating renderer completeness or changing retained widget semantics

- id: desktop_ui.sdl3_runtime_rendering.render_maintained_examples_with_real_widget_drawing
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  given:
    - Maintained foundational, advanced, transport, and styled examples are run through the compiled visible-window path
  when:
    - The SDL3 host presents native windows through SDL_Renderer
  then:
    - The host renders widget-complete geometry, text, imagery, and style states for those maintained example surfaces instead of only drawing placeholder frame shells

- id: desktop_ui.sdl3_runtime_rendering.realize_native_text_and_image_resources
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
  given:
    - The compiled visible-window runtime receives text and image resources while SDL3 companion libraries are present
  when:
    - The host prepares and renders those resources
  then:
    - Text and image content are realized through the native SDL3-backed pipeline and diagnostics report whether native or fallback handling was used
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/sdl3_runtime_rendering.spec.md
  covers:
    - desktop_ui.sdl3_runtime_rendering.callback_lifecycle
    - desktop_ui.sdl3_runtime_rendering.sdl_renderer_first_backend
    - desktop_ui.sdl3_runtime_rendering.gpu_backend_reserved_evolution
    - desktop_ui.sdl3_runtime_rendering.logical_units_and_dpi_scaling
    - desktop_ui.sdl3_runtime_rendering.retained_widget_pipeline
    - desktop_ui.sdl3_runtime_rendering.adapter_seam_before_full_renderer
    - desktop_ui.sdl3_runtime_rendering.widget_complete_visible_realization
    - desktop_ui.sdl3_runtime_rendering.native_window_mapping
    - desktop_ui.sdl3_runtime_rendering.in_window_layering
    - desktop_ui.sdl3_runtime_rendering.text_and_image_companions
    - desktop_ui.sdl3_runtime_rendering.native_resource_realization
    - desktop_ui.sdl3_runtime_rendering.desktop_input_contract
    - desktop_ui.sdl3_runtime_rendering.present_high_dpi_screen
    - desktop_ui.sdl3_runtime_rendering.coordinate_multiwindow_layers
    - desktop_ui.sdl3_runtime_rendering.evolve_render_backend_without_semantic_drift
    - desktop_ui.sdl3_runtime_rendering.bootstrap_adapter_before_full_drawing
    - desktop_ui.sdl3_runtime_rendering.render_maintained_examples_with_real_widget_drawing
    - desktop_ui.sdl3_runtime_rendering.realize_native_text_and_image_resources
```
