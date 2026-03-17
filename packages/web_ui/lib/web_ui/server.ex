defmodule WebUi.Server do
  @moduledoc """
  Package-facing entrypoint for the Phoenix server-side runtime boundary.
  """

  alias WebUi.Server.{RenderModel, Screen, State, Sync, ViewState}

  @type responsibility ::
          :authoritative_runtime_state
          | :frontend_coordination
          | :native_event_routing
          | :boundary_event_authority

  @type capability ::
          :mount
          | :render_view_state
          | :render_model_generation
          | :event_handling
          | :sync_envelopes
          | :screen_contract

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :authoritative_runtime_state,
      :frontend_coordination,
      :native_event_routing,
      :boundary_event_authority
    ]
  end

  @spec capabilities() :: [capability()]
  def capabilities do
    [
      :mount,
      :render_view_state,
      :render_model_generation,
      :event_handling,
      :sync_envelopes,
      :screen_contract
    ]
  end

  @spec mount(module(), keyword()) :: {:ok, State.t()} | {:error, WebUi.Server.Error.t()}
  def mount(screen, opts \\ []) do
    State.mount(screen, opts)
  end

  @spec handle_event(State.t(), String.t(), map()) ::
          {:ok, State.t()} | {:error, WebUi.Server.Error.t()}
  def handle_event(%State{} = state, event, payload) do
    State.handle_event(state, event, payload)
  end

  @spec render_view_state(State.t()) :: ViewState.t()
  def render_view_state(%State{} = state) do
    state.view_state
  end

  @spec sync_envelope(State.t(), keyword()) :: {:ok, map()}
  def sync_envelope(%State{} = state, opts \\ []) do
    State.sync_envelope(state, opts)
  end

  @spec modules() :: [module()]
  def modules do
    [Screen, State, ViewState, RenderModel, Sync]
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      authoritative_server?: true,
      browser_authoritative?: false,
      shared_runtime_for_native_and_iur?: true
    }
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      screen_contract: :ready,
      server_state: :ready,
      view_state_generation: :ready,
      render_models: :ready,
      sync_envelopes: :ready
    }
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
