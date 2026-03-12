defmodule UnifiedUi.Dsl.Transformers.InitTransformer do
  @moduledoc """
  Spark transformer that generates the `init/1` function for Elm Architecture.

  This transformer extracts the initial state from the DSL `state` entity
  and generates an `init/1` function that returns it as a map with atom keys.

  ## Example

  Given DSL with:

      ui do
        state count: 0, username: "guest", active: true
      end

  Generates:

      @impl true
      def init(_opts) do
        %{count: 0, username: "guest", active: true}
      end

  If no state is defined, generates an init that returns an empty map.
  """

  use Spark.Dsl.Transformer
  alias UnifiedUi.Dsl.CompileIndex

  @impl true
  @spec transform(Spark.Dsl.t()) :: {:ok, Spark.Dsl.t()} | {:error, term()}
  def transform(dsl_state) do
    initial_state = get_initial_state(dsl_state)

    code =
      quote do
        @impl true
        def init(_opts) do
          unquote(Macro.escape(initial_state))
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

  # Extract initial state from DSL state entity
  defp get_initial_state(dsl_state) do
    case CompileIndex.get(dsl_state).state do
      [] -> %{}
      [%{attrs: state_keyword}] when is_list(state_keyword) -> Enum.into(state_keyword, %{})
      _ -> %{}
    end
  end
end
