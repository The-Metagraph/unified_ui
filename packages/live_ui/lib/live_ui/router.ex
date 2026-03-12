defmodule LiveUi.Router do
  @moduledoc """
  Tiny route helpers for host Phoenix routers.
  """

  alias LiveUi.Live.DynamicLive

  @spec screen(module()) :: module()
  def screen(wrapper_module) when is_atom(wrapper_module), do: wrapper_module

  @spec dynamic_live() :: module()
  def dynamic_live, do: DynamicLive
end
