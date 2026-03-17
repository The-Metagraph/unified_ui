defmodule WebUi.Widgets.Layout do
  @moduledoc """
  Baseline layout widgets used by foundational native and canonical flows.
  """

  alias WebUi.Widgets.Builder

  @kinds [:row, :column]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec row([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def row(children, opts \\ []) when is_list(children) do
    build_layout(:row, children, opts, :horizontal)
  end

  @spec column([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def column(children, opts \\ []) when is_list(children) do
    build_layout(:column, children, opts, :vertical)
  end

  defp build_layout(kind, children, opts, direction) do
    opts = Builder.options(opts)

    Builder.widget(kind,
      id: Builder.require_id!(opts, kind),
      props: %{
        direction: direction,
        gap: Builder.option(opts, :gap),
        align: Builder.option(opts, :align),
        justify: Builder.option(opts, :justify)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout})
    )
  end
end
