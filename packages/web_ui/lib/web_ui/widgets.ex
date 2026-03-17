defmodule WebUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for the native `web_ui` widget surface.
  """

  alias WebUi.Widget

  alias WebUi.Widgets.{
    Data,
    Feedback,
    Forms,
    Foundational,
    Input,
    Layout,
    Navigation,
    Operational,
    Visualization
  }

  @type responsibility ::
          :native_widget_surface
          | :layout_surface
          | :layer_surface
          | :style_hooks
          | :direct_use_surface

  @kind_family_catalog %{
    text: :foundational,
    label: :foundational,
    icon: :foundational,
    image: :foundational,
    button: :foundational,
    link: :foundational,
    separator: :foundational,
    spacer: :foundational,
    content: :foundational,
    text_input: :input,
    form_builder: :input,
    field_group: :input,
    field: :input,
    select: :input,
    checkbox: :input,
    tabs: :navigation,
    menu: :navigation,
    row: :layout,
    column: :layout,
    dialog: :layer,
    table: :data,
    tree_view: :data,
    markdown_viewer: :document,
    log_viewer: :document,
    status: :feedback,
    progress: :feedback,
    inline_feedback: :feedback,
    gauge: :visualization,
    sparkline: :visualization,
    bar_chart: :visualization,
    line_chart: :visualization,
    canvas: :visualization,
    stream_widget: :operational,
    process_monitor: :operational,
    cluster_dashboard: :operational,
    command_palette: :operational,
    supervision_tree_viewer: :operational
  }

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :native_widget_surface,
      :layout_surface,
      :layer_surface,
      :style_hooks,
      :direct_use_surface
    ]
  end

  @spec families() :: [Widget.family()]
  def families do
    @kind_family_catalog
    |> Map.values()
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec kinds() :: [atom()]
  def kinds do
    @kind_family_catalog
    |> Map.keys()
    |> Enum.sort_by(&to_string/1)
  end

  @spec family_for_kind(atom() | String.t()) :: Widget.family()
  def family_for_kind(kind) do
    Map.get(@kind_family_catalog, normalize_kind(kind), :unknown)
  end

  @spec widget(atom() | String.t(), keyword() | map()) :: Widget.t()
  def widget(kind, attrs \\ []) do
    Widget.new(kind, attrs)
  end

  @spec normalize(Widget.t() | map() | keyword()) :: {:ok, Widget.t()} | {:error, term()}
  def normalize(%Widget{} = widget), do: {:ok, widget}

  def normalize(attrs) when is_map(attrs) or is_list(attrs) do
    attrs = normalize_map(attrs)

    case {Map.fetch(attrs, :kind), Map.fetch(attrs, :id)} do
      {{:ok, kind}, {:ok, _id}} ->
        {:ok, Widget.new(kind, attrs)}

      _other ->
        {:error, :invalid_widget}
    end
  end

  @spec normalize_many([Widget.t() | map() | keyword()]) :: {:ok, [Widget.t()]} | {:error, term()}
  def normalize_many(widgets) when is_list(widgets) do
    widgets
    |> Enum.reduce_while({:ok, []}, fn widget, {:ok, acc} ->
      case normalize(widget) do
        {:ok, normalized} -> {:cont, {:ok, [normalized | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, normalized} -> {:ok, Enum.reverse(normalized)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec modules() :: [module()]
  def modules do
    [
      Widget,
      Foundational,
      Input,
      Navigation,
      Layout,
      Forms,
      Data,
      Feedback,
      Visualization,
      Operational
    ]
  end

  @spec style_contract() :: map()
  def style_contract do
    %{
      widget_level_hooks: [:variant, :tone, :state, :layout],
      metadata_keys: [:style_hooks, :metadata],
      renderer_native?: true
    }
  end

  @spec metadata_contract() :: map()
  def metadata_contract do
    %{
      required_keys: [:id, :kind],
      optional_keys: [:props, :slots, :state, :style_hooks, :events, :metadata, :family]
    }
  end

  @spec events_contract() :: map()
  def events_contract do
    %{
      event_payload_shape: :map,
      event_names: [
        :change,
        :submit,
        :open,
        :close,
        :focus,
        :navigation,
        :command,
        :sort,
        :filter,
        :paginate,
        :expand
      ]
    }
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_definition: :ready,
      family_catalog: :ready,
      metadata_contract: :ready,
      foundational_widgets: :ready,
      input_widgets: :ready,
      navigation_widgets: :ready,
      form_composition: :ready,
      layout_primitives: :ready,
      advanced_data_widgets: :ready,
      advanced_feedback_widgets: :ready,
      advanced_visualization_widgets: :ready,
      advanced_operational_widgets: :ready
    }
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__

  defp normalize_kind(kind) when is_atom(kind), do: kind

  defp normalize_kind(kind) when is_binary(kind) do
    Enum.find(kinds(), kind, fn candidate -> Atom.to_string(candidate) == kind end)
  end

  defp normalize_map(map) when is_map(map) do
    Map.new(map, fn {key, value} -> {normalize_key(key), value} end)
  end

  defp normalize_map(list) when is_list(list), do: list |> Enum.into(%{}) |> normalize_map()

  defp normalize_key("id"), do: :id
  defp normalize_key("family"), do: :family
  defp normalize_key("kind"), do: :kind
  defp normalize_key("props"), do: :props
  defp normalize_key("slots"), do: :slots
  defp normalize_key("state"), do: :state
  defp normalize_key("style_hooks"), do: :style_hooks
  defp normalize_key("events"), do: :events
  defp normalize_key("metadata"), do: :metadata
  defp normalize_key(key), do: key
end
