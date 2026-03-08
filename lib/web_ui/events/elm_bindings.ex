defmodule WebUi.Events.ElmBindings do
  @moduledoc """
  Canonical Elm binding helpers for standard widget events and browser subscriptions.
  """

  alias WebUi.Events.EventCatalog
  alias WebUi.TypedError

  @spec on_click(String.t(), String.t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def on_click(widget_id, widget_kind, data \\ %{}) do
    build_event("unified.button.clicked", widget_id, widget_kind, data, %{
      binding: "Html.Events.onClick"
    })
  end

  @spec on_input(String.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_input(widget_id, widget_kind, value, data \\ %{})

  def on_input(widget_id, widget_kind, value, data) when is_binary(value) do
    data =
      data
      |> Map.put_new(:value, value)
      |> Map.put_new(:input_id, widget_id)

    build_event("unified.input.changed", widget_id, widget_kind, data, %{
      binding: "Html.Events.onInput"
    })
  end

  def on_input(widget_id, widget_kind, _value, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_input_value",
       "validation",
       false,
       %{widget_id: widget_id, widget_kind: widget_kind, reason: "value must be a string"}
     )}
  end

  @spec on_submit(String.t(), String.t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def on_submit(widget_id, widget_kind, data \\ %{}) do
    data = Map.put_new(data, :form_id, widget_id)

    build_event("unified.form.submitted", widget_id, widget_kind, data, %{
      binding: "Html.Events.onSubmit",
      prevent_default: true
    })
  end

  @spec on_menu_action(String.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_menu_action(widget_id, widget_kind, action_id, data \\ %{})

  def on_menu_action(widget_id, widget_kind, action_id, data)
      when is_binary(action_id) and is_map(data) do
    trimmed_action_id = String.trim(action_id)

    if trimmed_action_id != "" do
      action_data = Map.put_new(data, :action_id, trimmed_action_id)

      build_event("unified.menu.action_selected", widget_id, widget_kind, action_data, %{
        binding: "Html.Events.onClick"
      })
    else
      {:error,
       TypedError.new(
         "elm_bindings.invalid_menu_action",
         "validation",
         false,
         %{
           widget_id: widget_id,
           widget_kind: widget_kind,
           reason: "action_id must be a non-empty string"
         }
       )}
    end
  end

  def on_menu_action(widget_id, widget_kind, _action_id, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_menu_action",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason: "action_id must be a non-empty string and data must be a map"
       }
     )}
  end

  @spec on_table_row_select(String.t(), String.t(), non_neg_integer(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_table_row_select(widget_id, widget_kind, row_index, data \\ %{})

  def on_table_row_select(widget_id, widget_kind, row_index, data)
      when is_integer(row_index) and row_index >= 0 and is_map(data) do
    selection_data = Map.put_new(data, :row_index, row_index)

    build_event("unified.table.row_selected", widget_id, widget_kind, selection_data, %{
      binding: "Html.Events.onClick"
    })
  end

  def on_table_row_select(widget_id, widget_kind, _row_index, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_row_select_payload",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason: "row_index must be a non-negative integer and data must be a map"
       }
     )}
  end

  @spec on_table_sort(String.t(), String.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_table_sort(widget_id, widget_kind, column, direction, data \\ %{})

  def on_table_sort(widget_id, widget_kind, column, direction, data)
      when is_binary(column) and is_binary(direction) and is_map(data) do
    trimmed_column = String.trim(column)
    normalized_direction = String.downcase(String.trim(direction))

    if trimmed_column != "" and normalized_direction in ["asc", "desc"] do
      sort_data =
        data
        |> Map.put_new(:column, trimmed_column)
        |> Map.put_new(:direction, normalized_direction)

      build_event("unified.table.sorted", widget_id, widget_kind, sort_data, %{
        binding: "Html.Events.onClick"
      })
    else
      {:error,
       TypedError.new(
         "elm_bindings.invalid_sort_payload",
         "validation",
         false,
         %{
           widget_id: widget_id,
           widget_kind: widget_kind,
           reason: "column must be non-empty and direction must be asc or desc"
         }
       )}
    end
  end

  def on_table_sort(widget_id, widget_kind, _column, _direction, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_sort_payload",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason: "column/direction must be strings and data must be a map"
       }
     )}
  end

  @spec on_tab_change(String.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_tab_change(widget_id, widget_kind, tab_id, data \\ %{})

  def on_tab_change(widget_id, widget_kind, tab_id, data)
      when is_binary(tab_id) and is_map(data) do
    trimmed_tab_id = String.trim(tab_id)

    if trimmed_tab_id != "" do
      tab_data = Map.put_new(data, :tab_id, trimmed_tab_id)

      build_event("unified.tab.changed", widget_id, widget_kind, tab_data, %{
        binding: "Html.Events.onClick"
      })
    else
      {:error,
       TypedError.new(
         "elm_bindings.invalid_tab_change_payload",
         "validation",
         false,
         %{
           widget_id: widget_id,
           widget_kind: widget_kind,
           reason: "tab_id must be a non-empty string"
         }
       )}
    end
  end

  def on_tab_change(widget_id, widget_kind, _tab_id, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_tab_change_payload",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason: "tab_id must be a non-empty string and data must be a map"
       }
     )}
  end

  @spec on_tree_node_select(String.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_tree_node_select(widget_id, widget_kind, node_id, data \\ %{})

  def on_tree_node_select(widget_id, widget_kind, node_id, data)
      when is_binary(node_id) and is_map(data) do
    trimmed_node_id = String.trim(node_id)

    if trimmed_node_id != "" do
      node_data = Map.put_new(data, :node_id, trimmed_node_id)

      build_event("unified.tree.node_selected", widget_id, widget_kind, node_data, %{
        binding: "Html.Events.onClick"
      })
    else
      {:error,
       TypedError.new(
         "elm_bindings.invalid_tree_select_payload",
         "validation",
         false,
         %{
           widget_id: widget_id,
           widget_kind: widget_kind,
           reason: "node_id must be a non-empty string"
         }
       )}
    end
  end

  def on_tree_node_select(widget_id, widget_kind, _node_id, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_tree_select_payload",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason: "node_id must be a non-empty string and data must be a map"
       }
     )}
  end

  @spec on_tree_node_toggle(String.t(), String.t(), String.t(), boolean(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_tree_node_toggle(widget_id, widget_kind, node_id, expanded, data \\ %{})

  def on_tree_node_toggle(widget_id, widget_kind, node_id, expanded, data)
      when is_binary(node_id) and is_boolean(expanded) and is_map(data) do
    trimmed_node_id = String.trim(node_id)

    if trimmed_node_id != "" do
      node_data =
        data
        |> Map.put_new(:node_id, trimmed_node_id)
        |> Map.put_new(:expanded, expanded)

      build_event("unified.tree.node_toggled", widget_id, widget_kind, node_data, %{
        binding: "Html.Events.onClick"
      })
    else
      {:error,
       TypedError.new(
         "elm_bindings.invalid_tree_toggle_payload",
         "validation",
         false,
         %{
           widget_id: widget_id,
           widget_kind: widget_kind,
           reason: "node_id must be a non-empty string"
         }
       )}
    end
  end

  def on_tree_node_toggle(widget_id, widget_kind, _node_id, _expanded, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_tree_toggle_payload",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason:
           "node_id must be a non-empty string, expanded must be a boolean, and data must be a map"
       }
     )}
  end

  @spec on_focus(String.t(), String.t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def on_focus(widget_id, widget_kind, data \\ %{}) do
    build_event("unified.element.focused", widget_id, widget_kind, data, %{
      binding: "Html.Events.onFocus"
    })
  end

  @spec on_blur(String.t(), String.t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def on_blur(widget_id, widget_kind, data \\ %{}) do
    build_event("unified.element.blurred", widget_id, widget_kind, data, %{
      binding: "Html.Events.onBlur"
    })
  end

  @spec decode_action_key(String.t(), String.t(), map(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def decode_action_key(widget_id, widget_kind, key_event, data \\ %{})

  def decode_action_key(widget_id, widget_kind, key_event, data)
      when is_map(key_event) and is_map(data) do
    case fetch_string(key_event, :key) do
      nil ->
        {:error,
         TypedError.new(
           "elm_bindings.invalid_key_event",
           "validation",
           false,
           %{widget_id: widget_id, widget_kind: widget_kind, reason: "missing key"}
         )}

      key ->
        action_data =
          data
          |> Map.put_new(:action, key)
          |> Map.put_new(:key, key)
          |> put_if_present(:code, fetch_string(key_event, :code))
          |> put_if_present(:target_id, fetch_string(key_event, :target_id))
          |> Map.put_new(:ctrl_key, fetch_boolean(key_event, :ctrl_key))
          |> Map.put_new(:alt_key, fetch_boolean(key_event, :alt_key))
          |> Map.put_new(:shift_key, fetch_boolean(key_event, :shift_key))
          |> Map.put_new(:meta_key, fetch_boolean(key_event, :meta_key))

        build_event("unified.action.requested", widget_id, widget_kind, action_data, %{
          binding: "Html.Events.on \"keydown\""
        })
    end
  end

  def decode_action_key(widget_id, widget_kind, _key_event, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_key_event",
       "validation",
       false,
       %{widget_id: widget_id, widget_kind: widget_kind, reason: "key event must be a map"}
     )}
  end

  @spec decode_canvas_pointer(String.t(), map(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def decode_canvas_pointer(widget_id, pointer_event, data \\ %{})

  def decode_canvas_pointer(widget_id, pointer_event, data)
      when is_map(pointer_event) and is_map(data) do
    x = fetch_number(pointer_event, :x) || fetch_number(pointer_event, :client_x)
    y = fetch_number(pointer_event, :y) || fetch_number(pointer_event, :client_y)
    phase = fetch_string(pointer_event, :phase) || fetch_string(pointer_event, :type)

    cond do
      is_nil(x) or is_nil(y) or is_nil(phase) ->
        {:error,
         TypedError.new(
           "elm_bindings.invalid_pointer_event",
           "validation",
           false,
           %{widget_id: widget_id, reason: "x, y, and phase/type are required"}
         )}

      true ->
        pointer_data =
          data
          |> Map.put_new(:x, x)
          |> Map.put_new(:y, y)
          |> Map.put_new(:phase, phase)
          |> put_if_present(:pointer_id, fetch_string(pointer_event, :pointer_id))
          |> put_if_present(:button, fetch_number(pointer_event, :button))

        build_event("unified.canvas.pointer.changed", widget_id, "canvas", pointer_data, %{
          binding: "Browser.Events pointer subscriptions"
        })
    end
  end

  def decode_canvas_pointer(widget_id, _pointer_event, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_pointer_event",
       "validation",
       false,
       %{widget_id: widget_id, reason: "pointer event must be a map"}
     )}
  end

  @spec on_resize(String.t(), String.t(), integer(), integer(), map()) ::
          {:ok, map()} | {:error, TypedError.t()}
  def on_resize(widget_id, widget_kind, width, height, data \\ %{})

  def on_resize(widget_id, widget_kind, width, height, data)
      when is_integer(width) and is_integer(height) and is_map(data) do
    resize_data =
      data
      |> Map.put_new(:width, width)
      |> Map.put_new(:height, height)

    build_event("unified.viewport.resized", widget_id, widget_kind, resize_data, %{
      binding: "Browser.Events.onResize"
    })
  end

  def on_resize(widget_id, widget_kind, _width, _height, _data) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_resize_payload",
       "validation",
       false,
       %{
         widget_id: widget_id,
         widget_kind: widget_kind,
         reason: "width/height must be integers and data must be a map"
       }
     )}
  end

  @spec subscription_specs(String.t(), String.t(), keyword()) :: [map()]
  def subscription_specs(widget_id, widget_kind, opts \\ []) do
    []
    |> maybe_add_subscription(Keyword.get(opts, :resize, true), %{
      subscription_id: "global.resize:" <> widget_id,
      event_type: "unified.viewport.resized",
      binding: "Browser.Events.onResize",
      widget_id: widget_id,
      widget_kind: widget_kind
    })
    |> maybe_add_subscription(Keyword.get(opts, :keyboard_actions, false), %{
      subscription_id: "global.keydown:" <> widget_id,
      event_type: "unified.action.requested",
      binding: "Browser.Events.onKeyDown",
      widget_id: widget_id,
      widget_kind: widget_kind
    })
    |> maybe_add_subscription(Keyword.get(opts, :canvas_pointer, false), %{
      subscription_id: "global.pointer:" <> widget_id,
      event_type: "unified.canvas.pointer.changed",
      binding: "Browser.Events pointer subscriptions",
      widget_id: widget_id,
      widget_kind: widget_kind
    })
    |> Enum.sort_by(& &1.subscription_id)
  end

  @spec reconcile_subscriptions([map()], [map()]) :: %{
          subscribe: [map()],
          unsubscribe: [map()],
          active: [map()]
        }
  def reconcile_subscriptions(current, desired) when is_list(current) and is_list(desired) do
    normalized_current = normalize_subscriptions(current)
    normalized_desired = normalize_subscriptions(desired)

    current_by_id = Map.new(normalized_current, &{&1.subscription_id, &1})
    desired_by_id = Map.new(normalized_desired, &{&1.subscription_id, &1})

    current_ids = Map.keys(current_by_id)
    desired_ids = Map.keys(desired_by_id)

    subscribe =
      desired_ids
      |> Kernel.--(current_ids)
      |> Enum.sort()
      |> Enum.map(&Map.fetch!(desired_by_id, &1))

    unsubscribe =
      current_ids
      |> Kernel.--(desired_ids)
      |> Enum.sort()
      |> Enum.map(&Map.fetch!(current_by_id, &1))

    %{
      subscribe: subscribe,
      unsubscribe: unsubscribe,
      active: Enum.sort_by(normalized_desired, & &1.subscription_id)
    }
  end

  defp build_event(event_type, widget_id, widget_kind, data, meta)
       when is_binary(event_type) and is_binary(widget_id) and is_binary(widget_kind) and
              is_map(data) and is_map(meta) do
    with :ok <- validate_widget_ref(widget_id, widget_kind),
         enriched_data <-
           data |> Map.put_new(:widget_id, widget_id) |> Map.put_new(:widget_kind, widget_kind),
         :ok <- EventCatalog.validate_event(event_type, enriched_data) do
      event = %{
        type: event_type,
        widget_id: widget_id,
        widget_kind: widget_kind,
        data: enriched_data
      }

      if map_size(meta) == 0 do
        {:ok, event}
      else
        {:ok, Map.put(event, :meta, meta)}
      end
    else
      {:error, %TypedError{} = error} -> {:error, error}
    end
  end

  defp build_event(_event_type, widget_id, widget_kind, _data, _meta) do
    {:error,
     TypedError.new(
       "elm_bindings.invalid_event_payload",
       "validation",
       false,
       %{widget_id: widget_id, widget_kind: widget_kind, reason: "event payload is malformed"}
     )}
  end

  defp validate_widget_ref(widget_id, widget_kind) do
    if String.trim(widget_id) != "" and String.trim(widget_kind) != "" do
      :ok
    else
      {:error,
       TypedError.new(
         "elm_bindings.invalid_widget_ref",
         "validation",
         false,
         %{widget_id: widget_id, widget_kind: widget_kind}
       )}
    end
  end

  defp maybe_add_subscription(subscriptions, true, subscription),
    do: [subscription | subscriptions]

  defp maybe_add_subscription(subscriptions, _enabled, _subscription), do: subscriptions

  defp normalize_subscriptions(subscriptions) do
    subscriptions
    |> Enum.map(&normalize_subscription/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq_by(& &1.subscription_id)
  end

  defp normalize_subscription(subscription) when is_map(subscription) do
    subscription_id = fetch_string(subscription, :subscription_id)
    event_type = fetch_string(subscription, :event_type)
    binding = fetch_string(subscription, :binding)
    widget_id = fetch_string(subscription, :widget_id)
    widget_kind = fetch_string(subscription, :widget_kind)

    if Enum.all?(
         [subscription_id, event_type, binding, widget_id, widget_kind],
         &(is_binary(&1) and &1 != "")
       ) do
      %{
        subscription_id: subscription_id,
        event_type: event_type,
        binding: binding,
        widget_id: widget_id,
        widget_kind: widget_kind
      }
    else
      nil
    end
  end

  defp normalize_subscription(_subscription), do: nil

  defp put_if_present(map, _key, nil), do: map
  defp put_if_present(map, key, value), do: Map.put_new(map, key, value)

  defp fetch_any(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp fetch_any(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key) || Map.get(map, safe_existing_atom(key))
  end

  defp fetch_string(map, key) when is_map(map) do
    key
    |> candidate_keys()
    |> Enum.find_value(fn candidate ->
      case fetch_any(map, candidate) do
        value when is_binary(value) ->
          trimmed = String.trim(value)

          if trimmed != "" do
            value
          else
            nil
          end

        _ ->
          nil
      end
    end)
  end

  defp fetch_number(map, key) when is_map(map) do
    key
    |> candidate_keys()
    |> Enum.find_value(fn candidate ->
      case fetch_any(map, candidate) do
        value when is_integer(value) -> value
        value when is_float(value) -> value
        _ -> nil
      end
    end)
  end

  defp fetch_boolean(map, key) when is_map(map) do
    key
    |> candidate_keys()
    |> Enum.find_value(false, fn candidate ->
      case fetch_any(map, candidate) do
        value when is_boolean(value) -> value
        _ -> nil
      end
    end)
  end

  defp candidate_keys(key) when is_atom(key) do
    string_key = Atom.to_string(key)
    [key, string_key, String.replace(string_key, "_", ""), camel_key(string_key)] |> Enum.uniq()
  end

  defp candidate_keys(key) when is_binary(key) do
    [key, String.replace(key, "_", ""), camel_key(key)] |> Enum.uniq()
  end

  defp camel_key(key) when is_binary(key) do
    case String.split(key, "_") do
      [single] ->
        single

      [head | tail] ->
        head <> Enum.map_join(tail, "", &String.capitalize/1)
    end
  end

  defp safe_existing_atom(key) when is_binary(key) do
    try do
      String.to_existing_atom(key)
    rescue
      ArgumentError -> nil
    end
  end
end
