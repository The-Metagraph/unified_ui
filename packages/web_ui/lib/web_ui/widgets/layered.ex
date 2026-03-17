defmodule WebUi.Widgets.Layered do
  @moduledoc """
  Native layered composition widgets for dialogs, toasts, overlays, and
  context-sensitive web surfaces.
  """

  alias WebUi.Widgets.{Builder, Navigation}

  @kinds [:overlay, :dialog, :toast, :alert_dialog, :context_menu]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec overlay(
          WebUi.Widget.t() | map() | keyword(),
          [WebUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: WebUi.Widget.t()
  def overlay(base, layers, opts \\ []) when is_list(layers) do
    opts = Builder.options(opts)

    Builder.widget(:overlay,
      id: Builder.require_id!(opts, :overlay),
      props: %{
        mode: Builder.option(opts, :mode, :stacked),
        background_fill: Builder.option(opts, :background_fill, :transparent),
        dismissible?: Builder.option(opts, :dismissible?),
        focus_scope: Builder.option(opts, :focus_scope),
        z_order: Builder.option(opts, :z_order, :overlay)
      },
      slots:
        Builder.slot_map([
          {:base, base},
          {:layers, layers}
        ]),
      state: Builder.state(opts, [:disabled?, :open?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, open: :open, close: :close, dismiss: :dismiss),
      metadata: Builder.metadata(opts, %{native_surface: :layer, layered?: true})
    )
  end

  @spec dialog(WebUi.Widget.t() | map() | keyword(), keyword() | map()) :: WebUi.Widget.t()
  def dialog(content, opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:dialog,
      id: Builder.require_id!(opts, :dialog),
      props: %{
        title: Builder.option(opts, :title),
        modal?: Builder.option(opts, :modal?, true),
        dismissible?: Builder.option(opts, :dismissible?, true),
        size: Builder.option(opts, :size, :md),
        background_fill: Builder.option(opts, :background_fill, :scrim),
        focus_scope: Builder.option(opts, :focus_scope, :dialog)
      },
      slots: Builder.slot_map([{:content, content}]),
      state: Builder.state(opts, [:disabled?, :open?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, close: :close, dismiss: :dismiss),
      metadata: Builder.metadata(opts, %{native_surface: :layer, layered?: true})
    )
  end

  @spec toast(WebUi.Widget.t() | map() | keyword(), keyword() | map()) :: WebUi.Widget.t()
  def toast(content, opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:toast,
      id: Builder.require_id!(opts, :toast),
      props: %{
        placement: Builder.option(opts, :placement, :top_end),
        duration_ms: Builder.option(opts, :duration_ms, 5000),
        severity: Builder.option(opts, :severity, :info),
        transient?: Builder.option(opts, :transient?, true)
      },
      slots: Builder.slot_map([{:content, content}]),
      state: Builder.state(opts, [:disabled?, :open?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, close: :close, dismiss: :dismiss),
      metadata: Builder.metadata(opts, %{native_surface: :layer, layered?: true})
    )
  end

  @spec alert_dialog(WebUi.Widget.t() | map() | keyword(), keyword() | map()) :: WebUi.Widget.t()
  def alert_dialog(content, opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:alert_dialog,
      id: Builder.require_id!(opts, :alert_dialog),
      props: %{
        title: Builder.option(opts, :title),
        severity: Builder.option(opts, :severity, :warning),
        requires_confirmation?: Builder.option(opts, :requires_confirmation?, true),
        background_fill: Builder.option(opts, :background_fill, :scrim),
        focus_scope: Builder.option(opts, :focus_scope, :alert_dialog)
      },
      slots: Builder.slot_map([{:content, content}]),
      state: Builder.state(opts, [:disabled?, :open?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, close: :close, dismiss: :dismiss),
      metadata: Builder.metadata(opts, %{native_surface: :layer, layered?: true})
    )
  end

  @spec context_menu(
          [keyword() | map()] | WebUi.Widget.t() | map() | keyword(),
          keyword() | map()
        ) ::
          WebUi.Widget.t()
  def context_menu(items_or_menu, opts \\ []) do
    opts = Builder.options(opts)

    menu = normalize_menu(items_or_menu, opts)

    Builder.widget(:context_menu,
      id: Builder.require_id!(opts, :context_menu),
      props: %{
        anchor: Builder.option(opts, :anchor, %{}),
        placement: Builder.option(opts, :placement, :bottom_start),
        dismissible?: Builder.option(opts, :dismissible?, true),
        background_fill: Builder.option(opts, :background_fill, :none)
      },
      slots: Builder.slot_map([{:menu, menu}]),
      state: Builder.state(opts, [:disabled?, :open?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, close: :close, dismiss: :dismiss),
      metadata: Builder.metadata(opts, %{native_surface: :layer, layered?: true})
    )
  end

  defp normalize_menu(%WebUi.Widget{} = menu, _opts), do: menu

  defp normalize_menu(menu, _opts) when is_map(menu) do
    Builder.child!(menu)
  end

  defp normalize_menu(items, opts) when is_list(items) do
    Navigation.menu(items,
      id: Builder.option(opts, :menu_id, "#{Builder.require_id!(opts, :context_menu)}-menu"),
      orientation: :vertical,
      active_item: Builder.option(opts, :active_item)
    )
  end
end
