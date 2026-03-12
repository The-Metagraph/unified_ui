# Phase 2.2: Basic Layout Entities

**Branch:** `feature/phase-2.2-basic-layout-entities`
**Created:** 2025-02-05
**Status:** In Progress

## Overview

This section implements the foundational layout containers (VBox and HBox) that allow arranging widgets and other layouts in vertical and horizontal patterns. These are the building blocks for creating complex UI structures.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.2:

### Task 2.2: Define Spark.Dsl.Entity structs for basic layout containers

Create entity definitions for the foundational layout containers: vbox (vertical box) and hbox (horizontal box).

## Implementation Plan

### 2.2.1 Create `lib/unified_ui/dsl/entities/layouts.ex`
- [ ] Create new layouts entities module
- [ ] Follow same pattern as widgets.ex from Phase 2.1

### 2.2.2 Define `vbox_entity` with schema
- [ ] args: `[:children]` - Note: need to handle `do` block for children
- [ ] options:
  - `id` - Unique identifier (atom, optional)
  - `spacing` - Space between children (integer, default: 0)
  - `padding` - Internal padding (integer, optional)
  - `align_items` - Cross-axis alignment (:start, :center, :end, :stretch)
  - `justify_content` - Main-axis alignment (:start, :center, :end, :space_between, :space_around)
  - `style` - Inline style (keyword list, optional)
  - `visible` - Whether layout is visible (boolean, default: true)

### 2.2.3 Define `hbox_entity` with schema
- [ ] args: `[:children]` - Note: need to handle `do` block for children
- [ ] options: Same as vbox

### 2.2.4 Create corresponding IUR structs
- [ ] `UnifiedUi.IUR.Layouts.VBox` - Already exists, need to verify/extend
- [ ] `UnifiedUi.IUR.Layouts.HBox` - Already exists, need to verify/extend

### 2.2.5 Define alignment values
- [ ] align_items: `:start`, `:center`, `:end`, `:stretch`
- [ ] justify_content: `:start`, `:center`, `:end`, `:space_between`, `:space_around`

### 2.2.6 Add comprehensive `@doc` strings with examples

## Design Decisions

### Children Handling
Unlike widgets which have specific args, layouts need to handle children via `do` blocks. This requires:
- No positional args (empty list or special handling)
- `entities` list in the entity definition
- Spark will handle the `do` block parsing

### Alignment Semantics
- For VBox (vertical layout):
  - `align_items` controls horizontal alignment of children
  - `justify_content` controls vertical distribution

- For HBox (horizontal layout):
  - `align_items` controls vertical alignment of children
  - `justify_content` controls horizontal distribution

### Existing IUR Structs
The VBox and HBox IUR structs already exist in `lib/unified_ui/iur/layouts.ex`:
- They have `children`, `spacing`, `align`, `id` fields
- Need to verify if we need to add `padding`, `justify_content`, `style`, `visible`

## Files to Create/Modify

### New Files
- `lib/unified_ui/dsl/entities/layouts.ex` - Layout entity definitions
- `test/unified_ui/dsl/entities/layouts_test.exs` - Layout entity tests

### Files to Check/Modify
- `lib/unified_ui/iur/layouts.ex` - Verify existing structs have all needed fields
- `lib/unified_ui/dsl/extension.ex` - Register layout entities
- `test/unified_ui/iur/iur_test.exs` - May need additional layout tests

## Dependencies

- Depends on Phase 1: Foundation (DSL structure, IUR)
- Depends on Phase 2.1: Basic Widget Entities (widgets to place in layouts)
- Enables Phase 2.5: IUR Tree Building (layouts to build trees from)

## Unit Tests Checklist

From planning document:
- [ ] Test vbox entity with children list
- [ ] Test hbox entity with children list
- [ ] Test vbox with nested layouts
- [ ] Test hbox with nested layouts
- [ ] Test spacing option
- [ ] Test padding option (if added)
- [ ] Test align_items option with all valid values
- [ ] Test justify_content option with all valid values
- [ ] Test invalid align_items value raises error
- [ ] Verify target structs store children correctly

## Progress

### Current Status
- ✅ Planning document created
- ⏳ Ready to start implementation

### Next Steps
1. Check existing IUR layout structs
2. Add missing fields if needed
3. Create layout entities module
4. Register entities in DSL extension
5. Create tests

## Notes

### Questions for Developer
1. Should we add `padding` field to IUR layout structs? (Not currently present)
2. Should we add `justify_content` field? (Currently only have `align`)
3. How should children be handled in the entity - as args or via entities list?

### Technical Considerations
- Spark.Dsl.Entity supports nested entities via the `entities` list
- Children are likely entities within the layout entity
- Need to check Spark documentation for pattern on container entities

## References

- Phase 2.1 Implementation: `notes/features/phase-2.1-basic-widget-entities.md`
- Phase 2 Planning: `notes/planning/phase-02.md`
- Spark Docs: Check for nested entity patterns
