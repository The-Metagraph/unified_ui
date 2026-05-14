# TerminalUi Runtime

This subject defines the target runtime behavior of `terminal_ui` as a
`term_ui`-backed terminal library.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [TerminalUi Package](./package.spec.md)
- [TerminalUi Native Widgets](./native_widgets.spec.md)
- [TerminalUi Capabilities](./capabilities.spec.md)
- [TerminalUi Transport](./transport.spec.md)

```spec-meta
id: terminal_ui.runtime
kind: runtime
status: active
summary: Target terminal runtime contract for `terminal_ui`, including backend selection, terminal lifecycle coordination, and shared runtime semantics across richer and limited terminal environments.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
```

## Requirements

```spec-requirements
- id: terminal_ui.runtime.term_ui_foundation
  statement: The terminal runtime shall use a `term_ui`-backed rendering and input foundation while allowing package-local adapter layers to preserve `terminal_ui` package semantics.
  priority: must
  stability: stable

- id: terminal_ui.runtime.shared_runtime_across_backends
  statement: The package shall maintain one coherent terminal runtime model across richer raw-mode execution and TTY-compatible fallback execution even when capability depth differs.
  priority: must
  stability: stable

- id: terminal_ui.runtime.native_and_iur_entrypoints_share_runtime
  statement: The same runtime architecture shall support both direct native `terminal_ui` usage and canonical IUR rendering so the package does not split into unrelated runtime models.
  priority: must
  stability: stable

- id: terminal_ui.runtime.terminal_lifecycle_and_input
  statement: The runtime shall coordinate terminal boot, backend negotiation, resize handling, focus, paste, keyboard and mouse input, redraw scheduling, and terminal restore in a way that preserves canonical terminal UI meaning.
  priority: must
  stability: stable

- id: terminal_ui.runtime.capability_variation_bounded
  statement: Terminal-specific capability differences may vary by backend, terminal emulator, or operating system, but those variations shall remain bounded behind the shared `terminal_ui` runtime model.
  priority: must
  stability: stable

- id: terminal_ui.runtime.canonical_navigation_transition_support
  statement: When canonical navigation interactions are emitted or consumed, the runtime shall map canonical screen-transition actions onto terminal-appropriate screen replacement, bounded history transitions, modal transitions, or section/screen swaps while preserving one shared terminal runtime model.
  priority: must
  stability: stable

- id: terminal_ui.runtime.no_url_routing_assumption
  statement: The terminal runtime shall not require browser-style path syntax, host-router names, or URL-matching semantics as the canonical navigation contract; symbolic screen identifiers and terminal-local transition policies remain the authoritative runtime boundary.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.runtime_run_same_screen_on_multiple_capability_profiles
  covers:
    - terminal_ui.runtime.shared_runtime_across_backends
    - terminal_ui.runtime.capability_variation_bounded
  given:
    - The same native or canonical-IUR-driven screen is launched in richer raw-mode and TTY-compatible terminal environments
  when:
    - `terminal_ui` runs the screen
  then:
    - The package preserves one runtime model and one canonical UI meaning while allowing bounded capability-driven degradation underneath

- id: terminal_ui.runtime_handle_canonical_navigation_transition
  covers:
    - terminal_ui.runtime.canonical_navigation_transition_support
    - terminal_ui.runtime.no_url_routing_assumption
  given:
    - A native or canonical terminal screen emits a canonical navigation transition such as screen replacement, history traversal, or modal open/close
  when:
    - `terminal_ui` resolves the transition
  then:
    - The runtime updates terminal screen state through symbolic screen resolution and bounded terminal transition policies without introducing browser-route semantics
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/runtime.spec.md
  covers:
    - terminal_ui.runtime.term_ui_foundation
    - terminal_ui.runtime.shared_runtime_across_backends
    - terminal_ui.runtime.native_and_iur_entrypoints_share_runtime
    - terminal_ui.runtime.terminal_lifecycle_and_input
    - terminal_ui.runtime.capability_variation_bounded
    - terminal_ui.runtime.canonical_navigation_transition_support
    - terminal_ui.runtime.no_url_routing_assumption
    - terminal_ui.runtime_run_same_screen_on_multiple_capability_profiles
    - terminal_ui.runtime_handle_canonical_navigation_transition
```
