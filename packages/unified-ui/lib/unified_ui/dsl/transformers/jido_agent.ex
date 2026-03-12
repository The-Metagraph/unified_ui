defmodule UnifiedUi.Dsl.Transformers.JidoAgentTransformer do
  @moduledoc """
  Spark transformer that injects agent integration helpers for DSL modules.

  The generated helpers bridge DSL components with `UnifiedUi.Agent` runtime
  processes and provide a `handle_signal/2` entry point for signal-driven
  updates.
  """

  use Spark.Dsl.Transformer

  alias Spark.Dsl.Transformer
  alias UnifiedUi.Dsl.Transformers.UpdateTransformer

  @click_signal_type "unified.button.clicked"
  @change_signal_type "unified.input.changed"
  @submit_signal_type "unified.form.submitted"

  @impl true
  @spec transform(Spark.Dsl.t()) :: {:ok, Spark.Dsl.t()} | {:error, term()}
  def transform(dsl_state) do
    code =
      quote do
        @doc """
        Initializes component state for agent runtime startup.

        Delegates to generated component `init/1`.
        """
        @spec agent_init(keyword()) :: map()
        def agent_init(opts) when is_list(opts) do
          init(opts)
        end

        @doc """
        Handles incoming signals using the DSL-generated routing logic.
        """
        @spec handle_signal(map(), term()) :: map()
        def handle_signal(state, %Jido.Signal{type: unquote(@click_signal_type)} = signal) do
          dispatch_click_signal(state, signal)
        end

        def handle_signal(state, %{type: unquote(@click_signal_type)} = signal) do
          dispatch_click_signal(state, signal)
        end

        def handle_signal(state, %Jido.Signal{type: unquote(@change_signal_type)} = signal) do
          dispatch_change_signal(state, signal)
        end

        def handle_signal(state, %{type: unquote(@change_signal_type)} = signal) do
          dispatch_change_signal(state, signal)
        end

        def handle_signal(state, %Jido.Signal{type: unquote(@submit_signal_type)} = signal) do
          dispatch_submit_signal(state, signal)
        end

        def handle_signal(state, %{type: unquote(@submit_signal_type)} = signal) do
          dispatch_submit_signal(state, signal)
        end

        def handle_signal(state, _signal), do: state

        @doc """
        Starts this DSL component module as a supervised `UnifiedUi.Agent`.
        """
        @spec start_component(UnifiedUi.Agent.component_id(), keyword()) ::
                {:ok, pid()} | {:error, term()}
        def start_component(component_id, opts \\ [])
            when is_atom(component_id) and is_list(opts) do
          UnifiedUi.Agent.start_component(__MODULE__, component_id, opts)
        end

        @doc """
        Stops a running component agent by id.
        """
        @spec stop_component(UnifiedUi.Agent.component_id()) :: :ok | {:error, term()}
        def stop_component(component_id) when is_atom(component_id) do
          UnifiedUi.Agent.stop_component(component_id)
        end

        @doc """
        Sends a signal to a running component agent by id.
        """
        @spec signal_component(UnifiedUi.Agent.component_id(), term()) :: :ok | {:error, term()}
        def signal_component(component_id, signal) when is_atom(component_id) do
          UnifiedUi.Agent.signal_component(component_id, signal)
        end

        defoverridable agent_init: 1
        defoverridable handle_signal: 2
      end

    {:ok, Transformer.eval(dsl_state, [], code)}
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
  def after?(UpdateTransformer), do: true
  def after?(_other), do: false

  @doc """
  Indicates whether this transformer runs in the after-compile phase.
  """
  @impl true
  @spec after_compile?() :: boolean()
  def after_compile?, do: false
end
