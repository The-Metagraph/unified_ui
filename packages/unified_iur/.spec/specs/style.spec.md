# Style

`UnifiedIUR.Style` defines platform-agnostic visual attributes and merge semantics for element styling.

```spec-meta
id: unified_iur.style
kind: module
status: active
summary: Struct schema and merge behavior for reusable style values.
surface:
  - lib/unified_iur/style.ex
```

## Requirements

```spec-requirements
- id: unified_iur.style.struct_shape
  statement: The style struct shall include foreground/background colors, text attributes, spacing fields, size constraints, and alignment options.
  priority: must
  stability: stable

- id: unified_iur.style.new_constructor
  statement: `Style.new/1` shall build a `UnifiedIUR.Style` struct from keyword attributes while preserving module defaults for omitted fields.
  priority: must
  stability: stable

- id: unified_iur.style.merge_pair
  statement: `Style.merge/2` shall return the non-nil operand when either side is nil and otherwise combine styles with deduplicated attributes and right-side value precedence.
  priority: must
  stability: stable

- id: unified_iur.style.merge_many
  statement: `Style.merge_many/1` shall reduce style lists in order and skip nil entries during the merge fold.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: command
  target: mix test
  execute: true
  covers:
    - unified_iur.style.struct_shape
    - unified_iur.style.new_constructor
    - unified_iur.style.merge_pair
    - unified_iur.style.merge_many
```
