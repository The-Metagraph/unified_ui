# Phase 3: First Real Widget

This phase completes the proof-of-concept by adding a layout engine and implementing a fully interactive button widget. The layout engine calculates widget positions, enabling proper hit testing and flexible UI composition. This phase delivers a complete, working desktop UI component in Elixir.

---

## 3.1 Layout Engine Foundation

Create the layout system that calculates widget positions and sizes within containers.

- [ ] **Task 3.1** Create `DesktopUI.Layout` module

Implement the core layout engine:

- [ ] 3.1.1 Define `Layout` struct with x, y, width, height fields
- [ ] 3.1.2 Define layout context with available bounds and constraints
- [ ] 3.1.3 Implement `calculate/3` - UI tree, available bounds, context
- [ ] 3.1.4 Add layout result type (laid_out_ui_tree)
- [ ] 3.1.5 Implement intrinsic size calculation for widgets
- [ ] 3.1.6 Add size constraints (min, max, fixed)

**Implementation Notes:**
- Use a simple box model (content + padding + margin)
- Start with fixed sizes, grow to constraints later
- Layout result annotates each node with its calculated bounds
- Support both pixel-based and proportional sizes
- Include overflow handling (clip, scroll, overflow)
- Return error for unsatisfiable constraints

**Unit Tests for Section 3.1:**
- [ ] 3.1.1 Verify Layout struct creation with valid bounds
- [ ] 3.1.2 Verify layout context initializes correctly
- [ ] 3.1.3 Verify calculate returns valid layout tree
- [ ] 3.1.4 Verify intrinsic size calculation for label
- [ ] 3.1.5 Verify intrinsic size calculation for button
- [ ] 3.1.6 Verify min/max constraints are enforced
- [ ] 3.1.7 Verify fixed size overrides intrinsic size

---

## 3.2 VBox Container Layout

Implement vertical box layout for stacking widgets.

- [ ] **Task 3.2** Implement VBox layout algorithm

Create vertical container layout:

- [ ] 3.2.1 Implement `layout_vbox/3` - children, available bounds, props
- [ ] 3.2.2 Calculate total height required for all children
- [ ] 3.2.3 Distribute available space among children
- [ ] 3.2.4 Handle `:spacing` prop for gaps between widgets
- [ ] 3.2.5 Handle `:padding` prop for container margins
- [ ] 3.2.6 Support `:align` prop (:left, :center, :right)
- [ ] 3.2.7 Handle overflow when children exceed available space

**Implementation Notes:**
- Children stack vertically (y accumulates, x stays same)
- Width: container width minus padding
- Height: sum of children plus spacing
- Spacing applies between children, not before first or after last
- Default alignment is :left (or :top for vertical context)
- Overflow: clip by default, options for scroll later

**Unit Tests for Section 3.2:**
- [ ] 3.2.1 Verify two widgets stack vertically
- [ ] 3.2.2 Verify spacing creates gaps between widgets
- [ ] 3.2.3 Verify padding creates container margins
- [ ] 3.2.4 Verify :center alignment positions correctly
- [ ] 3.2.5 Verify :right alignment positions correctly
- [ ] 3.2.6 Verify overflow clips correctly
- [ ] 3.2.7 Verify empty container has zero size

---

## 3.3 HBox Container Layout

Implement horizontal box layout for arranging widgets side-by-side.

- [ ] **Task 3.3** Implement HBox layout algorithm

Create horizontal container layout:

- [ ] 3.3.1 Implement `layout_hbox/3` - children, available bounds, props
- [ ] 3.3.2 Calculate total width required for all children
- [ ] 3.3.3 Distribute available space horizontally
- [ ] 3.3.4 Handle `:spacing` prop for horizontal gaps
- [ ] 3.3.5 Handle `:padding` prop
- [ ] 3.3.6 Support `:align` prop (:top, :center, :bottom)
- [ ] 3.3.7 Handle overflow when children exceed available space

**Implementation Notes:**
- Children arrange horizontally (x accumulates, y stays same)
- Width: sum of children plus spacing
- Height: maximum child height (or container height)
- Spacing applies between children
- Default alignment is :top
- Mirror VBox logic but for horizontal axis

**Unit Tests for Section 3.3:**
- [ ] 3.3.1 Verify two widgets arrange horizontally
- [ ] 3.3.2 Verify spacing creates horizontal gaps
- [ ] 3.3.3 Verify padding works correctly
- [ ] 3.3.4 Verify :center alignment works
- [ ] 3.3.5 Verify :bottom alignment works
- [ ] 3.3.6 Verify overflow clips correctly
- [ ] 3.3.7 Verify nested containers (vbox in hbox, vice versa)

---

## 3.4 Widget Size Hints

Add size calculation and hints for individual widget types.

- [ ] **Task 3.4** Implement widget size hints

Create size calculation for widgets:

