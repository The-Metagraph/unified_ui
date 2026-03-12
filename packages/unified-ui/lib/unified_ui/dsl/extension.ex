defmodule UnifiedUi.Dsl.Extension do
  @moduledoc """
  The Spark DSL Extension for UnifiedUi.

  This extension defines the DSL constructs for building multi-platform user interfaces.
  It provides sections for UI definitions, widgets, layouts, styles, and signals.

  ## Usage

  To use the UnifiedUi DSL in your module:

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

  ## DSL Structure

  The DSL is organized into sections:

  * `:ui` - Top-level section for UI definitions
  * `:widgets` - Widget entity definitions (text, button, label, text_input, etc.)
  * `:layouts` - Layout entity definitions (vbox, hbox, grid, etc.)
  * `:styles` - Style and theme definitions
  * `:signals` - Signal type definitions for inter-component communication

  ## Sections

  ### UI Section

  The `ui` section is the top-level entry point for defining UIs.
  It can contain layouts and widgets.

  ### Widgets Section

  The `widgets` section contains individual widget definitions.
  Widgets are the basic building blocks of a UI (text, buttons, inputs, etc.).

  ### Layouts Section

  The `layouts` section contains layout containers that arrange widgets.
  Layouts can contain other layouts and widgets.

  ### Styles Section

  The `styles` section defines visual styling options.
  Styles include colors, fonts, spacing, and other visual properties.

  ### Signals Section

  The `signals` section defines signal types for inter-component communication.
  Signals are used with the JidoSignal library for agent-based communication.

  """

  @behaviour Spark.Dsl.Extension

  require Spark.Dsl.Extension

  alias UnifiedUi.Dsl.Sections

  @sections [
    Sections.Ui.section(),
    Sections.Widgets.section(),
    Sections.Layouts.section(),
    Sections.Styles.section(),
    Sections.Signals.section()
  ]

  Spark.Dsl.Extension.build(__MODULE__, __MODULE__, @sections, [])

  @transformers [
    UnifiedUi.Dsl.Transformers.PrecomputeTransformer,
    UnifiedUi.Dsl.Transformers.InitTransformer,
    UnifiedUi.Dsl.Transformers.UpdateTransformer,
    UnifiedUi.Dsl.Transformers.JidoAgentTransformer,
    UnifiedUi.Dsl.Transformers.ViewTransformer
  ]

  @verifiers [
    UnifiedUi.Dsl.Verifiers.EntityUniquenessVerifier,
    UnifiedUi.Dsl.Verifiers.UniqueIdVerifier,
    UnifiedUi.Dsl.Verifiers.LayoutStructureVerifier,
    UnifiedUi.Dsl.Verifiers.SignalHandlerVerifier,
    UnifiedUi.Dsl.Verifiers.RequiredAttributeVerifier,
    UnifiedUi.Dsl.Verifiers.StyleReferenceVerifier,
    UnifiedUi.Dsl.Verifiers.StateReferenceVerifier
  ]

  @info_sections [:signals]

  @spec sections() :: [Spark.Dsl.Section.t()]
  def sections, do: @sections

  @spec transformers() :: [module()]
  def transformers, do: @transformers

  @spec verifiers() :: [module()]
  def verifiers, do: @verifiers

  @doc """
  Sections exposed via `UnifiedUi.Info`.
  """
  @spec info_sections() :: [atom()]
  def info_sections, do: @info_sections

  @doc """
  Info module for UnifiedUi DSL introspection.
  """
  @spec info_module() :: module()
  def info_module, do: UnifiedUi.Info

  @spec add_extensions() :: [module()]
  def add_extensions, do: []

  @spec dsl_patches() :: [term()]
  def dsl_patches, do: []

  @spec module_imports() :: [module()]
  def module_imports, do: []

  @spec module_prefix() :: term()
  def module_prefix, do: __MODULE__

  @spec persisters() :: [module()]
  def persisters, do: []
end
