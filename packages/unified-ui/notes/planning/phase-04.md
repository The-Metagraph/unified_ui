# Phase 4: Advanced Features & Styling

This phase expands the widget library to include all TermUi widgets, implements advanced layouts, creates a comprehensive theming system, and adds advanced features like data visualization and monitoring widgets.

---

## 4.1 Data Visualization Widgets

- [x] **Task 4.1** Implement data visualization widgets (gauge, sparkline, charts)

Create widget entities and renderer support for data visualization components.

- [x] 4.1.1 Define `@gauge_entity` with schema:
  - args: `[:id, value]`
  - options: `min`, `max`, `label`, `width`, `height`, `color_zones`
- [x] 4.1.2 Define `@sparkline_entity` with schema:
  - args: `[:id, data]`
  - options: `width`, `height`, `color`, `show_dots`, `show_area`
- [x] 4.1.3 Define `@bar_chart_entity` with schema:
  - args: `[:id, data]`
  - options: `width`, `height`, `orientation`, `show_labels`
- [x] 4.1.4 Define `@line_chart_entity` with schema:
  - args: `[:id, data]`
  - options: `width`, `height`, `show_dots`, `show_area`
- [x] 4.1.5 Create target and IUR structs
- [x] 4.1.6 Implement terminal renderer converters
- [x] 4.1.7 Implement desktop renderer converters
- [x] 4.1.8 Implement web renderer converters (SVG-based)

**Implementation Notes:**
- Data: list of {label, value} tuples
- Terminal: ASCII/block characters
- Desktop: native chart widgets
- Web: SVG or canvas-based charts

**Unit Tests for Section 4.1:**
- [x] Test gauge entity and conversion
- [x] Test sparkline entity and conversion
- [x] Test bar_chart entity and conversion
- [x] Test line_chart entity and conversion
- [x] Test all platforms render charts

---

## 4.2 Table Widget

- [x] **Task 4.2** Implement the table widget for tabular data display

Create a comprehensive table widget with sorting, selection, and scrolling.

- [x] 4.2.1 Define `@column_entity` (nested) with schema:
  - args: `[:key, header]`
  - options: `sortable`, `formatter`, `width`, `align`
- [x] 4.2.2 Define `@table_entity` with schema:
  - args: `[:id, data]`
  - options: `columns`, `selected_row`, `height`, `on_row_select`, `on_sort`
- [x] 4.2.3 Create target and IUR structs
- [x] 4.2.4 Implement terminal renderer converter
- [x] 4.2.5 Implement desktop renderer converter
- [x] 4.2.6 Implement web renderer converter
- [x] 4.2.7 Add sorting logic
- [x] 4.2.8 Add selection handling

**Implementation Notes:**
- Data: list of maps or keyword lists
- Formatter: `fn value -> formatted_value end`
- Terminal: scrollable table with headers
- Desktop: native table widget
- Web: HTML table with sortable headers

**Unit Tests for Section 4.2:**
- [x] Test table entity with columns
- [x] Test table with map data
- [x] Test table with formatter function
- [x] Test table sorting emits signal
- [x] Test table selection emits signal
- [x] Test all platforms render tables

---

## 4.3 Navigation Widgets

- [x] **Task 4.3** Implement navigation widgets (menu, tabs, tree_view)

Create widgets for navigation: menus, tabs, and tree views.

- [x] 4.3.1 Define `@menu_item_entity` (nested) with schema:
  - args: `[:label]`
  - options: `id`, `action`, `disabled`, `submenu`
- [x] 4.3.2 Define `@menu_entity` with schema:
  - args: `[:id, items]`
  - options: `title`, `position`
- [x] 4.3.3 Define `@context_menu_entity` with schema:
  - args: `[:id, items]`
  - options: `trigger_on`
- [x] 4.3.4 Define `@tab_entity` (nested) with schema:
  - args: `[:id, label]`
  - options: `icon`, `disabled`, `content`
- [x] 4.3.5 Define `@tabs_entity` with schema:
  - args: `[:id, tabs]`
  - options: `position`, `active_tab`, `on_change`
- [x] 4.3.6 Define `@tree_node_entity` (nested data)
- [x] 4.3.7 Define `@tree_view_entity` with schema:
  - args: `[:id, root_nodes]`
  - options: `selected_node`, `expanded_nodes`, `on_select`
- [x] 4.3.8 Create target and IUR structs
- [x] 4.3.9 Implement renderer converters for all platforms

