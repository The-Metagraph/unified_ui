defmodule TerminalUi.Widgets.Forms do
  @moduledoc """
  Baseline grouped form composition helpers for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.{Builder, Foundational}

  @kinds [:form_builder, :field_group, :field]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec form_builder(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def form_builder(id, children, opts \\ []) when is_list(children) do
    Widget.new(:form_builder,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :form_builder], opts),
          %{native_surface: :forms}
        ),
      state: Builder.state(opts),
      attributes: %{
        mode: Keyword.get(opts, :mode, :grouped),
        autocomplete: Keyword.get(opts, :autocomplete, true)
      },
      slot_children: %{default: children},
      events: Builder.events(submit: opts[:on_submit]),
      styles: Builder.styles(opts)
    )
  end

  @spec field_group(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def field_group(id, children, opts \\ []) when is_list(children) do
    Widget.new(:field_group,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([role: :field_group], opts),
          %{native_surface: :forms}
        ),
      state: Builder.state(opts),
      attributes: %{
        legend: Keyword.get(opts, :legend),
        description: Keyword.get(opts, :group_description),
        collapsible: Keyword.get(opts, :collapsible, false)
      },
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec field(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def field(id, control, opts \\ []) do
    control = normalize_child(control)
    control_id = Keyword.get(opts, :control_id, control.id)

    label_widget =
      case Keyword.get(opts, :label) do
        nil ->
          nil

        label when is_binary(label) ->
          Foundational.label("#{id}-label", label, for: control_id, relationship: :field_label)

        label ->
          normalize_child(label)
      end

    help_widget =
      case Keyword.get(opts, :help) do
        nil -> nil
        help when is_binary(help) -> Foundational.text("#{id}-help", help)
        help -> normalize_child(help)
      end

    Widget.new(:field,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([role: :field], opts),
          %{native_surface: :forms}
        ),
      state: Builder.state(opts),
      attributes: %{name: Keyword.get(opts, :name), control_id: control_id},
      slots: [:label, :control, :help],
      slot_children:
        slot_children([
          {:label, label_widget},
          {:control, control},
          {:help, help_widget}
        ]),
      styles: Builder.styles(opts)
    )
  end

  defp slot_children(entries) do
    entries
    |> Enum.reject(fn {_slot, child} -> is_nil(child) end)
    |> Map.new(fn {slot, child} -> {slot, [child]} end)
  end

  defp normalize_child(%Widget{} = child), do: child

  defp normalize_child(child) when is_list(child),
    do: Widget.new(Keyword.get(child, :kind, :text), child)

  defp normalize_child(child) when is_map(child),
    do: Widget.new(Map.get(child, :kind, :text), child)

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
