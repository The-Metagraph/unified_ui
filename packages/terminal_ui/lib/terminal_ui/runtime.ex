defmodule TerminalUi.Runtime do
  @moduledoc """
  Shared runtime entrypoint for native and canonical `terminal_ui` screens.
  """

  alias Jido.Signal
  alias TerminalUi.{Backend, Layer, Layout, Transport}
  alias TerminalUi.Renderer
  alias TerminalUi.Runtime.{Boot, Error, EventLoop, EventRouter, Realization, Screen, State}
  alias UnifiedIUR.Element

  @type validation_state :: :foundational_realization_ready | :advanced_runtime_ready

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      Boot,
      EventLoop,
      EventRouter,
      Screen,
      Realization,
      State,
      Error,
      Layout,
      Layer
    ]
  end

  @spec capabilities() :: [atom()]
  def capabilities do
    [
      :native_mount,
      :runtime_boot,
      :capability_snapshot,
      :backend_selection,
      :event_loop_scaffold,
      :screen_composition,
      :shared_realization_model,
      :advanced_display_systems,
      :layered_runtime_behavior,
      :capability_fallbacks,
      :canonical_foundational_rendering,
      :canonical_boundary_events,
      :normalized_terminal_inputs,
      :shared_event_routing,
      :focus_traversal,
      :binding_surface,
      :deterministic_runtime_errors
    ]
  end

  @spec validation_state() :: validation_state()
  def validation_state, do: :advanced_runtime_ready

  @spec assumptions() :: map()
  def assumptions do
    %{
      term_ui_backed: true,
      shared_runtime_for_native_and_canonical: true,
      layered_runtime_shared: true,
      boundary_local_routing_shared: true,
      capability_aware: true,
      keyboard_first: true,
      renderer_boot_path_present: true
    }
  end

  @spec mount_native_screen(map(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_native_screen(screen, opts \\ []) when is_map(screen) do
    with {:ok, backend_mode} <- Backend.select(opts) do
      Boot.prepare_native_screen(screen, backend_mode, opts)
    else
      {:error, {:unsupported_backend_mode, mode}} ->
        {:error, Error.new(:unsupported_backend_mode, %{backend_mode: mode})}
    end
  end

  @spec mount_iur_screen(Element.t(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_iur_screen(%Element{} = element, opts \\ []) do
    with {:ok, _backend_mode} <- Backend.select(opts),
         {:ok, rendered_root} <- Renderer.render(element, opts) do
      Boot.prepare_rendered_screen(rendered_root, :canonical, opts)
    else
      {:error, {:unsupported_backend_mode, mode}} ->
        {:error, Error.new(:unsupported_backend_mode, %{backend_mode: mode})}

      {:error, %TerminalUi.Renderer.Error{} = error} ->
        {:error, Error.new(error.reason, error.details)}
    end
  end

  @spec dispatch_native_event(State.t(), keyword() | map()) ::
          {:ok, State.t(), map()} | {:error, Error.t() | term()}
  def dispatch_native_event(%State{} = runtime_state, attrs)
      when is_map(attrs) or is_list(attrs) do
    attrs =
      attrs
      |> normalize_map()
      |> Map.put_new(:backend_mode, runtime_state.backend_mode)
      |> Map.put_new(:runtime_id, runtime_state.runtime_id)
      |> Map.put_new(:screen, runtime_state.screen_id)
      |> Map.put_new(:source_kind, runtime_state.source_kind)

    with {:ok, translation} <- Transport.from_native_event(attrs),
         {:ok, route_result} <- EventRouter.route(runtime_state, translation) do
      {:ok, apply_route(runtime_state, route_result), route_result}
    end
  end

  @spec dispatch_widget_interaction(State.t(), String.t() | atom(), atom(), keyword() | map()) ::
          {:ok, State.t(), map()} | {:error, Error.t() | term()}
  def dispatch_widget_interaction(%State{} = runtime_state, widget_id, family, attrs \\ []) do
    attrs =
      attrs
      |> normalize_map()
      |> Map.put(:widget_id, widget_id)
      |> Map.put(:family, family)
      |> Map.put_new(:input_family, input_family_for(family))

    dispatch_native_event(runtime_state, attrs)
  end

  @spec handle_boundary_signal(State.t(), Signal.t() | map()) ::
          {:ok, State.t(), map()} | {:error, Error.t() | term()}
  def handle_boundary_signal(%State{} = runtime_state, signal) do
    with {:ok, translation} <- Transport.from_boundary_signal(signal),
         {:ok, route_result} <- EventRouter.route(runtime_state, translation) do
      {:ok, apply_route(runtime_state, route_result), route_result}
    end
  end

  defp apply_route(%State{} = runtime_state, route_result) do
    translation = route_result.translation

    %{
      runtime_state
      | focus: apply_focus(runtime_state.focus, translation, route_result.route),
        event_loop: EventLoop.record_route(runtime_state.event_loop, route_result),
        event_log: runtime_state.event_log ++ [event_log_entry(route_result)]
    }
  end

  defp apply_focus(nil, _translation, _route), do: nil

  defp apply_focus(focus, %{family: :focus, widget_id: widget_id}, :local_runtime)
       when not is_nil(widget_id) do
    %{
      current: to_string(widget_id),
      order:
        ([to_string(widget_id)] ++ List.wrap(Map.get(focus, :order, [])))
        |> Enum.uniq()
    }
  end

  defp apply_focus(focus, _translation, _route), do: focus

  defp event_log_entry(route_result) do
    translation = route_result.translation

    %{
      route: route_result.route,
      family: route_result.family,
      input_family: route_result.input_family,
      runtime_event: route_result.runtime_event,
      boundary: route_result.boundary,
      widget_id: translation.widget_id,
      local_handling: route_result.local_handling,
      signal_type:
        case Map.get(translation, :signal) do
          %Signal{} = signal -> signal.type
          _other -> nil
        end
    }
  end

  defp input_family_for(family) when family in [:submit, :change], do: :key
  defp input_family_for(:selection), do: :mouse
  defp input_family_for(:navigation), do: :key
  defp input_family_for(:command), do: :shortcut
  defp input_family_for(:focus), do: :focus
  defp input_family_for(_family), do: :key

  defp normalize_map(attrs) when is_map(attrs), do: Map.new(attrs)
  defp normalize_map(attrs) when is_list(attrs), do: Enum.into(attrs, %{})
end
