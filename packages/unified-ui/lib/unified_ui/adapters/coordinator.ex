defmodule UnifiedUi.Adapters.Coordinator do
  @moduledoc """
  Coordinates rendering across multiple platforms for multi-platform support.

  This module allows a single UI definition to render on multiple platforms
  simultaneously, with platform detection, renderer selection, state
  synchronization, and concurrent renderer support.

  ## Platform Detection

  The coordinator can auto-detect the current platform:

      platform = Coordinator.detect_platform()
      # => :terminal | :desktop | :web

  ## Multi-Platform Rendering

  Render the same UI on multiple platforms:

      # Render on all available platforms
      {:ok, results} = Coordinator.render_all(iur_tree)

      # Render on specific platforms
      {:ok, results} = Coordinator.render_on(iur_tree, [:terminal, :web])

      # Render concurrently
      {:ok, results} = Coordinator.concurrent_render(iur_tree, [:terminal, :desktop, :web])

  ## Renderer Selection

  Select appropriate renderer(s) based on configuration:

      # Auto-select based on platform
      {:ok, renderer} = Coordinator.select_renderer(:terminal)

      # Get all available renderers
      renderers = Coordinator.available_renderers()
      # => [:terminal, :desktop, :web]

  ## State Synchronization

  Synchronize state across multiple platforms:

      # Sync state to all renderers
      :ok = Coordinator.sync_state(new_state, renderer_states)

      # Merge states from multiple sources
      merged = Coordinator.merge_states([state1, state2, state3])

  """

  alias UnifiedUi.Adapters.Terminal
  alias UnifiedUi.Adapters.Desktop
  alias UnifiedUi.Adapters.Web
  alias UnifiedUi.Adapters.Terminal.Events, as: TerminalEvents
  alias UnifiedUi.Adapters.Desktop.Events, as: DesktopEvents
  alias UnifiedUi.Adapters.Web.Events, as: WebEvents
  alias UnifiedUi.SignalBus
  alias UnifiedUi.Signals
  alias Jido.Signal

  @type platform :: :terminal | :desktop | :web
  @type platforms :: [platform()]
  @type renderer :: module()
  @type event_module :: module()
  @type target ::
          pid()
          | atom()
          | (Signal.t() -> term())
          | {module(), atom(), [term()]}
          | {:component, UnifiedUi.Agent.component_id()}
          | {:topic, SignalBus.topic()}
  @type renderer_state :: map()
  @type render_result :: {:ok, renderer_state()} | {:error, term()}
  @type event_result :: {:ok, Signal.t()} | {:error, term()}
  @type multi_render_result :: %{platform() => render_result()}

  # Platform module mapping
  @platform_modules %{
    terminal: Terminal,
    desktop: Desktop,
    web: Web
  }

  @state_sync_topic "unified_ui:state_sync"

  # Platform event module mapping
  @event_modules %{
    terminal: TerminalEvents,
    desktop: DesktopEvents,
    web: WebEvents
  }

  # Platform Detection

  @doc """
  Auto-detects the current platform based on environment.

  ## Detection Strategy

  * **:web** - Running in Phoenix/Plug context (HTTP/WebSocket connection)
  * **:desktop** - Running in a GUI environment (desktop app)
  * **:terminal** - Default/fallback (TTY available)

  ## Examples

      iex> Coordinator.detect_platform()
      :terminal

  """
  @spec detect_platform() :: platform()
  def detect_platform do
    cond do
      web_environment?() -> :web
      desktop_environment?() -> :desktop
      true -> :terminal
    end
  end

  @doc """
  Checks if running in a terminal environment.

  ## Examples

      iex> Coordinator.terminal?()
      true

  """
  @spec terminal?() :: boolean()
  def terminal? do
    detect_platform() == :terminal
  end

  @doc """
  Checks if running in a desktop environment.

  ## Examples

      iex> Coordinator.desktop?()
      false

  """
  @spec desktop?() :: boolean()
  def desktop? do
    detect_platform() == :desktop
  end

  @doc """
  Checks if running in a web environment.

  ## Examples

      iex> Coordinator.web?()
      false

  """
  @spec web?() :: boolean()
  def web? do
    detect_platform() == :web
  end

  @doc """
  Checks if a specific platform is supported/available.

  ## Examples

      iex> Coordinator.supports_platform?(:terminal)
      true

      iex> Coordinator.supports_platform?(:web)
      true

  """
  @spec supports_platform?(platform()) :: boolean()
  def supports_platform?(platform) when platform in [:terminal, :desktop, :web] do
    Map.has_key?(@platform_modules, platform)
  end

  def supports_platform?(_), do: false

  # Multi-Platform Rendering

  @doc """
  Renders a UI on all available platforms.

  ## Parameters

  * `iur_tree` - The IUR tree to render
  * `opts` - Options passed to all renderers

  ## Returns

  * `{:ok, results}` - Map of platform to render result
  * `{:error, reason}` - All renderers failed

  ## Examples

      {:ok, results} = Coordinator.render_all(iur_tree)
      # => %{terminal: {:ok, terminal_state}, desktop: {:ok, desktop_state}, ...}

  """
  @spec render_all(UnifiedUi.Renderer.iur_tree(), keyword()) ::
          {:ok, multi_render_result()} | {:error, term()}
  def render_all(iur_tree, opts \\ []) do
    platforms = available_renderers()
    render_on(iur_tree, platforms, opts)
  end

  @doc """
  Renders a UI on specific platform(s).

  ## Parameters

  * `iur_tree` - The IUR tree to render
  * `platforms` - List of platforms to render on
  * `opts` - Options passed to renderers

  ## Returns

  * `{:ok, results}` - Map of platform to render result
  * `{:error, reason}` - Rendering failed

  ## Examples

      {:ok, results} = Coordinator.render_on(iur_tree, [:terminal, :web])
      # => %{terminal: {:ok, ...}, web: {:ok, ...}}

  """
  @spec render_on(UnifiedUi.Renderer.iur_tree(), platforms(), keyword()) ::
          {:ok, multi_render_result()} | {:error, term()}
  def render_on(iur_tree, platforms, opts \\ []) when is_list(platforms) do
    results =
      platforms
      |> Enum.reduce(%{}, fn platform, acc ->
        result = render_on_platform(iur_tree, platform, opts)
        Map.put(acc, platform, result)
      end)

    # Check if at least one renderer succeeded
    if Enum.any?(results, fn {_platform, result} -> match?({:ok, _}, result) end) do
      {:ok, results}
    else
      {:error, :all_renderers_failed}
    end
  end

  @doc """
  Renders a UI concurrently on multiple platforms.

  ## Parameters

  * `iur_tree` - The IUR tree to render
  * `platforms` - List of platforms to render on
  * `opts` - Options including:
    * `:timeout` - Timeout in ms for each renderer (default: 5000)

  ## Returns

  * `{:ok, results}` - Map of platform to render result
  * `{:error, reason}` - Rendering failed

  ## Examples

      {:ok, results} = Coordinator.concurrent_render(iur_tree, [:terminal, :desktop, :web], timeout: 10000)

  """
  @spec concurrent_render(UnifiedUi.Renderer.iur_tree(), platforms(), keyword()) ::
          {:ok, multi_render_result()} | {:error, term()}
  def concurrent_render(iur_tree, platforms, opts \\ []) when is_list(platforms) do
    timeout = Keyword.get(opts, :timeout, 5000)
    renderer_opts = Keyword.delete(opts, :timeout)

    platform_tasks =
      Enum.map(platforms, fn platform ->
        task =
          Task.async(fn ->
            render_on_platform(iur_tree, platform, renderer_opts)
          end)

        {platform, task}
      end)

    results_map = await_render_tasks(platform_tasks, timeout)

    # Check if at least one renderer succeeded
    if Enum.any?(results_map, fn {_platform, result} -> match?({:ok, _}, result) end) do
      {:ok, results_map}
    else
      {:error, :all_renderers_failed_or_timeout}
    end
  end

  @doc false
  @spec await_render_tasks([{platform(), Task.t()}], non_neg_integer()) :: multi_render_result()
  def await_render_tasks(platform_tasks, timeout)
      when is_list(platform_tasks) and is_integer(timeout) and timeout >= 0 do
    Enum.reduce(platform_tasks, %{}, fn {platform, task}, acc ->
      result =
        case Task.yield(task, timeout) do
          {:ok, render_result} ->
            render_result

          {:exit, reason} ->
            _ = Task.shutdown(task, :brutal_kill)
            {:error, {:task_exit, reason}}

          nil ->
            _ = Task.shutdown(task, :brutal_kill)
            {:error, :timeout}
        end

      Map.put(acc, platform, result)
    end)
  end

  # Renderer Selection

  @doc """
  Selects the renderer module for a given platform.

  ## Examples

      iex> Coordinator.select_renderer(:terminal)
      {:ok, UnifiedUi.Adapters.Terminal}

  """
  @spec select_renderer(platform()) :: {:ok, renderer()} | {:error, term()}
  def select_renderer(platform) when platform in [:terminal, :desktop, :web] do
    case Map.get(@platform_modules, platform) do
      nil -> {:error, :invalid_platform}
      renderer -> {:ok, renderer}
    end
  end

  def select_renderer(_), do: {:error, :invalid_platform}

  @doc """
  Selects multiple renderer modules.

  ## Examples

      iex> Coordinator.select_renderers([:terminal, :web])
      {:ok, [UnifiedUi.Adapters.Terminal, UnifiedUi.Adapters.Web]}

  """
  @spec select_renderers(platforms()) :: {:ok, [renderer()]} | {:error, term()}
  def select_renderers(platforms) when is_list(platforms) do
    renderers =
      Enum.reduce_while(platforms, {:ok, []}, fn platform, {:ok, acc} ->
        case select_renderer(platform) do
          {:ok, renderer} -> {:cont, {:ok, [renderer | acc]}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case renderers do
      {:ok, renderer_list} -> {:ok, Enum.reverse(renderer_list)}
      error -> error
    end
  end

  @doc """
  Returns list of all available platforms.

  ## Examples

      iex> Coordinator.available_renderers()
      [:terminal, :desktop, :web]

  """
  @spec available_renderers() :: platforms()
  def available_renderers do
    Map.keys(@platform_modules)
  end

  @doc """
  Returns list of enabled platforms (all are currently enabled).

  ## Examples

      iex> Coordinator.enabled_renderers()
      [:terminal, :desktop, :web]

  """
  @spec enabled_renderers() :: platforms()
  def enabled_renderers do
    # For now, all platforms are enabled
    # Future: could be configured via application config
    available_renderers()
  end

  # Event Normalization and Dispatch

  @doc """
  Selects the event module for a given platform.

  ## Examples

      iex> Coordinator.event_module(:terminal)
      {:ok, UnifiedUi.Adapters.Terminal.Events}

  """
  @spec event_module(platform()) :: {:ok, event_module()} | {:error, term()}
  def event_module(platform) when platform in [:terminal, :desktop, :web] do
    case Map.get(@event_modules, platform) do
      nil -> {:error, :invalid_platform}
      module -> {:ok, module}
    end
  end

  def event_module(_), do: {:error, :invalid_platform}

  @doc """
  Subscribes the current process to a signal topic broadcast by the coordinator.

  Messages are delivered as `{:unified_ui_signal, %Jido.Signal{...}}`.
  """
  @spec subscribe_signals(SignalBus.topic()) :: :ok | {:error, term()}
  def subscribe_signals(topic \\ SignalBus.default_topic()) do
    SignalBus.subscribe(topic)
  end

  @doc """
  Unsubscribes the current process from a signal topic.
  """
  @spec unsubscribe_signals(SignalBus.topic()) :: :ok | {:error, term()}
  def unsubscribe_signals(topic \\ SignalBus.default_topic()) do
    SignalBus.unsubscribe(topic)
  end

  @doc """
  Returns the default state synchronization topic.
  """
  @spec state_sync_topic() :: SignalBus.topic()
  def state_sync_topic, do: @state_sync_topic

  @doc """
  Returns the state synchronization topic for a specific platform.
  """
  @spec state_sync_topic(platform()) :: SignalBus.topic()
  def state_sync_topic(platform) when platform in [:terminal, :desktop, :web] do
    "#{@state_sync_topic}:#{platform}"
  end

  @doc """
  Subscribes the current process to state synchronization signals.
  """
  @spec subscribe_state_sync(SignalBus.topic()) :: :ok | {:error, term()}
  def subscribe_state_sync(topic \\ @state_sync_topic) do
    SignalBus.subscribe(topic)
  end

  @doc """
  Unsubscribes the current process from state synchronization signals.
  """
  @spec unsubscribe_state_sync(SignalBus.topic()) :: :ok | {:error, term()}
  def unsubscribe_state_sync(topic \\ @state_sync_topic) do
    SignalBus.unsubscribe(topic)
  end

  @doc """
  Normalizes a platform event into a unified signal.

  ## Parameters

  * `platform` - Platform where the event originated
  * `event_type` - Platform event type (for example, `:click`, `:change`)
  * `data` - Event payload map
  * `opts` - Options forwarded to the platform event adapter

  ## Returns

  * `{:ok, signal}` - Event normalized to `Jido.Signal`
  * `{:error, reason}` - Normalization failed

  """
  @spec normalize_event(platform(), atom(), map(), keyword()) :: event_result()
  def normalize_event(platform, event_type, data, opts \\ [])

  def normalize_event(platform, event_type, data, opts)
      when is_atom(event_type) and is_map(data) do
    with {:ok, module} <- event_module(platform) do
      module.to_signal(event_type, data, opts)
    end
  end

  def normalize_event(_platform, _event_type, _data, _opts), do: {:error, :invalid_event}

  @doc """
  Normalizes and dispatches a platform event to a single target.

  Supported targets:
  * PID
  * Registered process name atom (or component id atom routed via `UnifiedUi.Agent`)
  * 1-arity function
  * MFA tuple `{Module, :function, args}` (signal is prepended to args)
  * Component tuple `{:component, component_id}` (routes through `UnifiedUi.Agent`)
  * PubSub topic tuple `{:topic, "topic_name"}` (fanout via `UnifiedUi.SignalBus`)

  Returns the normalized signal on success.
  """
  @spec dispatch_event(platform(), atom(), map(), target(), keyword()) :: event_result()
  def dispatch_event(platform, event_type, data, target, opts \\ []) do
    with {:ok, signal} <- normalize_event(platform, event_type, data, opts),
         :ok <- route_signal(signal, target) do
      {:ok, signal}
    end
  end

  @doc """
  Normalizes and dispatches a platform event to multiple targets.

  Returns the normalized signal if all dispatches succeed.
  """
  @spec broadcast_event(platform(), atom(), map(), [target()], keyword()) :: event_result()
  def broadcast_event(platform, event_type, data, targets, opts \\ [])

  def broadcast_event(platform, event_type, data, targets, opts) when is_list(targets) do
    with {:ok, signal} <- normalize_event(platform, event_type, data, opts) do
      dispatch_errors =
        targets
        |> Enum.map(&route_signal(signal, &1))
        |> Enum.filter(&match?({:error, _}, &1))

      if dispatch_errors == [] do
        {:ok, signal}
      else
        {:error, {:dispatch_failed, dispatch_errors}}
      end
    end
  end

  def broadcast_event(_platform, _event_type, _data, _targets, _opts) do
    {:error, :invalid_targets}
  end

  @doc """
  Routes a normalized signal to a dispatch target.
  """
  @spec route_signal(Signal.t(), target()) :: :ok | {:error, term()}
  def route_signal(%Signal{} = signal, target) when is_pid(target) do
    if Process.alive?(target) do
      send(target, signal)
      :ok
    else
      {:error, :target_not_alive}
    end
  end

  def route_signal(%Signal{} = signal, target) when is_atom(target) do
    case Process.whereis(target) do
      nil -> route_component_atom_target(signal, target)
      pid -> route_signal(signal, pid)
    end
  end

  def route_signal(%Signal{} = signal, target) when is_function(target, 1) do
    run_target(fn -> target.(signal) end)
  end

  def route_signal(%Signal{} = signal, {module, function, args})
      when is_atom(module) and is_atom(function) and is_list(args) do
    run_target(fn -> apply(module, function, [signal | args]) end)
  end

  def route_signal(%Signal{} = signal, {:component, component_id}) when is_atom(component_id) do
    UnifiedUi.Agent.signal_component(component_id, signal)
  end

  def route_signal(%Signal{} = signal, {:topic, topic}) when is_binary(topic) do
    SignalBus.broadcast(signal, topic)
  end

  def route_signal(%Signal{}, _target), do: {:error, :invalid_target}

  defp route_component_atom_target(%Signal{} = signal, component_id) when is_atom(component_id) do
    case UnifiedUi.Agent.signal_component(component_id, signal) do
      :ok -> :ok
      {:error, :not_found} -> {:error, :target_not_found}
    end
  end

  # State Synchronization

  @doc """
  Synchronizes state across all provided renderer states.

  ## Parameters

  * `new_state` - The new state to synchronize
  * `renderer_states` - Map of platform to renderer state

  ## Returns

  * `:ok` - State synchronized

  ## Examples

      :ok = Coordinator.sync_state(new_state, %{terminal: term_state, web: web_state})

  """
  @spec sync_state(map(), %{platform() => renderer_state()}) :: :ok
  def sync_state(new_state, renderer_states) when is_map(new_state) and is_map(renderer_states) do
    broadcast_state(new_state, renderer_states)
  end

  def sync_state(_new_state, _renderer_states) do
    :ok
  end

  @doc """
  Merges multiple states into a single state.

  ## Parameters

  * `states` - List of states to merge

  ## Returns

  * Merged state map

  ## Merge Strategy

  * Later states override earlier states (last-write-wins)
  * Deep merge for nested maps
  * Concatenation for lists

  ## Examples

      state1 = %{count: 1, items: ["a"]}
      state2 = %{count: 2, items: ["b"]}
      Coordinator.merge_states([state1, state2])
      # => %{count: 2, items: ["a", "b"]}

  """
  @spec merge_states([map()]) :: map()
  def merge_states(states) when is_list(states) do
    Enum.reduce(states, %{}, fn state, acc ->
      deep_merge(acc, state)
    end)
  end

  @doc """
  Resolves conflicts between states.

  ## Parameters

  * `old_state` - Original state
  * `new_state` - New state with potential conflicts

  ## Returns

  * Resolved state

  ## Conflict Resolution Strategy

  Default: Last-write-wins (new_state overrides old_state)

  ## Examples

      old = %{count: 1, name: "old"}
      new = %{count: 2, name: "new"}
      Coordinator.conflict_resolution(old, new)
      # => %{count: 2, name: "new"}

  """
  @spec conflict_resolution(map(), map()) :: map()
  def conflict_resolution(_old_state, new_state) do
    # Default conflict resolution: last-write-wins
    new_state
  end

  @doc """
  Broadcasts state to all renderer states.

  ## Parameters

  * `state` - State to broadcast
  * `renderer_states` - Map of platform to renderer state

  ## Returns

  * `:ok` - State broadcasted

  ## Examples

      :ok = Coordinator.broadcast_state(%{count: 1}, %{terminal: term_state})

  """
  @spec broadcast_state(map(), %{platform() => renderer_state()}) :: :ok
  def broadcast_state(state, renderer_states) when is_map(state) and is_map(renderer_states) do
    synced_states = synchronize_platform_states(state, renderer_states)
    synchronized_at = DateTime.utc_now() |> DateTime.to_iso8601()

    global_payload = %{
      state: state,
      synced_states: synced_states,
      platforms: Map.keys(synced_states),
      synchronized_at: synchronized_at
    }

    global_signal = build_state_sync_signal(global_payload, "global")
    maybe_broadcast_state_signal(global_signal, @state_sync_topic)

    Enum.each(synced_states, fn {platform, platform_state} ->
      payload = %{
        platform: platform,
        state: platform_state,
        synchronized_at: synchronized_at
      }

      platform_signal = build_state_sync_signal(payload, Atom.to_string(platform))
      maybe_broadcast_state_signal(platform_signal, state_sync_topic(platform))
      maybe_route_state_signal(platform_signal, Map.get(renderer_states, platform))
    end)

    :ok
  end

  def broadcast_state(_state, _renderer_states) do
    :ok
  end

  # Private Helpers

  # Render on a single platform
  defp render_on_platform(iur_tree, platform, opts) do
    case select_renderer(platform) do
      {:ok, renderer} ->
        try do
          renderer.render(iur_tree, opts)
        rescue
          error -> {:error, error}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Detect web environment
  defp web_environment? do
    # Check for Phoenix/Plug context using multiple reliable methods
    # 1. Check if Phoenix application is configured
    # 2. Check for Phoenix.PubSub (more stable than process name)
    # 3. Check for Plug connection in process dictionary (if in request)
    Application.get_env(:phoenix, :version) != nil or
      Application.get_env(:plug, :version) != nil or
      pubsub_loaded?()
  end

  # Detect desktop environment
  defp desktop_environment? do
    # Check for desktop environment using multiple methods
    # 1. Check for DesktopUi framework
    # 2. Check for display server (X11/Wayland)
    # 3. Check for common desktop environment variables
    desktop_app_loaded?() or
      has_display_server?() or
      has_desktop_env?()
  end

  # Check if Phoenix.PubSub is available (more reliable than process name)
  defp pubsub_loaded? do
    # Check if Phoenix.PubSub module exists and is loaded
    # This is more reliable than checking for specific process names
    case Code.ensure_loaded(Phoenix.PubSub) do
      {:module, _} -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  # Check if DesktopUi application is available
  defp desktop_app_loaded? do
    # Check if DesktopUi is configured or module is available
    Application.get_env(:desktop_ui, :version) != nil or
      desktop_ui_module_loaded?()
  end

  defp desktop_ui_module_loaded? do
    # Try to check if DesktopUi module is available
    case Code.ensure_loaded(Draw) do
      {:module, _} -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  # Check for X11 or Wayland display server
  defp has_display_server? do
    System.get_env("DISPLAY") != nil or
      System.get_env("WAYLAND_DISPLAY") != nil
  end

  # Check for common desktop environment variables
  defp has_desktop_env? do
    # Common desktop environment indicators
    vars = [
      "XDG_CURRENT_DESKTOP",
      "XDG_SESSION_TYPE",
      "GNOME_DESKTOP_SESSION_ID",
      "KDE_FULL_SESSION",
      "SESSION_MANAGER"
    ]

    Enum.any?(vars, fn var -> System.get_env(var) != nil end)
  end

  # Deep merge for nested maps
  defp deep_merge(left, right) when is_map(left) and is_map(right) do
    Map.merge(left, right, fn _k, lv, rv ->
      if is_map(lv) and is_map(rv) do
        deep_merge(lv, rv)
      else
        rv
      end
    end)
  end

  defp deep_merge(_left, right), do: right

  defp synchronize_platform_states(new_state, renderer_states) do
    Enum.reduce(renderer_states, %{}, fn {platform, renderer_state}, acc ->
      if platform in [:terminal, :desktop, :web] and is_map(renderer_state) do
        existing_state = extract_renderer_sync_state(renderer_state)
        merged_state = merge_states([existing_state, new_state])
        resolved_state = conflict_resolution(existing_state, merged_state)
        Map.put(acc, platform, resolved_state)
      else
        acc
      end
    end)
  end

  defp extract_renderer_sync_state(renderer_state) when is_map(renderer_state) do
    cond do
      is_map(Map.get(renderer_state, :synced_state)) -> Map.get(renderer_state, :synced_state)
      is_map(Map.get(renderer_state, :state)) -> Map.get(renderer_state, :state)
      is_map(Map.get(renderer_state, :model_state)) -> Map.get(renderer_state, :model_state)
      true -> %{}
    end
  end

  defp build_state_sync_signal(payload, subject) do
    case Signals.create(
           "unified.state.synchronized",
           payload,
           source: "/unified_ui/coordinator",
           subject: subject
         ) do
      {:ok, signal} -> signal
      {:error, _reason} -> nil
    end
  end

  defp maybe_broadcast_state_signal(nil, _topic), do: :ok

  defp maybe_broadcast_state_signal(%Signal{} = signal, topic) do
    _ = SignalBus.broadcast(signal, topic)
    :ok
  end

  defp maybe_route_state_signal(nil, _renderer_state), do: :ok

  defp maybe_route_state_signal(%Signal{} = signal, renderer_state) when is_map(renderer_state) do
    case Map.get(renderer_state, :sync_target) do
      nil -> :ok
      target -> route_signal(signal, target)
    end
  end

  defp maybe_route_state_signal(_signal, _renderer_state), do: :ok

  defp run_target(callback) when is_function(callback, 0) do
    case callback.() do
      {:error, _reason} = error -> error
      _ -> :ok
    end
  rescue
    error -> {:error, {:target_failure, error}}
  catch
    kind, reason -> {:error, {:target_failure, {kind, reason}}}
  end
end
