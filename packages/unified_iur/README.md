# UnifiedIUR

**Intermediate UI Representation** - Pure data structures for user interfaces.

UnifiedIUR provides simple, immutable data structures that represent UI elements without any rendering logic or platform dependencies. This allows the `unified_ui` DSL and platform libraries (TermUi, DesktopUi, WebUi) to share a common UI representation.

## Installation

Add `unified_iur` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unified_iur, "~> 0.1.0"}
  ]
end
```

## Overview

UnifiedIUR contains three main types of UI elements:

- **Widgets** - Basic UI components (Text, Button, Label, TextInput, Gauge, Sparkline, BarChart, LineChart, Column, Table)
- **Layouts** - Container elements (VBox, HBox)
- **Style** - Visual styling attributes

## Usage

### Creating IUR structs directly

```elixir
# Create a button widget
button = %UnifiedIUR.Widgets.Button{
  id: :submit,
  label: "Submit",
  on_click: :submit
}

# Create a text widget
text = %UnifiedIUR.Widgets.Text{
  content: "Hello, World!"
}

# Create a style
style = %UnifiedIUR.Style{
  fg: :blue,
  attrs: [:bold]
}
```

### Using the Element protocol

```elixir
# Get element metadata
metadata = UnifiedIUR.Element.metadata(button)
# => %{type: :button, id: :submit, label: "Submit", ...}

# Get children (for layouts)
children = UnifiedIUR.Element.children(vbox)
# => [%Text{...}, %Button{...}]
```

## Platform Integration

Platform libraries can consume UnifiedIUR by implementing converters that transform IUR structs into their native format:

```elixir
# Example: TermUi renderer
defmodule TermUi.Renderers.IUR do
  alias UnifiedIUR.Widgets

  def render(%Widgets.Button{label: label} = button) do
    TermUI.Button.button(label)
    |> TermUI.Component.Helpers.styled(style_from(button))
  end
end
```

## License

MIT License
