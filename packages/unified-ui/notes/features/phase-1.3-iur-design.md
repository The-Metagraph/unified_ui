# Feature: Phase 1.3 - Intermediate UI Representation (IUR) Design

## Problem Statement

The UnifiedUi library requires a platform-agnostic Intermediate UI Representation (IUR) system. The IUR is what the `view/1` function returns (per The Elm Architecture) and what platform-specific renderers consume. Without a well-defined IUR, there's no contract between the DSL code generation and the rendering layer, making multi-platform support impossible.

## Solution Overview

Design and implement a set of Elixir structs and protocols that represent UI elements in a platform-agnostic manner:

1. **Element Protocol** - A protocol for polymorphic access to UI element properties
2. **Widget Structs** - Base widgets (Text, Button) as simple data containers
3. **Layout Structs** - Container layouts (VBox, HBox) for arranging widgets
4. **Style Struct** - Platform-agnostic style representation with merge functions

The IUR follows these principles:
- **Data containers only** - No business logic, just data
- **Protocol-based** - Extensible through protocols
- **Platform-agnostic** - No terminal/web/desktop-specific concepts
- **Immutable** - Structs are immutable, enabling functional patterns

## Agent Consultations Performed

- **research-agent**: Reviewed the unified-ui architecture document for IUR requirements
- **elixir-expert**: Consulted for Elixir protocol and struct best practices

## Technical Details

### Location
- **Protocol**: `lib/unified_ui/iur/element.ex`
- **Widgets**: `lib/unified_ui/iur/widgets.ex`
- **Layouts**: `lib/unified_ui/iur/layouts.ex`
- **Styles**: `lib/unified_ui/iur/styles.ex`
- **Tests**: `test/unified_ui/iur/`

### IUR Design

From the research document, the IUR is described as:

> "An intermediate UI representation (IUR) – a tree of structs representing widgets and layouts with their fully resolved properties (including styles and any dynamic content derived from the component's state)... Each renderer will implement a common set of protocols or behaviors for traversing this IUR and mapping its elements to the native UI toolkit."

### Protocol-Based Design

The `UnifiedUi.IUR.Element` protocol provides:
- `children/1` - Get child elements for tree traversal
- `metadata/1` - Get element properties (id, style, etc.)

### Widget Structs

**Text** - Simple text display
```elixir
%UnifiedUi.IUR.Widgets.Text{
  content: "Hello",
  style: %UnifiedUi.IUR.Style{fg: :blue, attrs: [:bold]},
  id: :greeting
}
```

**Button** - Interactive button
```elixir
%UnifiedUi.IUR.Widgets.Button{
  label: "Click Me",
  on_click: :button_clicked,
  disabled: false,
  style: %UnifiedUi.IUR.Style{bg: :blue},
  id: :submit_btn
}
```

### Layout Structs

**VBox** - Vertical box layout
```elixir
%UnifiedUi.IUR.Layouts.VBox{
  children: [
    %Text{content: "Title"},
    %Button{label: "OK"}
  ],
  spacing: 1,
  align: :center,
  id: :main_container
}
```

**HBox** - Horizontal box layout
```elixir
%UnifiedUi.IUR.Layouts.HBox{
  children: [
    %Text{content: "Label:"},
    %Button{label: "Submit"}
  ],
  spacing: 2,
  align: :start,
  id: :form_row
}
```

### Style Struct

```elixir
%UnifiedUi.IUR.Style{
  fg: :blue,           # Foreground color
  bg: :white,          # Background color
  attrs: [:bold],      # Text attributes
  padding: 2           # Padding
}
```

## Success Criteria

1. [x] Element protocol defined with children/1 and metadata/1
2. [x] Text widget struct created with proper fields
3. [x] Button widget struct created with proper fields
4. [x] VBox layout struct created with children support
5. [x] HBox layout struct created with children support
6. [x] Style struct created with common attributes
7. [x] Style merge function implemented
8. [x] All structs implement Element protocol
9. [x] Tests verify struct creation and protocol behavior
10. [x] Documentation added for renderer implementers

