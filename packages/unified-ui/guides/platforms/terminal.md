# Terminal Platform Guide

The terminal adapter renders UnifiedIUR trees through TermUi-compatible structures.

## Adapter Module

- `UnifiedUi.Adapters.Terminal`
- Event mapper: `UnifiedUi.Adapters.Terminal.Events`
- Style converter: `UnifiedUi.Adapters.Terminal.Style`

## Typical Flow

```elixir
iur = MyScreen.view(state)
{:ok, term_tree} = UnifiedUi.Adapters.Terminal.render(iur)
```

## Terminal Considerations

- Keep text concise and structured for narrow widths.
- Prefer explicit spacing (`padding`, `spacing`) over deep nesting.
- Use stable IDs for deterministic key/mouse event routing.

## Event Handling

Use terminal event normalization before calling `update/2`:

```elixir
signal = UnifiedUi.Adapters.Terminal.Events.to_signal(:button_click, %{action: :save})
{:ok, state} = MyScreen.update(state, signal)
```
