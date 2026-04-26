defmodule TerminalUi.Runtime.Navigation do
  @moduledoc """
  Canonical screen-transition handling for the shared `terminal_ui` runtime.
  """

  alias TerminalUi.Runtime.{Error, Screen, State}
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  @default_history_limits %{raw: 20, tty: 5}

  @spec initialize(String.t(), String.t() | nil, atom(), map(), keyword()) :: map()
  def initialize(screen_id, title, backend_mode, capabilities, opts \\ []) do
    history_limit = Keyword.get(opts, :history_limit, Map.get(@default_history_limits, backend_mode, 10))

    %{
      active: %{screen_id: screen_id, title: title, params: %{}},
      history: [],
      forward: [],
      modals: [],
      history_limit: history_limit,
      last_transition: nil,
      last_realization: realization_summary(%{action: :mount}, backend_mode, capabilities, false)
    }
  end

  @spec transition?(map()) :: boolean()
  def transition?(%{family: :navigation, target: target}) when is_map(target) do
    not is_nil(Interaction.navigation_descriptor(target))
  end

  def transition?(_other), do: false

  @spec summary(map() | nil) :: map()
  def summary(%{
        active: active,
        history: history,
        forward: forward,
        modals: modals,
        last_transition: last_transition,
        last_realization: last_realization
      }) do
    %{
      active_screen_id: active.screen_id,
      history_depth: length(history),
      forward_depth: length(forward),
      modal_depth: length(modals),
      current_modal: modals |> List.last() |> modal_summary(),
      last_transition: last_transition,
      last_realization: last_realization
    }
  end

  def summary(_other), do: %{}

  @spec apply_transition(State.t(), map()) :: {:ok, State.t()} | {:error, Error.t()}
  def apply_transition(%State{} = runtime_state, translation) when is_map(translation) do
    with {:ok, descriptor} <- validate_navigation_descriptor(translation),
         {:ok, navigation} <- apply_descriptor(runtime_state.navigation, descriptor, runtime_state) do
      {:ok, synchronize_runtime(runtime_state, navigation, descriptor)}
    end
  end

  defp validate_navigation_descriptor(translation) do
    descriptor = boundary_descriptor(translation)

    case BoundaryTransport.validate_boundary_descriptor(descriptor) do
      :ok ->
        {:ok, navigation_descriptor(translation)}

      {:error, {:forbidden_navigation_keys, keys}} ->
        {:error, Error.new(:host_route_navigation_syntax, %{keys: keys}, :event_routing)}

      {:error, reason} ->
        {:error, Error.new(:invalid_navigation_transition, %{reason: inspect(reason)}, :event_routing)}
    end
  end

  defp apply_descriptor(navigation, descriptor, runtime_state) do
    action = Map.get(descriptor, :action)

    case action do
      action when action in [:navigate_to, "navigate_to"] ->
        {:ok, navigate_to(navigation, descriptor, runtime_state)}

      action when action in [:replace_with, "replace_with"] ->
        {:ok, replace_with(navigation, descriptor, runtime_state)}

      action when action in [:go_back, "go_back"] ->
        go_back(navigation, descriptor, runtime_state)

      action when action in [:go_forward, "go_forward"] ->
        go_forward(navigation, descriptor, runtime_state)

      action when action in [:open_modal, "open_modal"] ->
        {:ok, open_modal(navigation, descriptor, runtime_state)}

      action when action in [:close_modal, "close_modal"] ->
        close_modal(navigation, descriptor, runtime_state)

      _other ->
        {:error,
         Error.new(
           :unsupported_navigation_context,
           %{action: action, reason: :unsupported_navigation_action},
           :event_routing
         )}
    end
  end

  defp navigate_to(navigation, descriptor, runtime_state) do
    target = screen_entry(descriptor)

    history =
      [navigation.active | navigation.history]
      |> Enum.take(navigation.history_limit)

    navigation
    |> Map.put(:active, target)
    |> Map.put(:history, history)
    |> Map.put(:forward, [])
    |> Map.put(:last_transition, descriptor)
    |> Map.put(
      :last_realization,
      realization_summary(descriptor, runtime_state.backend_mode, runtime_state.capabilities, false)
    )
  end

  defp replace_with(navigation, descriptor, runtime_state) do
    navigation
    |> Map.put(:active, screen_entry(descriptor))
    |> Map.put(:forward, [])
    |> Map.put(:last_transition, descriptor)
    |> Map.put(
      :last_realization,
      realization_summary(descriptor, runtime_state.backend_mode, runtime_state.capabilities, false)
    )
  end

  defp go_back(%{history: []}, descriptor, _runtime_state) do
    {:error,
     Error.new(
       :unsupported_navigation_context,
       %{action: descriptor.action, reason: :empty_history},
       :event_routing
     )}
  end

  defp go_back(navigation, descriptor, runtime_state) do
    [previous | history_rest] = navigation.history

    {:ok,
     navigation
     |> Map.put(:active, previous)
     |> Map.put(:history, history_rest)
     |> Map.put(:forward, [navigation.active | navigation.forward])
     |> Map.put(:last_transition, descriptor)
     |> Map.put(
       :last_realization,
       realization_summary(descriptor, runtime_state.backend_mode, runtime_state.capabilities, false)
     )}
  end

  defp go_forward(%{forward: []}, descriptor, _runtime_state) do
    {:error,
     Error.new(
       :unsupported_navigation_context,
       %{action: descriptor.action, reason: :empty_forward},
       :event_routing
     )}
  end

  defp go_forward(navigation, descriptor, runtime_state) do
    [next | forward_rest] = navigation.forward

    {:ok,
     navigation
     |> Map.put(:active, next)
     |> Map.put(:history, [navigation.active | navigation.history] |> Enum.take(navigation.history_limit))
     |> Map.put(:forward, forward_rest)
     |> Map.put(:last_transition, descriptor)
     |> Map.put(
       :last_realization,
       realization_summary(descriptor, runtime_state.backend_mode, runtime_state.capabilities, false)
     )}
  end

  defp open_modal(navigation, descriptor, runtime_state) do
    degrade? = runtime_state.backend_mode == :tty

    modal_entry =
      %{
        modal: Map.get(descriptor, :modal),
        params: normalize_map(Map.get(descriptor, :params, %{})),
        metadata: normalize_map(Map.get(descriptor, :metadata, %{})),
        realization:
          if(degrade?,
            do: :focused_surface,
            else: :inline_overlay
          )
      }

    navigation
    |> Map.update!(:modals, &(&1 ++ [modal_entry]))
    |> Map.put(:last_transition, descriptor)
    |> Map.put(
      :last_realization,
      realization_summary(descriptor, runtime_state.backend_mode, runtime_state.capabilities, degrade?)
    )
  end

  defp close_modal(%{modals: []}, descriptor, _runtime_state) do
    {:error,
     Error.new(
       :invalid_modal_transition,
       %{action: descriptor.action, reason: :no_modal},
       :event_routing
     )}
  end

  defp close_modal(navigation, descriptor, runtime_state) do
    requested_modal = Map.get(descriptor, :modal)
    current_modal = navigation.modals |> List.last() |> Map.get(:modal)

    cond do
      not is_nil(requested_modal) and requested_modal != current_modal ->
        {:error,
         Error.new(
           :invalid_modal_transition,
           %{action: descriptor.action, requested_modal: requested_modal, current_modal: current_modal},
           :event_routing
         )}

      true ->
        {:ok,
         navigation
         |> Map.put(:modals, Enum.drop(navigation.modals, -1))
         |> Map.put(:last_transition, descriptor)
         |> Map.put(
           :last_realization,
           realization_summary(descriptor, runtime_state.backend_mode, runtime_state.capabilities, false)
         )}
    end
  end

  defp synchronize_runtime(runtime_state, navigation, descriptor) do
    screen_id = navigation.active.screen_id
    title = navigation.active.title || default_title(screen_id)

    %{
      runtime_state
      | screen_id: screen_id,
        title: title,
        screen: synchronize_screen(runtime_state.screen, screen_id, title, navigation, descriptor),
        navigation: navigation
    }
  end

  defp synchronize_screen(%Screen{} = screen, screen_id, title, navigation, descriptor) do
    metadata =
      screen.metadata
      |> Map.put(:current_screen_id, screen_id)
      |> Map.put(:navigation_action, Map.get(descriptor, :action))
      |> Map.put(:navigation_summary, summary(navigation))

    %{screen | id: screen_id, title: title, metadata: metadata}
  end

  defp screen_entry(descriptor) do
    screen_id = Map.get(descriptor, :screen)

    %{
      screen_id: normalize_screen_id(screen_id),
      title: default_title(screen_id),
      params: normalize_map(Map.get(descriptor, :params, %{}))
    }
  end

  defp realization_summary(descriptor, backend_mode, capabilities, degraded?) do
    action = Map.get(descriptor, :action)

    %{
      action: action,
      backend_mode: backend_mode,
      transition_mode: transition_mode(action, backend_mode),
      degraded?: degraded?,
      fallback:
        if(degraded?,
          do: fallback_for(action, capabilities),
          else: nil
        ),
      intent_preserved?: true
    }
  end

  defp transition_mode(action, _backend_mode) when action in [:navigate_to, "navigate_to"], do: :screen_replacement
  defp transition_mode(action, _backend_mode) when action in [:replace_with, "replace_with"], do: :screen_replacement
  defp transition_mode(action, _backend_mode) when action in [:go_back, "go_back", :go_forward, "go_forward"], do: :bounded_history
  defp transition_mode(action, :tty) when action in [:open_modal, "open_modal", :close_modal, "close_modal"], do: :focused_surface
  defp transition_mode(action, _backend_mode) when action in [:open_modal, "open_modal", :close_modal, "close_modal"], do: :inline_overlay
  defp transition_mode(_action, _backend_mode), do: :screen_replacement

  defp fallback_for(action, _capabilities) when action in [:open_modal, "open_modal", :close_modal, "close_modal"] do
    :focused_surface
  end

  defp fallback_for(action, capabilities) when action in [:navigate_to, "navigate_to", :replace_with, "replace_with"] do
    if Map.get(capabilities, :positioning, false), do: nil, else: :screen_replacement
  end

  defp fallback_for(_action, _capabilities), do: nil

  defp modal_summary(nil), do: nil

  defp modal_summary(modal) do
    %{
      modal: modal.modal,
      params: modal.params,
      realization: modal.realization
    }
  end

  defp boundary_descriptor(translation) do
    %{
      family: :navigation,
      intent: Map.get(translation, :intent),
      source_context: %{
        element_id: Map.get(translation, :widget_id),
        scope: :screen
      },
      target: Map.get(translation, :target, %{}),
      metadata: %{}
    }
  end

  defp navigation_descriptor(translation) do
    Interaction.navigation_descriptor(Map.get(translation, :target, %{})) || %{}
  end

  defp normalize_screen_id(screen_id) when is_binary(screen_id), do: screen_id
  defp normalize_screen_id(screen_id) when is_atom(screen_id), do: to_string(screen_id)
  defp normalize_screen_id(screen_id), do: screen_id |> to_string()

  defp default_title(screen_id) when is_atom(screen_id) do
    screen_id
    |> Atom.to_string()
    |> default_title()
  end

  defp default_title(screen_id) when is_binary(screen_id) do
    screen_id
    |> String.split(~r/[_-]+/)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(map) when is_list(map), do: Enum.into(map, %{})
  defp normalize_map(_other), do: %{}
end
