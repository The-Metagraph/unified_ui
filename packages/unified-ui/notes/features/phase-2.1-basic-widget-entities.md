# Phase 2.1: Basic Widget Entities - Implementation Plan

**Feature:** Implement section 2.1 of Phase 2 - Basic Widget Entities
**Branch:** `feature/phase-2.1-basic-widget-entities`
**Created:** 2026-02-05
**Status:** Planning

---

## Problem Statement

Phase 1 established the DSL framework, IUR system, and Elm Architecture foundation. However, the DSL has no actual widget entities defined - the widgets section is empty with only placeholder comments. Developers cannot define UIs using the DSL yet.

To make the DSL functional, we need to define Spark.Dsl.Entity structs for the core widgets: button, text, label, and text_input.

---

## Solution Overview

We will create DSL entity definitions for the four basic widgets that map to the existing IUR structs. Each entity will:
1. Define its schema (required args and optional options)
2. Specify a target struct (either existing IUR or new)
3. Include comprehensive documentation
4. Support proper validation through Spark's built-in mechanisms

**Key Design Decisions:**
- Reuse existing IUR structs for Text and Button
- Create new IUR structs for Label and TextInput
- Support `on_click` as atom, tuple, or function reference
- Support `on_change` for TextInput with new value as argument
- All widgets support `id`, `style`, and `visible` options

---

## Technical Details

### Current State

**Existing IUR Widgets** (`lib/unified_ui/iur/widgets.ex`):
- `UnifiedUi.IUR.Widgets.Text` - Already exists ✅
- `UnifiedUi.IUR.Widgets.Button` - Already exists ✅

**Need to Create**:
- `UnifiedUi.IUR.Widgets.Label` - Label widget for form inputs
- `UnifiedUi.IUR.Widgets.TextInput` - Text input widget

**DSL Extension** (`lib/unified_ui/dsl/extension.ex`):
- Widgets section exists but has empty entities list
- Need to add 4 widget entities

### Files to Create

1. **`lib/unified_ui/dsl/entities/widgets.ex`**
   - Define `@button_entity` Spark.Dsl.Entity
   - Define `@text_entity` Spark.Dsl.Entity
   - Define `@label_entity` Spark.Dsl.Entity
   - Define `@text_input_entity` Spark.Dsl.Entity

### Files to Modify

1. **`lib/unified_ui/iur/widgets.ex`**
   - Add `Label` struct module
   - Add `TextInput` struct module

2. **`lib/unified_ui/dsl/extension.ex`**
   - Import widget entities from entities module
   - Add entities to `@widgets_section`

### Test Files to Create

1. **`test/unified_ui/dsl/entities/widgets_test.exs`**
   - Test button entity with required label argument
   - Test button entity with all optional options
   - Test text entity with content argument
   - Test label entity with for and text arguments
   - Test text_input entity with required id argument
   - Test text_input with different type options
   - Test on_click accepts various formats
   - Verify target structs are created correctly

2. **`test/unified_ui/iur/widgets_test.exs`** (expand existing)
   - Add tests for Label struct
   - Add tests for TextInput struct
   - Add protocol implementation tests

---

## Entity Specifications

### Button Entity

```elixir
@button_entity %Spark.Dsl.Entity{
  name: :button,
  target: UnifiedUi.IUR.Widgets.Button,
  args: [:label],
  schema: [
    label: [type: :string, required: true],
    id: [type: :atom, required: false],
    on_click: [
      type: {:or, [:atom, {:tuple, [:atom, :map]}, :mfa]},
      required: false
    ],
    disabled: [type: :boolean, required: false, default: false],
    style: [type: :keyword_list, required: false],
    visible: [type: :boolean, required: false, default: true]
  ],
  describe: "A clickable button with a label"
}
```

### Text Entity

```elixir
@text_entity %Spark.Dsl.Entity{
  name: :text,
  target: UnifiedUi.IUR.Widgets.Text,
  args: [:content],
  schema: [
    content: [type: :string, required: true],
    id: [type: :atom, required: false],
    style: [type: :keyword_list, required: false],
    visible: [type: :boolean, required: false, default: true]
  ],
  describe: "Displays text content"
}
```

### Label Entity

```elixir
@label_entity %Spark.Dsl.Entity{
  name: :label,
  target: UnifiedUi.IUR.Widgets.Label,
  args: [:for, :text],
  schema: [
    for: [type: :atom, required: true],
    text: [type: :string, required: true],
    id: [type: :atom, required: false],
    style: [type: :keyword_list, required: false],
    visible: [type: :boolean, required: false, default: true]
  ],
  describe: "A label for a form input, associating text with an input id"
}
```

### TextInput Entity

```elixir
@text_input_entity %Spark.Dsl.Entity{
  name: :text_input,
  target: UnifiedUi.IUR.Widgets.TextInput,
  args: [:id],
  schema: [
    id: [type: :atom, required: true],
    value: [type: :string, required: false],
    placeholder: [type: :string, required: false],
    type: [
      type: {:one_of, [:text, :password, :email, :number, :tel]},
      required: false,
      default: :text
    ],
    on_change: [
      type: {:or, [:atom, {:tuple, [:atom, :map]}, :mfa]},
      required: false
    ],
    on_submit: [
      type: {:or, [:atom, {:tuple, [:atom, :map]}, :mfa]},
      required: false
    ],
    disabled: [type: :boolean, required: false, default: false],
    style: [type: :keyword_list, required: false],
    visible: [type: :boolean, required: false, default: true]
  ],
  describe: "A text input field for user data entry"
}
```

---

## IUR Struct Specifications

### Label Struct

