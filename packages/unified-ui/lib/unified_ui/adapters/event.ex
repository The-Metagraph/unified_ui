# spec-coverage: unified_ui.adapters.event_normalization

defmodule UnifiedUi.Adapters.Event do
  @moduledoc """
  Canonical adapter-side event normalization and dispatch helpers.

  This module is the shared adapter event contract for `unified-ui`. Platform
  adapters convert local events into canonical `Jido.Signal` values here and may
  optionally dispatch those signals to running `UnifiedUi.Agent` components.
  """

  alias Jido.Signal
  alias UnifiedUi.Adapters.Security
  alias UnifiedUi.Agent, as: UiAgent
  alias UnifiedUi.Signals

  @type platform :: :terminal | :desktop | :web
  @type event_type :: atom()
  @type event_data :: map()
  @type event :: %{type: event_type(), data: event_data()}

  @doc """
  Creates a platform event map from a type and payload.
  """
  @spec create_event(event_type(), event_data()) :: event()
  def create_event(type, data) when is_atom(type) and is_map(data) do
    %{type: type, data: data}
  end

  @doc """
  Converts a platform event to a canonical `Jido.Signal`.

  Supported event types are the shared adapter surface used by the terminal,
  desktop, and web event modules. Platform-specific options such as
  `:allowed_hook_names` are consumed here and are not forwarded into the signal.
  """
  @spec to_signal(platform(), event_type(), event_data(), keyword()) ::
          {:ok, Signal.t()} | {:error, term()}
  def to_signal(platform, event_type, data, opts \\ [])

  def to_signal(platform, :click, data, opts) when platform in [:terminal, :desktop, :web] do
    standard_signal(platform, :click, data, opts)
  end

  def to_signal(platform, :change, data, opts) when platform in [:terminal, :desktop, :web] do
    standard_signal(platform, :change, data, opts)
  end

  def to_signal(platform, :submit, data, opts) when platform in [:terminal, :desktop, :web] do
    standard_signal(platform, :submit, data, opts)
  end

  def to_signal(platform, :focus, data, opts) when platform in [:terminal, :desktop, :web] do
    standard_signal(platform, :focus, data, opts)
  end

  def to_signal(platform, :blur, data, opts) when platform in [:terminal, :desktop, :web] do
    standard_signal(platform, :blur, data, opts)
  end

  def to_signal(platform, :key_press, data, opts) when platform in [:terminal, :desktop, :web] do
    custom_signal(platform, "unified.key.pressed", data, opts)
  end

  def to_signal(:web, :key_release, data, opts) do
    custom_signal(:web, "unified.key.released", data, opts)
  end

  def to_signal(platform, :mouse, %{action: _action} = data, opts)
      when platform in [:terminal, :desktop] do
    action_signal(platform, :mouse, data, opts)
  end

  def to_signal(:desktop, :window, %{action: _action} = data, opts) do
    action_signal(:desktop, :window, data, opts)
  end

  def to_signal(:web, :hook, %{hook_name: hook_name} = data, opts) do
    allowed_hook_names = Keyword.get(opts, :allowed_hook_names, [])

    if hook_name in allowed_hook_names do
      custom_signal(:web, "unified.web.#{hook_name}", data, opts)
    else
      {:error, :invalid_hook}
    end
  end

  def to_signal(_platform, _event_type, data, _opts) when not is_map(data),
    do: {:error, :invalid_payload}

  def to_signal(_platform, _event_type, _data, _opts), do: {:error, :unsupported_event}

  @doc """
  Creates and optionally dispatches a platform event as a canonical `Jido.Signal`.
  """
  @spec dispatch(platform(), event_type(), event_data(), keyword()) ::
          {:ok, Signal.t()} | {:error, term()}
  def dispatch(platform, event_type, data, opts \\ []) do
    with {:ok, signal} <- to_signal(platform, event_type, data, opts),
         :ok <- maybe_dispatch_to_component(signal, opts) do
      {:ok, signal}
    end
  end

  @doc """
  Adds canonical adapter metadata to an event payload.
  """
  @spec normalize_payload(platform(), event_data()) :: event_data()
  def normalize_payload(platform, payload)
      when platform in [:terminal, :desktop, :web] and is_map(payload) do
    Map.put(payload, :platform, platform)
  end

  @doc """
  Extracts common event metadata from a platform event payload.
  """
  @spec extract_metadata(map()) :: map()
  def extract_metadata(platform_event) when is_map(platform_event) do
    %{}
    |> maybe_put(platform_event, :x)
    |> maybe_put(platform_event, :y)
    |> maybe_put(platform_event, :ctrl, [:control, :ctrl])
    |> maybe_put(platform_event, :alt, [:modifier_alt, :alt])
    |> maybe_put(platform_event, :shift, [:modifier_shift, :shift])
    |> maybe_put(platform_event, :meta, [:modifier_meta, :meta])
    |> maybe_put(platform_event, :timestamp, [:time, :timestamp_ms, :ms])
  end

  defp standard_signal(platform, signal_name, data, opts) when is_map(data) do
    with :ok <- Security.validate_signal_payload(data) do
      Signals.create(signal_name, normalize_payload(platform, data), signal_opts(platform, opts))
    end
  end

  defp standard_signal(_platform, _signal_name, _data, _opts), do: {:error, :invalid_payload}

  defp custom_signal(platform, signal_type, data, opts) when is_map(data) do
    with :ok <- Security.validate_signal_payload(data) do
      Signals.create(signal_type, normalize_payload(platform, data), signal_opts(platform, opts))
    end
  end

  defp custom_signal(_platform, _signal_type, _data, _opts), do: {:error, :invalid_payload}

  defp action_signal(platform, category, %{action: action} = data, opts) when is_map(data) do
    with :ok <- Security.validate_event_action(category, action) do
      custom_signal(platform, "unified.#{category}.#{action}", data, opts)
    end
  end

  defp action_signal(_platform, _category, _data, _opts), do: {:error, :invalid_payload}

  defp maybe_dispatch_to_component(signal, opts) do
    case Keyword.get(opts, :component_id) do
      nil ->
        :ok

      component_id when is_atom(component_id) ->
        UiAgent.signal_component(component_id, signal)

      _other ->
        {:error, :invalid_component_id}
    end
  end

  defp signal_opts(platform, opts) do
    opts
    |> Keyword.drop([:allowed_hook_names, :component_id])
    |> Keyword.put_new(:source, "/unified_ui/#{platform}")
  end

  defp maybe_put(acc, source, key) do
    maybe_put(acc, source, key, key)
  end

  defp maybe_put(acc, source, target_key, source_keys) when is_list(source_keys) do
    case Enum.find_value(source_keys, fn source_key ->
           case Map.fetch(source, source_key) do
             {:ok, value} -> {:found, Map.put(acc, target_key, value)}
             :error -> nil
           end
         end) do
      {:found, result} -> result
      _ -> acc
    end
  end

  defp maybe_put(acc, source, target_key, source_key) do
    case Map.fetch(source, source_key) do
      {:ok, value} -> Map.put(acc, target_key, value)
      :error -> acc
    end
  end
end
