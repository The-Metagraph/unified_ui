defmodule DesktopUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint placeholder for `desktop_ui`.
  """

  alias UnifiedIUR.Element

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [
      :accept_canonical_iur,
      :reuse_native_runtime_model,
      :prepare_for_desktop_widget_mapping
    ]
  end

  @spec validation_state() :: atom()
  def validation_state, do: :entrypoint_ready
end
