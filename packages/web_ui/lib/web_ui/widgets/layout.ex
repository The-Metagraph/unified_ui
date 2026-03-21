defmodule WebUi.Widgets.Layout do
  @moduledoc """
  Baseline layout widgets used by foundational native and canonical flows.
  """

  alias WebUi.Widgets.Builder

  @kinds [:stack, :panel, :row, :column]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec stack(String.t() | atom(), [WebUi.Widget.t() | map() | keyword()], keyword() | map()) ::
          WebUi.Widget.t()
  def stack(id, children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:stack,
      id: id,
      attributes: %{
        direction: Builder.option(opts, :direction, :column),
        gap: Builder.option(opts, :gap)
      },
      slot_children: %{default: Builder.children!(children)},
      styles: Builder.styles(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout})
    )
  end

  @spec panel(
          String.t() | atom(),
          String.t(),
          [WebUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          WebUi.Widget.t()
  def panel(id, title, children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:panel,
      id: id,
      attributes: %{
        title: title,
        tone: Builder.option(opts, :tone, :default)
      },
      slot_children: %{default: Builder.children!(children)},
      styles: Builder.styles(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout, role: :panel})
    )
  end

  @spec row(String.t() | atom(), [WebUi.Widget.t() | map() | keyword()], keyword() | map()) ::
          WebUi.Widget.t()
  def row(id, children, opts \\ []) when is_list(children) do
    build_linear(:row, id, children, opts, :horizontal)
  end

  @spec column(String.t() | atom(), [WebUi.Widget.t() | map() | keyword()], keyword() | map()) ::
          WebUi.Widget.t()
  def column(id, children, opts \\ []) when is_list(children) do
    build_linear(:column, id, children, opts, :vertical)
  end

  defp build_linear(kind, id, children, opts, direction) do
    opts = Builder.options(opts)

    Builder.widget(kind,
      id: id,
      attributes: %{
        direction: direction,
        gap: Builder.option(opts, :gap),
        align: Builder.option(opts, :align),
        justify: Builder.option(opts, :justify)
      },
      slot_children: %{default: Builder.children!(children)},
      styles: Builder.styles(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout})
    )
  end
end
