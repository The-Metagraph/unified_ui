# Desktop UI Demo

A standalone demo application for `desktop_ui` showcasing all available widgets with interactive navigation.

## Features

- **Sidebar Navigation**: Category-based widget browser with clickable links
- **Topbar Menu**: Organized menu with widget categories and submenus
- **Screen Navigation**: Navigate between widgets using the Phase 12 navigation system
- **Widget Demos**: Interactive examples for each widget type
- **Search**: Quick widget search functionality

## Widget Categories

- **Content** (9 widgets): button, text, icon, image, label, link, separator, spacer
- **Layout** (5 widgets): box, content, row, column, grid
- **Forms** (3 widgets): form_builder, field_group, field
- **Input** (9 widgets): text_input, numeric_input, toggle, checkbox, radio_group, select, pick_list, date_input, time_input, file_input
- **Navigation** (4 widgets): menu, tabs, breadcrumbs, list
- **Data** (4 widgets): table, tree_view, markdown_viewer, log_viewer
- **Feedback** (7 widgets): status, progress, gauge, sparkline, bar_chart, line_chart
- **Display** (4 widgets): viewport, scroll_bar, split_pane, canvas
- **Overlay** (5 widgets): overlay, dialog, alert_dialog, context_menu, toast
- **Operational** (4 widgets): stream_widget, process_monitor, supervision_tree, cluster_dashboard

## Running the Demo

```bash
cd demo
mix deps.get
mix run
```

## Project Structure

```
demo/
├── mix.exs                           # Mix project configuration
├── config/
│   └── config.ex                     # Application configuration
├── lib/
│   └── demo/
│       ├── app.ex                    # Application entry point
│       ├── screens.ex               # Screen registry
│       ├── screens/
│       │   ├── main.ex              # Main demo screen
│       │   ├── home.ex              # Home screen
│       │   └── widget_screen.ex     # Generic widget screen
│       └── widgets/
│           ├── sidebar.ex           # Navigation sidebar
│           ├── topbar.ex            # Application topbar
│           └── content_area.ex      # Content area widget
└── README.md                         # This file
```

## Navigation

The demo uses the `DesktopUi.Navigation.Controller` for screen-to-screen navigation:

- **Home Screen**: Overview with category links
- **Widget Screens**: Individual demos for each widget
- **History**: Back/forward navigation support
- **Sidebar**: Category-based navigation
- **Topbar Menu**: Category menu with widget submenus
