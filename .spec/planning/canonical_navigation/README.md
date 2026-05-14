# Canonical Navigation Planning

This directory contains the phased implementation plan for canonical navigation
control across `UnifiedUi`, `UnifiedIUR`, shared signal transport, and runtime
package consumers.

## Phase Files

1. [Phase 1 - UnifiedUi Authored Navigation Surface and Descriptor Backbone](./phase-01-unified-ui-authored-navigation-surface-and-descriptor-backbone.md): implement and validate authored navigation intent, including stack-based modal authoring semantics.
2. [Phase 2 - Compiler, UnifiedIUR, and Signal Transport Alignment](./phase-02-compiler-unified-iur-and-signal-transport-alignment.md): lower authored navigation into canonical IUR descriptors and shared boundary fixtures, including modal stack transition fixtures.
3. [Phase 3 - Runtime Modal Stack Navigation Alignment](./phase-03-runtime-modal-stack-navigation-alignment.md): align `live_ui`, `elm_ui`, `desktop_ui`, and `terminal_ui` with the new canonical modal stack behavior.

## Numbering

- Phases: `N`
- Sections: `N.M`
- Tasks: `N.M.K`
- Subtasks: `N.M.K.L`

Every phase, section, task, and subtask uses Markdown checkboxes. Every phase,
section, and task starts with a short description paragraph. Each phase ends
with an integration-testing section.
