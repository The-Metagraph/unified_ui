defmodule WebUi.Events.EventCatalog do
  @moduledoc """
  Canonical widget event type catalog and payload-key validation.
  """

  alias WebUi.TypedError

  @standard_event_types [
    "unified.button.clicked",
    "unified.input.changed",
    "unified.form.submitted",
    "unified.element.focused",
    "unified.element.blurred",
    "unified.item.selected"
  ]

  @event_specs %{
    "unified.button.clicked" => %{
      baseline: :standard,
      binding: "Html.Events.onClick",
      required_all_of: [],
      required_any_of: [["action", "button_id", "widget_id"]],
      route_family: :click
    },
    "unified.input.changed" => %{
      baseline: :standard,
      binding: "Html.Events.onInput",
      required_all_of: ["value"],
      required_any_of: [["input_id", "widget_id"]],
      route_family: :change
    },
    "unified.form.submitted" => %{
      baseline: :standard,
      binding: "Html.Events.onSubmit",
      required_all_of: [],
      required_any_of: [["form_id", "widget_id"]],
      route_family: :submit
    },
    "unified.element.focused" => %{
      baseline: :standard,
      binding: "Html.Events.onFocus",
      required_all_of: ["widget_id"],
      required_any_of: [],
      route_family: :focus
    },
    "unified.element.blurred" => %{
      baseline: :standard,
      binding: "Html.Events.onBlur",
      required_all_of: ["widget_id"],
      required_any_of: [],
      route_family: :focus
    },
    "unified.item.selected" => %{
      baseline: :standard,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id"],
      required_any_of: [["item_id", "index", "value"]],
      route_family: :selection
    },
    "unified.item.toggled" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["selected", "widget_id"],
      required_any_of: [["item_id", "index"]],
      route_family: :selection
    },
    "unified.menu.action_selected" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "action_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.table.row_selected" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "row_index"],
      required_any_of: [],
      route_family: :selection
    },
    "unified.table.sorted" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "column", "direction"],
      required_any_of: [],
      route_family: :click
    },
    "unified.tab.changed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "tab_id"],
      required_any_of: [],
      route_family: :selection
    },
    "unified.tab.closed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "tab_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.tree.node_selected" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "node_id"],
      required_any_of: [],
      route_family: :selection
    },
    "unified.tree.node_toggled" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "node_id", "expanded"],
      required_any_of: [],
      route_family: :selection
    },
    "unified.overlay.confirmed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "action_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.overlay.closed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.scroll.changed" => %{
      baseline: :extended,
      binding: "Html.Events.on \"scroll\"",
      required_all_of: ["widget_id", "position"],
      required_any_of: [],
      route_family: :change
    },
    "unified.split.resized" => %{
      baseline: :extended,
      binding: "Browser.Events mouse subscriptions",
      required_all_of: ["widget_id", "panes"],
      required_any_of: [],
      route_family: :change
    },
    "unified.split.collapse_changed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "pane_id", "collapsed"],
      required_any_of: [],
      route_family: :change
    },
    "unified.command.executed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "command_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.action.requested" => %{
      baseline: :extended,
      binding: "Html.Events.on \"keydown\"",
      required_all_of: ["widget_id", "action"],
      required_any_of: [],
      route_family: :click
    },
    "unified.toast.dismissed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "toast_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.toast.cleared" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id"],
      required_any_of: [],
      route_family: :click
    },
    "unified.chart.point_selected" => %{
      baseline: :extended,
      binding: "Html.Events.on + Json.Decode",
      required_all_of: ["widget_id", "series", "point"],
      required_any_of: [],
      route_family: :selection
    },
    "unified.chart.point_hovered" => %{
      baseline: :extended,
      binding: "Html.Events.on + Json.Decode",
      required_all_of: ["widget_id", "series", "point"],
      required_any_of: [],
      route_family: :selection
    },
    "unified.canvas.pointer.changed" => %{
      baseline: :extended,
      binding: "Html.Events.on + pointer decode",
      required_all_of: ["widget_id", "x", "y", "phase"],
      required_any_of: [],
      route_family: :change
    },
    "unified.link.clicked" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "href"],
      required_any_of: [],
      route_family: :click
    },
    "unified.view.changed" => %{
      baseline: :extended,
      binding: "Html.Events.onClick",
      required_all_of: ["widget_id", "view"],
      required_any_of: [],
      route_family: :change
    },
    "unified.viewport.resized" => %{
      baseline: :extended,
      binding: "Browser.Events.onResize",
      required_all_of: ["widget_id", "width", "height"],
      required_any_of: [],
      route_family: :change
    }
  }

  @spec standard_event_types() :: [String.t()]
  def standard_event_types, do: @standard_event_types

  @spec extended_event_types() :: [String.t()]
  def extended_event_types do
    @event_specs
    |> Enum.filter(fn {_type, spec} -> spec.baseline == :extended end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  @spec all_event_types() :: [String.t()]
  def all_event_types do
    @event_specs
    |> Map.keys()
    |> Enum.sort()
  end

  @spec event_spec(String.t()) :: {:ok, map()} | {:error, TypedError.t()}
  def event_spec(event_type) when is_binary(event_type) do
    case Map.get(@event_specs, event_type) do
      nil ->
        {:error,
         TypedError.new(
           "event_catalog.unknown_event_type",
           "validation",
           false,
           %{event_type: event_type}
         )}

      spec ->
        {:ok, Map.put(spec, :event_type, event_type)}
    end
  end

  def event_spec(_event_type) do
    {:error,
     TypedError.new(
       "event_catalog.invalid_event_type",
       "validation",
       false,
       %{reason: "event_type must be a string"}
     )}
  end

  @spec validate_event(String.t(), map()) :: :ok | {:error, TypedError.t()}
  def validate_event(event_type, data) when is_binary(event_type) and is_map(data) do
    with {:ok, spec} <- event_spec(event_type) do
      required_all_of = spec.required_all_of
      required_any_of = spec.required_any_of

      missing_all_of = Enum.filter(required_all_of, &(missing_or_blank?(data, &1)))

      missing_any_of =
        required_any_of
        |> Enum.filter(fn alternatives -> Enum.all?(alternatives, &missing_or_blank?(data, &1)) end)

      case {missing_all_of, missing_any_of} do
        {[], []} ->
          :ok

        _ ->
          {:error,
           TypedError.new(
             "event_catalog.missing_required_keys",
             "validation",
             false,
             %{
               event_type: event_type,
               missing_all_of: missing_all_of,
               missing_any_of_groups: missing_any_of
             }
           )}
      end
    end
  end

  def validate_event(event_type, _data) when is_binary(event_type) do
    {:error,
     TypedError.new(
       "event_catalog.invalid_event_data",
       "validation",
       false,
       %{event_type: event_type, reason: "data must be a map"}
     )}
  end

  @spec route_family(String.t()) :: {:ok, atom()} | {:error, TypedError.t()}
  def route_family(event_type) when is_binary(event_type) do
    with {:ok, spec} <- event_spec(event_type) do
      {:ok, spec.route_family}
    end
  end

  @spec required_key_spec(String.t()) :: {:ok, map()} | {:error, TypedError.t()}
  def required_key_spec(event_type) when is_binary(event_type) do
    with {:ok, spec} <- event_spec(event_type) do
      {:ok, %{required_all_of: spec.required_all_of, required_any_of: spec.required_any_of}}
    end
  end

  defp missing_or_blank?(data, key) do
    value =
      key
      |> candidate_keys()
      |> Enum.find_value(fn candidate -> Map.get(data, candidate) end)

    case value do
      nil -> true
      "" -> true
      _ -> false
    end
  end

  defp candidate_keys(key) when is_atom(key), do: [key, Atom.to_string(key)]

  defp candidate_keys(key) when is_binary(key) do
    case safe_existing_atom(key) do
      nil -> [key]
      atom -> [key, atom]
    end
  end

  defp safe_existing_atom(key) do
    try do
      String.to_existing_atom(key)
    rescue
      ArgumentError -> nil
    end
  end
end
