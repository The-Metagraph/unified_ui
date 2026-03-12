# Phase 2.8: Style System Foundation

**Branch:** `feature/phase-2.8-style-system-foundation`
**Created:** 2025-02-07
**Status:** In Progress

## Overview

This section implements the foundational style system, adding named styles that can be defined once and referenced throughout the UI. This enables consistent styling and style inheritance through the `extends` option.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.8:

### Task 2.8: Create the foundational style system

Implement the basic style system that will be expanded in later phases.

## Problem Statement

Currently, styles can only be specified inline as keyword lists on individual widgets and layouts. This leads to:
1. Repetition - common styles must be repeated across elements
2. Inconsistency - slight variations creep in
3. Maintenance burden - changing a shared style requires updating many locations
4. No inheritance mechanism for creating style variants

## Solution Overview

Add named style entities to the DSL that:
1. Can be defined once in the `styles` section
2. Can be referenced by name in widget/layout `style` attributes
3. Support inheritance via `extends` option
4. Merge with inline styles for final computed style

## Design Decisions

### Style Entity Structure

```elixir
style :header do
  attributes [
    fg: :cyan,
    attrs: [:bold],
    padding: 1
  ]
end
```

### Style Inheritance

Styles can extend other styles:

```elixir
style :error_header do
  extends :header
  attributes [
    fg: :red,
    attrs: [:bold, :underline]
  ]
end
```

### Style Resolution

When a widget references a named style:
1. Fetch the named style definition
2. Resolve any `extends` references recursively
3. Merge with inline styles (inline takes precedence)
4. Return final IUR.Style struct

### Current State

The IUR.Style struct already exists with merge functionality. This phase adds:
1. DSL entity for defining named styles
2. Style resolver for computing final styles from references
3. Support for style references in widget/layout `style` attributes

## Implementation Plan

### 2.8.1 Define style entity with schema

- [ ] Create `lib/unified_ui/dsl/entities/styles.ex`
- [ ] Define `@style_entity` with schema:
  - args: `[:name]`
  - options: `attributes`, `extends`
- [ ] Add to styles section entities list

### 2.8.2 Create target struct

- [ ] Create `UnifiedUi.Dsl.Style` target struct
- [ ] Fields: name, extends, attributes
- [ ] Store parsed DSL data

### 2.8.3 Update IUR style struct

- [ ] IUR.Style already exists and is well-designed
- [ ] No changes needed
- [ ] Verify merge_many/1 handles inheritance

### 2.8.4 Define base style attributes

- [ ] Validate attributes match IUR.Style schema
- [ ] fg, bg, attrs, padding, margin, width, height, align, spacing
- [ ] Already defined in styles section schema

### 2.8.5 Create style resolver module

- [ ] Create `lib/unified_ui/dsl/style_resolver.ex`
- [ ] Implement `resolve_style/2` - resolve named style to IUR.Style
- [ ] Implement `resolve_with_inheritance/2` - handle extends
- [ ] Handle circular reference detection

### 2.8.6 Implement style merge function

- [ ] IUR.Style.merge/2 already exists
- [ ] IUR.Style.merge_many/1 already exists
- [ ] Verify these work with resolver output

### 2.8.7 Add inline style support

- [ ] Inline styles already work (keyword lists)
- [ ] Add support for style references (atom names)
- [ ] Add support for combining named + inline styles
- [ ] Update view_transformer to resolve style references

## API Design

### Defining Named Styles

```elixir
defmodule MyApp.MyScreen do
  use UnifiedUi.Dsl

  styles do
    style :primary_button do
      attributes [
        fg: :white,
        bg: :blue,
        attrs: [:bold],
        padding: 1
      ]
    end

    style :danger_button do
      extends :primary_button
      attributes [
        bg: :red
      ]
    end
  end

  ui do
    vbox do
      button "Save", style: :primary_button
      button "Delete", style: :danger_button
      text "Custom", style: [:primary_button, fg: :green]
    end
  end
end
```

### Style Resolution in Code

```elixir
# Resolve a named style to IUR.Style
style = UnifiedUi.Dsl.StyleResolver.resolve(dsl_state, :primary_button)
# => %IUR.Style{fg: :white, bg: :blue, attrs: [:bold], padding: 1, ...}

# Resolve with inline override
style = UnifiedUi.Dsl.StyleResolver.resolve(dsl_state, :primary_button, fg: :green)
# => %IUR.Style{fg: :green, bg: :blue, attrs: [:bold], padding: 1, ...}
```

## Entity Schema Summary

### Style Entity

```elixir
@style_entity %Spark.Dsl.Entity{
  name: :style,
  target: UnifiedUi.Dsl.Style,
  args: [:name],
  schema: [
    name: [
      type: :atom,
      doc: "Unique name for this style.",
      required: true
    ],
    extends: [
      type: :atom,
      doc: "Optional parent style name to inherit from.",
      required: false
    ],
    attributes: [
      type: :keyword_list,
      doc: "Style attributes (fg, bg, attrs, padding, margin, etc.)",
      required: false
    ]
  ],
  describe: """
  A named style definition that can be referenced by widgets and layouts.
  Styles support inheritance through the extends option.
  """
}
```

## Test Checklist

From planning document:
- [ ] Test style entity with attributes
- [ ] Test style entity with extends
- [ ] Test style resolver works
- [ ] Test style merge works
- [ ] Test inline styles apply correctly
- [ ] Test style inheritance works
- [ ] Test circular reference detection in extends
- [ ] Test combining named and inline styles

## Files to Create

### New Files
- `lib/unified_ui/dsl/entities/styles.ex` - Style entity definition
- `lib/unified_ui/dsl/style_resolver.ex` - Style resolution module
- `lib/unified_ui/dsl/style.ex` - Target struct for style entities
- `test/unified_ui/dsl/style_resolver_test.exs` - Resolver tests

### Files to Modify
- `lib/unified_ui/dsl/sections/styles.ex` - Add style entity to section
- `lib/unified_ui/dsl/extension.ex` - Ensure styles section is registered
- `lib/unified_ui/dsl/transformers/view_transformer.ex` - Resolve style references
- Update existing widget/layout tests for style references

## Dependencies

- Depends on Phase 1: Foundation (IUR.Style exists)
- Depends on Phase 2.1: Basic Widget Entities (widgets need styles)
- Depends on Phase 2.2: Basic Layout Entities (layouts need styles)
- Enables Phase 2.10: Integration Tests (styled UI testing)

## Progress

### Current Status
- ✅ Planning document created
- ✅ Feature branch created
- ⏳ Creating style entity
- ⏳ Creating style resolver
- ⏳ Writing tests

### Next Steps
1. Create style entity in entities/styles.ex
2. Create target struct in dsl/style.ex
3. Create style resolver module
4. Update view_transformer to resolve styles
5. Write comprehensive tests
