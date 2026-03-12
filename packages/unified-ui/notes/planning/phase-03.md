# Phase 3: Renderer Implementations

This phase implements all three platform renderers in parallel. Each renderer consumes the IUR produced by the DSL and translates it to calls for its target UI library (TermUi, DesktopUi, WebUi). The renderers are developed concurrently to ensure platform parity and shared patterns.

Implementation naming note: runtime modules live under `UnifiedUi.Adapters.*` and source files under `lib/unified_ui/adapters/**`.

---

## 3.1 Renderer Architecture

- [x] **Task 3.1** Define the renderer behavior and shared architecture

Create the common architecture that all renderers follow, including protocols and helper modules.

- [x] 3.1.1 Create `lib/unified_ui/adapters/protocol.ex` with:
  - `UnifiedUi.Renderer` behaviour
  - `render/2` - IUR to platform widgets
  - `update/3` - Update existing widgets
  - `destroy/1` - Cleanup resources
- [x] 3.1.2 Create `lib/unified_ui/adapters/shared.ex` with:
  - `traverse_iur/2` - Generic tree traversal
  - `find_by_id/2` - Find IUR element by ID
  - `collect_styles/1` - Collect all styles
- [x] 3.1.3 Define renderer state management
- [x] 3.1.4 Define event-to-signal conversion pattern
- [x] 3.1.5 Document renderer contract

**Implementation Notes:**
- All renderers adopt the Renderer behaviour
- Shared utilities avoid code duplication
- State management pattern consistent across renderers
- Events converted to JidoSignal uniformly

**Unit Tests for Section 3.1:**
- [x] Test Renderer behaviour is defined
- [x] Test traverse_iur works correctly
- [x] Test find_by_id finds elements
- [x] Test collect_styles gathers all styles
- [x] Test shared utilities work

---

## 3.2 Terminal Renderer - Core

- [x] **Task 3.2** Implement the Terminal renderer for basic widgets and layouts

Create the UnifiedUi.Adapters.Terminal module that converts IUR to TermUi widgets.

- [x] 3.2.1 Create `lib/unified_ui/adapters/terminal/renderer.ex`
- [x] 3.2.2 Implement `render/2` entry point
- [x] 3.2.3 Implement basic widget converters:
  - `convert_text/2` - IUR.Text → TermUi text
  - `convert_button/2` - IUR.Button → TermUi button
  - `convert_label/2` - IUR.Label → TermUi label
  - `convert_text_input/2` - IUR.TextInput → TermUi text_input
- [x] 3.2.4 Implement layout converters:
  - `convert_vbox/2` - IUR.VBox → TermUi stack(:vertical)
  - `convert_hbox/2` - IUR.HBox → TermUi stack(:horizontal)
- [x] 3.2.5 Implement style converter:
  - `convert_style/1` - IUR.Style → TermUi.Style
- [x] 3.2.6 Create Terminal.Server GenServer for terminal lifecycle

**Implementation Notes:**
- Uses TermUi.Widget.* constructors
- Style mapping: fg/bg to TermUi colors
- Layout spacing/padding in character cells
- Server GenServer manages terminal rendering

**Unit Tests for Section 3.2:**
- [x] Test convert_text produces TermUi text
- [x] Test convert_button produces TermUi button
- [x] Test convert_label produces TermUi label
- [x] Test convert_text_input produces TermUi text_input
- [x] Test convert_vbox produces vertical stack
- [x] Test convert_hbox produces horizontal stack
- [x] Test convert_style maps colors correctly
- [x] Test nested layout conversion

---

## 3.3 Desktop Renderer - Core

- [x] **Task 3.3** Implement the Desktop renderer for basic widgets and layouts

Create the UnifiedUi.Adapters.Desktop module that converts IUR to DesktopUi widgets.

- [x] 3.3.1 Create `lib/unified_ui/adapters/desktop/renderer.ex`
- [x] 3.3.2 Implement `render/2` entry point
- [x] 3.3.3 Implement basic widget converters:
  - `convert_text/2` - IUR.Text → DesktopUi text
  - `convert_button/2` - IUR.Button → DesktopUi button
  - `convert_label/2` - IUR.Label → DesktopUi label
  - `convert_text_input/2` - IUR.TextInput → DesktopUi text_input
- [x] 3.3.4 Implement layout converters:
  - `convert_vbox/2` - IUR.VBox → DesktopUi vbox
  - `convert_hbox/2` - IUR.HBox → DesktopUi hbox
- [x] 3.3.5 Implement style converter for DesktopUi
- [x] 3.3.6 Create Desktop.Server GenServer for desktop window lifecycle

