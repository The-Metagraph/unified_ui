defmodule DesktopUi.Runtime.Navigation do
  @moduledoc """
  Canonical screen-transition handling for the shared `desktop_ui` runtime.
  """

  alias DesktopUi.Navigation.{Controller, Integration, Registry, Signal}
  alias DesktopUi.Navigation.State, as: NavigationState
  alias DesktopUi.Runtime.{Error, Screen, State}
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  @spec transition?(map()) :: boolean()
  def transition?(%{family: :navigation, target: target}) when is_map(target) do
    not is_nil(Interaction.navigation_descriptor(target))
  end

  def transition?(_other), do: false

  @spec apply_transition(State.t(), map()) :: {:ok, State.t()} | {:error, Error.t()}
  def apply_transition(%State{navigation_controller: nil}, translation) when is_map(translation) do
    if transition?(translation) do
      {:error,
       Error.new(
         :no_navigation_controller,
         %{action: descriptor_action(translation)},
         :event_routing
       )}
    else
      {:error, Error.new(:invalid_navigation_transition, %{reason: :missing_navigation_target}, :event_routing)}
    end
  end

  def apply_transition(%State{} = runtime_state, translation) when is_map(translation) do
    with {:ok, descriptor} <- validate_navigation_descriptor(translation),
         :ok <- validate_transition_context(runtime_state, descriptor),
         {:ok, signal} <- Signal.from_map(descriptor),
         {:ok, updated_runtime, nav_state, _transition} <-
           Integration.handle_navigation(runtime_state, signal) do
      {:ok, synchronize_runtime(updated_runtime, nav_state, runtime_state, descriptor)}
    else
      {:error, %Error{} = error} ->
        {:error, error}

      {:error, {:unknown_screen, screen_id}} ->
        {:error,
         Error.new(
           :unresolved_navigation_target,
           %{action: descriptor_action(translation), screen_id: screen_id},
           :event_routing
         )}

      {:error, :no_modal} ->
        {:error,
         Error.new(
           :invalid_modal_transition,
           %{action: descriptor_action(translation), reason: :no_modal},
           :event_routing
         )}

      {:error, :empty_history} ->
        {:error,
         Error.new(
           :unsupported_navigation_context,
           %{action: descriptor_action(translation), reason: :empty_history},
           :event_routing
         )}

      {:error, :empty_forward} ->
        {:error,
         Error.new(
           :unsupported_navigation_context,
           %{action: descriptor_action(translation), reason: :empty_forward},
           :event_routing
         )}

      {:error, reason} ->
        {:error,
         Error.new(
           :invalid_navigation_transition,
           %{action: descriptor_action(translation), reason: inspect(reason)},
           :event_routing
         )}
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

  defp validate_transition_context(%State{} = runtime_state, descriptor) do
    action = Map.get(descriptor, :action)

    cond do
      action in [:close_modal, "close_modal"] and modal_mismatch?(runtime_state, descriptor) ->
        {:error,
         Error.new(
           :invalid_modal_transition,
           %{action: action, requested_modal: Map.get(descriptor, :modal)},
           :event_routing
         )}

      true ->
        :ok
    end
  end

  defp synchronize_runtime(updated_runtime, %NavigationState{} = nav_state, previous_runtime, descriptor) do
    screen_id = current_screen_id(nav_state, updated_runtime.screen_id)
    title = resolve_screen_title(previous_runtime, screen_id, updated_runtime.current_screen_module)

    %{
      updated_runtime
      | screen_id: screen_id,
        title: title,
        screen: synchronize_screen(updated_runtime.screen, screen_id, title, descriptor, nav_state)
    }
  end

  defp synchronize_screen(%Screen{} = screen, screen_id, title, descriptor, nav_state) do
    metadata =
      screen.metadata
      |> Map.put(:current_screen_id, screen_id)
      |> Map.put(:navigation_action, Map.get(descriptor, :action))
      |> Map.put(:modal_depth, NavigationState.modal_depth(nav_state))

    %{screen | id: screen_id, title: title, metadata: metadata}
  end

  defp resolve_screen_title(runtime_state, screen_id, current_screen_module) do
    metadata =
      case Controller.registry(runtime_state.navigation_controller) do
        registry when is_atom(registry) ->
          Registry.metadata(registry, normalize_registry_id(screen_id))

        _other ->
          %{}
      end

    Map.get(metadata, :title) ||
      Map.get(metadata, "title") ||
      default_title(screen_id, current_screen_module)
  end

  defp current_screen_id(%NavigationState{current: current}, fallback),
    do: normalize_screen_id(current, fallback)

  defp normalize_screen_id(screen_id, _fallback) when is_binary(screen_id), do: screen_id
  defp normalize_screen_id(screen_id, _fallback) when is_atom(screen_id), do: to_string(screen_id)
  defp normalize_screen_id(_screen_id, fallback), do: fallback

  defp normalize_registry_id(screen_id) when is_binary(screen_id), do: String.to_atom(screen_id)
  defp normalize_registry_id(screen_id), do: screen_id

  defp default_title(screen_id, _current_screen_module) when is_atom(screen_id) do
    screen_id
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp default_title(screen_id, _current_screen_module) when is_binary(screen_id) and screen_id != "" do
    screen_id
    |> String.split(~r/[_-]+/)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp default_title(_screen_id, current_screen_module) when is_atom(current_screen_module) do
    current_screen_module
    |> Module.split()
    |> List.last()
  end

  defp default_title(_screen_id, _current_screen_module), do: "Screen"

  defp modal_mismatch?(%State{navigation_state: nil}, %{modal: modal}) when not is_nil(modal), do: true

  defp modal_mismatch?(%State{navigation_state: nav_state}, %{modal: modal})
       when not is_nil(modal) and modal != "" do
    case NavigationState.top_modal(nav_state) do
      {current_modal, _module, _params} -> current_modal != modal
      nil -> true
    end
  end

  defp modal_mismatch?(_runtime_state, _descriptor), do: false

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

  defp descriptor_action(translation) do
    translation
    |> navigation_descriptor()
    |> Map.get(:action)
  end
end
