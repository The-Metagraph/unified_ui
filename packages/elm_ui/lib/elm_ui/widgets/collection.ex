defmodule ElmUi.Widgets.Collection do
  @moduledoc """
  Native repeated collection representation for `elm_ui`.
  """

  alias ElmUi.Widgets.Builder

  @kinds [:repeated_collection]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec repeated_collection(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def repeated_collection(id, rows, opts \\ []) when is_list(rows) do
    opts =
      opts
      |> Builder.options()
      |> Map.put(:id, id)

    empty_state =
      opts
      |> Builder.option(:empty_state, [])
      |> List.wrap()

    Builder.widget(:repeated_collection,
      id: id,
      attributes: %{
        item_alias: Builder.option(opts, :item_alias, :item),
        index_alias: Builder.option(opts, :index_alias, :index),
        key_path: Builder.option(opts, :key_path, []),
        rows: Builder.option(opts, :row_metadata, [])
      },
      slot_children:
        Builder.slot_map([
          {:row, rows},
          {:empty_state, empty_state}
        ]),
      state: Builder.state(opts, [:disabled, :loading]),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_change: :change, on_select: :selection),
      metadata: Builder.metadata(opts, %{native_surface: :collection, row_scope?: true})
    )
  end
end
