# Web Platform Guide

The web adapter converts UnifiedIUR elements into web-renderer structures suitable for browser-facing rendering layers.

## Adapter Module

- `UnifiedUi.Adapters.Web`
- Event mapper: `UnifiedUi.Adapters.Web.Events`
- Style converter: `UnifiedUi.Adapters.Web.Style`

## Typical Flow

```elixir
iur = MyScreen.view(state)
{:ok, web_tree} = UnifiedUi.Adapters.Web.render(iur)
```

## Web Considerations

- Keep DSL layout semantics renderer-agnostic.
- Avoid platform-specific assumptions in `update/2`.
- Normalize all UI events through the web events module before state transitions.

## Event Handling

```elixir
signal = UnifiedUi.Adapters.Web.Events.to_signal(:click, %{action: :submit})
{:ok, state} = MyScreen.update(state, signal)
```
