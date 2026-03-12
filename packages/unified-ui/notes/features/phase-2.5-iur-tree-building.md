# Phase 2.5: IUR Tree Building

**Branch:** `feature/phase-2.5-iur-tree-building`
**Created:** 2025-02-06
**Status:** Completed

## Overview

This section implements the IUR (Intermediate UI Representation) tree builder that traverses the DSL definition and builds the corresponding IUR tree. This enables the view/1 function to return a proper UI tree instead of an empty container.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.5:

### Task 2.5: Implement IUR tree building from DSL definitions

Create the system that traverses the DSL definition and builds the corresponding IUR tree.

## Implementation Plan

### 2.5.1 Create `lib/unified_ui/iur/builder.ex`
- [x] Create UnifiedUi.IUR.Builder module
- [x] Implement build/1 function that accepts DSL state
- [x] Set up entity extraction from DSL sections

### 2.5.2 Implement `build/1` function that traverses DSL state
- [x] Extract entities from [:ui] section of DSL
- [x] Determine root entity (usually a layout)
- [x] Call appropriate build function based on entity type

### 2.5.3 Implement widget-to-IUR conversion for all basic widgets
- [x] build_button/1 - Convert button entity to IUR.Button
- [x] build_text/1 - Convert text entity to IUR.Text
- [x] build_label/1 - Convert label entity to IUR.Label
- [x] build_text_input/1 - Convert text_input entity to IUR.TextInput

### 2.5.4 Implement layout-to-IUR conversion for all basic layouts
- [x] build_vbox/2 - Convert vbox entity to IUR.VBox
- [x] build_hbox/2 - Convert hbox entity to IUR.HBox
- [x] Recursively build children

### 2.5.5 Handle nested structures recursively
- [x] Process children lists for layouts
- [x] Handle arbitrary nesting depth
- [x] Preserve entity structure in IUR tree

### 2.5.6 Apply style resolution during build
- [x] Convert inline style keyword lists to IUR.Style structs
- [x] Set style field on IUR elements
- [x] Handle nil styles

### 2.5.7 Validate IUR tree structure
- [x] Ensure required fields are present
- [x] Validate children lists
- [x] Check for nil values where required

### 2.5.8 Update view_transformer to use builder
- [x] Import UnifiedUi.IUR.Builder
- [x] Call Builder.build(dsl_state) instead of empty VBox
- [x] Return built IUR tree from view/1

## Design Decisions

### Builder Architecture

The builder module will:
1. Accept a Spark DSL state (from the view transformer context)
2. Extract entities from the `[:ui]` section
3. Convert each entity to its corresponding IUR struct
4. Recursively process nested layouts
5. Return the root IUR element (typically a layout)

### Entity-to-IUR Mapping

| DSL Entity | Target Struct | Module |
|------------|---------------|--------|
| button | Widgets.Button | UnifiedUi.IUR.Widgets.Button |
| text | Widgets.Text | UnifiedUi.IUR.Widgets.Text |
| label | Widgets.Label | UnifiedUi.IUR.Widgets.Label |
| text_input | Widgets.TextInput | UnifiedUi.IUR.Widgets.TextInput |
| vbox | Layouts.VBox | UnifiedUi.IUR.Layouts.VBox |
| hbox | Layouts.HBox | UnifiedUi.IUR.Layouts.HBox |

### Style Handling

Inline styles (keyword lists) from DSL entities will be converted to IUR.Style structs during the build process. This happens in the builder via a helper function.

## Files to Create

### New Files
- `lib/unified_ui/iur/builder.ex` - Main builder module
- `test/unified_ui/iur/builder_test.exs` - Builder tests

### Files to Modify
- `lib/unified_ui/dsl/transformers/view_transformer.ex` - Use builder in generated view/1
- `test/unified_ui/dsl/transformers/view_transformer_test.exs` - Update for new behavior

## Dependencies

- Depends on Phase 1: Foundation (IUR structs defined)
- Depends on Phase 2.1: Basic Widget Entities (widget DSL entities)
- Depends on Phase 2.2: Basic Layout Entities (layout DSL entities)
- Enables Phase 2.3: Full state interpolation (now IUR tree exists)

## Test Checklist

From planning document:
- [ ] Test build creates correct IUR for single widget
- [ ] Test build creates correct IUR for nested layouts
- [ ] Test build handles deeply nested structures
- [ ] Test build applies styles correctly
- [ ] Test build validates structure

## Progress

### Current Status
- ✅ Planning document created
- ⏳ Understanding existing IUR and DSL structures
- ⏳ Implementing builder module

### Next Steps
1. Create builder module with entity conversion functions
2. Implement recursive tree building
3. Update view_transformer to use builder
4. Create comprehensive tests
