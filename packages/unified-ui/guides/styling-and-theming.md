# Styling And Theming

UnifiedUi supports inline styles and named styles resolved at compile/runtime.

## Inline Style

```elixir
text "Header", style: [fg: :cyan, attrs: [:bold], padding: 1]
```

## Named Styles

```elixir
styles do
  style :header do
    attributes [fg: :cyan, attrs: [:bold], padding: 1]
  end

  style :primary_button do
    attributes [bg: :blue, fg: :white, padding: 1]
  end
end
```

## Common Style Keys

- colors: `fg`, `bg`
- text attributes: `attrs`
- spacing: `padding`, `margin`
- dimensions: `width`, `height`
- alignment: `align`

## Resolution Flow

1. DSL stores inline and named style declarations.
2. `UnifiedUi.Dsl.StyleResolver` builds a concrete `UnifiedIUR.Style`.
3. Adapter-specific style modules map IUR style to platform output.

## Platform Notes

- Terminal styles map to ANSI/text UI attributes.
- Desktop and Web adapters translate style maps to renderer-friendly props.
- Unsupported style keys should be treated as no-ops by adapters.

## Best Practices

- Prefer named styles for shared semantics (`:error_text`, `:primary_button`).
- Use inline styles for one-off adjustments.
- Keep style names domain-oriented rather than visual-only when possible.
