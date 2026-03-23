# Styling, Capabilities, And Inspection

`terminal_ui` keeps terminal styling and degradation explicit so maintainers can
see how a rich-terminal and fallback-terminal realization differ without losing
the core screen meaning.

## Styling And Themes

- `TerminalUi.Style` defines styling primitives and widget hooks
- `TerminalUi.Theme` defines theme catalogs and continuity rules
- `TerminalUi.Runtime.StyleResolver` applies those decisions during realization
- `TerminalUi.Continuity` compares native and canonical styled output through
  one diagnostic model

## Capability Profiles

`TerminalUi.Capabilities` and `TerminalUi.Degradation` expose two main profiles:

- `:rich_terminal`
  - Unicode, richer color, mouse, positioned canvas, layered presentation
- `:fallback_terminal`
  - ASCII fallback, limited color, keyboard-first alternatives, inline overlay
    and paged-scroll behavior

The package treats those differences as explicit bounded variation, not
accidental loss.

## Inspection Surface

Use these helpers during package work:

- `TerminalUi.Inspection.package_overview/0`
- `TerminalUi.Inspection.runtime_snapshot/1`
- `TerminalUi.Inspect.preview/1`
- `TerminalUi.Reference.capability_summary/0`
- `TerminalUi.Validate.capability_behavior/0`

These surfaces make it easier to review widget coverage, theme resolution,
transport mappings, and fallback decisions together.

## Recommended Review Commands

- `mix terminal_ui.inspect native_styled_review --format diagnostics`
- `mix terminal_ui.inspect styled_continuity_review --format comparison`
- `mix terminal_ui.inspect styled_degradation_review --format comparison`
- `mix terminal_ui.validate --format report`
