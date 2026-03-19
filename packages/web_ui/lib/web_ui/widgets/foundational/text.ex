defmodule WebUi.Widgets.Foundational.Text do
  @moduledoc """
  Native text widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :text

  @impl true
  def metadata, do: %{name: "Text", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{value: {:string, required: true}}

  @impl true
  def render_server(props, _opts) do
    {:safe, ~s(<span class="webui-text">#{props.value}</span>)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "text", value: props.value}
  end

  @impl true
  def default_state, do: %{}
end
