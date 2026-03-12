# Desktop Platform Guide

The desktop adapter converts UnifiedIUR elements into desktop-renderer structures.

## Adapter Module

- `UnifiedUi.Adapters.Desktop`
- Event mapper: `UnifiedUi.Adapters.Desktop.Events`
- Style converter: `UnifiedUi.Adapters.Desktop.Style`

## Typical Flow

```elixir
iur = MyScreen.view(state)
{:ok, desktop_tree} = UnifiedUi.Adapters.Desktop.render(iur)
```

## Desktop Considerations

- Preserve semantic IDs and action names for consistent event handling.
- Keep styles declarative and adapter-neutral at DSL level.
- Use coordinator APIs when running desktop + another target simultaneously.

## Event Handling

```elixir
signal = UnifiedUi.Adapters.Desktop.Events.to_signal(:click, %{action: :open_settings})
{:ok, state} = MyScreen.update(state, signal)
```
