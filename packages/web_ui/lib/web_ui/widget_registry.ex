defmodule WebUi.WidgetRegistry do
  @moduledoc """
  Built-in widget catalog registry with deterministic term_ui parity baseline.
  """

  alias WebUi.Observability.Diagnostics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.Events.EventCatalog
  alias WebUi.TypedError
  alias WebUi.WidgetDescriptor
  alias WebUi.WidgetRegistrationRequest

  @required_builtin_ids [
    "block",
    "button",
    "label",
    "list",
    "pick_list",
    "progress",
    "text_input_primitive",
    "alert_dialog",
    "bar_chart",
    "canvas",
    "cluster_dashboard",
    "command_palette",
    "context_menu",
    "dialog",
    "form_builder",
    "gauge",
    "line_chart",
    "log_viewer",
    "markdown_viewer",
    "menu",
    "process_monitor",
    "scroll_bar",
    "sparkline",
    "split_pane",
    "stream_widget",
    "supervision_tree_viewer",
    "table",
    "tabs",
    "text_input",
    "toast",
    "toast_manager",
    "tree_view",
    "viewport"
  ]

  @builtin_widget_entries [
    %{widget_id: "block", termui_module: "TermUI.Widget.Block", category: "primitive", required_event_types: [], optional_event_types: []},
    %{widget_id: "button", termui_module: "TermUI.Widget.Button", category: "primitive", required_event_types: ["unified.button.clicked", "unified.element.focused", "unified.element.blurred"], optional_event_types: []},
    %{widget_id: "label", termui_module: "TermUI.Widget.Label", category: "primitive", required_event_types: [], optional_event_types: []},
    %{widget_id: "list", termui_module: "TermUI.Widget.List", category: "primitive", required_event_types: ["unified.item.selected", "unified.item.toggled"], optional_event_types: []},
    %{widget_id: "pick_list", termui_module: "TermUI.Widget.PickList", category: "primitive", required_event_types: ["unified.item.selected", "unified.overlay.closed"], optional_event_types: []},
    %{widget_id: "progress", termui_module: "TermUI.Widget.Progress", category: "primitive", required_event_types: [], optional_event_types: []},
    %{widget_id: "text_input_primitive", termui_module: "TermUI.Widget.TextInput", category: "primitive", required_event_types: ["unified.input.changed", "unified.form.submitted", "unified.element.focused", "unified.element.blurred"], optional_event_types: []},
    %{widget_id: "alert_dialog", termui_module: "TermUI.Widgets.AlertDialog", category: "overlay", required_event_types: ["unified.overlay.confirmed", "unified.overlay.closed", "unified.button.clicked"], optional_event_types: []},
    %{widget_id: "bar_chart", termui_module: "TermUI.Widgets.BarChart", category: "visualization", required_event_types: [], optional_event_types: ["unified.chart.point_selected", "unified.chart.point_hovered"]},
    %{widget_id: "canvas", termui_module: "TermUI.Widgets.Canvas", category: "visualization", required_event_types: ["unified.canvas.pointer.changed"], optional_event_types: ["unified.button.clicked"]},
    %{widget_id: "cluster_dashboard", termui_module: "TermUI.Widgets.ClusterDashboard", category: "runtime", required_event_types: ["unified.item.selected", "unified.view.changed", "unified.action.requested"], optional_event_types: []},
    %{widget_id: "command_palette", termui_module: "TermUI.Widgets.CommandPalette", category: "navigation", required_event_types: ["unified.input.changed", "unified.item.selected", "unified.command.executed", "unified.overlay.closed"], optional_event_types: []},
    %{widget_id: "context_menu", termui_module: "TermUI.Widgets.ContextMenu", category: "overlay", required_event_types: ["unified.menu.action_selected", "unified.item.selected", "unified.overlay.closed"], optional_event_types: []},
    %{widget_id: "dialog", termui_module: "TermUI.Widgets.Dialog", category: "overlay", required_event_types: ["unified.overlay.confirmed", "unified.overlay.closed", "unified.button.clicked"], optional_event_types: []},
    %{widget_id: "form_builder", termui_module: "TermUI.Widgets.FormBuilder", category: "utility", required_event_types: ["unified.input.changed", "unified.form.submitted", "unified.item.toggled", "unified.element.focused", "unified.element.blurred"], optional_event_types: []},
    %{widget_id: "gauge", termui_module: "TermUI.Widgets.Gauge", category: "visualization", required_event_types: [], optional_event_types: []},
    %{widget_id: "line_chart", termui_module: "TermUI.Widgets.LineChart", category: "visualization", required_event_types: [], optional_event_types: ["unified.chart.point_selected", "unified.chart.point_hovered"]},
    %{widget_id: "log_viewer", termui_module: "TermUI.Widgets.LogViewer", category: "data", required_event_types: ["unified.scroll.changed", "unified.item.selected"], optional_event_types: ["unified.input.changed"]},
    %{widget_id: "markdown_viewer", termui_module: "TermUI.Widgets.MarkdownViewer", category: "data", required_event_types: [], optional_event_types: ["unified.link.clicked"]},
    %{widget_id: "menu", termui_module: "TermUI.Widgets.Menu", category: "navigation", required_event_types: ["unified.menu.action_selected", "unified.item.selected"], optional_event_types: []},
    %{widget_id: "process_monitor", termui_module: "TermUI.Widgets.ProcessMonitor", category: "runtime", required_event_types: ["unified.item.selected", "unified.action.requested"], optional_event_types: []},
    %{widget_id: "scroll_bar", termui_module: "TermUI.Widgets.ScrollBar", category: "navigation", required_event_types: ["unified.scroll.changed"], optional_event_types: []},
    %{widget_id: "sparkline", termui_module: "TermUI.Widgets.Sparkline", category: "visualization", required_event_types: [], optional_event_types: ["unified.chart.point_selected", "unified.chart.point_hovered"]},
    %{widget_id: "split_pane", termui_module: "TermUI.Widgets.SplitPane", category: "navigation", required_event_types: ["unified.split.resized", "unified.split.collapse_changed"], optional_event_types: []},
    %{widget_id: "stream_widget", termui_module: "TermUI.Widgets.StreamWidget", category: "runtime", required_event_types: [], optional_event_types: ["unified.item.selected", "unified.scroll.changed"]},
    %{widget_id: "supervision_tree_viewer", termui_module: "TermUI.Widgets.SupervisionTreeViewer", category: "runtime", required_event_types: ["unified.tree.node_selected", "unified.tree.node_toggled", "unified.action.requested"], optional_event_types: []},
    %{widget_id: "table", termui_module: "TermUI.Widgets.Table", category: "data", required_event_types: ["unified.table.row_selected", "unified.table.sorted"], optional_event_types: ["unified.item.toggled"]},
    %{widget_id: "tabs", termui_module: "TermUI.Widgets.Tabs", category: "navigation", required_event_types: ["unified.tab.changed"], optional_event_types: ["unified.tab.closed"]},
    %{widget_id: "text_input", termui_module: "TermUI.Widgets.TextInput", category: "utility", required_event_types: ["unified.input.changed", "unified.form.submitted", "unified.element.focused", "unified.element.blurred"], optional_event_types: []},
    %{widget_id: "toast", termui_module: "TermUI.Widgets.Toast", category: "overlay", required_event_types: ["unified.toast.dismissed"], optional_event_types: []},
    %{widget_id: "toast_manager", termui_module: "TermUI.Widgets.ToastManager", category: "overlay", required_event_types: ["unified.toast.dismissed"], optional_event_types: ["unified.toast.cleared"]},
    %{widget_id: "tree_view", termui_module: "TermUI.Widgets.TreeView", category: "data", required_event_types: ["unified.tree.node_selected", "unified.tree.node_toggled"], optional_event_types: []},
    %{widget_id: "viewport", termui_module: "TermUI.Widgets.Viewport", category: "navigation", required_event_types: ["unified.scroll.changed"], optional_event_types: ["unified.viewport.resized"]}
  ]
  |> Enum.map(fn entry ->
    Map.put(entry, :event_types, entry.required_event_types ++ entry.optional_event_types)
  end)

  @route_key_requirements %{
    click: ["action", "button_id", "widget_id", "id"],
    change: ["input_id", "widget_id", "field", "action", "id"],
    submit: ["form_id", "action", "id"]
  }

  @route_key_conventions %{
    "click" => @route_key_requirements.click,
    "change" => @route_key_requirements.change,
    "submit" => @route_key_requirements.submit
  }

  @capability_registry %{
    "emit_widget_events" => 1,
    "read_view_state" => 1,
    "request_js_interop" => 1
  }

  @custom_widget_id_regex ~r/^custom\.[a-z0-9]+(?:_[a-z0-9]+)*\.[a-z0-9]+(?:_[a-z0-9]+)*$/

  @catalog_fingerprint :erlang.phash2(@builtin_widget_entries)

  @enforce_keys [:built_in_index, :custom_index, :descriptor_index, :implementation_index, :catalog_fingerprint]

  defstruct built_in_index: %{},
            custom_index: %{},
            descriptor_index: %{},
            implementation_index: %{},
            catalog_fingerprint: @catalog_fingerprint

  @type widget_entry :: %{
          widget_id: String.t(),
          origin: String.t(),
          implementation_ref: String.t() | nil,
          termui_module: String.t(),
          category: String.t(),
          required_event_types: [String.t()],
          optional_event_types: [String.t()],
          event_types: [String.t()]
        }

  @type t :: %__MODULE__{
          built_in_index: %{String.t() => widget_entry()},
          custom_index: %{String.t() => widget_entry()},
          descriptor_index: %{String.t() => WidgetDescriptor.t()},
          implementation_index: %{String.t() => String.t()},
          catalog_fingerprint: non_neg_integer()
        }

  @spec new() :: {:ok, t()} | {:error, TypedError.t()}
  def new do
    with :ok <- parity_check(),
         :ok <- validate_categories(),
         :ok <- validate_event_types(),
         {:ok, descriptors} <- validate_descriptors() do
      {:ok,
       %__MODULE__{
         built_in_index: Map.new(@builtin_widget_entries, &{&1.widget_id, builtin_entry(&1)}),
         custom_index: %{},
         descriptor_index: Map.new(descriptors, &{&1.widget_id, &1}),
         implementation_index: %{},
         catalog_fingerprint: @catalog_fingerprint
       }}
    end
  end

  @spec builtin_widget_entries() :: [widget_entry()]
  def builtin_widget_entries do
    Enum.map(@builtin_widget_entries, &Map.new/1)
  end

  @spec builtin_widget_ids() :: [String.t()]
  def builtin_widget_ids do
    Enum.map(@builtin_widget_entries, & &1.widget_id)
  end

  @spec builtin_widget_descriptors() :: [WidgetDescriptor.t()]
  def builtin_widget_descriptors do
    Enum.map(@builtin_widget_entries, &descriptor_from_entry/1)
  end

  @spec allowed_categories() :: [String.t()]
  def allowed_categories, do: WidgetDescriptor.allowed_categories()

  @spec capability_registry() :: %{String.t() => %{version: pos_integer()}}
  def capability_registry do
    Map.new(@capability_registry, fn {capability, version} ->
      {capability, %{version: version}}
    end)
  end

  @spec parity_check() :: :ok | {:error, TypedError.t()}
  def parity_check do
    actual = builtin_widget_ids()

    if actual == @required_builtin_ids do
      :ok
    else
      {:error,
       TypedError.new(
         "widget_registry.catalog_mismatch",
         "validation",
         false,
         %{expected_ids: @required_builtin_ids, actual_ids: actual}
       )}
    end
  end

  @spec validate_categories() :: :ok | {:error, TypedError.t()}
  def validate_categories do
    invalid_entries = Enum.reject(@builtin_widget_entries, &(&1.category in allowed_categories()))

    case invalid_entries do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_category",
           "validation",
           false,
           %{invalid_entries: invalid_entries, allowed_categories: allowed_categories()}
        )}
    end
  end

  @spec validate_event_types() :: :ok | {:error, TypedError.t()}
  def validate_event_types do
    allowed = MapSet.new(EventCatalog.all_event_types())

    invalid_entries =
      @builtin_widget_entries
      |> Enum.map(fn entry ->
        unknown_event_types = Enum.reject(entry.event_types, &MapSet.member?(allowed, &1))

        if unknown_event_types == [] do
          nil
        else
          %{widget_id: entry.widget_id, unknown_event_types: unknown_event_types}
        end
      end)
      |> Enum.reject(&is_nil/1)

    case invalid_entries do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_event_type",
           "validation",
           false,
           %{invalid_entries: invalid_entries}
         )}
    end
  end

  @spec validate_catalog_fingerprint(non_neg_integer()) :: :ok | {:error, TypedError.t()}
  def validate_catalog_fingerprint(expected) when is_integer(expected) and expected >= 0 do
    if expected == @catalog_fingerprint do
      :ok
    else
      {:error,
       TypedError.new(
         "widget_registry.catalog_fingerprint_mismatch",
         "validation",
         false,
         %{expected_fingerprint: expected, actual_fingerprint: @catalog_fingerprint}
       )}
    end
  end

  @spec catalog_fingerprint() :: non_neg_integer()
  def catalog_fingerprint, do: @catalog_fingerprint

  @spec entry(t(), String.t()) :: {:ok, widget_entry()} | {:error, TypedError.t()}
  def entry(%__MODULE__{built_in_index: builtins, custom_index: customs}, widget_id) when is_binary(widget_id) do
    case Map.get(builtins, widget_id) || Map.get(customs, widget_id) do
      nil ->
        {:error,
         TypedError.new(
           "widget_registry.unknown_widget",
           "validation",
           false,
           %{widget_id: widget_id}
         )}

      entry ->
        {:ok, Map.new(entry)}
    end
  end

  @spec descriptor(t(), String.t()) :: {:ok, WidgetDescriptor.t()} | {:error, TypedError.t()}
  def descriptor(%__MODULE__{descriptor_index: descriptors}, widget_id) when is_binary(widget_id) do
    case Map.get(descriptors, widget_id) do
      nil ->
        {:error,
         TypedError.new(
           "widget_registry.descriptor_not_found",
           "validation",
           false,
           %{widget_id: widget_id}
         )}

      descriptor ->
        {:ok, descriptor}
    end
  end

  @spec list_descriptors(t(), keyword()) :: [WidgetDescriptor.t()]
  def list_descriptors(%__MODULE__{descriptor_index: descriptors}, filters \\ []) when is_list(filters) do
    descriptors
    |> Map.values()
    |> Enum.filter(fn descriptor ->
      matches_filter?(descriptor, :category, Keyword.get(filters, :category)) and
        matches_filter?(descriptor, :origin, Keyword.get(filters, :origin))
    end)
    |> Enum.sort_by(& &1.widget_id)
  end

  @spec list_by_category(t(), String.t()) :: [WidgetDescriptor.t()]
  def list_by_category(%__MODULE__{} = registry, category) when is_binary(category) do
    list_descriptors(registry, category: category)
  end

  @spec list_by_origin(t(), String.t()) :: [WidgetDescriptor.t()]
  def list_by_origin(%__MODULE__{} = registry, origin) when is_binary(origin) do
    list_descriptors(registry, origin: origin)
  end

  @spec register_custom(t(), map() | WidgetRegistrationRequest.t()) :: {:ok, t()} | {:error, TypedError.t()}
  def register_custom(%__MODULE__{} = registry, request) do
    with {:ok, normalized_request} <- WidgetRegistrationRequest.validate(request),
         :ok <- validate_custom_registration(registry, normalized_request) do
      descriptor = normalized_request.descriptor
      widget_id = descriptor.widget_id

      updated_registry =
        %__MODULE__{
          registry
          | custom_index: Map.put(registry.custom_index, widget_id, custom_entry(normalized_request)),
            descriptor_index: Map.put(registry.descriptor_index, widget_id, descriptor),
            implementation_index: Map.put(registry.implementation_index, widget_id, normalized_request.implementation_ref)
        }

      {:ok, updated_registry}
    end
  end

  @spec register_custom_with_events(t(), map() | WidgetRegistrationRequest.t()) ::
          {:ok, t(), [map()]} | {:error, TypedError.t(), [map()]}
  def register_custom_with_events(%__MODULE__{} = registry, request) do
    context = request_context(request)
    widget_id = request_widget_id(request)

    case register_custom(registry, request) do
      {:ok, updated_registry} ->
        {:ok, updated_registry, [registered_event(widget_id, context)]}

      {:error, %TypedError{} = error} ->
        {:error, error, [registration_failed_event(widget_id, error, context)]}
    end
  end

  @spec implementation_ref(t(), String.t()) :: {:ok, String.t()} | {:error, TypedError.t()}
  def implementation_ref(%__MODULE__{implementation_index: index}, widget_id) when is_binary(widget_id) do
    case Map.get(index, widget_id) do
      nil ->
        {:error,
         TypedError.new(
           "widget_registry.implementation_not_found",
           "validation",
           false,
           %{widget_id: widget_id}
         )}

      implementation_ref ->
        {:ok, implementation_ref}
    end
  end

  defp validate_descriptors do
    @builtin_widget_entries
    |> Enum.map(&descriptor_from_entry/1)
    |> Enum.reduce_while({:ok, []}, fn descriptor_map, {:ok, acc} ->
      case WidgetDescriptor.validate(descriptor_map) do
        {:ok, descriptor} -> {:cont, {:ok, [descriptor | acc]}}
        {:error, %TypedError{} = error} -> {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, descriptors} -> {:ok, Enum.reverse(descriptors)}
      {:error, %TypedError{} = error} -> {:error, error}
    end
  end

  defp validate_custom_registration(registry, %WidgetRegistrationRequest{} = request) do
    descriptor = request.descriptor

    with :ok <- validate_custom_origin(descriptor),
         :ok <- validate_custom_widget_id(registry, descriptor.widget_id),
         :ok <- validate_custom_props_schema(descriptor),
         :ok <- validate_custom_capabilities(descriptor),
         :ok <- validate_custom_event_schema(descriptor) do
      :ok
    end
  end

  defp validate_custom_origin(%WidgetDescriptor{origin: "custom"}), do: :ok

  defp validate_custom_origin(%WidgetDescriptor{} = descriptor) do
    {:error,
     TypedError.new(
       "widget_registry.invalid_custom_origin",
       "validation",
       false,
       %{widget_id: descriptor.widget_id, origin: descriptor.origin}
     )}
  end

  defp validate_custom_widget_id(%__MODULE__{} = registry, widget_id) when is_binary(widget_id) do
    cond do
      widget_id in @required_builtin_ids ->
        {:error,
         TypedError.new(
           "widget_registry.reserved_widget_id",
           "validation",
           false,
           %{widget_id: widget_id}
         )}

      not Regex.match?(@custom_widget_id_regex, widget_id) ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_custom_widget_id",
           "validation",
           false,
           %{widget_id: widget_id, required_format: "custom.<namespace>.<name>"}
         )}

      Map.has_key?(registry.custom_index, widget_id) ->
        {:error,
         TypedError.new(
           "widget_registry.duplicate_custom_widget_id",
           "conflict",
           false,
           %{widget_id: widget_id}
         )}

      true ->
        :ok
    end
  end

  defp validate_custom_props_schema(%WidgetDescriptor{} = descriptor) do
    props_schema = descriptor.props_schema
    type = Map.get(props_schema, :type) || Map.get(props_schema, "type")

    cond do
      type != "object" ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_custom_props_schema",
           "validation",
           false,
           %{widget_id: descriptor.widget_id, reason: "props_schema.type must be object"}
         )}

      descriptor.state_model == "stateful" and
          not is_boolean(Map.get(props_schema, :additional_properties) || Map.get(props_schema, "additional_properties")) ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_custom_props_schema",
           "validation",
           false,
           %{
             widget_id: descriptor.widget_id,
             reason: "stateful custom widgets must declare additional_properties boolean"
           }
         )}

      true ->
        :ok
    end
  end

  defp validate_custom_event_schema(%WidgetDescriptor{} = descriptor) do
    event_types =
      Map.get(descriptor.event_schema, :event_types) ||
        Map.get(descriptor.event_schema, "event_types")

    cond do
      not is_list(event_types) ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_custom_event_schema",
           "validation",
           false,
           %{widget_id: descriptor.widget_id, reason: "event_schema.event_types must be a list"}
         )}

      true ->
        invalid_event_types = Enum.reject(event_types, &supported_custom_event_type?/1)

        cond do
          invalid_event_types != [] ->
            {:error,
             TypedError.new(
               "widget_registry.invalid_custom_event_schema",
               "validation",
               false,
               %{widget_id: descriptor.widget_id, invalid_event_types: invalid_event_types}
             )}

          true ->
            validate_custom_route_key_conventions(descriptor, event_types)
        end
    end
  end

  defp supported_custom_event_type?(event_type) when is_binary(event_type) do
    cond do
      String.starts_with?(event_type, "unified.") ->
        match?({:ok, _}, EventCatalog.event_spec(event_type))

      String.starts_with?(event_type, "custom.") ->
        Regex.match?(~r/^custom\.[a-z0-9]+(?:_[a-z0-9]+)*(?:\.[a-z0-9]+(?:_[a-z0-9]+)*)+$/, event_type)

      true ->
        false
    end
  end

  defp supported_custom_event_type?(_event_type), do: false

  defp validate_custom_capabilities(%WidgetDescriptor{} = descriptor) do
    descriptor.capabilities
    |> Enum.reduce_while(:ok, fn capability, :ok ->
      case parse_capability(capability) do
        {:ok, %{name: name, version: version}} ->
          case Map.get(@capability_registry, name) do
            nil ->
              {:halt,
               {:error,
                TypedError.new(
                  "widget_registry.unsupported_custom_capability",
                  "validation",
                  false,
                  %{widget_id: descriptor.widget_id, capability: capability, supported: Map.keys(@capability_registry)}
                )}}

            expected_version when not is_nil(version) and expected_version != version ->
              {:halt,
               {:error,
                TypedError.new(
                  "widget_registry.custom_capability_version_mismatch",
                  "validation",
                  false,
                  %{
                    widget_id: descriptor.widget_id,
                    capability: name,
                    expected_version: expected_version,
                    requested_version: version
                  }
                )}}

            _expected_version ->
              {:cont, :ok}
          end

        {:error, %TypedError{} = error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp parse_capability(capability) when is_binary(capability) do
    case Regex.named_captures(~r/^(?<name>[a-z][a-z0-9_]*)(?:@(?<version>[0-9]+))?$/, capability) do
      %{"name" => name, "version" => ""} ->
        {:ok, %{name: name, version: nil}}

      %{"name" => name, "version" => version} ->
        {:ok, %{name: name, version: String.to_integer(version)}}

      _ ->
        {:error,
         TypedError.new(
           "widget_registry.invalid_custom_capability",
           "validation",
           false,
           %{capability: capability, required_format: "<capability>@<version>"}
         )}
    end
  end

  defp parse_capability(capability) do
    {:error,
     TypedError.new(
       "widget_registry.invalid_custom_capability",
       "validation",
       false,
       %{capability: capability, required_format: "<capability>@<version>"}
     )}
  end

  defp validate_custom_route_key_conventions(descriptor, event_types) do
    event_contracts =
      Map.get(descriptor.event_schema, :event_contracts) ||
        Map.get(descriptor.event_schema, "event_contracts") ||
        %{}

    violations =
      event_types
      |> Enum.reduce([], fn event_type, acc ->
        case fetch_event_contract(event_contracts, event_type) do
          nil ->
            acc

          contract ->
            route_family = to_string(Map.get(contract, :route_family) || Map.get(contract, "route_family") || "")
            required_route_keys = Map.get(@route_key_conventions, route_family, [])

            if required_route_keys == [] or route_key_contract_satisfied?(contract, required_route_keys) do
              acc
            else
              [%{event_type: event_type, route_family: route_family, required_keys: required_route_keys} | acc]
            end
        end
      end)
      |> Enum.reverse()

    case violations do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "widget_registry.custom_route_key_convention_violation",
           "validation",
           false,
           %{widget_id: descriptor.widget_id, violations: violations}
         )}
    end
  end

  defp fetch_event_contract(event_contracts, event_type) when is_map(event_contracts) and is_binary(event_type) do
    Map.get(event_contracts, event_type) ||
      Map.get(event_contracts, safe_existing_atom(event_type))
  end

  defp route_key_contract_satisfied?(contract, required_keys) do
    required_all_of = Map.get(contract, :required_all_of) || Map.get(contract, "required_all_of") || []
    required_any_of = Map.get(contract, :required_any_of) || Map.get(contract, "required_any_of") || []

    present_keys =
      required_all_of ++
        (required_any_of
         |> List.wrap()
         |> List.flatten())

    Enum.all?(required_keys, &(&1 in present_keys))
  end

  defp descriptor_from_entry(entry) do
    event_types = entry.event_types

    %{
      widget_id: entry.widget_id,
      origin: "builtin",
      category: entry.category,
      state_model: state_model(event_types),
      props_schema: %{
        type: "object",
        additional_properties: true,
        required: []
      },
      event_schema: event_schema(entry),
      version: "v1",
      capabilities: []
    }
  end

  defp event_schema(entry) do
    route_families =
      entry.event_types
      |> Enum.map(&route_family_for/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.sort()

    route_key_requirements =
      route_families
      |> Enum.filter(&Map.has_key?(@route_key_requirements, &1))
      |> Map.new(fn family -> {family, Map.fetch!(@route_key_requirements, family)} end)

    event_contracts =
      entry.event_types
      |> Map.new(fn event_type ->
        required_key_spec =
          case EventCatalog.required_key_spec(event_type) do
            {:ok, spec} -> spec
            {:error, _} -> %{required_all_of: [], required_any_of: []}
          end

        {event_type, Map.put(required_key_spec, :route_family, route_family_for(event_type))}
      end)

    %{
      version: "v1",
      interaction_mode: interaction_mode(entry.event_types),
      required_event_types: entry.required_event_types,
      optional_event_types: entry.optional_event_types,
      event_types: entry.event_types,
      route_key_requirements: route_key_requirements,
      event_contracts: event_contracts
    }
  end

  defp state_model([]), do: "stateless"
  defp state_model(_event_types), do: "stateful"

  defp interaction_mode([]), do: "none"
  defp interaction_mode(_event_types), do: "interactive"

  defp route_family_for(event_type) do
    case EventCatalog.route_family(event_type) do
      {:ok, family} -> family
      {:error, _} -> nil
    end
  end

  defp matches_filter?(_descriptor, _field, nil), do: true

  defp matches_filter?(descriptor, field, expected) do
    Map.get(descriptor, field) == expected
  end

  defp builtin_entry(entry) do
    entry
    |> Map.new()
    |> Map.put(:origin, "builtin")
    |> Map.put(:implementation_ref, nil)
  end

  defp custom_entry(%WidgetRegistrationRequest{} = request) do
    descriptor = request.descriptor
    event_schema = descriptor.event_schema

    %{
      widget_id: descriptor.widget_id,
      origin: "custom",
      implementation_ref: request.implementation_ref,
      termui_module: request.implementation_ref,
      category: descriptor.category,
      required_event_types: Map.get(event_schema, :required_event_types, []),
      optional_event_types: Map.get(event_schema, :optional_event_types, []),
      event_types: Map.get(event_schema, :event_types, [])
    }
  end

  defp registered_event(widget_id, context) do
    {:ok, event} =
      RuntimeEvent.build(
        %{
          event_name: "runtime.widget.registered.v1",
          event_version: "v1",
          service: "widget_registry",
          source: "WebUi.WidgetRegistry",
          outcome: "ok",
          payload: %{widget_id: widget_id}
        },
        context
      )

    Map.put(event, :widget_id, widget_id)
  end

  defp registration_failed_event(widget_id, error, context) do
    Diagnostics.denied_path_event(
      "runtime.widget.registration_failed.v1",
      "WebUi.WidgetRegistry",
      "widget_registry",
      context,
      error,
      %{widget_id: widget_id}
    )
    |> Map.put(:widget_id, widget_id)
    |> Map.put(:error_code, error.error_code)
    |> Map.put(:category, error.category)
  end

  defp request_widget_id(%WidgetRegistrationRequest{descriptor: descriptor}) when is_struct(descriptor, WidgetDescriptor),
    do: descriptor.widget_id

  defp request_widget_id(request) when is_map(request) do
    descriptor = Map.get(request, :descriptor) || Map.get(request, "descriptor") || %{}
    Map.get(descriptor, :widget_id) || Map.get(descriptor, "widget_id") || "unknown_widget"
  end

  defp request_widget_id(_request), do: "unknown_widget"

  defp request_context(%WidgetRegistrationRequest{context: context}), do: context

  defp request_context(request) when is_map(request) do
    case Map.get(request, :context) || Map.get(request, "context") do
      context when is_map(context) -> context
      _ -> %{}
    end
  end

  defp request_context(_request), do: %{}

  defp safe_existing_atom(value) when is_binary(value) do
    try do
      String.to_existing_atom(value)
    rescue
      ArgumentError -> nil
    end
  end
end