**Implementation Notes:**
- DesktopUi is consumed as a dependency
- DesktopUi widgets follow similar patterns to TermUi
- Desktop uses pixel-based spacing
- Style conversion adapts to desktop capabilities

**Unit Tests for Section 3.3:**
- [x] Test convert_text produces DesktopUi text
- [x] Test convert_button produces DesktopUi button
- [x] Test convert_label produces DesktopUi label
- [x] Test convert_text_input produces DesktopUi text_input
- [x] Test convert_vbox produces DesktopUi vbox
- [x] Test convert_hbox produces DesktopUi hbox
- [x] Test convert_style adapts to desktop
- [x] Test nested layout conversion

---

## 3.4 Web Renderer - Core

- [x] **Task 3.4** Implement the Web renderer for basic widgets and layouts

Create the UnifiedUi.Adapters.Web module that converts IUR to web UI (HTML/LiveView).

- [x] 3.4.1 Create `lib/unified_ui/adapters/web/renderer.ex`
- [x] 3.4.2 Implement `render/2` entry point
- [x] 3.4.3 Implement basic widget converters (HTML):
  - `convert_text/2` - IUR.Text → <span>
  - `convert_button/2` - IUR.Button → <button>
  - `convert_label/2` - IUR.Label → <label>
  - `convert_text_input/2` - IUR.TextInput → <input>
- [x] 3.4.4 Implement layout converters (CSS):
  - `convert_vbox/2` - IUR.VBox → flexbox column
  - `convert_hbox/2` - IUR.HBox → flexbox row
- [x] 3.4.5 Implement style converter:
  - `convert_style/1` - IUR.Style → CSS
- [x] 3.4.6 Add HEEx template support
- [x] 3.4.7 Create Web.Server for LiveView integration

**Implementation Notes:**
- WebUi is consumed as a dependency
- HTML5 semantic elements
- CSS flexbox for layouts
- LiveView phx-event bindings for interactivity
- ARIA attributes for accessibility

**Unit Tests for Section 3.4:**
- [x] Test convert_text produces HTML <span>
- [x] Test convert_button produces HTML <button>
- [x] Test convert_label produces HTML <label>
- [x] Test convert_text_input produces HTML <input>
- [x] Test convert_vbox produces flexbox column
- [x] Test convert_hbox produces flexbox row
- [x] Test convert_style produces CSS
- [x] Test HEEx templates work

---

## 3.5 Terminal Event Handling

- [x] **Task 3.5** Implement event capture and signal dispatch for Terminal

Capture TermUi events and convert them to JidoSignal messages.

- [x] 3.5.1 Create `lib/unified_ui/adapters/terminal/events.ex`
- [x] 3.5.2 Define terminal event types
- [x] 3.5.3 Implement event capture from TermUi
- [x] 3.5.4 Implement event-to-signal converter
- [x] 3.5.5 Implement signal dispatch to agents
- [x] 3.5.6 Add keyboard event handling
- [x] 3.5.7 Add mouse event handling (where supported)

**Implementation Notes:**
- TermUi events captured via callbacks
- Converted to JidoSignal for agent communication
- Keyboard: key press, special keys
- Mouse: clicks (if terminal supports)

**Unit Tests for Section 3.5:**
- [x] Test button click captured and converted
- [x] Test text input change captured
- [x] Test keyboard events captured
- [x] Test event converts to JidoSignal
- [x] Test signal dispatches to agent

---

## 3.6 Desktop Event Handling

- [x] **Task 3.6** Implement event capture and signal dispatch for Desktop

Capture DesktopUi events and convert them to JidoSignal messages.

- [x] 3.6.1 Create `lib/unified_ui/adapters/desktop/events.ex`
- [x] 3.6.2 Define desktop event types
- [x] 3.6.3 Implement event capture from DesktopUi
- [x] 3.6.4 Implement event-to-signal converter
- [x] 3.6.5 Implement signal dispatch to agents
- [x] 3.6.6 Add keyboard event handling
- [x] 3.6.7 Add mouse event handling
- [x] 3.6.8 Add window event handling

**Implementation Notes:**
- DesktopUi events captured via native callbacks
- Full mouse and keyboard support
- Window events: resize, move, close
- Event data includes coordinates

**Unit Tests for Section 3.6:**
- [x] Test button click captured and converted
- [x] Test text input change captured
- [x] Test keyboard events captured
- [x] Test mouse events captured
- [x] Test window events captured
- [x] Test event converts to JidoSignal
- [x] Test signal dispatches to agent

---

## 3.7 Web Event Handling

- [x] **Task 3.7** Implement event capture and signal dispatch for Web

Capture browser events and convert them to JidoSignal messages.

