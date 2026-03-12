# Widget Event Specs

This directory defines the widget interaction events that `web_ui` handlers are expected to process.

Scope:

1. Canonical event type names and payload shape conventions.
2. Widget-to-event mappings aligned to the built-in widget catalog.
3. Elm binding guidance for turning DOM/subscription events into typed messages.

## Source Basis

The event model in this directory is derived from:

- Elm `Html.Events` API surface (`onClick`, `onInput`, `onSubmit`, `onFocus`, `onBlur`, custom `on`)  
  [elm/html source](https://github.com/elm/html/blob/1.0.0/src/Html/Events.elm)
- Elm `Browser.Events` subscriptions (`onKeyDown`, `onKeyUp`, `onMouseMove`, `onResize`, `onVisibilityChange`)  
  [elm/browser source](https://github.com/elm/browser/blob/1.0.2/src/Browser/Events.elm)
- Existing signal naming used by `unified-ui` (`unified.button.clicked`, `unified.input.changed`, etc.)  
  [signals.ex](/Users/Pascal/code/unified/unified-ui/lib/unified_ui/signals.ex)
- Existing widget callbacks and interaction behavior in `term_ui` parity widgets  
  `/Users/Pascal/code/unified/term_ui/lib/term_ui/widget` and `/Users/Pascal/code/unified/term_ui/lib/term_ui/widgets`

## Documents

- [event_type_catalog.md](/Users/Pascal/code/unified/web_ui/specs/events/event_type_catalog.md)
- [widget_event_matrix.md](/Users/Pascal/code/unified/web_ui/specs/events/widget_event_matrix.md)
- [elm_binding_examples.md](/Users/Pascal/code/unified/web_ui/specs/events/elm_binding_examples.md)
