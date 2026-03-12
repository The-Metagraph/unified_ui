# Documentation

Current documentation and example maintenance contract for UnifiedUi.

```spec-meta
id: unified_ui.documentation
kind: workflow
status: active
summary: Guide set, API docs, example coverage, and cross-reference integrity for UnifiedUi documentation.
surface:
  - README.md
  - guides/getting-started.md
  - guides/dsl-reference.md
  - guides/layout-system.md
  - guides/widget-reference.md
  - guides/styling-and-theming.md
  - guides/signals-and-events.md
  - guides/extensions.md
  - guides/platform-guides.md
  - guides/platforms/*.md
  - guides/dashboard-tutorial.md
  - guides/troubleshooting.md
  - examples/custom_widget/README.md
```

## Requirements

```spec-requirements
- id: unified_ui.documentation.guide_set
  statement: The repository shall ship current guides for getting started, DSL usage, layouts, widgets, styling, signals, extensions, platform adapters, dashboard tutorial, and troubleshooting.
  priority: must
  stability: evolving

- id: unified_ui.documentation.guide_cross_references
  statement: Markdown links and anchors inside the guide set shall resolve to existing files and headings.
  priority: must
  stability: stable

- id: unified_ui.documentation.guide_examples_compile
  statement: Elixir code examples in guides shall compile against the current library surface.
  priority: must
  stability: evolving

- id: unified_ui.documentation.api_docs
  statement: Application modules and public APIs shall provide docs, and the selected doctest surface shall execute successfully.
  priority: must
  stability: stable

- id: unified_ui.documentation.extension_example
  statement: The shipped custom widget example shall remain consistent with the extension guidance and continue compiling as an executable example.
  priority: should
  stability: evolving
```

## Verification

```spec-verification
- kind: readme_file
  target: README.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/getting-started.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/dsl-reference.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/layout-system.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/widget-reference.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/styling-and-theming.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/signals-and-events.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/extensions.md
  covers:
    - unified_ui.documentation.guide_set
    - unified_ui.documentation.extension_example

- kind: guide_file
  target: guides/platform-guides.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/platforms/terminal.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/platforms/desktop.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/platforms/web.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/dashboard-tutorial.md
  covers:
    - unified_ui.documentation.guide_set

- kind: guide_file
  target: guides/troubleshooting.md
  covers:
    - unified_ui.documentation.guide_set

- kind: file
  target: examples/custom_widget/README.md
  covers:
    - unified_ui.documentation.extension_example

- kind: test_file
  target: test/unified_ui/docs_compliance_test.exs
  covers:
    - unified_ui.documentation.api_docs

- kind: test_file
  target: test/unified_ui/documentation_examples_test.exs
  covers:
    - unified_ui.documentation.api_docs

- kind: test_file
  target: test/unified_ui/guides_cross_reference_test.exs
  covers:
    - unified_ui.documentation.guide_cross_references

- kind: test_file
  target: test/unified_ui/guides_examples_compile_test.exs
  covers:
    - unified_ui.documentation.guide_examples_compile

- kind: test_file
  target: test/unified_ui/guides_dashboard_tutorial_test.exs
  covers:
    - unified_ui.documentation.guide_set

- kind: test_file
  target: test/unified_ui/guides_extensions_guide_test.exs
  covers:
    - unified_ui.documentation.extension_example

- kind: test_file
  target: test/unified_ui/examples/custom_widget_extension_test.exs
  covers:
    - unified_ui.documentation.extension_example

- kind: command
  target: mix test test/unified_ui/docs_compliance_test.exs test/unified_ui/documentation_examples_test.exs test/unified_ui/guides_cross_reference_test.exs test/unified_ui/guides_examples_compile_test.exs test/unified_ui/guides_dashboard_tutorial_test.exs test/unified_ui/guides_extensions_guide_test.exs test/unified_ui/examples/custom_widget_extension_test.exs
  execute: true
  covers:
    - unified_ui.documentation.guide_set
    - unified_ui.documentation.guide_cross_references
    - unified_ui.documentation.guide_examples_compile
    - unified_ui.documentation.api_docs
    - unified_ui.documentation.extension_example
```
