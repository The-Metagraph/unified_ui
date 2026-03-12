defmodule LiveUi.Components.Helpers do
  @moduledoc false

  alias LiveUi.Assets
  alias LiveUi.IUR.ValueNormalizer
  alias LiveUi.Style.Compiler

  @spec id(map()) :: String.t() | nil
  def id(descriptor), do: Map.get(descriptor, :id, Map.get(descriptor, "id"))

  @spec kind(map()) :: String.t() | nil
  def kind(descriptor), do: Map.get(descriptor, :kind, Map.get(descriptor, "kind"))

  @spec props(map()) :: map()
  def props(descriptor), do: Map.get(descriptor, :props, Map.get(descriptor, "props", %{}))

  @spec children(map()) :: [map()]
  def children(descriptor),
    do: Map.get(descriptor, :children, Map.get(descriptor, "children", []))

  @spec signal_bindings(map()) :: [map()]
  def signal_bindings(descriptor),
    do: Map.get(descriptor, :signal_bindings, Map.get(descriptor, "signal_bindings", []))

  @spec binding(map(), String.t() | [String.t()]) :: map() | nil
  def binding(descriptor, events) do
    events = List.wrap(events)

    Enum.find(signal_bindings(descriptor), fn binding ->
      Map.get(binding, :event, Map.get(binding, "event")) in events
    end)
  end

  @spec intent(map() | nil, String.t() | nil) :: String.t() | nil
  def intent(nil, default), do: default

  def intent(binding, default) do
    payload = Map.get(binding, :payload, Map.get(binding, "payload", %{}))

    payload
    |> Map.get("intent", Map.get(payload, :intent, default))
    |> normalize_string()
  end

  @spec binding_value(map() | nil, String.t()) :: term()
  def binding_value(nil, _key), do: nil

  def binding_value(binding, key) do
    payload = Map.get(binding, :payload, Map.get(binding, "payload", %{}))
    Map.get(payload, key, Map.get(payload, String.to_atom(key)))
  end

  @spec classes(map(), [String.t()]) :: [String.t()]
  def classes(descriptor, base_classes \\ []) do
    style = props(descriptor) |> Map.get("style", %{})
    base_classes ++ Compiler.compile(style)
  end

  @spec inline_style(map()) :: String.t() | nil
  def inline_style(descriptor) do
    style = props(descriptor) |> Map.get("style", %{})
    Compiler.inline(style)
  end

  @spec hook_name(map()) :: String.t() | nil
  def hook_name(descriptor), do: Assets.hook_name(kind(descriptor))

  @spec direct_descriptor(map(), String.t(), map()) :: map()
  def direct_descriptor(assigns, kind, extra_props \\ %{}) do
    %{
      id: Map.get(assigns, :id, Map.get(assigns, "id")),
      kind: kind,
      props: direct_props(assigns, extra_props),
      signal_bindings: Map.get(assigns, :signal_bindings, Map.get(assigns, "signal_bindings", []))
    }
  end

  @spec direct_props(map(), map()) :: map()
  def direct_props(assigns, extra_props \\ %{}) do
    extra_props
    |> Map.merge(%{
      "style" => merged_direct_style(assigns),
      "visible" => Map.get(assigns, :visible, Map.get(assigns, "visible", true))
    })
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  @spec visible?(map()) :: boolean()
  def visible?(descriptor) do
    descriptor
    |> props()
    |> Map.get("visible", true)
    |> truthy?()
  end

  @spec truthy?(term()) :: boolean()
  def truthy?(value) when value in [false, nil, "false", "0", 0], do: false
  def truthy?(_value), do: true

  @spec scalar_string(term()) :: String.t() | nil
  def scalar_string(nil), do: nil
  def scalar_string(value) when is_binary(value), do: value
  def scalar_string(value) when is_atom(value), do: Atom.to_string(value)
  def scalar_string(value), do: to_string(value)

  @spec event_attrs(String.t(), String.t() | nil, map(), map() | nil, map()) :: keyword()
  def event_attrs(dom_event, live_event \\ nil, descriptor, binding, extra_payload \\ %{})

  def event_attrs(_dom_event, _live_event, _descriptor, nil, _extra_payload), do: []

  def event_attrs(dom_event, live_event, descriptor, binding, extra_payload) do
    live_event = normalize_event_name(live_event || dom_event)
    dom_event = normalize_event_name(dom_event)
    payload = binding_payload(binding) |> Map.merge(normalize_payload_map(extra_payload))

    [
      {"phx-#{dom_event}", live_event},
      {"phx-value-widget_id", id(descriptor)},
      {"phx-value-widget_kind", kind(descriptor)},
      {"phx-value-event_#{live_event}_intent", intent(binding, live_event)}
    ] ++ payload_attrs(live_event, payload)
  end

  @spec hook_event_attrs(String.t(), map(), map() | nil, map()) :: keyword()
  def hook_event_attrs(event_name, descriptor, binding, extra_payload \\ %{})

  def hook_event_attrs(_event_name, _descriptor, nil, _extra_payload), do: []

  def hook_event_attrs(event_name, descriptor, binding, extra_payload) do
    event_name = normalize_event_name(event_name)
    payload = binding_payload(binding) |> Map.merge(normalize_payload_map(extra_payload))

    [
      {"data-live-ui-event", event_name},
      {"data-live-ui-intent", intent(binding, event_name)},
      {"data-live-ui-widget-id", id(descriptor)},
      {"data-live-ui-widget-kind", kind(descriptor)}
    ] ++ hook_payload_attrs(payload)
  end

  @spec merge_attrs([keyword()]) :: keyword()
  def merge_attrs(attr_lists) when is_list(attr_lists) do
    attr_lists
    |> Enum.reduce(%{}, fn attrs, acc -> Enum.into(attrs, acc) end)
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp binding_payload(binding) do
    binding
    |> Map.get(:payload, Map.get(binding, "payload", %{}))
    |> normalize_payload_map()
    |> expand_nested_payload()
  end

  defp expand_nested_payload(payload) do
    nested_payload =
      case Map.get(payload, "payload") do
        %{} = nested -> nested
        _ -> %{}
      end

    payload
    |> Map.drop(["intent", "payload"])
    |> Map.merge(nested_payload)
  end

  defp normalize_payload_map(%{} = payload), do: ValueNormalizer.normalize_map(payload)
  defp normalize_payload_map(other), do: %{"value" => ValueNormalizer.normalize_value(other)}

  defp payload_attrs(event_name, payload) do
    Enum.flat_map(payload, fn {key, value} ->
      key = scalar_string(key)

      cond do
        is_nil(value) ->
          []

        scalar?(value) ->
          [{"phx-value-event_#{event_name}_#{key}", scalar_attr(value)}]

        true ->
          [
            {"phx-value-event_#{event_name}_json_#{key}",
             Jason.encode!(ValueNormalizer.normalize_value(value))}
          ]
      end
    end)
  end

  defp hook_payload_attrs(payload) do
    case Map.drop(payload, ["intent"]) do
      payload when map_size(payload) == 0 ->
        []

      payload ->
        [{"data-live-ui-payload", Jason.encode!(ValueNormalizer.normalize_map(payload))}]
    end
  end

  defp scalar?(value) when is_binary(value) or is_integer(value) or is_float(value), do: true
  defp scalar?(value) when is_boolean(value) or is_atom(value), do: true
  defp scalar?(_value), do: false

  defp scalar_attr(value) when is_boolean(value), do: if(value, do: "true", else: "false")
  defp scalar_attr(value), do: scalar_string(value)

  defp normalize_event_name(value) when is_binary(value), do: value
  defp normalize_event_name(value) when is_atom(value), do: Atom.to_string(value)

  defp normalize_string(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      normalized -> normalized
    end
  end

  defp normalize_string(value) when is_atom(value),
    do: value |> Atom.to_string() |> normalize_string()

  defp normalize_string(_value), do: nil

  defp merged_direct_style(assigns) do
    style = Map.get(assigns, :style, Map.get(assigns, "style", %{}))
    class_name = Map.get(assigns, :class, Map.get(assigns, "class"))

    case normalize_class_name(class_name) do
      nil ->
        style

      class_name ->
        existing = Map.get(style, "class", Map.get(style, :class))

        Map.put(
          style,
          "class",
          Enum.join(Enum.reject([existing, class_name], &(&1 in [nil, ""])), " ")
        )
    end
  end

  defp normalize_class_name(nil), do: nil
  defp normalize_class_name(""), do: nil
  defp normalize_class_name(class_name) when is_binary(class_name), do: class_name
  defp normalize_class_name(class_name) when is_list(class_name), do: Enum.join(class_name, " ")
  defp normalize_class_name(class_name), do: to_string(class_name)
end
