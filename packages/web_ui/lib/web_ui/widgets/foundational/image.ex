defmodule WebUi.Widgets.Foundational.Image do
  @moduledoc """
  Native image widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :image

  @impl true
  def metadata, do: %{name: "Image", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{source: {:string, required: true}, alt_text: {:string, default: ""}}

  @impl true
  def render_server(props, _opts) do
    alt = Map.get(props, :alt_text, "")
    {:safe, ~s(<img src="#{props.source}" alt="#{alt}" class="webui-image" />)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "image", source: props.source, alt_text: Map.get(props, :alt_text, "")}
  end

  @impl true
  def default_state, do: %{}
end
