# Phase 2.9: DSL Module - Feature Planning

**Date:** 2025-02-07
**Branch:** `feature/phase-2.9-dsl-module`
**Status:** ✅ Complete

## Problem Statement

The UnifiedUi DSL has all the necessary entities, sections, transformers, and verifiers defined, but there is no convenient entry point module for users. Developers currently need to manually configure Spark.Dsl with the UnifiedUi extension, which is cumbersome and not user-friendly.

## Solution Overview

Created a primary `UnifiedUi.Dsl` module that developers use to define their UI components. This module:
1. Uses `Spark.Dsl` with the UnifiedUi.Extension
2. Provides comprehensive documentation with examples
3. Follows the **Reactor pattern** - using `top_level?: true` for the UI section

## Technical Details

### Files Created/Modified

- **`lib/unified_ui/dsl/dsl.ex`** - Enhanced with comprehensive documentation (~287 lines)
- **`lib/unified_ui/dsl/extension.ex`** - Added widget/layout entities to UI section, `top_level?: true`
- **`lib/unified_ui/dsl/sections/ui.ex`** - `top_level?` function returns `true`
- **`test/unified_ui/dsl_test.exs`** - Created with working tests

### Key Discovery: Reactor Pattern

After investigating the Reactor library (https://github.com/ash-project/reactor), we discovered the correct pattern for Spark DSL usage:

1. **Top-Level Sections**: Reactor uses `top_level?: true` for its main section
2. **No Wrapper Macro**: Users write entities directly in the module body (no `reactor do...end` wrapper)
3. **Direct Entity Imports**: The `prepare` function imports entity macros directly into user modules

### Why Our Initial Approach Failed

With `top_level?: false`, Spark DSL's `prepare` function expects the section macro to be exported from the Extension module. However, Spark DSL doesn't properly export section macros for non-top-level sections, making them unimportable.

With `top_level?: true`, the section macro is NOT used - entities are imported directly instead.

## DSL Pattern (Following Reactor)

### Old (Broken) Pattern:
```elixir
defmodule MyApp.MyScreen do
  use UnifiedUi.Dsl

  ui do              # ❌ This doesn't work
    vbox do
      text "Hello"
    end
  end
end
```

### New (Working) Pattern:
```elixir
defmodule MyApp.MyScreen do
  @behaviour UnifiedUi.ElmArchitecture
  use UnifiedUi.Dsl

  vbox do            # ✅ Entities written directly
    text "Hello"
  end
end
```

## What Was Accomplished

1. ✅ Created feature branch
2. ✅ Created planning document
3. ✅ Enhanced `UnifiedUi.Dsl` module with comprehensive documentation
4. ✅ Added widget/layout entities (vbox, hbox, text, button, label, text_input) to UI section
5. ✅ Set `top_level?: true` on UI section (following Reactor pattern)
6. ✅ Extension properly configured with all sections, transformers, and verifiers
7. ✅ Investigated Reactor library to understand correct Spark DSL usage
8. ✅ All 570 tests passing

## Current State

The DSL infrastructure is fully functional:
- Extension defines all sections (ui, widgets, layouts, styles, signals)
- UI section contains all widget and layout entities with `top_level?: true`
- Transformers generate init/update/view functions
- Verifiers validate DSL state
- Comprehensive documentation with examples
- All 570 tests passing

## Implementation Status

- [x] Create feature branch
- [x] Create planning document
- [x] Enhance DSL module documentation
- [x] Add entities to UI section
- [x] Set top_level? to true
- [x] Investigate Reactor library for correct pattern
- [x] Fix section macro issue using top-level pattern
- [x] Write comprehensive tests
- [x] Verify all tests pass (570 tests, 0 failures)
- [x] Write summary

## Notes/Considerations

1. **Reactor Pattern**: The key insight was that Reactor uses `top_level?: true` and doesn't require a section macro wrapper. This is the correct pattern for Spark DSL.

2. **User Experience**: The new pattern is actually cleaner - users don't need to wrap their UI in `ui do...end`.

3. **Documentation Quality**: Comprehensive documentation has been added with examples showing the correct usage pattern.

4. **Future Expansion**: This DSL module is now the foundation for all future widget and layout additions.
