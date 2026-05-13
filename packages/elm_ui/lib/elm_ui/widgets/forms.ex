defmodule ElmUi.Widgets.Forms do
  @moduledoc """
  Baseline grouped form composition helpers for `elm_ui`.
  """

  alias ElmUi.Widgets.{Builder, Foundational}

  @kinds [:form_builder, :host_form_shell, :form, :field_group, :field, :form_field]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec form(String.t() | atom(), [ElmUi.Widget.t() | map() | keyword()], keyword() | map()) ::
          ElmUi.Widget.t()
  def form(id, children, opts \\ []) when is_list(children) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:form,
      id: id,
      attributes: %{
        mode: Builder.option(opts, :mode, :grouped),
        autocomplete: Builder.option(opts, :autocomplete, true)
      },
      slot_children: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_submit: :submit),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end

  @spec form_builder(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def form_builder(id, children, opts \\ []) when is_list(children) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:form_builder,
      id: id,
      attributes: %{
        mode: Builder.option(opts, :mode, :grouped),
        autocomplete: Builder.option(opts, :autocomplete, true)
      },
      slot_children: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_submit: :submit),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end

  @spec host_form_shell(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def host_form_shell(id, children, opts \\ []) when is_list(children) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:host_form_shell,
      id: id,
      attributes: %{
        owner: Builder.option(opts, :owner, :host),
        lifecycle: Builder.option(opts, :lifecycle, :host_owned),
        action_placement: Builder.option(opts, :action_placement, :footer),
        mode: Builder.option(opts, :mode, :host_owned),
        submit_intent: Builder.option(opts, :submit_intent),
        autocomplete: Builder.option(opts, :autocomplete, true),
        validation_summary: Builder.option(opts, :validation_summary)
      },
      slot_children:
        Builder.slot_map([
          {:default, children},
          {:fields, Builder.option(opts, :fields)},
          {:actions, Builder.option(opts, :actions)}
        ]),
      state: Builder.state(opts, [:disabled, :loading, :focused]),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_submit: :submit, on_change: :change),
      metadata: Builder.metadata(opts, %{native_surface: :forms, host_owned?: true})
    )
  end

  @spec field_group(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def field_group(id, children, opts \\ []) when is_list(children) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:field_group,
      id: id,
      attributes: %{
        legend: Builder.option(opts, :legend),
        description: Builder.option(opts, :group_description),
        collapsible: Builder.option(opts, :collapsible, false)
      },
      slot_children: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      styles: Builder.styles(opts),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end

  @spec field(String.t() | atom(), ElmUi.Widget.t() | map() | keyword(), keyword() | map()) ::
          ElmUi.Widget.t()
  def field(id, control, opts \\ []) do
    build_field(:field, id, control, opts)
  end

  @spec form_field(String.t() | atom(), ElmUi.Widget.t() | map() | keyword(), keyword() | map()) ::
          ElmUi.Widget.t()
  def form_field(id, control, opts \\ []) do
    build_field(:form_field, id, control, opts)
  end

  defp build_field(kind, id, control, opts) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))
    control = Builder.child!(control)
    control_id = Builder.option(opts, :control_id, control.id)

    label_widget =
      case Builder.option(opts, :label) do
        nil ->
          nil

        label when is_binary(label) ->
          Foundational.label("#{id}-label", label,
            for: control_id,
            relationship: :field_label
          )

        label ->
          Builder.child!(label)
      end

    help_widget =
      case Builder.option(opts, :help) do
        nil -> nil
        help when is_binary(help) -> Foundational.text("#{id}-help", help)
        help -> Builder.child!(help)
      end

    Builder.widget(kind,
      id: id,
      attributes: %{
        name: Builder.option(opts, :name),
        control_id: control_id
      },
      slot_children:
        Builder.slot_map([
          {:label, label_widget},
          {:control, control},
          {:help, help_widget}
        ]),
      state: Builder.state(opts),
      styles: Builder.styles(opts),
      metadata: Builder.metadata(opts, %{native_surface: :forms})
    )
  end
end