- [ ] 3.4.1 Implement `intrinsic_size/2` for label widget (text dimensions)
- [ ] 3.4.2 Implement `intrinsic_size/2` for button widget (text + padding)
- [ ] 3.4.3 Implement `intrinsic_size/2` for container (children size)
- [ ] 3.4.4 Support `:width` and `:height` props to override intrinsic
- [ ] 3.4.5 Support `:min_width`, `:min_height` constraints
- [ ] 3.4.6 Support `:max_width`, `:max_height` constraints
- [ ] 3.4.7 Add `:expand` prop for flexible sizing

**Implementation Notes:**
- For now, use fixed/estimated sizes (no text rendering yet)
- Label: estimate based on character count * char_width
- Button: text size + padding (e.g., 20px horizontal, 10px vertical)
- Container: derived from children
- :expand true means fill available space
- Defaults when sizes not specified

**Unit Tests for Section 3.4:**
- [ ] 3.4.1 Verify label calculates size from text
- [ ] 3.4.2 Verify button calculates size from text plus padding
- [ ] 3.4.3 Verify container calculates from children
- [ ] 3.4.4 Verify explicit width/height overrides intrinsic
- [ ] 3.4.5 Verify min constraints are enforced
- [ ] 3.4.6 Verify max constraints are enforced
- [ ] 3.4.7 Verify expand fills available space

---

## 3.5 Renderer with Layout

Update the renderer to use calculated layout positions.

- [ ] **Task 3.5** Update SDL2 renderer with layout

Integrate layout into rendering:

- [ ] 3.5.1 Update `DesktopUI.Renderer.SDL2.render/2` to accept layout tree
- [ ] 3.5.2 Use calculated bounds from layout for each widget
- [ ] 3.5.3 Remove hardcoded positioning from renderer
- [ ] 3.5.4 Pass layout results through render pipeline
- [ ] 3.5.5 Support nested layouts correctly
- [ ] 3.5.6 Handle layout errors gracefully

**Implementation Notes:**
- Layout tree should be a separate pass before rendering
- Each widget in layout tree has explicit x, y, width, height
- Renderer simply uses these bounds for drawing
- No position calculation in renderer anymore
- Store layout tree in runtime state for hit testing

**Unit Tests for Section 3.5:**
- [ ] 3.5.1 Verify renderer uses layout bounds for positioning
- [ ] 3.5.2 Verify nested containers render correctly
- [ ] 3.5.3 Verify spacing is visible in rendered output
- [ ] 3.5.4 Verify padding creates margins in rendered output
- [ ] 3.5.5 Verify alignment is visible in rendered output
- [ ] 3.5.6 Verify invalid layout returns error

---

## 3.6 Hit Testing with Layout

Implement accurate hit testing using calculated layout bounds.

- [ ] **Task 3.6** Implement hit testing system

Create hit testing for widget interaction:

- [ ] 3.6.1 Create `hit_test/3` function - layout tree, x, y
- [ ] 3.6.2 Return widget ID and message for clicked widget
- [ ] 3.6.3 Handle nested containers correctly
- [ ] 3.6.4 Return nil for clicks outside any widget
- [ ] 3.6.5 Handle overlapping widgets (topmost wins)
- [ ] 3.6.6 Store current layout in Runtime for hit testing

**Implementation Notes:**
- Traverse layout tree depth-first or reverse for z-order
- Point-in-rect test for each widget
- Return the widget's `on_click` message if defined
- Container widgets don't typically receive clicks
- Cache hit test results for rapid events
- Support event bubbling later (propagation to parent)

**Unit Tests for Section 3.6:**
- [ ] 3.6.1 Verify click inside button returns button's message
- [ ] 3.6.2 Verify click outside all widgets returns nil
- [ ] 3.6.3 Verify click in nested container finds correct widget
- [ ] 3.6.4 Verify click on container with no on_click returns nil
- [ ] 3.6.5 Verify overlapping widgets handle correctly
- [ ] 3.6.6 Verify hit test works with scrolled content (future)

---

## 3.7 Runtime Layout Integration

Update Runtime to use layout engine and hit testing.

- [ ] **Task 3.7** Integrate layout into Runtime

Complete the rendering pipeline:

- [ ] 3.7.1 Update Runtime to calculate layout before rendering
- [ ] 3.7.2 Store current layout tree in Runtime state
- [ ] 3.7.3 Use layout for hit testing on mouse events
- [ ] 3.7.4 Trigger layout recalculation when UI tree changes
- [ ] 3.7.5 Trigger layout recalculation on window resize
- [ ] 3.7.6 Optimize to skip layout if nothing changed

**Implementation Notes:**
- Layout pass happens after `view/1`, before renderer
- Store UI tree version to detect changes
- Window resize triggers new layout with new bounds
- Layout bounds come from window size
- Consider dirty-layout (only recalc changed subtrees)
- Include timing metrics for performance

