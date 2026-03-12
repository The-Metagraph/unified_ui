defmodule LiveUi.IUR.Interpreter do
  @moduledoc """
  Normalizes canonical UnifiedIUR nodes and compatible extension structs into descriptor trees.
  """

  alias LiveUi.ConfigurationError
  alias LiveUi.Descriptor
  alias LiveUi.IUR.Dependency
  alias LiveUi.IUR.ValueNormalizer

  @signal_fields [
    "action",
    "on_cancel",
    "on_change",
    "on_click",
    "on_close",
    "on_confirm",
    "on_dismiss",
    "on_hover",
    "on_item",
    "on_process_select",
    "on_resize_change",
    "on_row_select",
    "on_scroll",
    "on_select",
    "on_sort",
    "on_submit",
    "on_toggle",
    "signal"
  ]

  @spec interpret(map() | struct()) :: {:ok, Descriptor.t()} | {:error, ConfigurationError.t()}
  def interpret(payload) do
    do_interpret(payload, [])
  end

  @spec collect_signal_bindings(Descriptor.t() | nil) :: [map()]
  def collect_signal_bindings(nil), do: []

  def collect_signal_bindings(%Descriptor{} = descriptor) do
    descriptor.signal_bindings ++ Enum.flat_map(descriptor.children, &collect_signal_bindings/1)
  end

  defp do_interpret(payload, path) when is_map(payload) do
    cond do
      protocol_element?(payload) -> interpret_protocol_element(payload, path)
      true -> interpret_map_payload(payload, path)
    end
  end

  defp do_interpret(_payload, _path) do
    {:error, ConfigurationError.new("unified_iur payload must be a map or struct")}
  end

  defp interpret_map_payload(payload, path) do
    with :ok <- Dependency.validate_markers(payload),
         kind when is_binary(kind) <- ValueNormalizer.kind(payload),
         true <- LiveUi.WidgetRegistry.supported_kind?(kind),
         {:ok, children} <- interpret_children(ValueNormalizer.children(payload), path),
         id <- ValueNormalizer.id(payload, fallback_id(kind, path)),
         raw_props <- ValueNormalizer.raw_props(payload),
         props <- ValueNormalizer.normalize_map(raw_props) do
      {:ok,
       %Descriptor{
         id: id,
         kind: kind,
         props: props,
         children: children,
         signal_bindings: extract_signal_bindings(raw_props, id, kind)
       }}
    else
      nil ->
        {:error, ConfigurationError.new("unified_iur payload is missing a supported kind")}

      false ->
        {:error,
         ConfigurationError.new("unified_iur node kind is unsupported", %{
           kind: ValueNormalizer.kind(payload)
         })}

      {:error, %ConfigurationError{} = error} ->
        {:error, error}
    end
  end

  defp interpret_protocol_element(payload, path) do
    metadata = protocol_metadata(payload)
    kind = metadata |> Map.get(:type, Map.get(metadata, "type")) |> normalize_kind()

    with true <- is_binary(kind) and kind != "",
         true <- LiveUi.WidgetRegistry.supported_kind?(kind),
         {:ok, children} <- interpret_children(protocol_children(payload), path),
         id <- ValueNormalizer.id(metadata, fallback_id(kind, path)),
         raw_props <- ValueNormalizer.raw_metadata_props(metadata),
         props <- ValueNormalizer.normalize_map(raw_props) do
      {:ok,
       %Descriptor{
         id: id,
         kind: kind,
         props: props,
         children: children,
         signal_bindings: extract_signal_bindings(raw_props, id, kind)
       }}
    else
      false ->
        {:error,
         ConfigurationError.new("unified_iur node kind is unsupported", %{
           kind: inspect(Map.get(metadata, :type, Map.get(metadata, "type")))
         })}

      {:error, %ConfigurationError{} = error} ->
        {:error, error}
    end
  end

  defp interpret_children(children, path) do
    children
    |> Enum.with_index()
    |> Enum.map(fn {child, index} -> do_interpret(child, path ++ [index]) end)
    |> Enum.reduce_while({:ok, []}, fn
      {:ok, descriptor}, {:ok, acc} -> {:cont, {:ok, acc ++ [descriptor]}}
      {:error, error}, _acc -> {:halt, {:error, error}}
    end)
  end

  defp extract_signal_bindings(props, widget_id, widget_kind) do
    Enum.flat_map(@signal_fields, fn field ->
      case Map.get(props, field, Map.get(props, String.to_atom(field))) do
        nil ->
          []

        value ->
          [
            %{
              event: field,
              widget_id: widget_id,
              widget_kind: widget_kind,
              payload: normalize_signal_payload(value)
            }
          ]
      end
    end)
  end

  defp normalize_signal_payload(value) do
    case value do
      %{} = map ->
        ValueNormalizer.normalize_map(map)

      atom when is_atom(atom) ->
        %{"intent" => Atom.to_string(atom)}

      {intent, %{} = payload} when is_atom(intent) ->
        %{"intent" => Atom.to_string(intent), "payload" => ValueNormalizer.normalize_map(payload)}

      {module, function, args}
      when is_atom(module) and is_atom(function) and is_list(args) ->
        %{
          "intent" => Atom.to_string(function),
          "dispatch" => %{
            "module" => Atom.to_string(module),
            "function" => Atom.to_string(function),
            "args" => ValueNormalizer.normalize_value(args)
          }
        }

      other ->
        %{"value" => ValueNormalizer.normalize_value(other)}
    end
  end

  defp protocol_element?(payload) do
    match?(%{__struct__: _}, payload) and Code.ensure_loaded?(UnifiedIUR.Element) and
      protocol_impl(payload) not in [nil, UnifiedIUR.Element.Any]
  end

  defp protocol_metadata(payload), do: UnifiedIUR.Element.metadata(payload)
  defp protocol_children(payload), do: UnifiedIUR.Element.children(payload)
  defp protocol_impl(payload), do: UnifiedIUR.Element.impl_for(payload)

  defp fallback_id(kind, []), do: "#{kind}-root"
  defp fallback_id(kind, path), do: "#{kind}-" <> Enum.join(path, "-")

  defp normalize_kind(kind) when is_atom(kind), do: kind |> Atom.to_string() |> normalize_kind()
  defp normalize_kind(kind) when is_binary(kind), do: kind |> String.trim() |> String.downcase()
  defp normalize_kind(_kind), do: nil
end
