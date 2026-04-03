# Widget Component Runtime Integration Tests

This test file verifies the shared runtime's ability to mount, update, and route
events to explicit widget component boundaries in both native and canonical rendering modes.

## Test Scenarios

### 1. Native Screens with Widget Component Boundaries

**Test**: `native screens can compose mountable widget component boundaries through the shared runtime`

Verifies that:
- Native screens can use widget component boundaries (Button.component, Text.component)
- The shared runtime properly composes these component boundaries
- Widget identities are correctly established with "native" mode
- Widget boundaries are rendered with `data-live-ui-widget-boundary` attributes

**Expected Behavior**: The runtime should create widget component boundaries for each
widget that has a Component submodule using LiveUi.Widget. The widget-key attribute
should reflect the widget family, name, id, and mode.

### 2. Widget-Targeted Event Routing with Local State

**Test**: `runtime routes widget-targeted events and preserves bounded widget-local state`

Verifies that:
- Widget-targeted events are routed through the shared runtime
- The runtime correctly identifies the target widget component module
- Widget-local state (e.g., a counter) is scoped to the widget component boundary
- Local state persists across event updates
- The runtime provides widget-local state to the widget component on updates

**Expected Behavior**: When a widget event is fired, the runtime should:
1. Decode the event to find the target widget
2. Call the widget's handle_widget_event/3 callback with the current local state
3. Store the updated local state back in the runtime
4. Re-render the widget with the updated state

### 3. Canonical Rendering with Widget Component Boundaries

**Test**: `canonical runtime rendering reuses widget component boundaries for mounted widgets`

Verifies that:
- Canonical IUR rendering uses the same widget component boundaries as native screens
- The widget-key attribute reflects "canonical" mode
- Interactive widgets in canonical IUR render through widget components
- The canonical rendering path integrates with the shared runtime state

**Expected Behavior**: When canonical IUR is rendered:
1. The renderer creates widget component boundaries for interactive widgets
2. The mode is set to "canonical" in the widget identity
3. Widget events route through the canonical event handling path
4. Widget-local state is managed through the canonical runtime

## Current Status

**Phase 11.1.1.3** ✅ Complete - Structural layout primitives are correctly identified

**Phase 11.2** ⚠️ In Progress - Runtime backbone realignment is partially complete:
- ✅ `LiveUi.Component.mount/1` function handles runtime state integration
- ✅ Renderer updated to pass runtime_state to widget components
- ✅ CanonicalScreen updated to pass runtime_state to renderer
- ⚠️ Widget mode tracking has issues - canonical mode not propagating correctly
  through the full render chain in some cases
- ⚠️ Tests written but not yet passing due to mode tracking issues

**Phase 11.3** ✅ Complete - Transitional compatibility surfaces:
- Helper functions identify widget component vs function component modules
- Compatibility wrapper exists for all widget components
- Tests verify the classification is correct

**Phase 11.4** ⚠️ In Progress - Integration tests:
- Tests are written and cover the key scenarios
- Tests will pass once Phase 11.2 mode tracking is resolved
- No additional test scenarios needed

## Known Issues

### Mode Tracking in Canonical Rendering

The widget-key attribute shows "native" mode instead of "canonical" in some render
paths. This is because the widget's LiveComponent update function recreates the
widget_identity when `incoming_assigns[:widget_identity]` is not set.

The mount function passes `widget_identity={widget_identity}` to the LiveComponent,
but there may be an update cycle where the widget_identity is not preserved.

**Resolution**: This requires either:
1. Ensuring widget_identity is always in the socket assigns
2. Modifying the Widget's update function to prioritize the passed widget_identity
3. Using a different mechanism for mode tracking

This is tracked as part of the ongoing Phase 11.2 work.

### Phoenix.HTML.Safe Protocol Errors

Some tests encounter Phoenix.HTML.Safe protocol errors when rendering widgets with
runtime_state. This occurs because the renderer is passing the RuntimeState struct
directly in attributes, which Phoenix doesn't know how to convert to HTML.

**Resolution**: The mount function already handles this by extracting the mode from
runtime_state and passing it separately. The renderer should not include runtime_state
directly in attributes.

## Migration Notes

When migrating from direct widget rendering to widget component boundaries:

1. **Native widgets**: Use `<LiveUi.Widgets.Button.component>` or `<LiveUi.Component.mount>`
2. **Direct render calls**: Continue to work for backward compatibility via the component/1 wrapper
3. **Runtime integration**: Pass runtime_state when mounting screens that need canonical IUR rendering
4. **Event handling**: Widget events will be routed through the shared runtime's event handling

The component/1 function provides a compatibility wrapper that calls the widget LiveComponent,
so existing code using `<LiveUi.Widgets.Button.render>` will continue to work while the
underlying architecture is updated.
