# Feature: Phase 1.2 - Spark DSL Extension Module

## Problem Statement

The UnifiedUi library requires a core Spark DSL Extension module to serve as the foundation for the declarative UI DSL. This extension will aggregate all DSL entities, sections, transformers, and verifiers into a cohesive DSL that developers can use to define multi-platform user interfaces. Without this extension, there is no foundation for building the DSL constructs.

## Solution Overview

Create the core Spark.Dsl.Extension module following Spark's established patterns. The extension will define:
- A top-level `:ui` section for UI definitions
- A `:widgets` section for widget entity definitions
- A `:layouts` section for layout entity definitions
- A `:styles` section for style and theme definitions
- A `:signals` section for signal type definitions

Each section will have properly configured entity and section imports to allow for nested DSL constructs.

## Agent Consultations Performed

- **research-agent**: Reviewed Spark DSL patterns from the research document (`notes/research/spark-dsl.md`)
- **elixir-expert**: Consulted for Elixir/Spark best practices for extension modules

## Technical Details

### Location
- **Primary file**: `unified_ui/lib/unified_ui/dsl/extension.ex`
- **Test file**: `unified_ui/test/unified_ui/dsl/extension_test.exs`
- **Section modules**: `unified_ui/lib/unified_ui/dsl/sections/`

### Spark Extension Pattern

Based on the research, the extension module follows this pattern:

```elixir
defmodule UnifiedUi.Dsl.Extension do
  use Spark.Dsl.Extension,
    sections: [
      # List of Spark.Dsl.Section structs
    ],
    transformers: [
      # List of transformer modules
    ],
    verifiers: [
      # List of verifier modules
    ]
end
```

### Sections to Define

1. **`:ui`** - Top-level section for UI definitions
   - Nested: widgets, layouts, styles
   - Options: id, theme

2. **`:widgets`** - Widget entity definitions
   - Entities (placeholder for now): text, button, label, text_input
   - No nesting initially

3. **`:layouts`** - Layout entity definitions
   - Entities (placeholder for now): vbox, hbox, grid
   - Can contain widgets and other layouts

4. **`:styles`** - Style and theme definitions
   - Style configuration entities
   - Theme definitions

5. **`:signals`** - Signal type definitions
   - Standard signal types
   - Custom signal definitions

### File Structure

```
lib/unified_ui/dsl/
├── extension.ex           # Main Spark.Dsl.Extension
├── sections/
│   ├── ui.ex             # UI section definition
│   ├── widgets.ex        # Widgets section definition
│   ├── layouts.ex        # Layouts section definition
│   ├── styles.ex         # Styles section definition
│   └── signals.ex        # Signals section definition
└── entities/
    └── (future: widget, layout, style entities)
```

### Dependencies

- `{:spark, "~> 1.0"}` - Already added in Phase 1.1

## Success Criteria

1. [x] Extension module compiles without errors
2. [x] All sections are properly registered
3. [x] Section imports work correctly (nested DSL)
4. [x] Entity imports work correctly
5. [x] Tests verify extension structure (24 tests pass)
6. [x] Documentation (@moduledoc) with usage examples

## Implementation Plan

### Step 1: Create Basic Extension Module
- [x] Create `lib/unified_ui/dsl/extension.ex`
- [x] Add `use Spark.Dsl.Extension` with empty sections list
- [x] Add @moduledoc with usage examples

### Step 2: Create UI Section
- [x] Create `lib/unified_ui/dsl/sections/ui.ex`
- [x] Define `@ui_section` with schema for top-level UI options
- [x] Configure nested entities for widgets, layouts

### Step 3: Create Widgets Section
- [x] Create `lib/unified_ui/dsl/sections/widgets.ex`
- [x] Define `@widgets_section` with empty entities list (placeholder)
- [x] Configure for future widget entities

### Step 4: Create Layouts Section
- [x] Create `lib/unified_ui/dsl/sections/layouts.ex`
- [x] Define `@layouts_section` with empty entities list (placeholder)
- [x] Configure for future layout entities

### Step 5: Create Styles Section
- [x] Create `lib/unified_ui/dsl/sections/styles.ex`
- [x] Define `@styles_section` with style schema options
- [x] Add style attribute definitions

### Step 6: Create Signals Section
- [x] Create `lib/unified_ui/dsl/sections/signals.ex`
- [x] Define `@signals_section` for signal definitions
- [x] Add standard signal type placeholders

### Step 7: Assemble Extension
- [x] Import all sections into main extension module
- [x] Configure `@sections` list
- [x] Set up entity imports for nesting

### Step 8: Create Tests
- [x] Create `test/unified_ui/dsl/extension_test.exs`
- [x] Test extension compiles without errors
- [x] Test sections are properly registered
- [x] Verify structure with Spark functions

## Status

**Current**: ✅ Complete - All implementation steps finished

**Next**: Write summary and request permission to merge

---

## Implementation Log

### 2025-02-04 - Initial Planning
- Feature planning document created
- Branch created: `feature/phase-1.2-dsl-extension`
- Researched Spark DSL patterns from existing research document
- Ready to begin implementation

### 2025-02-04 - Implementation
- Created main extension module at `lib/unified_ui/dsl/extension.ex`
- Created DSL module at `lib/unified_ui/dsl.ex`
- Created initial section modules in `lib/unified_ui/dsl/sections/`:
  - `ui.ex` - Top-level UI section
  - `widgets.ex` - Widget section placeholder
  - `layouts.ex` - Layout section placeholder
  - `styles.ex` - Style attributes (fg, bg, attrs, padding, margin, width, height, align, spacing)
  - `signals.ex` - Signal type definitions
- Created test file at `test/unified_ui/dsl/extension_test.exs`

### 2025-02-04 - Refactoring
- **Important**: Discovered that Spark expects sections as module attributes in the extension module itself, not as separate modules
- Refactored `extension.ex` to define all sections as module attributes (@ui_section, @widgets_section, etc.)
- Consolidated section definitions directly in the extension module
- Updated `dsl.ex` to include `standard_signals/0` helper function
- Simplified tests to work with the new structure
- All 24 tests pass

## Files Created/Modified

### Created
- `lib/unified_ui/dsl/extension.ex` - Main Spark.Dsl.Extension with all sections
- `lib/unified_ui/dsl.ex` - Main DSL module with __using__ macro
- `lib/unified_ui/dsl/sections/ui.ex` - UI section documentation
- `lib/unified_ui/dsl/sections/widgets.ex` - Widget section documentation
- `lib/unified_ui/dsl/sections/layouts.ex` - Layout section documentation
- `lib/unified_ui/dsl/sections/styles.ex` - Style attributes section
- `lib/unified_ui/dsl/sections/signals.ex` - Signals section documentation
- `test/unified_ui/dsl/extension_test.exs` - Comprehensive tests

## Architecture Notes

The final implementation follows Spark's pattern of defining sections as module attributes within the extension module itself:

```elixir
@ui_section %Spark.Dsl.Section{
  name: :ui,
  describe: "...",
  schema: [...],
  entities: [...]
}

use Spark.Dsl.Extension, sections: [@ui_section, @widgets_section, ...]
```

This is the correct approach as documented in [Spark.Dsl.Extension documentation](https://hexdocs.pm/spark/Spark.Dsl.Extension.html).