**Implementation Notes:**
- Items can have nested submenus
- Tabs: only active tab content rendered
- Tree: hierarchical data with expand/collapse
- Keyboard navigation for all

**Unit Tests for Section 4.3:**
- [x] Test menu entity with nested items
- [x] Test context_menu entity
- [x] Test tabs entity with multiple tabs
- [x] Test tab switching works
- [x] Test tree_view entity
- [x] Test tree expand/collapse
- [x] Test keyboard navigation
- [x] Test all platforms render navigation widgets

---

## 4.4 Dialog and Feedback Widgets

- [x] **Task 4.4** Implement dialog and feedback widgets (dialog, alert_dialog, toast)

Create modal dialogs and notification widgets.

- [x] 4.4.1 Define `@dialog_button_entity` (nested)
- [x] 4.4.2 Define `@dialog_entity` with schema:
  - args: `[:id, title, content]`
  - options: `buttons`, `on_close`, `width`, `height`, `closable`
- [x] 4.4.3 Define `@alert_dialog_entity` with schema:
  - args: `[:id, title, message]`
  - options: `severity`, `on_confirm`, `on_cancel`
- [x] 4.4.4 Define `@toast_entity` with schema:
  - args: `[:id, message]`
  - options: `severity`, `duration`, `on_dismiss`
- [x] 4.4.5 Create target and IUR structs
- [x] 4.4.6 Implement renderer converters for all platforms
- [x] 4.4.7 Implement modal behavior
- [x] 4.4.8 Implement auto-dismiss for toast

**Implementation Notes:**
- Dialog content can be nested layouts
- AlertDialog severity affects styling
- Toast: duration 0 means no auto-dismiss
- Modal blocks input to underlying UI

**Unit Tests for Section 4.4:**
- [x] Test dialog entity with content
- [x] Test dialog close signal
- [x] Test alert_dialog severity
- [x] Test toast auto-dismiss
- [x] Test modal behavior blocks background
- [x] Test all platforms render dialogs

---

## 4.5 Input Widgets

- [x] **Task 4.5** Implement advanced input widgets (pick_list, form_builder)

Create specialized input widgets for data entry.

- [x] 4.5.1 Define `@pick_list_option_entity` (nested)
- [x] 4.5.2 Define `@pick_list_entity` with schema:
  - args: `[:id, options]`
  - options: `selected`, `placeholder`, `searchable`, `on_select`, `allow_clear`
- [x] 4.5.3 Define `@form_field_entity` (nested)
- [x] 4.5.4 Define `@form_builder_entity` with schema:
  - args: `[:id, fields]`
  - options: `action`, `on_submit`, `submit_label`
- [x] 4.5.5 Define field types
- [x] 4.5.6 Create target and IUR structs
- [x] 4.5.7 Implement renderer converters for all platforms
- [x] 4.5.8 Implement form validation
- [x] 4.5.9 Implement search/filter for pick_list

**Implementation Notes:**
- PickList options: list of {value, label}
- Searchable enables text input filter
- FormBuilder fields: text, password, email, number, select, checkbox
- Validation runs on submit

**Unit Tests for Section 4.5:**
- [x] Test pick_list with options
- [x] Test pick_list search/filter
- [x] Test pick_list selection emits signal
- [x] Test form_builder with fields
- [x] Test form validation
- [x] Test form submission signal
- [x] Test all platforms render input widgets

---

## 4.6 Container Widgets

- [x] **Task 4.6** Implement container widgets (viewport, split_pane)

Create containers for scrollable content and resizable panes.

- [x] 4.6.1 Define `@viewport_entity` with schema:
  - args: `[:id, content]`
  - options: `width`, `height`, `scroll_x`, `scroll_y`, `on_scroll`, `border`
- [x] 4.6.2 Define `@split_pane_entity` with schema:
  - args: `[:id, panes]`
  - options: `orientation`, `initial_split`, `min_size`, `on_resize_change`
- [x] 4.6.3 Create target and IUR structs
- [x] 4.6.4 Implement renderer converters for all platforms
- [x] 4.6.5 Implement viewport scrolling state
- [x] 4.6.6 Implement split_pane resize state

**Implementation Notes:**
- Viewport clips content to dimensions
- SplitPane panes: list of two contents
- Initial_split: percentage (0-100)
- on_resize_change includes new split percentage

**Unit Tests for Section 4.6:**
- [x] Test viewport clips content
- [x] Test viewport scrolling emits signal
- [x] Test split_pane with two panes
- [x] Test split_pane resize emits signal
- [x] Test all platforms render containers