- [x] 3.7.1 Create `lib/unified_ui/adapters/web/events.ex`
- [x] 3.7.2 Define web event types
- [x] 3.7.3 Implement event capture via LiveView
- [x] 3.7.4 Implement event-to-signal converter
- [x] 3.7.5 Implement signal dispatch to agents
- [x] 3.7.6 Add phx-event bindings
- [x] 3.7.7 Add WebSocket communication
- [x] 3.7.8 Add reconnection handling

**Implementation Notes:**
- LiveView phx-click, phx-change, etc.
- WebSocket for real-time updates
- Reconnection with exponential backoff
- Event data includes form values

**Unit Tests for Section 3.7:**
- [x] Test button click captured via phx-click
- [x] Test input change captured via phx-change
- [x] Test keyboard events captured
- [x] Test event converts to JidoSignal
- [x] Test signal dispatches to agent
- [x] Test WebSocket reconnection works

---

## 3.8 Renderer Coordination

- [x] **Task 3.8** Implement coordination between renderers for multi-platform support

Create the system that allows a single UI definition to render on multiple platforms simultaneously.

- [x] 3.8.1 Create `lib/unified_ui/adapters/coordinator.ex`
- [x] 3.8.2 Implement multi-platform rendering
- [x] 3.8.3 Add platform detection
- [x] 3.8.4 Add renderer selection logic
- [x] 3.8.5 Implement state synchronization across platforms
- [x] 3.8.6 Add concurrent renderer support

**Implementation Notes:**
- Single UI can render on multiple platforms
- Platform detection for conditional behavior
- State shared via Jido agents
- Each renderer maintains own platform state

**Unit Tests for Section 3.8:**
- [x] Test UI renders on all platforms
- [x] Test platform detection works
- [x] Test renderer selection is correct
- [x] Test state syncs across platforms
- [x] Test concurrent renderers don't conflict

---

## 3.9 Phase 3 Integration Tests

Comprehensive integration tests to verify all three renderers work correctly.

- [x] 3.9.1 Test same UI renders on all three platforms
- [x] 3.9.2 Test events work identically across platforms
- [x] 3.9.3 Test state synchronization across platforms
- [x] 3.9.4 Test all basic widgets on all platforms
- [x] 3.9.5 Test all layouts on all platforms
- [x] 3.9.6 Test styles apply correctly on all platforms
- [x] 3.9.7 Test signal handling on all platforms
- [x] 3.9.8 Test multi-platform concurrent rendering
- [x] 3.9.9 Test renderer lifecycle (start/stop)

**Implementation Notes:**
- Create test UI with all widgets and layouts
- Test on actual platforms where possible
- Compare behavior across platforms
- Test concurrent multi-platform instances

**Unit Tests for Section 3.9:**
- [x] Test UI renders on terminal
- [x] Test UI renders on desktop
- [x] Test UI renders on web
- [x] Test events work on all platforms
- [x] Test state syncs correctly
- [x] Test concurrent instances work
- [x] Test cleanup works

---

## Success Criteria

1. **Terminal Renderer**: All basic widgets/layouts render on terminal
2. **Desktop Renderer**: All basic widgets/layouts render on desktop
3. **Web Renderer**: All basic widgets/layouts render on web
4. **Event Parity**: Events work consistently across platforms
5. **Style Adaptation**: Styles adapt appropriately per platform
6. **Multi-Platform**: Single UI definition works on all platforms
7. **Coordination**: Multiple renderers can run concurrently
8. **Test Coverage**: 80%+ coverage for all renderer code

---

## Critical Files

**New Files:**
- `lib/unified_ui/adapters/protocol.ex` - Renderer behaviour
- `lib/unified_ui/adapters/shared.ex` - Shared utilities
- `lib/unified_ui/adapters/coordinator.ex` - Multi-platform coordination
- `lib/unified_ui/adapters/terminal/renderer.ex` - Terminal renderer
- `lib/unified_ui/adapters/terminal/events.ex` - Terminal event handling
- `lib/unified_ui/adapters/terminal/server.ex` - Terminal server
- `lib/unified_ui/adapters/desktop/renderer.ex` - Desktop renderer
- `lib/unified_ui/adapters/desktop/events.ex` - Desktop event handling
- `lib/unified_ui/adapters/desktop/server.ex` - Desktop server
- `lib/unified_ui/adapters/web/renderer.ex` - Web renderer
- `lib/unified_ui/adapters/web/events.ex` - Web event handling
- `lib/unified_ui/adapters/web/server.ex` - Web server
- `test/unified_ui/integration/phase_3_test.exs` - Integration tests

**Dependencies:**
- Phase 2: Core Widgets & Layouts (widgets and layouts to render)

**Enables:**
- Phase 4: Advanced Features & Styling (renderer foundation for advanced widgets)
