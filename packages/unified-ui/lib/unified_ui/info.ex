defmodule UnifiedUi.Info do
  @moduledoc """
  Package-facing authored module introspection helpers.
  """

  alias Spark.Dsl.Extension
  alias UnifiedUi.Dsl.Node
  alias UnifiedUi.Examples
  alias UnifiedUi.Reference
  alias UnifiedUi.RowScope
  alias UnifiedUi.Signals
  alias UnifiedUi.Theme

  @required_fields_by_kind %{
    text: [:value],
    label: [:value],
    icon: [:name],
    image: [:source],
    badge: [:value],
    button: [:label],
    link: [:label, :target],
    text_input: [],
    numeric_input: [],
    toggle: [:label],
    checkbox: [:label],
    radio_group: [:label, :options],
    select: [:label, :options],
    pick_list: [:label, :options],
    file_input: [:label],
    menu: [:items],
    tabs: [:items],
    command_palette: [:items],
    field: [:field_name],
    form_field: [:field_name],
    disclosure: [:label],
    kicker: [:value],
    avatar: [:label],
    presence_dot: [:status],
    segmented_button_group: [:items],
    list_item_multi_column: [:columns],
    artifact_row: [:artifact, :title],
    sticky_header: [:title],
    pipeline_stepper_horizontal: [:steps],
    segmented_progress_bar: [:segments],
    workflow_stage_list_vertical: [:stages],
    meter_thin: [:current],
    event_callout: [:message],
    redline_inline: [:before_text, :after_text],
    code_block_syntax_highlighted: [:code],
    repeated_collection: [:collection_source, :key_path]
  }

  @state_fields [
    :active_item,
    :current,
    :disabled?,
    :elevation,
    :expanded?,
    :indeterminate?,
    :modal?,
    :open?,
    :pulse?,
    :severity,
    :status,
    :stuck?,
    :visible?
  ]

  @spec supported_construct_families() :: %{atom() => [atom()]}
  def supported_construct_families do
    Reference.construct_families()
  end

  @spec supported_compiled_construct_families() :: map()
  def supported_compiled_construct_families do
    Reference.compiled_construct_families()
  end

  @spec style_attribute_families() :: %{atom() => [atom()]}
  def style_attribute_families do
    Reference.style_attribute_families()
  end

  @spec composition_nodes(module()) :: [struct()]
  def composition_nodes(module) when is_atom(module) do
    Extension.get_entities(module, [:composition])
  end

  @spec composition_summary(module()) :: [map()]
  def composition_summary(module) when is_atom(module) do
    module
    |> composition_nodes()
    |> Enum.map(&Node.summary/1)
  end

  @spec authoring_surface_summary(module()) :: map()
  def authoring_surface_summary(module) when is_atom(module) do
    nodes = module |> composition_nodes() |> flatten_nodes()

    %{
      families:
        nodes
        |> Enum.map(& &1.family)
        |> sort_terms(),
      widgets: Enum.map(nodes, &node_authoring_summary/1),
      repeated_collections:
        nodes
        |> Enum.filter(&(&1.kind == :repeated_collection))
        |> Enum.map(&repeated_collection_summary/1),
      row_scope_refs:
        nodes
        |> Enum.flat_map(&row_scope_refs/1)
        |> Enum.uniq()
        |> Enum.sort_by(&inspect/1)
    }
  end

  @spec example_summaries() :: [map()]
  def example_summaries do
    Examples.catalog()
    |> Enum.map(fn example ->
      Map.put(example, :composition, composition_summary(example.module))
    end)
  end

  @spec module_summary(module()) :: map()
  def module_summary(module) when is_atom(module) do
    %{
      module: module,
      sections: section_usage(module),
      identifiers: declared_identifiers(module),
      identity: section_options(module, :identity),
      composition: section_options(module, :composition),
      themes: section_options(module, :themes),
      signals: section_options(module, :signals),
      theme_catalog: Theme.module_summary(module),
      signal_catalog: Signals.module_summary(module),
      validation_state: validation_state(module)
    }
  end

  @spec inspect_module(module()) :: map()
  def inspect_module(module) when is_atom(module) do
    module_summary(module)
  end

  @spec section_usage(module()) :: %{atom() => boolean()}
  def section_usage(module) when is_atom(module) do
    Reference.dsl_sections()
    |> Map.new(fn {section, metadata} ->
      {section, section_present?(module, section, metadata.fields)}
    end)
  end

  @spec declared_identifiers(module()) :: map()
  def declared_identifiers(module) when is_atom(module) do
    %{
      module_id: Extension.get_opt(module, [:identity], :id, nil),
      root_id: Extension.get_opt(module, [:composition], :root, nil),
      default_theme: Extension.get_opt(module, [:themes], :default_theme, nil),
      signal_namespace: Extension.get_opt(module, [:signals], :namespace, nil)
    }
  end

  @spec validation_state(module()) :: :phase_1_valid | :invalid
  def validation_state(module) when is_atom(module) do
    identifiers = declared_identifiers(module)
    sections = section_usage(module)
    root = identifiers.root_id
    module_id = identifiers.module_id
    slot = Extension.get_opt(module, [:composition], :default_slot, nil)
    mode = Extension.get_opt(module, [:composition], :mode, :screen)

    if sections.identity and sections.composition and
         not is_nil(module_id) and
         not is_nil(root) and
         module_id != root and
         (is_nil(slot) or mode == :fragment) do
      :phase_1_valid
    else
      :invalid
    end
  end

  defp section_options(module, section) do
    fields = Reference.dsl_sections() |> Map.fetch!(section) |> Map.fetch!(:fields)

    fields
    |> Enum.map(fn field -> {field, Extension.get_opt(module, [section], field, nil)} end)
    |> Enum.reject(fn {_field, value} -> is_nil(value) end)
    |> Enum.into(%{})
  end

  defp section_present?(module, section, fields) do
    Enum.any?(fields, fn field ->
      not is_nil(Extension.get_opt(module, [section], field, nil))
    end)
  end

  defp node_authoring_summary(%Node{} = node) do
    %{
      id: node.id,
      family: node.family,
      kind: node.kind,
      required_fields: Map.get(@required_fields_by_kind, node.kind, []),
      optional_slots: optional_slots(node),
      state_fields: present_fields(node, @state_fields),
      interaction_refs: node.interaction_refs,
      binding_refs: node.binding_refs
    }
    |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
    |> Enum.into(%{})
  end

  defp repeated_collection_summary(%Node{} = node) do
    %{
      id: node.id,
      collection_source: node.collection_source,
      item_alias: node.item_alias,
      index_alias: node.index_alias,
      key_path: node.key_path,
      empty_state: node.empty_state,
      child_template: child_template_summary(node.children)
    }
    |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
    |> Enum.into(%{})
  end

  defp child_template_summary([%Node{} = child | _rest]) do
    %{
      id: child.id,
      family: child.family,
      kind: child.kind,
      template_children: child.template_children
    }
    |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
    |> Enum.into(%{})
  end

  defp child_template_summary(_children), do: nil

  defp optional_slots(%Node{template_children: template_children})
       when is_list(template_children) and template_children != [] do
    [:template_children]
  end

  defp optional_slots(%Node{children: children}) when is_list(children) and children != [] do
    [:children]
  end

  defp optional_slots(_node), do: []

  defp present_fields(node, fields) do
    fields
    |> Enum.filter(fn field ->
      value = Map.get(node, field)
      not (is_nil(value) or value == [])
    end)
    |> sort_terms()
  end

  defp row_scope_refs(%Node{} = node) do
    node
    |> Map.from_struct()
    |> Map.drop([:__identifier__, :children])
    |> Map.values()
    |> collect_row_scope_refs()
  end

  defp collect_row_scope_refs(values) when is_list(values) do
    Enum.flat_map(values, &collect_row_scope_refs/1)
  end

  defp collect_row_scope_refs(value) when is_map(value) do
    cond do
      RowScope.reference?(value) ->
        [value]

      match?(%_struct{}, value) ->
        []

      true ->
        value
        |> Map.values()
        |> collect_row_scope_refs()
    end
  end

  defp collect_row_scope_refs(_value), do: []

  defp flatten_nodes(nodes) do
    Enum.flat_map(nodes, fn %Node{children: children} = node ->
      [node | flatten_nodes(children)]
    end)
  end

  defp sort_terms(values) do
    values
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end
end
