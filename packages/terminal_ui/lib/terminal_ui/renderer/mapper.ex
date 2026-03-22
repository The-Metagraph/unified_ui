defmodule TerminalUi.Renderer.Mapper do
  @moduledoc """
  Foundational canonical-to-native widget mapper for `terminal_ui`.
  """

  alias TerminalUi.Renderer.Error
  alias UnifiedIUR.{Binding, Element, Interaction}
  alias UnifiedIUR.Element.Child

  @spec map(Element.t(), keyword()) :: {:ok, TerminalUi.Widget.t()} | {:error, Error.t()}
  def map(element, opts \\ [])

  def map(%Element{id: nil} = element, _opts) do
    {:error, Error.new(:missing_canonical_identity, %{kind: element.kind, type: element.type})}
  end

  def map(%Element{} = element, _opts) do
    with :ok <- validate_attachments(element) do
      do_map(element)
    end
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:text, "text"] do
    {:ok,
     TerminalUi.Widgets.text(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:label, "label"] do
    {:ok,
     TerminalUi.Widgets.label(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:icon, "icon"] do
    {:ok,
     TerminalUi.Widgets.icon(
       element.id,
       first_present(
         [group_attr(element, :icon, :name), attr(element, :icon), attr(element, :name)],
         :unknown
       ),
       Keyword.merge(
         base_opts(element),
         fallback_text:
           first_present(
             [group_attr(element, :icon, :fallback_text), attr(element, :fallback_text)],
             "[icon]"
           )
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:image, "image"] do
    {:ok,
     TerminalUi.Widgets.image(
       element.id,
       first_present(
         [group_attr(element, :image, :source), attr(element, :source), attr(element, :src)],
         ""
       ),
       Keyword.merge(
         base_opts(element),
         alt: first_present([group_attr(element, :image, :alt_text), attr(element, :alt)], ""),
         degradation: :placeholder
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:button, "button"] do
    {:ok,
     TerminalUi.Widgets.button(
       element.id,
       content_text(element, "Button"),
       Keyword.merge(base_opts(element), on_press: interaction_payload(element, :click))
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:link, "link"] do
    {:ok,
     TerminalUi.Widgets.link(
       element.id,
       content_text(element, "Link"),
       first_present(
         [group_attr(element, :link, :target), attr(element, :href), attr(element, :target)],
         "#"
       ),
       Keyword.merge(base_opts(element), on_follow: interaction_payload(element, :click))
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:separator, "separator"] do
    {:ok,
     TerminalUi.Widgets.separator(
       element.id,
       Keyword.merge(
         base_opts(element),
         orientation:
           first_present(
             [group_attr(element, :separator, :orientation), attr(element, :orientation)],
             :horizontal
           )
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:spacer, "spacer"] do
    {:ok,
     TerminalUi.Widgets.spacer(
       element.id,
       Keyword.merge(base_opts(element),
         size: first_present([group_attr(element, :spacer, :size), attr(element, :size)], :md)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:text_input, "text_input", :numeric_input, "numeric_input"] do
    {:ok,
     TerminalUi.Widgets.text_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)], ""),
         binding: binding_name(element),
         placeholder:
           first_present(
             [group_attr(element, :input, :placeholder), attr(element, :placeholder)],
             ""
           ),
         on_change: interaction_payload(element, :change),
         on_submit: interaction_payload(element, :submit)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:toggle, "toggle"] do
    {:ok,
     TerminalUi.Widgets.toggle(
       element.id,
       content_text(element, label_text(element, "Toggle")),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_toggle: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:checkbox, "checkbox"] do
    {:ok,
     TerminalUi.Widgets.checkbox(
       element.id,
       label_text(element, "Checkbox"),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element)
       when kind in [:radio_group, "radio_group"] do
    {:ok,
     TerminalUi.Widgets.radio_group(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:select, "select"] do
    {:ok,
     TerminalUi.Widgets.select(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:menu, "menu"] do
    {:ok,
     TerminalUi.Widgets.menu(
       element.id,
       first_present([group_attr(element, :navigation, :items), attr(element, :items)], []),
       Keyword.merge(
         base_opts(element),
         current:
           first_present([group_attr(element, :navigation, :active_item), binding_value(element)]),
         binding: binding_name(element),
         on_navigate: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:tabs, "tabs"] do
    {:ok,
     TerminalUi.Widgets.tabs(
       element.id,
       first_present([group_attr(element, :navigation, :items), attr(element, :items)], []),
       Keyword.merge(
         base_opts(element),
         current:
           first_present([group_attr(element, :navigation, :active_item), binding_value(element)]),
         binding: binding_name(element),
         on_navigate: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:list, "list"] do
    {:ok,
     TerminalUi.Widgets.list(
       element.id,
       first_present([group_attr(element, :list, :items), attr(element, :items)], []),
       Keyword.merge(
         base_opts(element),
         current: first_present([attr(element, :current), binding_value(element)]),
         binding: binding_name(element),
         on_navigate: interaction_payload(element, :navigation),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp do_map(%Element{type: :widget, kind: kind} = element) when kind in [:content, "content"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok, TerminalUi.Widgets.container(element.id, children, base_opts(element))}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:column, "column"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.column(
         element.id,
         children,
         Keyword.merge(base_opts(element), gap: layout_attr(element, :gap, :sm))
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:row, "row"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.row(
         element.id,
         children,
         Keyword.merge(base_opts(element), gap: layout_attr(element, :gap, :sm))
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:stack, "stack"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.stack(
         element.id,
         children,
         Keyword.merge(base_opts(element), gap: layout_attr(element, :gap, :sm))
       )}
    end
  end

  defp do_map(%Element{type: :layout, kind: kind} = element) when kind in [:box, "box"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       TerminalUi.Widgets.container(
         element.id,
         children,
         Keyword.merge(base_opts(element), border: :single, padding: attr(element, :padding))
       )}
    end
  end

  defp do_map(%Element{} = element) do
    {:error,
     Error.new(:unsupported_canonical_construct, %{
       kind: element.kind,
       type: element.type,
       id: element.id
     })}
  end

  defp map_children(children) do
    children
    |> Enum.reduce_while({:ok, []}, fn child, {:ok, acc} ->
      case map(child) do
        {:ok, widget} -> {:cont, {:ok, acc ++ [widget]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp default_children(%Element{} = element) do
    element.children
    |> Enum.filter(&Child.present?/1)
    |> Enum.map(& &1.element)
  end

  defp validate_attachments(%Element{} = element) do
    with :ok <- validate_bindings(element),
         :ok <- validate_interactions(element) do
      :ok
    end
  end

  defp validate_bindings(%Element{} = element) do
    case Map.get(element.attributes, :bindings) do
      nil ->
        :ok

      bindings when is_list(bindings) ->
        if Enum.all?(bindings, &match?(%Binding{}, &1)) do
          :ok
        else
          {:error, Error.new(:invalid_canonical_bindings, %{id: element.id, kind: element.kind})}
        end

      _other ->
        {:error, Error.new(:invalid_canonical_bindings, %{id: element.id, kind: element.kind})}
    end
  end

  defp validate_interactions(%Element{} = element) do
    case Map.get(element.attributes, :interactions) do
      nil ->
        :ok

      interactions when is_list(interactions) ->
        if Enum.all?(interactions, &match?(%Interaction{}, &1)) do
          :ok
        else
          {:error,
           Error.new(:invalid_canonical_interactions, %{id: element.id, kind: element.kind})}
        end

      _other ->
        {:error,
         Error.new(:invalid_canonical_interactions, %{id: element.id, kind: element.kind})}
    end
  end

  defp base_opts(element) do
    []
    |> maybe_put(:label, label_text(element, nil))
    |> maybe_put(:description, description(element))
    |> maybe_put(:disabled, state_attr(element, :disabled?))
  end

  defp binding_name(element) do
    case first_binding(element) do
      %Binding{name: name} when not is_nil(name) -> name
      %Binding{path: path} when is_list(path) and path != [] -> List.last(path)
      _other -> nil
    end
  end

  defp binding_value(element) do
    case first_binding(element) do
      %Binding{value: nil, default: default} -> default
      %Binding{value: value} -> value
      _other -> nil
    end
  end

  defp first_binding(element) do
    element.attributes
    |> Map.get(:bindings, [])
    |> List.wrap()
    |> List.first()
  end

  defp interaction_payload(element, family) do
    element.attributes
    |> Map.get(:interactions, [])
    |> List.wrap()
    |> Enum.find(&(&1.family == family))
    |> case do
      nil ->
        nil

      %Interaction{} = interaction ->
        %{}
        |> maybe_put(:intent, interaction.intent)
        |> maybe_put(:binding, Map.get(interaction.target, :binding))
        |> maybe_put(:command, Map.get(interaction.payload, :command))
        |> maybe_put(:value, Map.get(interaction.payload, :value))
        |> maybe_put(:selection, Map.get(interaction.payload, :selection))
    end
  end

  defp content_text(element, default) do
    first_present(
      [group_attr(element, :content, :text), attr(element, :text), attr(element, :content)],
      default
    )
  end

  defp label_text(element, default) do
    first_present(
      [group_attr(element, :label, :text), attr(element, :label_text), attr(element, :label)],
      default
    )
  end

  defp description(%Element{} = element) do
    Map.get(element.metadata || %{}, :description)
  end

  defp state_attr(element, key) do
    group_attr(element, :state, key)
  end

  defp layout_attr(element, key, default) do
    first_present([group_attr(element, :layout, key), attr(element, key)], default)
  end

  defp group_attr(%Element{} = element, group, key) do
    case Map.get(element.attributes, group) do
      nil -> nil
      values when is_map(values) -> Map.get(values, key, Map.get(values, Atom.to_string(key)))
      _other -> nil
    end
  end

  defp attr(%Element{} = element, key) do
    Map.get(element.attributes, key, Map.get(element.attributes, Atom.to_string(key)))
  end

  defp first_present(values, default \\ nil) do
    Enum.find(values, default, &(not is_nil(&1)))
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value) when is_list(opts), do: Keyword.put(opts, key, value)
  defp maybe_put(opts, key, value) when is_map(opts), do: Map.put(opts, key, value)
end
