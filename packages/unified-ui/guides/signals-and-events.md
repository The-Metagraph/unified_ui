# Signals And Events

UnifiedUi normalizes platform events into signals consumed by `update/2`.

## Signal Shapes

Event handlers in DSL entities can use:

- atom: `:submit`
- tuple: `{:submit, %{source: :login_form}}`
- MFA tuple: `{MyModule, :handle_submit, []}`

## Event Normalization

Each adapter has an events module:

- `UnifiedUi.Adapters.Terminal.Events`
- `UnifiedUi.Adapters.Desktop.Events`
- `UnifiedUi.Adapters.Web.Events`

These translate platform-native event payloads into a consistent `Jido.Signal` structure.

## Update Loop

```elixir
@impl true
def update(state, %Jido.Signal{type: "unified.button.clicked", data: %{action: :increment}}) do
  {:ok, %{state | count: state.count + 1}}
end
```

## Routing Guidelines

- Keep action identifiers stable (`:increment`, `:save`, `:cancel`).
- Prefer explicit payload keys over positional assumptions.
- Treat unhandled signals as no-ops and return `{:ok, state}`.

## Inter-Component Messaging

For agent-driven flows, use `UnifiedUi.Signals` helpers and `JidoSignal` conventions so messages stay portable across render targets.
