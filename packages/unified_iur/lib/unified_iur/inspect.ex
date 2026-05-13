defmodule UnifiedIUR.Inspect do
  @moduledoc """
  Maintainer-facing inspection helpers for canonical `UnifiedIUR` values.
  """

  alias UnifiedIUR.{
    Element,
    Extension,
    Fixtures,
    Interaction,
    Interoperability,
    Normalize,
    PortableWidgetSupport,
    Reference,
    Validate
  }

  @type inspection_report :: %{
          fixture_id: String.t() | nil,
          identity: map() | nil,
          element_summary: map() | nil,
          tree_summary: map() | nil,
          classification: map() | nil,
          render_tree: String.t() | nil,
          attachments: [map()],
          styles: [map()],
          themes: [map()],
          interactions: [map()],
          portable_widgets: [map()],
          collections: [map()],
          diagnostics: map()
        }

  @spec fixture(String.t()) :: {:ok, inspection_report()} | :error
  def fixture(id) when is_binary(id) do
    case Fixtures.fixture(id) do
      {:ok, fixture} ->
        {:ok, Map.put(element(fixture.element), :fixture_id, fixture.id)}

      :error ->
        :error
    end
  end

  @spec navigation_fixture(String.t()) :: {:ok, map()} | :error
  def navigation_fixture(id) when is_binary(id) do
    case Fixtures.navigation_fixture(id) do
      {:ok, fixture} ->
        {:ok,
         fixture.interaction
         |> interaction()
         |> Map.put(:fixture_id, fixture.id)
         |> Map.put(:description, fixture.description)
         |> Map.put(:semantics, fixture.semantics)
         |> Map.put(:snapshot_path, fixture.snapshot_path)}

      :error ->
        :error
    end
  end

  @spec element(Element.t() | map() | keyword()) :: inspection_report()
  def element(input) do
    element = Normalize.element!(input)

    %{
      fixture_id: nil,
      identity: Interoperability.identity(element),
      element_summary: Reference.summarize_element(element),
      tree_summary: Reference.summarize_tree(element),
      classification: Interoperability.classify(element),
      render_tree: render_tree(element),
      attachments: Interoperability.attachments(element),
      styles: styles(element),
      themes: themes(element),
      interactions: interactions(element),
      portable_widgets: portable_widgets(element),
      collections: collections(element),
      diagnostics: Validate.diagnostics(element)
    }
  end

  @spec interaction(Interaction.t() | map() | keyword()) :: map()
  def interaction(input) do
    interaction = Interaction.new(input)

    %{
      family: interaction.family,
      intent: interaction.intent,
      source: interaction.source,
      target: interaction.target,
      navigation: Interaction.navigation_descriptor(interaction),
      payload: interaction.payload,
      metadata: interaction.metadata
    }
  end

  @spec render_tree(Element.t() | map() | keyword()) :: String.t()
  def render_tree(input) do
    input
    |> Normalize.element!()
    |> render_lines(0)
    |> Enum.join("\n")
  end

  @spec styles(Element.t() | map() | keyword()) :: [map()]
  def styles(input) do
    input
    |> Interoperability.walk()
    |> Enum.flat_map(fn element ->
      style = Map.get(element.attributes, :style)
      style_refs = Map.get(element.attributes, :style_refs, [])

      if is_nil(style) and style_refs == [] do
        []
      else
        [
          %{
            id: element.id,
            kind: element.kind,
            style: style,
            style_refs: style_refs
          }
        ]
      end
    end)
  end

  @spec themes(Element.t() | map() | keyword()) :: [map()]
  def themes(input) do
    input
    |> Interoperability.walk()
    |> Enum.flat_map(fn element ->
      case Map.fetch(element.attributes, :theme) do
        {:ok, theme} ->
          [
            %{
              id: element.id,
              kind: element.kind,
              theme: theme,
              theme_refs: Map.get(element.attributes, :theme_refs, [])
            }
          ]

        :error ->
          []
      end
    end)
  end

  @spec interactions(Element.t() | map() | keyword()) :: [map()]
  def interactions(input) do
    input
    |> Interoperability.walk()
    |> Enum.flat_map(fn element ->
      element.attributes
      |> Map.get(:interactions, [])
      |> Enum.map(fn interaction ->
        interaction
        |> interaction()
        |> Map.merge(%{
          id: element.id,
          kind: element.kind,
          interaction: Interaction.new(interaction)
        })
      end)
    end)
  end

  @spec portable_widgets(Element.t() | map() | keyword()) :: [map()]
  def portable_widgets(input) do
    input
    |> Interoperability.walk()
    |> Enum.flat_map(fn element ->
      if portable_widget_kind?(element.kind) do
        [
          %{
            id: element.id,
            type: element.type,
            kind: element.kind,
            family: portable_widget_family(element.kind),
            required_fields: required_fields(element.kind),
            degradation_hints: degradation_hints(element.kind),
            runtime_support: PortableWidgetSupport.support_for_kind(element.kind),
            semantic_fields: semantic_fields(element)
          }
        ]
      else
        []
      end
    end)
  end

  @spec collections(Element.t() | map() | keyword()) :: [map()]
  def collections(input) do
    input
    |> Interoperability.walk()
    |> Enum.flat_map(fn
      %Element{kind: :repeated_collection} = element ->
        collection = Map.get(element.attributes, :collection, %{})
        row_scope = Map.get(element.attributes, :row_scope, %{})

        [
          %{
            id: element.id,
            source: Map.get(collection, :source),
            item_alias: Map.get(collection, :item_alias),
            index_alias: Map.get(collection, :index_alias),
            key_path: Map.get(collection, :key_path, []),
            template: child_summary(element, :template),
            empty_state: child_summary(element, :empty_state),
            row_scope_bindings: Map.get(row_scope, :bindings, []),
            row_scope_summary:
              element
              |> PortableWidgetSupport.row_scope_report()
              |> Map.get(:collections, [])
              |> List.first()
          }
        ]

      _element ->
        []
    end)
  end

  @spec extension_metadata() :: map()
  def extension_metadata do
    %{
      extension_points: Extension.extension_points(),
      compatibility_rules: Extension.compatibility_rules(),
      iur_catalog: Extension.iur_catalog(),
      unified_ui_family_map: Extension.unified_ui_family_map()
    }
  end

  defp render_lines(%Element{} = element, depth) do
    current_line = "#{indent(depth)}- #{element.id} [#{element.type}:#{element.kind}]"

    child_lines =
      Enum.flat_map(element.children, fn child ->
        slot_line = "#{indent(depth + 1)}@#{child.slot}"

        case child.element do
          nil ->
            [slot_line <> " nil"]

          child_element ->
            [slot_line | render_lines(child_element, depth + 2)]
        end
      end)

    [current_line | child_lines]
  end

  defp indent(depth), do: String.duplicate("  ", depth)

  defp portable_widget_kind?(kind) do
    kind in UnifiedIUR.Widgets.semantic_kinds() or
      kind in UnifiedIUR.Widgets.workflow_kinds() or kind == :host_form_shell
  end

  defp portable_widget_family(kind) do
    cond do
      kind in UnifiedIUR.Widgets.semantic_kinds() -> :semantic
      kind in UnifiedIUR.Widgets.workflow_kinds() -> :workflow
      kind == :host_form_shell -> :forms
    end
  end

  defp required_fields(:host_form_shell), do: [[:form_shell, :owner], [:form_shell, :lifecycle]]
  defp required_fields(:disclosure), do: [[:disclosure, :label]]
  defp required_fields(:kicker), do: [[:kicker, :value]]
  defp required_fields(:avatar), do: [[:avatar, :label]]
  defp required_fields(:presence_dot), do: [[:presence, :status]]
  defp required_fields(:segmented_button_group), do: [[:segments, :items]]
  defp required_fields(:list_item_multi_column), do: [[:list_item, :columns]]
  defp required_fields(:artifact_row), do: [[:artifact, :value], [:artifact, :title]]
  defp required_fields(:sticky_header), do: [[:sticky_header, :title]]
  defp required_fields(:pipeline_stepper_horizontal), do: [[:workflow, :steps]]
  defp required_fields(:segmented_progress_bar), do: [[:progress, :segments]]
  defp required_fields(:workflow_stage_list_vertical), do: [[:workflow, :stages]]
  defp required_fields(:meter_thin), do: [[:meter, :current]]
  defp required_fields(:slide_over_panel), do: [[:panel, :placement]]
  defp required_fields(:event_callout), do: [[:callout, :message]]
  defp required_fields(:redline_inline), do: [[:redline, :before_text], [:redline, :after_text]]
  defp required_fields(:code_block_syntax_highlighted), do: [[:code_block, :code]]
  defp required_fields(:chat_composer), do: [[:composer]]
  defp required_fields(_kind), do: []

  defp degradation_hints(:code_block_syntax_highlighted), do: [:plain_text_code_fallback]
  defp degradation_hints(:slide_over_panel), do: [:inline_panel_fallback]
  defp degradation_hints(:chat_composer), do: [:text_input_and_submit_fallback]
  defp degradation_hints(:segmented_progress_bar), do: [:linear_progress_fallback]
  defp degradation_hints(_kind), do: []

  defp semantic_fields(%Element{} = element) do
    element.attributes
    |> Map.drop([:style, :theme, :bindings, :interactions, :interaction_scope])
    |> Map.drop([:content, :accessibility, :state])
  end

  defp child_summary(%Element{} = element, slot) do
    element.children
    |> Enum.find(&(&1.slot == slot))
    |> case do
      nil -> nil
      %{element: nil} -> nil
      %{element: child} -> %{id: child.id, type: child.type, kind: child.kind}
    end
  end
end
