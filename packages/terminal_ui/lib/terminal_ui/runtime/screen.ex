defmodule TerminalUi.Runtime.Screen do
  @moduledoc """
  Foundational screen composition model shared by native and canonical runtime paths.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Runtime.State

  @enforce_keys [:id, :source_kind, :backend_mode, :root]
  defstruct [
    :id,
    :title,
    :source_kind,
    :backend_mode,
    :root,
    layout: %{},
    metadata: %{},
    bindings: %{}
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t() | nil,
          source_kind: State.source_kind(),
          backend_mode: atom(),
          root: Widget.t(),
          layout: map(),
          metadata: map(),
          bindings: map()
        }

  @spec new(map(), State.source_kind(), atom(), keyword()) :: t()
  def new(screen, source_kind, backend_mode, opts \\ []) do
    root = Map.fetch!(screen, :root)
    screen_id = screen |> Map.fetch!(:id) |> to_string()

    %__MODULE__{
      id: screen_id,
      title: Map.get(screen, :title),
      source_kind: source_kind,
      backend_mode: backend_mode,
      root: root,
      layout: %{
        composition: composition_for(root),
        root_kind: root.kind,
        align: Keyword.get(opts, :align, :start)
      },
      metadata: %{
        direct_native: source_kind == :native,
        canonical_input: source_kind == :canonical,
        theme:
          Keyword.get(opts, :theme, Map.get(screen, :theme, TerminalUi.Theme.default_theme().id)),
        focus_traversal: :shared_runtime,
        binding_surface: :shared_runtime,
        layered_runtime: root.kind in TerminalUi.Layer.kinds(),
        advanced_display: root.kind in TerminalUi.Layout.kinds()
      },
      bindings: binding_overview(root)
    }
  end

  @spec summary(t()) :: map()
  def summary(%__MODULE__{} = screen) do
    %{
      id: screen.id,
      title: screen.title,
      source_kind: screen.source_kind,
      backend_mode: screen.backend_mode,
      root_kind: screen.root.kind,
      layout: screen.layout,
      bindings: screen.bindings
    }
  end

  defp binding_overview(%Widget{} = root) do
    root
    |> collect_binding_names([])
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
    |> then(fn names -> %{names: names, count: length(names)} end)
  end

  defp collect_binding_names(%Widget{} = widget, acc) do
    names =
      widget.bindings
      |> Map.values()
      |> Enum.reject(&is_nil/1)

    Enum.reduce(widget.children, acc ++ names, &collect_binding_names/2)
  end

  defp composition_for(root) do
    if root.kind in TerminalUi.Layout.kinds() or root.kind in TerminalUi.Layer.kinds() do
      :advanced_shared_runtime
    else
      :foundational_shared_runtime
    end
  end
end