---

## 4.7 Specialized Widgets

- [x] **Task 4.7** Implement specialized widgets (canvas, command_palette)

Create widgets for custom drawing and command discovery.

- [x] 4.7.1 Define `@canvas_entity` with schema:
  - args: `[:id]`
  - options: `width`, `height`, `draw`, `on_click`, `on_hover`
- [x] 4.7.2 Define drawing context protocol:
  - `draw_text/3`, `draw_line/5`, `draw_rect/4`, `clear/0`
- [x] 4.7.3 Define `@command_entity` (nested)
- [x] 4.7.4 Define `@command_palette_entity` with schema:
  - args: `[:id, commands]`
  - options: `placeholder`, `trigger_shortcut`, `on_select`
- [x] 4.7.5 Create target and IUR structs
- [x] 4.7.6 Implement renderer converters for all platforms
- [x] 4.7.7 Implement drawing context per platform
- [x] 4.7.8 Implement command palette search

**Implementation Notes:**
- Canvas: drawing function receives context
- Terminal: ASCII/block characters
- Desktop: native drawing API
- Web: HTML5 Canvas
- Command palette: search filters by label

**Unit Tests for Section 4.7:**
- [x] Test canvas with draw function
- [x] Test drawing context works
- [x] Test canvas click events
- [x] Test command_palette with commands
- [x] Test command_palette search
- [x] Test all platforms render specialized widgets

---

## 4.8 Monitoring Widgets

- [x] **Task 4.8** Implement monitoring widgets (log_viewer, process_monitor)

Create widgets for system monitoring and inspection.

- [x] 4.8.1 Define `@log_viewer_entity` with schema:
  - args: `[:id]`
  - options: `source`, `lines`, `auto_scroll`, `filter`
- [x] 4.8.2 Define `@stream_widget_entity` with schema:
  - args: `[:id, producer]`
  - options: `transform`, `buffer_size`, `on_item`
- [x] 4.8.3 Define `@process_monitor_entity` with schema:
  - args: `[:id]`
  - options: `node`, `refresh_interval`, `sort_by`, `on_process_select`
- [x] 4.8.4 Create target and IUR structs
- [x] 4.8.5 Implement renderer converters for terminal
- [x] 4.8.6 Implement renderer converters for desktop
- [x] 4.8.7 Implement renderer converters for web
- [x] 4.8.8 Implement auto-refresh

**Implementation Notes:**
- LogViewer: tails a log source (file or GenServer)
- StreamWidget: consumes from GenStage producer
- ProcessMonitor: queries :erlang.process_info
- All support auto-refresh intervals

**Unit Tests for Section 4.8:**
- [x] Test log_viewer with test source
- [x] Test log_viewer auto-scroll
- [x] Test stream_widget with producer
- [x] Test process_monitor returns data
- [x] Test auto-refresh works
- [x] Test all platforms render monitoring widgets

---

## 4.9 Advanced Layout System

- [x] **Task 4.9** Implement advanced layout containers (grid, stack, zbox)

Create advanced layout containers for complex UI arrangements.

- [x] 4.9.1 Define `@grid_entity` with schema:
  - args: `[:children]`
  - options: `id`, `columns`, `rows`, `gap`
- [x] 4.9.2 Define `@stack_entity` with schema:
  - args: `[:id, children]`
  - options: `active_index`, `transition`
- [x] 4.9.3 Define `@zbox_entity` with schema:
  - args: `[:id, children]`
  - options: `positions`
- [x] 4.9.4 Create target and IUR structs
- [x] 4.9.5 Implement renderer converters for all platforms
- [x] 4.9.6 Implement grid sizing (flexible units)
- [x] 4.9.7 Implement stack tab switching
- [x] 4.9.8 Implement zbox absolute positioning

**Implementation Notes:**
- Grid columns/rows use: integer, "1fr", "auto"
- Stack shows only active_index child
- Zbox positions children at absolute coordinates
- Terminal approximates with character cells

**Unit Tests for Section 4.9:**
- [x] Test grid with flexible sizing
- [x] Test stack active_index switching
- [x] Test zbox absolute positioning
- [x] Test nested advanced layouts
- [x] Test all platforms render advanced layouts

---

## 4.10 Comprehensive Theming System

- [x] **Task 4.10** Implement comprehensive theming and styling system

Create a complete theming system with named styles, themes, and platform adaptation.

