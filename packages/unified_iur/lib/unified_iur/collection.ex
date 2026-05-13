defmodule UnifiedIUR.Collection do
  @moduledoc """
  Canonical repeated collection constructs for renderer-independent row templates.
  """

  alias UnifiedIUR.Attachment
  alias UnifiedIUR.Binding
  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Metadata
  alias UnifiedIUR.Widgets.Foundational

  @type opts :: keyword() | map()
  @type child_input :: Child.t() | Element.t() | {Child.slot(), Element.t() | nil} | map() | nil

  @kinds [:repeated_collection]

  @spec kinds() :: [atom()]
  def kinds do
    @kinds
  end

  @spec repeated_collection(child_input(), opts()) :: Element.t()
  def repeated_collection(template, opts \\ []) do
    opts = normalize_opts(opts)
    item_alias = option(opts, :item_alias, :item)
    index_alias = option(opts, :index_alias, :index)
    key_path = normalize_path(option(opts, :key_path, option(opts, :key)))
    source = normalize_collection_source(option(opts, :source, option(opts, :collection_source)))
    empty_state = normalize_empty_state(option(opts, :empty_state))

    children =
      [{:template, template}]
      |> maybe_append(empty_state)

    Element.new(:composite, :repeated_collection,
      id: option(opts, :id),
      metadata: normalize_metadata(opts),
      attributes:
        %{}
        |> merge_attribute(:collection, %{
          source: source,
          item_alias: item_alias,
          index_alias: index_alias,
          key_path: key_path,
          template_slot: :template,
          empty_state_slot: if(empty_state, do: :empty_state)
        })
        |> merge_attribute(:row_scope, %{
          item_alias: item_alias,
          index_alias: index_alias,
          bindings: normalize_row_scope_bindings(option(opts, :row_scope_bindings, []))
        })
        |> Attachment.merge(opts,
          component: :repeated_collection,
          tone: option(opts, :tone),
          local_style: option(opts, :style)
        ),
      children: children
    )
  end

  @spec source(atom() | String.t() | keyword() | map() | Binding.t()) :: Binding.t()
  def source(value), do: normalize_collection_source(value)

  defp normalize_collection_source(nil), do: nil

  defp normalize_collection_source(%Binding{} = binding) do
    %{Binding.new(binding) | collection?: true}
  end

  defp normalize_collection_source(name) when is_atom(name) or is_binary(name) do
    Binding.new(name: name, path: [name], source: :binding, collection?: true)
  end

  defp normalize_collection_source(source) when is_list(source) or is_map(source) do
    source = normalize_opts(source)

    metadata =
      source
      |> option(:metadata, %{})
      |> normalize_map()
      |> Map.merge(Map.take(source, [:relationship, :resource, :ash_relationship, :ash_resource]))

    source
    |> Map.put(:metadata, metadata)
    |> Map.put(:collection?, true)
    |> Binding.new()
  end

  defp normalize_row_scope_bindings(bindings) do
    bindings
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&Binding.new/1)
  end

  defp normalize_empty_state(nil), do: nil
  defp normalize_empty_state(%Child{} = child), do: child
  defp normalize_empty_state(%Element{} = element), do: Child.new(:empty_state, element)

  defp normalize_empty_state(text) when is_binary(text) do
    Child.new(:empty_state, Foundational.text(text))
  end

  defp normalize_empty_state({slot, %Element{} = element})
       when is_atom(slot) or is_binary(slot) do
    Child.new(:empty_state, Element.put_attribute(element, :collection_slot, slot))
  end

  defp normalize_metadata(opts) do
    opts
    |> option(:metadata)
    |> Metadata.merge(%{
      authored_ref: option(opts, :authored_ref),
      description: option(opts, :description),
      annotations: option(opts, :annotations, %{}),
      tags: option(opts, :tags, []),
      extra: option(opts, :extra, %{})
    })
  end

  defp normalize_path(nil), do: []
  defp normalize_path(path) when is_atom(path) or is_binary(path), do: [path]
  defp normalize_path(path) when is_list(path), do: path

  defp normalize_opts(opts) when is_list(opts), do: Enum.into(opts, %{})
  defp normalize_opts(opts) when is_map(opts), do: Map.new(opts)

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp option(opts, key, default \\ nil) do
    Map.get(opts, key, Map.get(opts, Atom.to_string(key), default))
  end

  defp merge_attribute(attributes, _key, value) when value in [%{}, [], nil], do: attributes
  defp merge_attribute(attributes, key, value), do: Map.put(attributes, key, value)

  defp maybe_append(children, nil), do: children
  defp maybe_append(children, %Child{} = child), do: children ++ [child]
end
