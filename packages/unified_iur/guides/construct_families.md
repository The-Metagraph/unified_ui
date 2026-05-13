# Construct Families

`UnifiedIUR` defines the canonical construct families that runtime libraries
must be able to consume and that `unified_ui` must be able to author against.

## Widget Families

The canonical widget catalog is organized into these families:

- foundational widgets
- input widgets
- navigation widgets
- data widgets
- feedback widgets
- advanced operational widgets
- promoted semantic and micro-interaction widgets such as disclosure, kicker,
  avatar, presence, segmented controls, multi-column rows, artifact rows,
  sticky headers, and host-owned form shell markers
- promoted workflow, document, and composer widgets such as pipeline steppers,
  segmented progress, workflow stage lists, thin meters, slide-over panels,
  event callouts, inline redlines, syntax-highlighted code blocks, and chat
  composers

Reference coverage for each family lives in `UnifiedIUR.Fixtures` and is
validated through `mix unified_iur.validate`.

## Display-System Families

The canonical display-system surface includes:

- container constructs
- forms and field composition
- layout constructs
- layering and overlay constructs
- canvas and chart constructs
- repeated collection composition that connects a portable list source, one row
  template, row index/value/key descriptors, and stable generated child
  identity expectations

These families are the renderer-independent building blocks that runtime
libraries must map into their own native widget and display systems.

## Styling and Interaction Families

Portable attachments include:

- canonical local styles
- theme attachments and token references
- bindings
- interaction descriptors
- interaction scopes
- row-scope binding descriptors for repeated collection row templates

Reference fixtures are expected to cover all of these attachment families so
maintainers can review canonical shape changes before runtime libraries are
updated.