- [x] 4.10.1 Expand `@style_entity` with full attribute support
- [x] 4.10.2 Define `@theme_entity` with schema:
  - args: `[:name]`
  - options: `styles`, `base_theme`
- [x] 4.10.3 Define all style attributes:
  - Colors: fg, bg (RGB/hex support)
  - Typography: font_family, font_size, font_weight
  - Spacing: padding, margin
  - Borders: border (width, color, style)
- [x] 4.10.4 Create style resolver module
- [x] 4.10.5 Implement style inheritance
- [x] 4.10.6 Implement theme loading
- [x] 4.10.7 Implement platform style adaptation:
  - Terminal: ANSI codes
  - Desktop: native styles
  - Web: CSS
- [x] 4.10.8 Define standard themes (default, dark, light)
- [x] 4.10.9 Add theme switching at runtime

**Implementation Notes:**
- Styles can extend other styles
- Themes are collections of named styles
- Style resolution: atom → style def → merged attributes
- Platform-specific adaptation per renderer
- Runtime theme switching via signal

**Unit Tests for Section 4.10:**
- [x] Test style with all attributes
- [x] Test style inheritance
- [x] Test theme loads correctly
- [x] Test theme switching works
- [x] Test terminal style conversion
- [x] Test desktop style conversion
- [x] Test web style conversion (CSS)
- [x] Test standard themes load

---

## 4.11 Phase 4 Integration Tests

Comprehensive integration tests to verify all advanced widgets and features work correctly.

- [x] 4.11.1 Test all advanced widgets on all platforms
- [x] 4.11.2 Test all advanced layouts on all platforms
- [x] 4.11.3 Test theming system on all platforms
- [x] 4.11.4 Test theme switching works
- [x] 4.11.5 Test complex dashboard with all widget types
- [x] 4.11.6 Test data visualization with live data
- [x] 4.11.7 Test form validation and submission
- [x] 4.11.8 Test navigation widget interactions
- [x] 4.11.9 Test monitoring widgets with live data
- [x] 4.11.10 Test performance with 200+ element UI

**Implementation Notes:**
- Create comprehensive example dashboard
- Test all widget types
- Test all layout combinations
- Measure performance
- Test memory usage

**Unit Tests for Section 4.11:**
- [x] Test dashboard compiles
- [x] Test dashboard renders on all platforms
- [x] Test all widgets functional
- [x] Test performance acceptable
- [x] Test memory usage reasonable

---

## Success Criteria

1. **Widget Parity**: All TermUi widgets available in DSL
2. **Advanced Layouts**: Grid, stack, zbox layouts working
3. **Theming**: Comprehensive theming system with runtime switching
4. **Platform Support**: All widgets work on all three platforms
5. **Data Visualization**: Charts and gauges working
6. **Navigation**: Menus, tabs, tree views working
7. **Forms**: Complete form support with validation
8. **Monitoring**: Log viewer and process monitor working
9. **Performance**: Responsive UIs with 200+ elements
10. **Test Coverage**: 80%+ coverage for all new code

---

## Critical Files

**New Files:**
- `lib/unified_ui/dsl/entities/widgets_advanced.ex` - Advanced widget entities
- `lib/unified_ui/dsl/entities/layouts_advanced.ex` - Advanced layout entities
- `lib/unified_ui/dsl/entities/themes.ex` - Theme entities
- `lib/unified_ui/widgets/` - All widget target structs
- `lib/unified_ui/layouts/` - All layout target structs
- `lib/unified_ui/iur/widgets_advanced.ex` - Advanced IUR structs
- `lib/unified_ui/adapters/terminal/renderer.ex` - Terminal advanced converters
- `lib/unified_ui/adapters/desktop/renderer.ex` - Desktop advanced converters
- `lib/unified_ui/adapters/web/renderer.ex` - Web advanced converters
- `lib/unified_ui/styles/` - Complete style system
- `test/unified_ui/integration/phase4_test.exs` - Integration tests

**Modified Files:**
- `lib/unified_ui/dsl/extension.ex` - Add new entities and sections
- `lib/unified_ui/adapters/terminal/renderer.ex` - Add widget converters
- `lib/unified_ui/adapters/desktop/renderer.ex` - Add widget converters
- `lib/unified_ui/adapters/web/renderer.ex` - Add widget converters

---

## Dependencies

**Depends on:**
- Phase 3: Renderer Implementations (adapter foundation)

**Enables:**
- Phase 5: Testing, Docs & Tooling (complete widget library for documentation)
