defmodule WebUi.Widgets.Foundational.Icon do
  @moduledoc """
  Native icon widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :icon

  @impl true
  def metadata, do: %{name: "Icon", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{name: {:atom, required: true}}

  @impl true
  def render_server(props, _opts) do
    {:safe, ~s(<i class="webui-icon icon-#{props[:name]}"></i>)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "icon", name: props[:name]}
  end

  @impl true
  def default_state, do: %{}
end
