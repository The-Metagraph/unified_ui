defmodule WebUi.Widgets.Foundational.Spacer do
  @moduledoc """
  Native spacer widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :spacer

  @impl true
  def metadata, do: %{name: "Spacer", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{size: {:atom, default: :md}}

  @impl true
  def render_server(props, _opts) do
    size_map = %{xs: "4px", sm: "8px", md: "16px", lg: "24px"}
    size = Map.get(size_map, Map.get(props, :size, :md), "16px")

    {:safe, ~s(<div class="webui-spacer" style="min-height: #{size};"></div>)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "spacer", size: Map.get(props, :size, :md)}
  end

  @impl true
  def default_state, do: %{}
end
