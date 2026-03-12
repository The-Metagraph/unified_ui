# Feature: Extract Unified IUR Package

**Date Started:** 2025-02-10
**Date Completed:** 2025-02-10
**Branch:** `feature/extract-unified_iur-package`
**Status:** Completed

---

## Problem Statement

The Intermediate UI Representation (IUR) is currently embedded within the `unified_ui` project. This creates several problems:

1. **Tight Coupling**: Platform libraries (TermUi, DesktopUi, WebUi) must depend on the full unified_ui package just to use IUR structs
2. **Versioning Constraints**: IUR changes require bumping unified_ui version even when no DSL changes occur
3. **Circular Dependency Risk**: unified_ui depends on platform libraries (via mix deps), but platforms may want to depend on IUR
4. **Limited Reusability**: IUR as a pure data layer could be used independently by other projects that don't need the unified_ui DSL
5. **Unclear Separation**: The boundary between "pure data representation" and "DSL/build logic" is unclear

---

## Solution Overview

Extract IUR into a standalone `unified_iur` package that:

1. Contains ONLY the pure data representation (structs and protocols)
2. Has ZERO runtime dependencies on unified_ui, Spark, or platform libraries
3. Can be independently versioned following Semantic Versioning
4. Is consumed by unified_ui as a dependency
5. Can be optionally consumed by platform libraries

**Key Decision**: The `IUR.Builder` module will NOT be extracted - it is DSL concern and belongs in unified_ui.

---

## Agent Consultations Performed

This planning document was created based on thorough codebase exploration without requiring additional expert consultations at this planning stage. Expert consultation (elixir-expert, architecture-agent) is recommended during implementation.

---

## Technical Details

### Current IUR Structure

```
lib/unified_ui/iur/
├── element.ex           (7,873 bytes) - Protocol + all implementations
├── widgets.ex           (15,966 bytes) - 10 widget structs
├── layouts.ex           (6,219 bytes) - VBox, HBox structs
├── styles.ex            (5,034 bytes) - Style struct + merge functions
├── element_helpers.ex   (2,690 bytes) - Helper functions
└── builder.ex           (10,866 bytes) - DSL-to-IUR converter (NOT extracted)
```

### Files to Move to unified_iur

| Source | Target | Purpose |
|--------|--------|---------|
| `lib/unified_ui/iur/element.ex` | `lib/unified_iur/element.ex` | Protocol + implementations |
| `lib/unified_ui/iur/widgets.ex` | `lib/unified_iur/widgets.ex` | Widget structs |
| `lib/unified_ui/iur/layouts.ex` | `lib/unified_iur/layouts.ex` | Layout structs |
| `lib/unified_ui/iur/styles.ex` | `lib/unified_iur/styles.ex` | Style struct |
| `lib/unified_ui/iur/element_helpers.ex` | `lib/unified_iur/element_helpers.ex` | Helpers |
| `test/unified_ui/iur/*` | `test/unified_iur/*` | Test files |

### Files to Keep in unified_ui

| File | Reason |
|------|--------|
| `lib/unified_ui/iur/builder.ex` | DSL concern, depends on Spark |
| `lib/unified_ui/iur/.keep` | Directory placeholder |

### Module Name Changes

| Old Module | New Module |
|------------|------------|
| `UnifiedUi.IUR.Element` | `UnifiedIUR.Element` |
| `UnifiedUi.IUR.Widgets` | `UnifiedIUR.Widgets` |
| `UnifiedUi.IUR.Layouts` | `UnifiedIUR.Layouts` |
| `UnifiedUi.IUR.Style` | `UnifiedIUR.Style` |
| `UnifiedUi.IUR.ElementHelpers` | `UnifiedIUR.ElementHelpers` |

### Dependencies Analysis

**unified_iur will have:**
- Zero runtime dependencies
- Only dev/test dependencies (ex_unit, etc.)

**unified_ui will depend on:**
- `unified_iur` (new dependency)
- All other existing dependencies (spark, jido, etc.)

### Protocol Handling

The Element protocol presents unique challenges:
1. Protocol definition is in `element.ex`
2. All `defimpl` blocks are in the same file
3. Implementations reference `ElementHelpers`

**Solution**: Move the entire `element.ex` file to unified_iur. The protocol and all implementations will be in one package.

---

## Success Criteria

1. unified_iur package compiles independently with no dependencies
2. All existing tests pass after module renames
3. unified_ui compiles and depends on unified_iur
4. No circular dependencies exist
5. Documentation reflects new package structure
6. Backward compatibility aliases work (if needed)
7. Mix release/publish workflow works for unified_iur

---

## Implementation Plan

### Step 1: Create unified_iur Package Structure

1. Create new repository at `/home/ducky/code/elixir-ui/unified_iur`
2. Initialize with `mix new unified_iur`
3. Create directory structure
4. Set up basic mix.exs

### Step 2: Move and Adapt Core Files

5. Copy and adapt element.ex
6. Copy and adapt widgets.ex
7. Copy and adapt layouts.ex
8. Copy and adapt styles.ex
9. Copy and adapt element_helpers.ex
10. Update all internal references and module names

### Step 3: Update unified_ui

11. Add unified_iur dependency to mix.exs
12. Update all references to use UnifiedIUR.* modules
13. Move/rename IUR.Builder to stay in unified_ui
14. Update IUR.Builder to use UnifiedIUR.* modules
15. Remove old IUR directory files
16. Fix any broken references

### Step 4: Testing and Verification

17. Run unified_iur tests standalone
18. Run unified_ui tests with dependency
19. Update documentation
20. Verify no circular dependencies

---

## Notes/Considerations

### Implementation Summary

**Completed:**
- Created `unified_iur` package at `/home/ducky/code/elixir-ui/unified_iur`
- Moved all pure IUR data structures (element.ex, widgets.ex, layouts.ex, styles.ex, element_helpers.ex) to the new package
- Updated all module names from `UnifiedUi.IUR.*` to `UnifiedIUR.*`
- Kept `IUR.Builder` in `unified_ui` (DSL concern, depends on Spark)
- Updated `unified_ui` to depend on `unified_iur` via path dependency
- All 1148 tests pass

**Files Moved:**
- `lib/unified_ui/iur/element.ex` → `lib/unified_iur/element.ex`
- `lib/unified_ui/iur/widgets.ex` → `lib/unified_iur/widgets.ex`
- `lib/unified_ui/iur/layouts.ex` → `lib/unified_iur/layouts.ex`
- `lib/unified_ui/iur/styles.ex` → `lib/unified_iur/style.ex`
- `lib/unified_ui/iur/element_helpers.ex` → `lib/unified_iur/element_helpers.ex`

**Files Kept in unified_ui:**
- `lib/unified_ui/iur/builder.ex` - DSL concern, depends on Spark
- `lib/unified_ui/iur/.keep` - Directory placeholder

### Versioning Strategy

- unified_iur: Start at 0.1.0
- unified_ui: Bump to 0.2.0 (minor version for dependency change)

### Testing Strategy

1. First verify unified_iur tests pass standalone
2. Then verify unified_ui tests pass with dependency
3. Run integration tests to verify rendering pipeline

### Future Considerations

1. Platform libraries (term_ui, desktop_ui, web_ui) can optionally depend on unified_iur
2. Other projects could use unified_iur for their own UI representations
3. unified_iur could add JSON serialization for cross-language support
