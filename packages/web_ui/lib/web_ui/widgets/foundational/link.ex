defmodule WebUi.Widgets.Foundational.Link do
  @moduledoc """
  Native link widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :link

  @impl true
  def metadata, do: %{name: "Link", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{label: {:string, required: true}, target: {:string, required: true}}

  @impl true
  def render_server(props, _opts) do
    {:safe, ~s(<a href="#{props.target}" class="webui-link">#{props.label}</a>)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "link", label: props.label, target: props.target}
  end

  @impl true
  def default_state, do: %{}
end
