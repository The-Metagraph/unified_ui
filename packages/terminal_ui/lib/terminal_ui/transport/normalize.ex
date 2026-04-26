defmodule TerminalUi.Transport.Normalize do
  @moduledoc """
  Shared native terminal event normalization for `terminal_ui`.
  """

  alias TerminalUi.Transport.Error

  @type input_family :: :key | :mouse | :paste | :resize | :focus | :shortcut

  @raw_leak_keys [:escape_sequence, :termcode, :ansi, :backend_payload]
  @supported_backend_modes [:raw, :tty]
  @input_families [:key, :mouse, :paste, :resize, :focus, :shortcut]

  @spec input_families() :: [input_family()]
  def input_families, do: @input_families

  @spec normalize(keyword() | map()) :: {:ok, map()} | {:error, Error.t()}
  def normalize(attrs) when is_map(attrs) or is_list(attrs) do
    attrs = normalize_map(attrs)
    backend_mode = fetch(attrs, :backend_mode, :raw)

    with :ok <- validate_backend_mode(backend_mode),
         :ok <- validate_no_backend_leakage(attrs),
         {:ok, input_family} <- resolve_input_family(attrs),
         {:ok, family} <- resolve_canonical_family(attrs, input_family),
         {:ok, payload} <- normalize_payload(fetch(attrs, :payload, %{}), :native_local) do
      normalized = %{
        input_family: input_family,
        family: family,
        intent: fetch(attrs, :intent, default_intent(input_family, family)),
        runtime_event: fetch(attrs, :runtime_event, default_runtime_event(input_family, family)),
        boundary: resolve_boundary(attrs, family),
        source_kind: normalize_source_kind(fetch(attrs, :source_kind, :native)),
        backend_mode: backend_mode,
        widget_id: fetch(attrs, :widget_id),
        runtime_id: fetch(attrs, :runtime_id),
        screen: fetch(attrs, :screen, "unknown"),
        target: normalize_map(fetch(attrs, :target, %{})),
        payload: payload,
        normalized_input: normalized_input(attrs, input_family, backend_mode),
        local_handling: local_handling(input_family, backend_mode)
      }

      {:ok, normalized}
    end
  end

  def normalize(value), do: {:error, Error.invalid_native_event(value)}

  @spec diagnostics() :: map()
  def diagnostics do
    %{
      supported_backend_modes: @supported_backend_modes,
      input_families: @input_families,
      leaked_backend_keys: @raw_leak_keys
    }
  end

  defp validate_backend_mode(mode) when mode in @supported_backend_modes, do: :ok
  defp validate_backend_mode(mode), do: {:error, Error.unsupported_backend_mode(mode)}

  defp validate_no_backend_leakage(attrs) do
    leaked_keys =
      attrs
      |> Map.keys()
      |> Enum.filter(&(&1 in @raw_leak_keys))

    if leaked_keys == [] do
      :ok
    else
      {:error, Error.leaked_backend_detail(leaked_keys)}
    end
  end

  defp resolve_input_family(attrs) do
    case normalize_input_family(fetch(attrs, :input_family)) do
      family when family in @input_families ->
        {:ok, family}

      nil ->
        infer_input_family(attrs)

      invalid ->
        {:error, Error.invalid_native_event(invalid)}
    end
  end

  defp infer_input_family(attrs) do
    cond do
      present?(fetch(attrs, :shortcut)) -> {:ok, :shortcut}
      present?(fetch(attrs, :paste_text)) -> {:ok, :paste}
      present?(fetch(attrs, :width)) and present?(fetch(attrs, :height)) -> {:ok, :resize}
      present?(fetch(attrs, :focus_target)) or present?(fetch(attrs, :focused)) -> {:ok, :focus}
      present?(fetch(attrs, :mouse_action)) or present?(fetch(attrs, :pointer)) -> {:ok, :mouse}
      present?(fetch(attrs, :key)) -> {:ok, :key}
      true -> infer_input_family_from_family(attrs)
    end
  end

  defp infer_input_family_from_family(attrs) do
    case normalize_family(fetch(attrs, :family)) do
      :command -> {:ok, :shortcut}
      :navigation -> {:ok, :key}
      :selection -> {:ok, :mouse}
      :click -> {:ok, :mouse}
      :submit -> {:ok, :key}
      :change -> {:ok, :key}
      :focus -> {:ok, :focus}
      _other -> {:error, Error.invalid_native_event(attrs)}
    end
  end

  defp resolve_canonical_family(attrs, input_family) do
    case normalize_family(fetch(attrs, :family)) do
      family ->
        if family in TerminalUi.Transport.Signal.families() do
          {:ok, family}
        else
          case family do
            nil ->
              {:ok, default_family_for(input_family, attrs)}

            invalid ->
              {:error, Error.invalid_family(invalid)}
          end
        end
    end
  end

  defp default_family_for(:shortcut, _attrs), do: :command
  defp default_family_for(:paste, _attrs), do: :change
  defp default_family_for(:resize, _attrs), do: :navigation
  defp default_family_for(:focus, _attrs), do: :focus

  defp default_family_for(:mouse, attrs) do
    case normalize_mouse_action(fetch(attrs, :mouse_action)) do
      :move -> :navigation
      :scroll -> :navigation
      :select -> :selection
      :click -> :click
      nil -> :selection
    end
  end

  defp default_family_for(:key, attrs) do
    case normalize_key(fetch(attrs, :key)) do
      "enter" -> :submit
      "return" -> :submit
      "tab" -> :navigation
      "up" -> :navigation
      "down" -> :navigation
      _other -> :change
    end
  end

  defp resolve_boundary(attrs, family) do
    case normalize_boundary(fetch(attrs, :boundary)) do
      boundary when boundary in [:local, :boundary] ->
        boundary

      _other ->
        if family in TerminalUi.Transport.Signal.boundary_crossing_families() or
             fetch(attrs, :source_kind) in [:canonical, "canonical"] do
          :boundary
        else
          :local
        end
    end
  end

  defp normalize_payload(payload, _surface) when is_map(payload), do: {:ok, Map.new(payload)}
  defp normalize_payload(nil, _surface), do: {:ok, %{}}

  defp normalize_payload(payload, surface),
    do: {:error, Error.invalid_payload_mapping(payload, surface)}

  defp normalized_input(attrs, :shortcut, backend_mode) do
    %{
      shortcut: fetch(attrs, :shortcut),
      backend_mode: backend_mode,
      modifiers: List.wrap(fetch(attrs, :modifiers, []))
    }
  end

  defp normalized_input(attrs, :paste, backend_mode) do
    %{
      text: fetch(attrs, :paste_text),
      backend_mode: backend_mode
    }
  end

  defp normalized_input(attrs, :resize, backend_mode) do
    %{
      width: fetch(attrs, :width),
      height: fetch(attrs, :height),
      backend_mode: backend_mode
    }
  end

  defp normalized_input(attrs, :focus, backend_mode) do
    %{
      target: fetch(attrs, :focus_target),
      focused: fetch(attrs, :focused, true),
      backend_mode: backend_mode
    }
  end

  defp normalized_input(attrs, :mouse, backend_mode) do
    %{
      action: normalize_mouse_action(fetch(attrs, :mouse_action)),
      pointer: normalize_map(fetch(attrs, :pointer, %{})),
      backend_mode: backend_mode
    }
  end

  defp normalized_input(attrs, :key, backend_mode) do
    %{
      key: normalize_key(fetch(attrs, :key)),
      text: fetch(attrs, :text),
      modifiers: List.wrap(fetch(attrs, :modifiers, [])),
      backend_mode: backend_mode
    }
  end

  defp local_handling(:focus, _backend_mode), do: :focus_shift
  defp local_handling(:resize, :tty), do: :paged_resize
  defp local_handling(:resize, _backend_mode), do: :viewport_resize
  defp local_handling(:shortcut, _backend_mode), do: :shortcut_dispatch
  defp local_handling(:paste, _backend_mode), do: :inline_input_update
  defp local_handling(:mouse, :tty), do: :keyboard_fallback
  defp local_handling(:mouse, _backend_mode), do: :pointer_dispatch
  defp local_handling(:key, _backend_mode), do: :keypress_dispatch

  defp default_intent(input_family, family), do: :"#{input_family}_#{family}"
  defp default_runtime_event(input_family, family), do: "#{input_family}:#{family}"

  defp normalize_input_family(value) when is_atom(value), do: value
  defp normalize_input_family(value) when is_binary(value), do: String.to_atom(value)
  defp normalize_input_family(_value), do: nil

  defp normalize_family(value) when is_atom(value), do: value
  defp normalize_family(value) when is_binary(value), do: String.to_atom(value)
  defp normalize_family(_value), do: nil

  defp normalize_source_kind(:native), do: :native
  defp normalize_source_kind("native"), do: :native
  defp normalize_source_kind(:canonical), do: :canonical
  defp normalize_source_kind("canonical"), do: :canonical
  defp normalize_source_kind(_value), do: :native

  defp normalize_boundary(:local), do: :local
  defp normalize_boundary("local"), do: :local
  defp normalize_boundary(:boundary), do: :boundary
  defp normalize_boundary("boundary"), do: :boundary
  defp normalize_boundary(_value), do: nil

  defp normalize_key(key) when is_atom(key), do: Atom.to_string(key)
  defp normalize_key(key) when is_binary(key), do: String.downcase(key)
  defp normalize_key(_key), do: nil

  defp normalize_mouse_action(action) when action in [:click, :move, :scroll, :select], do: action
  defp normalize_mouse_action(action) when is_binary(action), do: String.to_atom(action)
  defp normalize_mouse_action(_action), do: nil

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(_value), do: true

  defp normalize_map(value) when is_map(value), do: Map.new(value)
  defp normalize_map(value) when is_list(value), do: Enum.into(value, %{})
  defp normalize_map(_value), do: %{}

  defp fetch(map, key, default \\ nil) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end
end
