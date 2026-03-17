defmodule WebUi.Widgets.Navigation do
  @moduledoc """
  Baseline navigation widgets for direct-use `web_ui` screens.
  """

  alias WebUi.Widgets.Builder

  @kinds [:menu, :tabs]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec menu([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def menu(items, opts \\ []) when is_list(items) do
    opts = Builder.options(opts)

    Builder.widget(:menu,
      id: Builder.require_id!(opts, :menu),
      props: %{
        orientation: Builder.option(opts, :orientation, :vertical),
        active_item: Builder.option(opts, :active_item),
        items: normalize_items(items)
      },
      state: Builder.state(opts, [:disabled?, :current?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, navigation: :navigation),
      metadata: Builder.metadata(opts, %{native_surface: :navigation})
    )
  end

  @spec tabs([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def tabs(items, opts \\ []) when is_list(items) do
    opts = Builder.options(opts)

    Builder.widget(:tabs,
      id: Builder.require_id!(opts, :tabs),
      props: %{
        orientation: Builder.option(opts, :orientation, :horizontal),
        active_item: Builder.option(opts, :active_item),
        items: normalize_items(items)
      },
      state: Builder.state(opts, [:disabled?, :current?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, navigation: :navigation),
      metadata: Builder.metadata(opts, %{native_surface: :navigation})
    )
  end

  defp normalize_items(items) do
    Enum.map(items, fn item ->
      item = Builder.options(item)

      %{}
      |> Builder.maybe_put(:id, Builder.option(item, :id))
      |> Builder.maybe_put(:label, Builder.option(item, :label))
      |> Builder.maybe_put(:value, Builder.option(item, :value))
      |> Builder.maybe_put(:description, Builder.option(item, :description))
      |> Builder.maybe_put(:disabled?, Builder.option(item, :disabled?))
      |> Builder.maybe_put(:active?, Builder.option(item, :active?))
    end)
  end
end