```elixir
defmodule Label do
  @moduledoc """
  Label widget for form inputs.

  Associates descriptive text with a form input widget.

  ## Fields

  * `for` - The id of the input this label is for
  * `text` - The label text to display
  * `id` - Optional unique identifier
  * `style` - Optional style struct

  ## Examples

      iex> %Label{for: :email_input, text: "Email:"}
      %Label{for: :email_input, text: "Email:", id: nil, style: nil}
  """

  defstruct [:for, :text, :id, style: nil]

  @type t :: %__MODULE__{
          for: atom(),
          text: String.t(),
          id: atom() | nil,
          style: UnifiedUi.IUR.Style.t() | nil
        }
end
```

### TextInput Struct

```elixir
defmodule TextInput do
  @moduledoc """
  Text input widget for user data entry.

  ## Fields

  * `id` - Required identifier for the input
  * `value` - Initial value (optional)
  * `placeholder` - Placeholder text when empty
  * `type` - Input type (:text, :password, :email, :number, :tel)
  * `on_change` - Signal to emit when value changes
  * `on_submit` - Signal to emit on Enter key
  * `disabled` - Whether the input is disabled
  * `style` - Optional style struct
  * `id` - Optional unique identifier (may differ from field id)

  ## Examples

      iex> %TextInput{id: :email, placeholder: "user@example.com"}
      %TextInput{id: :email, placeholder: "user@example.com", type: :text, ...}

      iex> %TextInput{id: :password, type: :password}
      %TextInput{id: :password, type: :password, ...}
  """

  defstruct [:id, :value, :placeholder, :type, :on_change, :on_submit, :disabled, :style, visible: true]

  @type input_type :: :text | :password | :email | :number | :tel
  @type t :: %__MODULE__{
          id: atom(),
          value: String.t() | nil,
          placeholder: String.t() | nil,
          type: input_type(),
          on_change: atom() | {atom(), any()} | nil,
          on_submit: atom() | {atom(), any()} | nil,
          disabled: boolean(),
          style: UnifiedUi.IUR.Style.t() | nil,
          visible: boolean()
        }
end
```

---

## Success Criteria

1. ✅ All 4 widget entities defined in DSL
2. ✅ Label and TextInput IUR structs created
3. ✅ Widget entities registered in DSL extension
4. ✅ All widgets implement IUR.Element protocol
5. ✅ Comprehensive test coverage (target: 30+ tests)
6. ✅ All tests pass
7. ✅ Code formatted with `mix format`

---

## Implementation Plan

### Step 1: Create IUR Structs for Label and TextInput
- Add `Label` module to `lib/unified_ui/iur/widgets.ex`
- Add `TextInput` module to `lib/unified_ui/iur/widgets.ex`
- Implement IUR.Element protocol for both
- Test struct creation and protocol implementations

### Step 2: Create Widget Entities Module
- Create `lib/unified_ui/dsl/entities/widgets.ex`
- Define `@button_entity`
- Define `@text_entity`
- Define `@label_entity`
- Define `@text_input_entity`
- Export entity functions

### Step 3: Update DSL Extension
- Import widget entities
- Add entities to `@widgets_section`
- Verify compilation

### Step 4: Create Tests
- Create `test/unified_ui/dsl/entities/widgets_test.exs`
- Test each entity with required args
- Test each entity with optional options
- Test validation errors
- Test IUR struct creation
- Update `test/unified_ui/iur/iur_test.exs` for Label and TextInput

### Step 5: Protocol Implementation
- Implement IUR.Element for Label
- Implement IUR.Element for TextInput
- Test metadata and children functions

### Step 6: Integration Testing
- Test DSL compiles with widget entities
- Test widget creation in DSL context
- Test all options work correctly

### Step 7: Final Verification
- Run all tests
- Run formatter
- Verify test coverage

---

## Progress Tracking

| Step | Description | Status | Notes |
|------|-------------|--------|-------|
| 1 | Create feature branch | ✅ Complete | Branch: feature/phase-2.1-basic-widget-entities |
| 2 | Create planning document | ✅ Complete | This document |
| 3 | Create IUR Label struct | Pending | |
| 4 | Create IUR TextInput struct | Pending | |
| 5 | Create widget entities module | Pending | |
| 6 | Update DSL extension | Pending | |
| 7 | Create entity tests | Pending | |
| 8 | Create IUR protocol tests | Pending | |
| 9 | Create integration tests | Pending | |
| 10 | Final verification | Pending | |
| 11 | Write summary | Pending | |
| 12 | Request merge permission | Pending | |

---

## Notes and Considerations

### Design Decisions

1. **Entity Target**: Use IUR structs directly as targets to avoid duplication
2. **Signal Handler Format**: Support atom, tuple, and MFA for flexibility
3. **Input Types**: Use `:one_of` for type validation in TextInput
4. **Visible Attribute**: Added to all widgets for future state binding support

### Potential Issues

1. **Entity Registration**: Need to ensure entities are properly registered in Spark DSL
2. **Protocol Implementation**: Must implement IUR.Element for new structs
3. **Test Organization**: Decide between separate test files or expanding existing

### Future Considerations

1. **Phase 2.2**: Will add layout entities (vbox, hbox)
2. **Phase 2.3**: Will add state interpolation for widget properties
3. **Phase 2.4**: Will add signal wiring and emission

---

## References

- Phase 2 Planning: `notes/planning/phase-02.md`
- Spark DSL Documentation: https://hexdocs.pm/spark
- IUR Widgets: `lib/unified_ui/iur/widgets.ex`
- DSL Extension: `lib/unified_ui/dsl/extension.ex`
