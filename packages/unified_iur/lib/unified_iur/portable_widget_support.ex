defmodule UnifiedIUR.PortableWidgetSupport do
  @moduledoc """
  Shared promoted-widget support matrix for canonical and runtime tooling.
  """

  alias UnifiedIUR.{Binding, Element, Interoperability, Widgets}

  @semantic_kinds Widgets.semantic_kinds()
  @workflow_kinds Widgets.workflow_kinds()
  @form_kinds [:host_form_shell]
  @collection_kinds [:repeated_collection]
  @runtime_packages [:live_ui, :elm_ui, :desktop_ui, :terminal_ui]
  @terminal_fallbacks %{
    disclosure: :inline_disclosure,
    kicker: nil,
    avatar: :initials_text,
    presence_dot: :status_text,
    segmented_button_group: :inline_menu_selection,
    list_item_multi_column: :linearized_row,
    artifact_row: :linearized_row,
    sticky_header: :inline_header,
    pipeline_stepper_horizontal: :ascii_progress,
    segmented_progress_bar: :ascii_progress,
    workflow_stage_list_vertical: :linearized_list,
    meter_thin: :ascii_progress,
    slide_over_panel: :inline_overlay,
    event_callout: :inline_feedback,
    redline_inline: :inline_diff,
    code_block_syntax_highlighted: :plain_code_block,
    chat_composer: :inline_text_prompt,
    host_form_shell: :linearized_form,
    repeated_collection: :linearized_collection
  }

  @spec semantic_kinds() :: [atom()]
  def semantic_kinds, do: @semantic_kinds

  @spec workflow_kinds() :: [atom()]
  def workflow_kinds, do: @workflow_kinds

  @spec form_kinds() :: [atom()]
  def form_kinds, do: @form_kinds

  @spec collection_kinds() :: [atom()]
  def collection_kinds, do: @collection_kinds

  @spec promoted_kind_families() :: %{atom() => [atom()]}
  def promoted_kind_families do
    %{
      semantic: semantic_kinds(),
      workflow: workflow_kinds(),
      forms: form_kinds(),
      collection: collection_kinds()
    }
  end

  @spec promoted_kinds() :: [atom()]
  def promoted_kinds do
    semantic_kinds() ++ workflow_kinds() ++ form_kinds() ++ collection_kinds()
  end

  @spec runtime_packages() :: [atom()]
  def runtime_packages, do: @runtime_packages

  @spec runtime_report(atom(), keyword() | map()) :: map()
  def runtime_report(runtime, opts \\ []) when is_atom(runtime) do
    opts = normalize_opts(opts)
    policy = runtime_policy(runtime)
    expected = promoted_kinds()
    native_supported = MapSet.new(Map.get(opts, :native_supported_kinds, expected))
    iur_supported = MapSet.new(Map.get(opts, :iur_supported_kinds, expected))

    widgets =
      Enum.map(expected, fn kind ->
        support = support_for_kind(runtime, kind)

        support
        |> Map.put(
          :native_support,
          support_status(support.native_support, native_supported, kind)
        )
        |> Map.put(:iur_support, support_status(support.iur_support, iur_supported, kind))
      end)

    native_missing = missing(expected, native_supported)
    iur_missing = missing(expected, iur_supported)

    %{
      runtime: runtime,
      support_mode: policy.support,
      expected_kinds: expected,
      native_missing_kinds: native_missing,
      iur_missing_kinds: iur_missing,
      widgets: widgets,
      complete?: native_missing == [] and iur_missing == []
    }
  end

  @spec runtime_support_matrix(keyword() | map()) :: [map()]
  def runtime_support_matrix(opts_by_runtime \\ %{}) do
    opts_by_runtime = normalize_opts(opts_by_runtime)

    Enum.map(runtime_packages(), fn runtime ->
      runtime_report(runtime, Map.get(opts_by_runtime, runtime, []))
    end)
  end

  @spec support_for_kind(atom(), atom()) :: map()
  def support_for_kind(runtime, kind) when is_atom(runtime) and is_atom(kind) do
    policy = runtime_policy(runtime)

    %{
      runtime: runtime,
      kind: kind,
      family: family_for_kind(kind),
      support: policy.support,
      native_support: policy.native_support,
      iur_support: policy.iur_support,
      fallback: fallback_for_kind(runtime, kind),
      required_review: required_review_for_kind(kind)
    }
  end

  @spec support_for_kind(atom()) :: [map()]
  def support_for_kind(kind) when is_atom(kind) do
    Enum.map(runtime_packages(), &support_for_kind(&1, kind))
  end

  @spec surface_validation(keyword() | map()) :: map()
  def surface_validation(opts) do
    opts = normalize_opts(opts)
    expected = promoted_kinds()
    authored = MapSet.new(Map.get(opts, :authored_kinds, []))
    iur = MapSet.new(Map.get(opts, :iur_kinds, []))
    runtime_reports = Map.get(opts, :runtime_reports, runtime_support_matrix())
    row_scope = Map.get(opts, :row_scope_report)

    missing_runtime =
      runtime_reports
      |> Enum.flat_map(fn report ->
        missing = report.native_missing_kinds ++ report.iur_missing_kinds
        if missing == [], do: [], else: [{report.runtime, Enum.uniq(missing)}]
      end)
      |> Map.new()

    row_scope_complete? = is_nil(row_scope) or Map.get(row_scope, :complete?, false)

    %{
      expected_kinds: expected,
      missing_authoring_kinds: missing(expected, authored),
      missing_iur_kinds: missing(expected, iur),
      missing_runtime_kinds: missing_runtime,
      row_scope: row_scope,
      complete?:
        missing(expected, authored) == [] and missing(expected, iur) == [] and
          missing_runtime == %{} and row_scope_complete?
    }
  end

  @spec row_scope_report(Element.t()) :: map()
  def row_scope_report(%Element{} = element) do
    collections =
      element
      |> Interoperability.walk()
      |> Enum.filter(&(&1.kind == :repeated_collection))
      |> Enum.map(&collection_row_scope_report/1)

    %{
      total_collections: length(collections),
      collections: collections,
      complete?: collections != [] and Enum.all?(collections, & &1.complete?)
    }
  end

  @spec family_for_kind(atom()) :: atom() | nil
  def family_for_kind(kind) when kind in @semantic_kinds, do: :semantic
  def family_for_kind(kind) when kind in @workflow_kinds, do: :workflow
  def family_for_kind(kind) when kind in @form_kinds, do: :forms
  def family_for_kind(kind) when kind in @collection_kinds, do: :collection
  def family_for_kind(_kind), do: nil

  defp collection_row_scope_report(%Element{} = element) do
    collection = Map.get(element.attributes, :collection, %{})
    row_bindings = collect_row_scope_bindings(element)
    source = Map.get(collection, :source)
    key_path = Map.get(collection, :key_path, [])
    has_row_key? = key_path != [] or binding_kind?(row_bindings, :key)

    renderer_local? =
      renderer_local_source?(source) or Enum.any?(row_bindings, &renderer_local_source?/1)

    %{
      id: element.id,
      source: source,
      item_alias: Map.get(collection, :item_alias),
      index_alias: Map.get(collection, :index_alias),
      key_path: key_path,
      row_scope_bindings: Enum.map(row_bindings, &binding_summary/1),
      has_row_key?: has_row_key?,
      has_row_index?: binding_kind?(row_bindings, :index),
      renderer_local?: renderer_local?,
      complete?:
        not is_nil(source) and key_path != [] and row_bindings != [] and
          has_row_key? and binding_kind?(row_bindings, :index) and not renderer_local?
    }
  end

  defp collect_row_scope_bindings(%Element{} = element) do
    attribute_bindings = collect_row_scope_bindings(element.attributes)

    child_bindings =
      element.children
      |> Enum.flat_map(fn
        %{element: %Element{} = child} -> collect_row_scope_bindings(child)
        _child -> []
      end)

    (attribute_bindings ++ child_bindings)
    |> Enum.uniq_by(&{&1.source, &1.scope, &1.path, Map.get(&1.metadata, :binding_kind)})
  end

  defp collect_row_scope_bindings(%Binding{source: :row_scope} = binding), do: [binding]
  defp collect_row_scope_bindings(%Binding{}), do: []

  defp collect_row_scope_bindings(value) when is_map(value) do
    value
    |> Map.values()
    |> Enum.flat_map(&collect_row_scope_bindings/1)
  end

  defp collect_row_scope_bindings(values) when is_list(values) do
    Enum.flat_map(values, &collect_row_scope_bindings/1)
  end

  defp collect_row_scope_bindings(_value), do: []

  defp binding_summary(%Binding{} = binding) do
    %{
      name: binding.name,
      source: binding.source,
      scope: binding.scope,
      path: binding.path,
      target: Map.get(binding.metadata, :target),
      binding_kind: Map.get(binding.metadata, :binding_kind)
    }
  end

  defp binding_kind?(bindings, kind) do
    Enum.any?(bindings, &(Map.get(&1.metadata, :binding_kind) == kind))
  end

  defp runtime_policy(:terminal_ui) do
    %{support: :degraded, native_support: :degraded, iur_support: :degraded}
  end

  defp runtime_policy(runtime) when runtime in @runtime_packages do
    %{support: :direct, native_support: :direct, iur_support: :direct}
  end

  defp fallback_for_kind(:terminal_ui, kind), do: Map.get(@terminal_fallbacks, kind)
  defp fallback_for_kind(_runtime, _kind), do: nil

  defp required_review_for_kind(:repeated_collection), do: [:row_scope, :stable_key, :empty_state]
  defp required_review_for_kind(:host_form_shell), do: [:host_lifecycle, :validation_summary]
  defp required_review_for_kind(kind) when kind in @workflow_kinds, do: [:workflow_state]
  defp required_review_for_kind(kind) when kind in @semantic_kinds, do: [:semantic_fields]
  defp required_review_for_kind(_kind), do: []

  defp support_status(status, supported, kind) do
    if MapSet.member?(supported, kind), do: status, else: :missing
  end

  defp missing(expected, supported) do
    expected
    |> Enum.reject(&MapSet.member?(supported, &1))
  end

  defp renderer_local_source?(%Binding{source: source, metadata: metadata}) do
    source in [:renderer_local, :callback, :phoenix, :ash_relationship] or
      Enum.any?(
        [:relationship, :resource, :ash_relationship, :ash_resource],
        &Map.has_key?(metadata, &1)
      )
  end

  defp renderer_local_source?(value) do
    value
    |> inspect()
    |> String.contains?(["Phoenix", "AshPhoenix", "Ash.Resource", "callback"])
  end

  defp normalize_opts(opts) when is_list(opts), do: Enum.into(opts, %{})
  defp normalize_opts(opts) when is_map(opts), do: Map.new(opts)
end
