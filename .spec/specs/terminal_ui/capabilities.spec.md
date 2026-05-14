# TerminalUi Capabilities

This subject defines how `terminal_ui` detects terminal capabilities, selects
backend behavior, and degrades visual or interaction behavior while preserving
canonical meaning.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [TerminalUi Package](./package.spec.md)
- [TerminalUi Runtime](./runtime.spec.md)
- [TerminalUi Native Widgets](./native_widgets.spec.md)
- [TerminalUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: terminal_ui.capabilities
kind: subsystem
status: active
summary: Target contract for capability detection, backend fallback, visual degradation, and interaction alternatives in `terminal_ui`.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/capabilities.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: terminal_ui.capabilities.detect_terminal_capabilities
  statement: The package shall detect and summarize terminal capabilities such as backend availability, color depth, Unicode support, mouse support, paste handling, resize behavior, and terminal dimensions before runtime realization depends on them.
  priority: must
  stability: stable

- id: terminal_ui.capabilities.backend_selection_and_fallback
  statement: The package shall select richer or limited terminal backends explicitly and allow deterministic fallback when raw-mode features are unavailable or intentionally disabled.
  priority: must
  stability: stable

- id: terminal_ui.capabilities.visual_degradation_policy
  statement: Canonical styling, characters, and visualization meaning shall degrade through explicit terminal-native policies for Unicode-to-ASCII and color-depth reduction rather than through accidental renderer loss.
  priority: must
  stability: stable

- id: terminal_ui.capabilities.interaction_alternatives_for_limited_backends
  statement: Mouse-dependent or positional features shall provide keyboard-first or inline alternatives whenever limited terminal capabilities prevent full interaction behavior.
  priority: must
  stability: stable

- id: terminal_ui.capabilities.capability_reporting_surface
  statement: The package shall expose inspectable capability and degradation summaries so native users and maintainers can see which runtime assumptions are active.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.capabilities_render_same_intent_on_rich_and_limited_terminals
  covers:
    - terminal_ui.capabilities.detect_terminal_capabilities
    - terminal_ui.capabilities.backend_selection_and_fallback
    - terminal_ui.capabilities.visual_degradation_policy
    - terminal_ui.capabilities.interaction_alternatives_for_limited_backends
    - terminal_ui.capabilities.capability_reporting_surface
  given:
    - The same direct-native or canonical screen is rendered in a rich terminal and a limited terminal
  when:
    - `terminal_ui` realizes the screen
  then:
    - The package detects the capability difference, applies explicit degradation or interaction alternatives, and preserves the same core screen intent
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/capabilities.spec.md
  covers:
    - terminal_ui.capabilities.detect_terminal_capabilities
    - terminal_ui.capabilities.backend_selection_and_fallback
    - terminal_ui.capabilities.visual_degradation_policy
    - terminal_ui.capabilities.interaction_alternatives_for_limited_backends
    - terminal_ui.capabilities.capability_reporting_surface
    - terminal_ui.capabilities_render_same_intent_on_rich_and_limited_terminals
```