**Unit Tests for Section 3.7:**
- [ ] 3.7.1 Verify layout is calculated after state change
- [ ] 3.7.2 Verify layout is stored in runtime state
- [ ] 3.7.3 Verify mouse click uses layout for hit testing
- [ ] 3.7.4 Verify window resize triggers recalculation
- [ ] 3.7.5 Verify unchanged UI skips layout calculation
- [ ] 3.7.6 Verify full pipeline: init → update → view → layout → render

---

## 3.8 Enhanced Counter Demo

Update the Counter component to demonstrate layout capabilities.

- [ ] **Task 3.8** Create polished Counter demo

Build a complete working example:

- [ ] 3.8.1 Use VBox for main vertical arrangement
- [ ] 3.8.2 Use HBox for button row (increment, decrement)
- [ ] 3.8.3 Add spacing and padding for visual polish
- [ ] 3.8.4 Add window title and sensible dimensions
- [ ] 3.8.5 Add center alignment for better appearance
- [ ] 3.8.6 Include quit button
- [ ] 3.8.7 Add visual feedback (different button colors)

**Implementation Notes:**
- Keep the component logic simple
- Focus on demonstrating layout features
- Use descriptive colors (e.g., primary, secondary)
- Include comments explaining layout choices
- Make it look decent for screenshots/demo
- Consider adding a simple visual indicator of count

**Unit Tests for Section 3.8:**
- [ ] 3.8.1 Verify Counter component renders without errors
- [ ] 3.8.2 Verify buttons are clickable
- [ ] 3.8.3 Verify layout matches expected structure
- [ ] 3.8.4 Verify spacing is visible
- [ ] 3.8.5 Verify all buttons function correctly
- [ ] 3.8.6 Verify quit button terminates application

---

## 3.9 Phase 3 Integration Tests

Comprehensive integration tests verifying the complete working system.

- [ ] **Task 3.9** Create end-to-end integration tests

Verify the complete desktop UI system:

- [ ] 3.9.1 Test full lifecycle with layout engine
- [ ] 3.9.2 Test Counter component with real button clicks
- [ ] 3.9.3 Test nested layouts (vbox in hbox, etc.)
- [ ] 3.9.4 Test window resize triggers re-layout
- [ ] 3.9.5 Test hit testing accuracy
- [ ] 3.9.6 Test alignment variants (left, center, right, top, bottom)
- [ ] 3.9.7 Test spacing and padding in complex layouts
- [ ] 3.9.8 Test multiple clicks in rapid succession

**Implementation Notes:**
- Tests run with real SDL window (headless for CI if possible)
- May need visual verification screenshots
- Include timing tests for performance regression
- Test cleanup should close windows properly
- Some tests may simulate user interaction
- Include stress tests for rapid clicks

**Actual Test Coverage:**
- Layout engine: 15 tests
- Renderer with layout: 6 tests
- Hit testing: 6 tests
- Runtime integration: 6 tests
- Counter demo: 6 tests
- End-to-end: 8 tests

**Total: 47 integration tests**

---

## Success Criteria

1. **Working Button**: Clicking increment/decrement buttons updates the display
2. **Visible Layout**: Spacing, padding, and alignment are clearly visible
3. **Window Resize**: Resizing window reflows layout correctly
4. **Accurate Clicks**: Hit testing works precisely for all widgets
5. **Complete Demo**: Counter component demonstrates full feature set

---

## Critical Files

**New Files:**
- `lib/desktop_ui/layout.ex` - Layout engine
- `lib/desktop_ui/layout/algorithm.ex` - Layout algorithms (vbox, hbox)
- `lib/desktop_ui/hit_test.ex` - Hit testing utilities
- `test/desktop_ui/layout_test.exs` - Layout tests
- `test/desktop_ui/layout/algorithm_test.exs` - Algorithm tests
- `test/desktop_ui/hit_test_test.exs` - Hit test tests
- `test/integration/phase_3_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/desktop_ui/renderer/sdl2.ex` - Use layout for positioning
- `lib/desktop_ui/runtime.ex` - Integrate layout engine
- `lib/desktop_ui/widget.ex` - Add size hint props
- `lib/desktop_ui/examples/counter.ex` - Enhanced demo

**Dependencies:**
- Phase 1: Architecture Validation (Runtime, Elm behaviour, Widget DSL)
- Phase 2: The Graphics Bridge (SDL2 NIFs, Graphics API, SDL2 Renderer)

---

## Dependencies

**This phase depends on:**
- Phase 1: Architecture Validation (complete)
- Phase 2: The Graphics Bridge (complete)

**Phases that depend on this phase:**
- Future phases: Text rendering, advanced widgets, styling system, theming
- Future phases: Scroll containers, complex layouts (grid, flexbox)
