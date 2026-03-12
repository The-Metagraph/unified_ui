defmodule UnifiedUi.Dsl.Transformers.ViewTransformer do
  @moduledoc """
  Spark transformer that generates the `view/1` function for Elm Architecture.

  This transformer generates a `view/1` function that returns an IUR tree.
  For Phase 2.5, it uses the IUR.Builder to convert DSL entities into IUR structs.

  ## State Interpolation

  The generated `view/1` passes runtime state into `UnifiedUi.IUR.Builder.build/2`.
  The builder resolves DSL state references like `{:state, :key}` against the
  current runtime state map.

  ## Example

  Generates:

      @impl true
      def view(state) do
        # The builder converts DSL entities to IUR structs
        case UnifiedUi.IUR.Builder.build(__dsl_state__()) do
          nil -> %UnifiedIUR.Layouts.VBox{children: []}
          iur -> iur
        end
      end

  """

  use Spark.Dsl.Transformer
  alias UnifiedUi.Dsl.CompileIndex

  @impl true
  @spec transform(Spark.Dsl.t()) :: {:ok, Spark.Dsl.t()} | {:error, term()}
  def transform(dsl_state) do
    CompileIndex.invalidate_runtime_view_state(
      Spark.Dsl.Transformer.get_persisted(dsl_state, :module)
    )

    # For Phase 2.5, we use the IUR.Builder to convert DSL entities to IUR
    code =
      quote do
        @impl true
        def view(state) do
          view_state = UnifiedUi.Dsl.CompileIndex.runtime_view_state(__MODULE__)

          case UnifiedUi.IUR.Builder.build(view_state, state) do
            nil ->
              # Fallback to empty VBox if no entities defined
              %UnifiedIUR.Layouts.VBox{
                id: nil,
                spacing: nil,
                align_items: nil,
                children: []
              }

            iur ->
              iur
          end
        end
      end

    {:ok, Spark.Dsl.Transformer.eval(dsl_state, [], code)}
  end

  @doc """
  Indicates whether this transformer should run before another transformer.
  """
  @impl true
  @spec before?(module()) :: boolean()
  def before?(_other), do: false

  @doc """
  Indicates whether this transformer should run after another transformer.
  """
  @impl true
  @spec after?(module()) :: boolean()
  def after?(_other), do: false

  @doc """
  Indicates whether this transformer runs in the after-compile phase.
  """
  @impl true
  @spec after_compile?() :: boolean()
  def after_compile?, do: false
end
