defmodule WebUi.Server do
  @moduledoc """
  Package-facing entrypoint for the Phoenix server-side runtime boundary.
  """

  @type responsibility ::
          :authoritative_runtime_state
          | :frontend_coordination
          | :native_event_routing
          | :boundary_event_authority

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :authoritative_runtime_state,
      :frontend_coordination,
      :native_event_routing,
      :boundary_event_authority
    ]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
