defmodule UnifiedUi.Dsl.Sections.Signals do
  @moduledoc """
  Canonical signals section definition used by the UnifiedUi DSL.
  """

  @signals_section %Spark.Dsl.Section{
    name: :signals,
    describe: """
    Signal type definitions for inter-component communication.
    """,
    schema: [
      name: [
        type: :atom,
        doc: "Signal name.",
        required: true
      ],
      payload: [
        type: :keyword_list,
        doc: "Optional payload schema.",
        required: false
      ],
      description: [
        type: :string,
        doc: "Optional signal description.",
        required: false
      ]
    ],
    entities: []
  }

  @doc false
  @spec section() :: Spark.Dsl.Section.t()
  def section, do: @signals_section

  @doc false
  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities, do: @signals_section.entities

  @doc false
  @spec top_level?() :: boolean()
  def top_level?, do: false

  @doc false
  @spec name() :: atom()
  def name, do: @signals_section.name

  @doc """
  Returns the list of standard signal types.
  """
  @spec standard_signals() :: [UnifiedUi.Signals.signal_name()]
  defdelegate standard_signals, to: UnifiedUi.Signals
end
