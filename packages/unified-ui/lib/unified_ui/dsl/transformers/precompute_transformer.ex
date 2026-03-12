defmodule UnifiedUi.Dsl.Transformers.PrecomputeTransformer do
  @moduledoc """
  Spark transformer that precomputes DSL entity indexes for downstream passes.

  The index is persisted on the DSL state so transformers and verifiers can
  reuse a single traversal instead of scanning sections repeatedly.
  """

  use Spark.Dsl.Transformer

  alias UnifiedUi.Dsl.CompileIndex

  @impl true
  @spec transform(Spark.Dsl.t()) :: {:ok, Spark.Dsl.t()} | {:error, term()}
  def transform(dsl_state) do
    {:ok, CompileIndex.persist(dsl_state)}
  end

  @impl true
  @spec before?(module()) :: boolean()
  def before?(_other), do: false

  @impl true
  @spec after?(module()) :: boolean()
  def after?(_other), do: false

  @impl true
  @spec after_compile?() :: boolean()
  def after_compile?, do: false
end
