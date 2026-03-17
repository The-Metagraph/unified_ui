defmodule UnifiedExamples.Shared.Runtime do
  @moduledoc """
  Shared compile and render helpers for standalone example applications.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Container
  alias UnifiedUi.Compiler

  @spec compile(module(), keyword() | map()) :: {:ok, UnifiedUi.Compiler.Result.t()}
  def compile(module, opts \\ []) when is_atom(module) do
    Compiler.compile(module, opts)
  end

  @spec iur(module(), keyword() | map()) :: {:ok, Element.t()}
  def iur(module, opts \\ []) when is_atom(module) do
    Compiler.iur(module, opts)
  end

  @spec iur!(module(), keyword() | map()) :: Element.t()
  def iur!(module, opts \\ []) when is_atom(module) do
    Compiler.iur!(module, opts)
  end

  @spec mount(module(), keyword()) :: {:ok, LiveUi.Runtime.State.t()} | {:error, term()}
  def mount(module, opts \\ []) when is_atom(module) do
    with {:ok, runtime_state} <-
           module
           |> iur!(opts)
           |> renderable_element()
           |> LiveUi.Runtime.mount_iur(opts) do
      {:ok, maybe_decorate_runtime_state(module, runtime_state)}
    end
  end

  @spec component_assigns(module(), keyword()) :: {:ok, map()} | {:error, term()}
  def component_assigns(module, opts \\ []) when is_atom(module) do
    with {:ok, runtime_state} <- mount(module, opts) do
      {:ok,
       %{
         id: runtime_component_id(module),
         runtime_state: runtime_state
       }}
    end
  end

  @spec render_html(module(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def render_html(module, opts \\ []) when is_atom(module) do
    with {:ok, assigns} <- component_assigns(module, opts) do
      html =
        assigns
        |> LiveUi.Runtime.component().render()
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      {:ok, html}
    end
  end

  @spec inspect(module(), keyword()) :: {:ok, map()} | {:error, term()}
  def inspect(module, opts \\ []) when is_atom(module) do
    module
    |> iur!(opts)
    |> renderable_element()
    |> LiveUi.Tooling.inspect_canonical(opts)
  end

  @spec runtime_component_id(module()) :: String.t()
  def runtime_component_id(module) when is_atom(module) do
    module
    |> Module.split()
    |> Enum.map_join("-", &Macro.underscore/1)
  end

  @spec renderable_element(Element.t()) :: Element.t()
  def renderable_element(%Element{
        type: :composite,
        kind: :screen,
        children: [%Child{slot: :default, element: %Element{} = element}]
      }) do
    element
  end

  def renderable_element(%Element{
        type: :composite,
        kind: :fragment,
        id: id,
        children: children
      }) do
    children
    |> filter_fragment_helpers()
    |> Container.box(id: :"#{id}_runtime_shell")
  end

  def renderable_element(%Element{} = element), do: element

  defp maybe_decorate_runtime_state(module, runtime_state) do
    if function_exported?(module, :decorate_runtime_state, 1) do
      module.decorate_runtime_state(runtime_state)
    else
      runtime_state
    end
  end

  defp filter_fragment_helpers(children) do
    descendant_ids =
      children
      |> Enum.flat_map(fn
        %Child{element: %Element{} = element} -> descendant_ids(element)
        _child -> []
      end)
      |> MapSet.new()

    Enum.reject(children, fn
      %Child{element: %Element{id: nil}} -> false
      %Child{element: %Element{id: id}} -> MapSet.member?(descendant_ids, id)
      _child -> false
    end)
  end

  defp descendant_ids(%Element{children: children}) do
    Enum.flat_map(children, fn
      %Child{element: %Element{id: id} = element} when not is_nil(id) ->
        [id | descendant_ids(element)]

      %Child{element: %Element{} = element} ->
        descendant_ids(element)

      _child ->
        []
    end)
  end
end
