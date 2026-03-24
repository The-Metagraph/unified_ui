defmodule DesktopUi.Runtime.Screen do
  @moduledoc """
  Foundational screen composition model shared by native and canonical runtime
  paths.
  """

  alias DesktopUi.Runtime.State
  alias DesktopUi.Widget

  @enforce_keys [:id, :source_kind, :platform_target, :root]
  defstruct [
    :id,
    :title,
    :source_kind,
    :platform_target,
    :root,
    metadata: %{},
    realization: %{}
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          source_kind: State.source_kind(),
          platform_target: atom(),
          root: Widget.t(),
          metadata: map(),
          realization: map()
        }

  @spec new(map(), State.source_kind(), keyword()) :: t()
  def new(screen, source_kind, opts \\ []) do
    root = Map.fetch!(screen, :root)

    %__MODULE__{
      id: screen |> Map.fetch!(:id) |> to_string(),
      title: Map.get(screen, :title, "Screen"),
      source_kind: source_kind,
      platform_target: Keyword.get(opts, :platform_target, :linux),
      root: root,
      metadata: %{
        shared_runtime: true,
        direct_native: source_kind == :native,
        canonical_input: source_kind == :canonical,
        runtime_foundation: :sdl2
      },
      realization: %{
        root_kind: root.kind,
        uses_window_registry: true,
        redraw_model: :shared_sdl_runtime
      }
    }
  end
end
