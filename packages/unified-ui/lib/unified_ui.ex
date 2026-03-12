defmodule UnifiedUi do
  @moduledoc """
  A Spark-powered DSL for building multi-platform user interfaces in Elixir.

  ## Overview

  UnifiedUi provides a declarative DSL for defining user interfaces that can
  compile to terminal, desktop, and web platforms. The DSL is built on top of
  the Spark library and integrates with the Jido ecosystem for agent-based
  component communication.

  ## Architecture

  The library consists of:

  - **DSL Layer**: Spark-based declarative UI definitions
  - **IUR (Intermediate UI Representation)**: Platform-agnostic UI structs
  - **Renderers**: Platform-specific adapters (Terminal, Desktop, Web)
  - **Widgets**: Pre-built UI components
  - **Layouts**: Container components for arranging widgets

  ## Example

  ```elixir
  defmodule MyApp.MyScreen do
    use UnifiedUi.Dsl

    ui do
      vbox style: [padding: 2] do
        text "Welcome to MyApp!"
        button "Click me", on_click: fn -> {:button_clicked, %{}} end
      end
    end
  end
  ```
  """

  @doc """
  Returns the library version.
  """
  @spec version() :: String.t()
  def version, do: "0.1.0"
end
