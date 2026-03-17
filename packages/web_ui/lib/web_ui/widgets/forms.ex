defmodule WebUi.Widgets.Forms do
  @moduledoc """
  Baseline grouped form composition helpers for `web_ui`.
  """

  alias WebUi.Widgets.{Builder, Foundational}

  @kinds [:form_builder, :field_group, :field]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec form_builder([WebUi.Widget.t() | map() | keyword()], keyword() | map()) ::
          WebUi.Widget.t()
  def form_builder(children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:form_builder,
      id: Builder.require_id!(opts, :form_builder),
      props: %{
        mode: Builder.option(opts, :mode, :grouped),
        autocomplete?: Builder.option(opts, :autocomplete?, true)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, submit: :submit),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end

  @spec field_group([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def field_group(children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:field_group,
      id: Builder.require_id!(opts, :field_group),
      props: %{
        legend: Builder.option(opts, :legend),
        description: Builder.option(opts, :group_description),
        collapsible?: Builder.option(opts, :collapsible?, false)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end

  @spec field(WebUi.Widget.t() | map() | keyword(), keyword() | map()) :: WebUi.Widget.t()
  def field(control, opts \\ []) do
    opts = Builder.options(opts)
    control = Builder.child!(control)
    control_id = Builder.option(opts, :control_id, control.id)

    label_widget =
      case Builder.option(opts, :label) do
        nil ->
          nil

        label when is_binary(label) ->
          Foundational.label(label,
            id: Builder.option(opts, :label_id, "#{control_id}-label"),
            for: control_id,
            relationship: :field_label
          )

        label ->
          Builder.child!(label)
      end

    help_widget =
      case Builder.option(opts, :help) do
        nil -> nil
        help when is_binary(help) -> Foundational.text(help, id: "#{control_id}-help")
        help -> Builder.child!(help)
      end

    Builder.widget(:field,
      id: Builder.require_id!(opts, :field),
      props: %{
        name: Builder.option(opts, :name),
        control_id: control_id
      },
      slots:
        Builder.slot_map([
          {:label, label_widget},
          {:control, control},
          {:help, help_widget}
        ]),
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end
end
