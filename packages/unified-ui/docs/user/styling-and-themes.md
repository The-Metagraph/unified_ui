# Styling and Themes

`UnifiedUi` styling is authored in canonical terms. You define theme-level
palette values and component styles once, then attach those definitions to
widgets through `theme_ref`, `style_refs`, and local `style(...)`.

## Theme Section

Themes live in the `themes` section:

```elixir
themes do
  default_theme(:workspace_dark)

  theme do
    id(:workspace)
    summary("Base workspace theme")

    palette_color do
      id(:surface)
      color(named_color(:black))
    end

    semantic_role do
      id(:primary_text)
      value(named_color(:white))
    end
  end
end
```

The supported theme declarations are:

- `theme`
- `palette_color`
- `semantic_role`
- `token`
- `component_style`

## Helper Functions

`use UnifiedUi.Dsl` imports helper functions from `UnifiedUi.Dsl.Helpers`:

- `named_color/1`
- `indexed_color/1`
- `rgb_color/3`
- `token_ref/1`
- `role_ref/1`
- `style_value/1`
- `binding_ref/1`

Those helpers let you author styling without dropping into renderer-local data
shapes.

## Reusable Theme Building Blocks

### Palette Colors

Palette colors define reusable base values:

```elixir
palette_color do
  id(:accent)
  color(named_color(:cyan))
end
```

### Semantic Roles

Semantic roles attach intent-driven meaning to a color value:

```elixir
semantic_role do
  id(:primary_text)
  value(named_color(:white))
end
```

### Tokens

Tokens capture reusable style fragments:

```elixir
token do
  id(:panel_shell)

  value(
    style_value(
      background: token_ref(:surface),
      spacing: %{padding: 2, gap: 1},
      border: %{width: 1, style: :solid}
    )
  )
end
```

### Component Styles

Component styles let you define shared styling for one component family:

```elixir
component_style do
  id(:panel_shell)
  component(:box)

  style(
    style_value(
      token_refs: [token_ref(:panel_shell)],
      foreground: role_ref(:primary_text)
    )
  )
end
```

You can scope component styles by `variant` and `state`.

## Styling Widgets

At the widget level, the main styling hooks are:

- `theme_ref(:theme_id)`
- `style_refs([:component_style_id])`
- `style(style_value(...))`
- `variant(:variant_name)`
- `tone(:tone_name)`

Example:

```elixir
box :activity_feed do
  theme_ref(:workspace_dark)
  style_refs([:panel_shell])

  text :activity_title do
    value("Activity feed")
    variant(:headline)
    tone(:info)
  end
end
```

## CSS Stylesheet Blocks

CSS stylesheet blocks are optional authoring input inside the `themes` section.
They are parsed, matched against authored nodes, resolved through cascade rules,
and lowered into canonical style data before `UnifiedIUR` output is emitted.

```elixir
themes do
  css :workspace_styles do
    source("""
    #activity_feed {
      background-color: #0f172a;
      padding: 12px 16px;
    }

    button:disabled {
      opacity: 0.45;
    }
    """)
  end
end
```

Selectors can target stable authored ids, portable classes, widget or component
kinds, supported descendant and child relationships, and supported state
pseudo-classes such as `:disabled`, `:focus`, `:selected`, and `:active`.

The `class` and `classes` widget attributes are portable selector metadata and
optional runtime hooks. They do not load a runtime stylesheet by themselves.

Accepted CSS syntax does not imply full browser CSS semantic equivalence.
Unsupported selectors, at-rules, properties, values, units, functions, and
unsafe external resources are ignored with diagnostics instead of being emitted
as raw runtime CSS.

## Supported Style Attribute Families

The canonical style model currently groups attributes into:

- `typography`
- `color`
- `spacing`
- `sizing`
- `alignment`
- `border`
- `visibility`
- `emphasis`

Representative keys include:

- typography: `font_family`, `font_size`, `font_weight`, `italic?`, `underline?`
- color: `foreground`, `background`, `border_color`, `role`
- spacing: `padding`, `padding_x`, `padding_y`, `margin`, `gap`
- sizing: `width`, `height`, `min_width`, `max_width`
- alignment: `align`, `justify`, `text_align`, `anchor`
- border: `width`, `radius`, `style`, `color`
- visibility: `hidden?`, `collapsed?`, `opacity`
- emphasis: `weight`, `intent`, `elevation`, `tone`

## State Variants

Styles can include state-specific overrides:

```elixir
style(
  style_value(
    sizing: %{width: :fill},
    alignment: %{align: :stretch},
    state_variants: %{
      focused: style_value(border_color: token_ref(:accent))
    }
  )
)
```

Supported component states currently include:

- `:default`
- `:focused`
- `:selected`
- `:disabled`
- `:active`

## Practical Guidance

- Put reusable styling in `themes`.
- Use `style_refs` when multiple widgets should share the same component style.
- Use local `style(...)` for focused per-node overrides.
- Use CSS blocks when selector-oriented authoring is clearer than repeating
  equivalent canonical style maps.
- Prefer semantic roles and tokens over hard-coded color repetition.
- Keep styling canonical; do not rely on runtime-specific CSS or renderer-local
  options here.

For a full cross-cutting example, inspect
`UnifiedUi.Examples.ThemedSignalWorkspace`.
