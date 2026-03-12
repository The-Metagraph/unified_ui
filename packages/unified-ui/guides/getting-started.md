# Getting Started

This guide shows the shortest path to building and rendering a UnifiedUi screen.

## 1. Add Dependencies

Add UnifiedUi and its runtime dependencies to your project:

```elixir
defp deps do
  [
    {:unified_ui, "~> 0.1"},
    {:jido, git: "https://github.com/agentjido/jido.git", tag: "v2.0.0"},
    {:jido_signal, "~> 2.0"},
    {:spark, "~> 1.0"}
  ]
end
```

## 2. Define a Screen Module

Create a module that uses `UnifiedUi.Dsl` and implements Elm callbacks:

```elixir
defmodule MyApp.CounterScreen do
  @behaviour UnifiedUi.ElmArchitecture
  use UnifiedUi.Dsl

  vbox do
    spacing 1
    text "Counter"
    text_input :name, placeholder: "Name"

    hbox do
      spacing 1
      button "Increment", id: :increment_button, on_click: :increment
      button "Decrement", id: :decrement_button, on_click: :decrement
    end
  end

  @impl true
  def init(_opts), do: %{count: 0}

  @impl true
  def update(state, %Jido.Signal{data: %{action: :increment}}) do
    %{state | count: state.count + 1}
  end

  def update(state, %Jido.Signal{data: %{action: :decrement}}) do
    %{state | count: state.count - 1}
  end

  def update(state, _signal), do: state
end
```

## 3. Build IUR and Render

Use one of the platform adapters to render the resulting IUR tree:

```elixir
state = MyApp.CounterScreen.init([])
iur = MyApp.CounterScreen.view(state)
{:ok, _rendered} = UnifiedUi.Adapters.Terminal.render(iur)
```

## 4. Handle Events

Map raw adapter events into normalized signals:

```elixir
state = MyApp.CounterScreen.init([])

{:ok, signal} =
  UnifiedUi.Adapters.Terminal.Events.to_signal(
    :click,
    %{widget_id: :increment_button, action: :increment}
  )

next_state = MyApp.CounterScreen.update(state, signal)
```

## Next Steps

- Review the full widget list in `guides/widget-reference.md`.
- Add styles with the `styles` section and inline style keywords.
- Use the coordinator when rendering to multiple platforms at once.
- Build custom widgets, layouts, and renderers with `guides/extensions.md`.
