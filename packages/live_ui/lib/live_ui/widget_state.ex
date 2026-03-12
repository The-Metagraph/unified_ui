defmodule LiveUi.WidgetState do
  @moduledoc """
  Server-authoritative widget-local state overlay applied after interpretation.
  """

  alias LiveUi.Descriptor

  @spec extract(String.t() | atom(), map()) :: map()
  def extract(event_name, payload) when is_map(payload) do
    explicit =
      case Map.get(payload, "widget_state", Map.get(payload, :widget_state)) do
        %{} = widget_state -> normalize_widget_state(widget_state)
        _ -> %{}
      end

    event_name
    |> derive_widget_state(payload)
    |> merge(explicit)
  end

  @spec merge(map(), map() | nil) :: map()
  def merge(current, incoming)

  def merge(current, nil) when is_map(current), do: current

  def merge(current, incoming) when is_map(current) and is_map(incoming) do
    Map.merge(current, incoming, fn _key, left, right ->
      if is_map(left) and is_map(right), do: merge(left, right), else: right
    end)
  end

  @spec extract(map()) :: map()
  def extract(payload) when is_map(payload), do: extract("unknown", payload)

  @spec apply_overlay(Descriptor.t() | nil, map()) :: Descriptor.t() | nil
  def apply_overlay(nil, _widget_state), do: nil

  def apply_overlay(%Descriptor{} = descriptor, widget_state) when is_map(widget_state) do
    merged_props =
      case Map.get(widget_state, descriptor.id) do
        %{} = local_state -> Map.merge(descriptor.props, local_state)
        _ -> descriptor.props
      end

    %Descriptor{
      descriptor
      | props: merged_props,
        children: Enum.map(descriptor.children, &apply_overlay(&1, widget_state))
    }
  end

  defp normalize_widget_state(widget_state) do
    Enum.into(widget_state, %{}, fn {widget_id, state} ->
      {normalize_widget_id(widget_id), normalize_state_map(state)}
    end)
  end

  defp derive_widget_state(event_name, payload) do
    widget_id = payload_value(payload, "widget_id")
    widget_kind = normalize_widget_id(payload_value(payload, "widget_kind"))

    case {widget_id, widget_kind} do
      {nil, _kind} ->
        %{}

      {_widget_id, nil} ->
        %{}

      {widget_id, kind} ->
        case local_state_for(kind, normalize_event_name(event_name), payload, widget_id) do
          %{} = local_state when map_size(local_state) > 0 ->
            %{widget_id => normalize_state_map(local_state)}

          _other ->
            %{}
        end
    end
  end

  defp local_state_for("tabs", event_name, payload, _widget_id) do
    %{}
    |> put_if_present("active_tab", scoped_value(payload, event_name, "tab_id"))
    |> put_if_present(
      "active_tab_index",
      normalize_integer(scoped_value(payload, event_name, "tab_index"))
    )
  end

  defp local_state_for("table", event_name, payload, _widget_id) do
    %{}
    |> put_if_present("selected_row_id", scoped_value(payload, event_name, "row_id"))
    |> put_if_present(
      "selected_row_index",
      normalize_integer(scoped_value(payload, event_name, "row_index"))
    )
    |> put_if_present("sort_column", scoped_value(payload, event_name, "sort_column"))
    |> put_if_present("sort_direction", scoped_value(payload, event_name, "direction"))
  end

  defp local_state_for("tree_node", event_name, payload, widget_id) do
    expanded = scoped_value(payload, event_name, "expanded")

    %{}
    |> put_if_present("node_id", scoped_value(payload, event_name, "node_id", widget_id))
    |> put_if_present("selected", true)
    |> put_if_present("expanded", toggle_boolean(expanded))
  end

  defp local_state_for("viewport", event_name, payload, _widget_id) do
    position = scoped_value(payload, event_name, "position")

    %{}
    |> put_if_present("axis", scoped_value(payload, event_name, "axis"))
    |> put_if_present(
      "scroll_top",
      position_value(position, "top", payload, event_name, "scroll_top")
    )
    |> put_if_present(
      "scroll_left",
      position_value(position, "left", payload, event_name, "scroll_left")
    )
  end

  defp local_state_for("split_pane", event_name, payload, _widget_id) do
    %{}
    |> put_if_present("sizes", normalize_sizes(scoped_value(payload, event_name, "sizes")))
    |> put_if_present("active_pane", scoped_value(payload, event_name, "active_pane"))
    |> put_if_present("orientation", scoped_value(payload, event_name, "orientation"))
  end

  defp local_state_for("command_palette", event_name, payload, _widget_id) do
    query =
      scoped_value(payload, event_name, "query") ||
        payload_value(payload, "query") ||
        payload_value(payload, "value")

    %{}
    |> put_if_present("query", query)
    |> put_if_present("active_command_id", scoped_value(payload, event_name, "active_command_id"))
    |> put_if_present("open", normalize_boolean(scoped_value(payload, event_name, "open")))
  end

  defp local_state_for("log_viewer", event_name, payload, _widget_id) do
    %{}
    |> put_if_present(
      "filter",
      scoped_value(payload, event_name, "filter") || payload_value(payload, "filter") ||
        payload_value(payload, "value")
    )
  end

  defp local_state_for("process_monitor", event_name, payload, _widget_id) do
    %{}
    |> put_if_present("selected_pid", scoped_value(payload, event_name, "pid"))
    |> put_if_present("selected_process_name", scoped_value(payload, event_name, "name"))
  end

  defp local_state_for(_kind, _event_name, _payload, _widget_id), do: %{}

  defp normalize_widget_id(widget_id) when is_atom(widget_id), do: Atom.to_string(widget_id)
  defp normalize_widget_id(nil), do: nil
  defp normalize_widget_id(widget_id) when is_binary(widget_id), do: widget_id
  defp normalize_widget_id(widget_id), do: to_string(widget_id)

  defp normalize_state_map(%{} = state) do
    Enum.into(state, %{}, fn {key, value} -> {normalize_widget_id(key), value} end)
  end

  defp normalize_state_map(other), do: %{"value" => other}

  defp payload_value(payload, key) do
    Map.get(payload, key, existing_atom_value(payload, key))
  end

  defp scoped_value(payload, event_name, key, default \\ nil) do
    scoped_key = "event_#{event_name}_#{key}"
    scoped_json_key = "event_#{event_name}_json_#{key}"
    json_key = "json_#{key}"

    payload_value(payload, scoped_key) ||
      decode_json(payload_value(payload, scoped_json_key)) ||
      payload_value(payload, key) ||
      decode_json(payload_value(payload, json_key)) ||
      default
  end

  defp position_value(%{} = position, key, _payload, _event_name, _fallback_key) do
    position
    |> payload_value(key)
    |> normalize_integer()
  end

  defp position_value(_position, _key, payload, event_name, fallback_key) do
    scoped_value(payload, event_name, fallback_key)
    |> normalize_integer()
  end

  defp normalize_event_name(value) when is_binary(value), do: value
  defp normalize_event_name(value) when is_atom(value), do: Atom.to_string(value)
  defp normalize_event_name(_value), do: "unknown"

  defp normalize_integer(value) when is_integer(value), do: value

  defp normalize_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _other -> value
    end
  end

  defp normalize_integer(value), do: value

  defp normalize_boolean(value) when value in [true, false], do: value
  defp normalize_boolean("true"), do: true
  defp normalize_boolean("false"), do: false
  defp normalize_boolean(value), do: value

  defp toggle_boolean(nil), do: nil
  defp toggle_boolean(value), do: not truthy?(value)

  defp truthy?(value) when value in [false, nil, "false", "0", 0], do: false
  defp truthy?(_value), do: true

  defp normalize_sizes(sizes) when is_list(sizes), do: Enum.map(sizes, &normalize_integer/1)
  defp normalize_sizes(_sizes), do: nil

  defp put_if_present(map, _key, nil), do: map
  defp put_if_present(map, _key, []), do: map
  defp put_if_present(map, key, value), do: Map.put(map, key, value)

  defp decode_json(value) when is_binary(value) do
    case Jason.decode(value) do
      {:ok, decoded} -> decoded
      {:error, _reason} -> value
    end
  end

  defp decode_json(value), do: value

  defp existing_atom_value(payload, key) when is_binary(key) do
    case safe_existing_atom(key) do
      nil -> nil
      atom_key -> Map.get(payload, atom_key)
    end
  end

  defp existing_atom_value(payload, key) when is_atom(key), do: Map.get(payload, key)
  defp existing_atom_value(_payload, _key), do: nil

  defp safe_existing_atom(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> nil
  end
end
