# Phase 3.8: Renderer Coordination

**Date Started:** 2025-02-08
**Date Completed:** 2025-02-08
**Branch:** `feature/phase-3.8-renderer-coordination`
**Status:** ✅ Complete

---

## Overview

This feature implements coordination between renderers for multi-platform support. It allows a single UI definition to render on multiple platforms simultaneously, with platform detection, renderer selection, state synchronization, and concurrent renderer support.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.8)

---

## Problem Statement

Phases 3.2-3.7 implemented individual renderers (Terminal, Desktop, Web) with their own event handling, but there's no mechanism to:
1. Coordinate rendering across multiple platforms
2. Detect the current platform for conditional behavior
3. Select the appropriate renderer(s) for a given context
4. Synchronize state across multiple active renderers
5. Run multiple renderers concurrently without conflicts

We need a coordinator module to unify these capabilities.

---

## Solution Overview

Implement `UnifiedUi.Renderers.Coordinator` module that:
1. Detects the current platform (terminal, desktop, web)
2. Selects appropriate renderer(s) based on configuration
3. Manages concurrent renderer instances
4. Synchronizes state across platforms via Jido agents
5. Provides a unified interface for multi-platform rendering

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Platform detection via environment | Reliable detection of runtime context |
| Single coordinator per UI instance | Avoids conflicts between renderers |
| State shared via Jido agents | Leverages existing agent architecture |
| Concurrent renderer support | Allows simultaneous multi-platform rendering |
| No GenServer yet | Coordination is synchronous for now |

---

## Technical Details

### Files to Create

1. **`lib/unified_ui/renderers/coordinator.ex`** (estimated ~400 lines)
   - Platform detection logic
   - Renderer selection logic
   - Multi-platform rendering orchestration
   - State synchronization helpers

2. **`test/unified_ui/renderers/coordinator_test.exs`** (estimated ~400 lines)
   - Unit tests for coordination logic

### Dependencies

**Internal:**
- `UnifiedUi.Renderers.Terminal` - Terminal renderer
- `UnifiedUi.Renderers.Desktop` - Desktop renderer
- `UnifiedUi.Renderers.Web` - Web renderer
- `UnifiedUi.Renderers.Protocol` - Renderer behavior

**External:**
- None for this phase (GenServer integration in future)

---

## Success Criteria

1. Platform detection works (terminal, desktop, web)
2. Renderer selection is correct (based on platform/config)
3. Multi-platform rendering works (same UI on multiple platforms)
4. State synchronization works across platforms
5. Concurrent renderers don't conflict
6. All tests pass
7. Documentation is complete

---

## Implementation Plan

### Task 3.8.1: Create Coordinator Module

- [x] Create `lib/unified_ui/renderers/coordinator.ex` (400+ lines)
- [x] Define platform types
- [x] Add module documentation

### Task 3.8.2: Implement Platform Detection

- [x] `detect_platform/0` - Auto-detect current platform
- [x] `is_terminal?/0` - Check if running in terminal
- [x] `is_desktop?/0` - Check if running in desktop environment
- [x] `is_web?/0` - Check if running in web environment
- [x] `supports_platform?/1` - Check if platform is available

### Task 3.8.3: Implement Multi-Platform Rendering

- [x] `render_all/2` - Render UI on all available platforms
- [x] `render_on/3` - Render UI on specific platform(s)
- [x] `concurrent_render/3` - Render UI on multiple platforms concurrently
- [x] Collect results from all renderers

### Task 3.8.4: Implement Renderer Selection

- [x] `select_renderer/1` - Select renderer for platform
- [x] `select_renderers/1` - Select multiple renderers
- [x] `available_renderers/0` - List available renderers
- [x] `enabled_renderers/0` - List enabled renderers

### Task 3.8.5: Implement State Synchronization

- [x] `sync_state/2` - Synchronize state across platforms
- [x] `merge_states/1` - Merge state from multiple sources
- [x] `conflict_resolution/2` - Resolve state conflicts
- [x] `broadcast_state/2` - Broadcast state to all renderers

### Task 3.8.6: Add Concurrent Renderer Support

- [x] `concurrent_render/3` - Render concurrently on multiple platforms
- [x] Handle renderer errors without affecting others
- [x] Aggregate results from all renderers
- [x] Timeout handling for slow renderers

### Task 3.8.7: Write Unit Tests

- [x] Test platform detection works
- [x] Test renderer selection is correct
- [x] Test UI renders on all platforms
- [x] Test state syncs across platforms
- [x] Test concurrent renderers don't conflict
- [x] Test error handling for unavailable renderers
- [x] Test integration scenarios

---

## Current Status

**Last Updated:** 2025-02-08

### What Works
- Platform detection (terminal, desktop, web)
- Renderer selection (single and multiple)
- Multi-platform rendering (same UI on multiple platforms)
- Concurrent rendering with timeout support
- State synchronization (merge, conflict resolution)
- Error handling for unavailable renderers
- All 43 tests pass

### What's Next
- GenServer for coordinator lifecycle (future phase)
- Dynamic renderer registration
- Renderer health monitoring
- Automatic fallback on renderer failure

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/renderers/coordinator_test.exs
```

---

## Notes/Considerations

### Platform Detection

**Terminal Environment:**
- Check if `TTY` is available
- Check for terminal-specific environment variables
- Default when no GUI detected

**Desktop Environment:**
- Check for desktop environment variables
- Check for GUI framework availability
- Check OS type (Linux, macOS, Windows)

**Web Environment:**
- Check for Phoenix/Plug context
- Check for HTTP connection
- Check for WebSocket presence

### State Synchronization Strategy

1. **Source of Truth**: Jido Agent holds canonical state
2. **Broadcast**: State changes broadcast to all renderers
3. **Conflict Resolution**: Last-write-wins or custom resolver
4. **Event Ordering**: Signals ordered by timestamp

### Concurrent Rendering

```elixir
# Render on all platforms concurrently
{:ok, results} = Coordinator.render_multi(iur, [:terminal, :desktop, :web])

# Result format
%{
  terminal: {:ok, terminal_render_tree},
  desktop: {:ok, desktop_render_tree},
  web: {:ok, html_render_tree}
}
```

### Error Handling

- Individual renderer failures don't affect others
- Results include error information for failed renderers
- Timeout option for slow/missing renderers

### Platform Types

```elixir
@type platform :: :terminal | :desktop | :web
@type platforms :: [platform()]
```

### Renderer Selection Logic

```elixir
# Auto-detect platform
platform = Coordinator.detect_platform()

# Manual selection
platforms = [:terminal, :web]  # Render on specific platforms

# All available
platforms = Coordinator.available_renderers()
```

### Future Enhancements

- GenServer for coordinator lifecycle
- Dynamic renderer registration
- Renderer health monitoring
- Automatic fallback on renderer failure
- Platform capability queries

---

## Dependencies

**Depends on:**
- Phase 3.2: Terminal Renderer (basic rendering)
- Phase 3.3: Desktop Renderer (basic rendering)
- Phase 3.4: Web Renderer (basic rendering)
- Phase 3.5-3.7: Event Handling (for full integration)

**Enables:**
- Multi-platform applications
- Phase 3.9: Integration Tests

---

## Tracking

**Tasks:** 30 tasks (30 core tasks completed)
**Completed:** 30/30 core tasks
**Status:** ✅ Complete
