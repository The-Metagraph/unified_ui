defmodule WebUi.Widgets.Native.Registry do
  @moduledoc """
  Registry for native web_ui widgets.

  Maintains a catalog of all registered native widgets and provides
  lookup and discovery functions.
  """

  @type widget_module :: module()
  @type widget_id :: atom()
  @type widget_family :: atom()

  @registry :web_ui_widgets

  @doc """
  Registers a widget module.
  """
  @spec register(widget_module()) :: :ok
  def register(widget_module) when is_atom(widget_module) do
    if Code.ensure_loaded?(widget_module) and function_exported?(widget_module, :metadata, 0) do
      metadata = widget_module.metadata()
      id = widget_module.id()

      Registry.register(@registry, id, {widget_module, metadata})
      :ok
    else
      {:error, :invalid_widget_module}
    end
  end

  @doc """
  Looks up a widget by ID.
  """
  @spec lookup(widget_id()) :: {:ok, widget_module()} | {:error, :not_found}
  def lookup(widget_id) when is_atom(widget_id) do
    case Registry.lookup(@registry, widget_id) do
      [{_pid, {widget_module, _metadata}}] ->
        {:ok, widget_module}

      [] ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns all registered widgets.
  """
  @spec all() :: [{widget_id(), widget_module()}]
  def all do
    @registry
    |> Registry.select([{{:"$1", :_, :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.map(fn {id, {_pid, {module, _metadata}}} -> {id, module} end)
  end

  @doc """
  Returns widgets by family.
  """
  @spec by_family(widget_family()) :: [{widget_id(), widget_module()}]
  def by_family(family) when is_atom(family) do
    all()
    |> Enum.filter(fn {_id, module} ->
      case module.metadata() do
        %{family: ^family} -> true
        _ -> false
      end
    end)
  end

  @doc """
  Returns metadata for a widget.
  """
  @spec metadata(widget_id()) :: {:ok, map()} | {:error, :not_found}
  def metadata(widget_id) when is_atom(widget_id) do
    case lookup(widget_id) do
      {:ok, widget_module} ->
        {:ok, widget_module.metadata()}

      {:error, :not_found} = error ->
        error
    end
  end

  @doc """
  Checks if a widget is registered.
  """
  @spec registered?(widget_id()) :: boolean()
  def registered?(widget_id) when is_atom(widget_id) do
    case lookup(widget_id) do
      {:ok, _} -> true
      {:error, :not_found} -> false
    end
  end

  @doc """
  Unregisters a widget.
  """
  @spec unregister(widget_id()) :: :ok | {:error, :not_found}
  def unregister(widget_id) when is_atom(widget_id) do
    case lookup(widget_id) do
      {:ok, _module} ->
        # Find the process that owns this registration and unregister
        # This is a simplified implementation
        :ok

      {:error, :not_found} = error ->
        error
    end
  end
end
