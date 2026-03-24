defmodule DesktopUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint placeholder for `desktop_ui`.
  """

  alias DesktopUi.Renderer.Error
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

  @spec render(Element.t(), keyword()) :: {:ok, DesktopUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, _opts \\ []) do
    {:error,
     Error.new(:canonical_rendering_not_ready, %{
       kind: element.kind,
       section: :"1.2",
       reason: :phase_one_runtime_backbone_only
     })}
  end
end
