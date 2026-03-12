defmodule LiveUi.Runtime do
  @moduledoc """
  Deterministic runtime shell shared by wrapper-based and dynamic entrypoints.
  """

  alias LiveUi.ConfigurationError
  alias LiveUi.IUR.Interpreter
  alias LiveUi.Live.EventRouter
  alias LiveUi.Runtime.Model
  alias LiveUi.Source
  alias LiveUi.WidgetState

  @type init_opt ::
          {:runtime_context, map()}
          | {:source, module()}
          | {:iur, term()}
          | {:source_opts, keyword()}
          | {:widget_state, map()}

  @spec init([init_opt()]) :: {:ok, Model.t()} | {:error, Exception.t()}
  def init(opts) when is_list(opts) do
    runtime_context = Keyword.get(opts, :runtime_context, %{})
    widget_state = Keyword.get(opts, :widget_state, %{})

    with {:ok, source} <- init_source(opts),
         screen_state <- init_screen_state(source),
         {:ok, build} <- build_view_state(source, screen_state, widget_state) do
      {:ok,
       Model.new(
         runtime_context: runtime_context,
         source: source,
         screen_state: screen_state,
         widget_state: widget_state,
         iur_tree: build.iur_tree,
         descriptor_tree: build.descriptor_tree,
         signal_bindings: build.signal_bindings,
         render_metadata: build.render_metadata,
         status: :ready
       )}
    end
  rescue
    error in [ConfigurationError, KeyError] -> {:error, error}
  end

  defp init_source(opts) do
    has_source? = Keyword.has_key?(opts, :source)
    has_iur? = Keyword.has_key?(opts, :iur)

    cond do
      has_source? and has_iur? ->
        {:error,
         ConfigurationError.new("live_ui runtime accepts either :source or :iur, not both")}

      has_source? ->
        {:ok, Source.new(Keyword.fetch!(opts, :source), Keyword.get(opts, :source_opts, []))}

      has_iur? ->
        {:ok, Source.new_iur(Keyword.fetch!(opts, :iur))}

      true ->
        {:error,
         ConfigurationError.new("live_ui runtime requires either a :source or :iur option")}
    end
  end

  @spec handle_event(Model.t(), String.t() | atom(), map()) ::
          {:ok, Model.t()} | {:error, Exception.t()}
  def handle_event(%Model{} = model, event_name, payload) when is_map(payload) do
    incoming_widget_state = WidgetState.extract(event_name, payload)
    widget_state = WidgetState.merge(model.widget_state || %{}, incoming_widget_state)

    with {:ok, signal} <- EventRouter.normalize(event_name, payload, model.runtime_context),
         screen_state <- update_screen_state(model.source, model.screen_state || %{}, signal),
         {:ok, build} <- build_view_state(model.source, screen_state, widget_state) do
      {:ok,
       %Model{
         model
         | descriptor_tree: build.descriptor_tree,
           event_count: model.event_count + 1,
           error: nil,
           iur_tree: build.iur_tree,
           last_event: %{name: event_name, payload: payload},
           last_signal: signal,
           render_metadata: build.render_metadata,
           screen_state: screen_state,
           signal_bindings: build.signal_bindings,
           status: :ready,
           widget_state: widget_state
       }}
    end
  end

  def handle_event(%Model{}, _event_name, _payload) do
    {:error, ConfigurationError.new("live_ui runtime events must provide a map payload")}
  end

  defp build_view_state(%Source{} = source, screen_state, widget_state) do
    iur_tree = render_iur_tree(source, screen_state)

    with {:ok, descriptor_tree} <- Interpreter.interpret(iur_tree) do
      descriptor_tree = WidgetState.apply_overlay(descriptor_tree, widget_state)

      {:ok,
       %{
         iur_tree: iur_tree,
         descriptor_tree: descriptor_tree,
         signal_bindings: Interpreter.collect_signal_bindings(descriptor_tree),
         render_metadata: %{
           root_id: descriptor_tree.id,
           root_kind: descriptor_tree.kind,
           node_count: count_nodes(descriptor_tree)
         }
       }}
    end
  rescue
    error in [ConfigurationError] -> {:error, error}
  end

  defp init_screen_state(%Source{kind: :module, module: source_module, opts: source_opts}) do
    source_module
    |> apply(:init, [source_opts])
    |> normalize_state_result(:init)
  end

  defp init_screen_state(%Source{kind: :iur}), do: %{}

  defp update_screen_state(%Source{kind: :module, module: source_module}, screen_state, signal) do
    source_module
    |> apply(:update, [screen_state, signal])
    |> normalize_state_result(:update)
  end

  defp update_screen_state(%Source{kind: :iur}, screen_state, _signal), do: screen_state

  defp render_iur_tree(%Source{kind: :module, module: source_module}, screen_state) do
    apply(source_module, :view, [screen_state])
  end

  defp render_iur_tree(%Source{kind: :iur, iur: iur_tree}, _screen_state), do: iur_tree

  defp count_nodes(descriptor) do
    1 + Enum.reduce(descriptor.children, 0, fn child, count -> count + count_nodes(child) end)
  end

  defp normalize_state_result(result, _callback_name) when is_map(result), do: result

  defp normalize_state_result({:ok, result}, callback_name),
    do: normalize_state_result(result, callback_name)

  defp normalize_state_result(other, callback_name) do
    raise ConfigurationError.new(
            "live_ui source #{callback_name}/#{callback_arity(callback_name)} must return a map or {:ok, map}",
            %{
              callback: callback_name,
              return: inspect(other)
            }
          )
  end

  defp callback_arity(:init), do: 1
  defp callback_arity(:update), do: 2
end