## Implementation Plan

### Step 1: Create Element Protocol
- [x] Create `lib/unified_ui/iur/element.ex`
- [x] Define `Element` protocol with `children/1` and `metadata/1`
- [x] Add @moduledoc explaining protocol purpose and usage
- [x] Document protocol for renderer implementers

### Step 2: Create Widget Structs
- [x] Create `lib/unified_ui/iur/widgets.ex`
- [x] Define `UnifiedUi.IUR.Widgets.Text` struct:
  - Fields: content, style, id
- [x] Define `UnifiedUi.IUR.Widgets.Button` struct:
  - Fields: label, on_click, disabled, style, id
- [x] Implement Element.protocol for Text
- [x] Implement Element.protocol for Button
- [x] Add @moduledoc with usage examples

### Step 3: Create Layout Structs
- [x] Create `lib/unified_ui/iur/layouts.ex`
- [x] Define `UnifiedUi.IUR.Layouts.VBox` struct:
  - Fields: children, spacing, align, id
- [x] Define `UnifiedUi.IUR.Layouts.HBox` struct:
  - Fields: children, spacing, align, id
- [x] Implement Element.protocol for VBox
- [x] Implement Element.protocol for HBox
- [x] Implement children/1 returning the children list
- [x] Add @moduledoc with layout examples

### Step 4: Create Style System
- [x] Create `lib/unified_ui/iur/styles.ex`
- [x] Define `UnifiedUi.IUR.Style` struct:
  - Fields: fg, bg, attrs, padding, margin, width, height, align
- [x] Implement `merge/2` function for style combination
- [x] Add `nil` handling for optional styles
- [x] Document style attribute meanings

### Step 5: Create Tests
- [x] Create `test/unified_ui/iur/element_test.exs`
- [x] Test Text IUR struct creation
- [x] Test Button IUR struct creation
- [x] Test VBox IUR struct with children
- [x] Test HBox IUR struct with children
- [x] Test Style struct creation
- [x] Test Element.protocol children/1 works
- [x] Test Element.protocol metadata/1 extracts properties
- [x] Test style merge functions

## Status

**Current**: ✅ Complete - All implementation steps finished

**Next**: Write summary and request permission to merge

---

## Implementation Log

### 2025-02-04 - Initial Planning
- Feature planning document created
- Branch created: `feature/phase-1.3-iur-design`
- Researched IUR requirements from unified-ui architecture document
- Ready to begin implementation

### 2025-02-04 - Implementation
- Created Element protocol at `lib/unified_ui/iur/element.ex`
- Created Style struct at `lib/unified_ui/iur/styles.ex` with merge functions
- Created widget structs at `lib/unified_ui/iur/widgets.ex` (Text, Button)
- Created layout structs at `lib/unified_ui/iur/layouts.ex` (VBox, HBox)
- Implemented Element protocol for all IUR structs
- Created comprehensive tests at `test/unified_ui/iur/iur_test.exs`
- All 55 tests pass (31 new IUR tests + 24 existing tests)

## Files Created

### Core IUR Modules
- `lib/unified_ui/iur/element.ex` - Element protocol for polymorphic access
- `lib/unified_ui/iur/widgets.ex` - Text and Button widget structs
- `lib/unified_ui/iur/layouts.ex` - VBox and HBox layout structs
- `lib/unified_ui/iur/styles.ex` - Style struct with merge functions

### Tests
- `test/unified_ui/iur/iur_test.exs` - Comprehensive IUR tests (31 tests)

## Key Design Decisions

1. **Protocol-based design**: The `Element` protocol allows polymorphic access to UI elements without knowing their specific types
2. **Data containers only**: IUR structs contain no business logic, just data
3. **Platform-agnostic**: Style attributes use platform-independent names (fg, bg, attrs, padding, etc.)
4. **Style merging**: `merge/2` and `merge_many/1` functions allow combining styles with later values overriding earlier ones
5. **Nil handling**: Style merge functions properly handle nil values for optional styles
