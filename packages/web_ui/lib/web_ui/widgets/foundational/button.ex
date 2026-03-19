defmodule WebUi.Widgets.Foundational.Button do
  @moduledoc """
  Native button widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :button

  @impl true
  def metadata, do: %{name: "Button", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{label: {:string, required: true}}

  @impl true
  def render_server(props, _opts) do
    {:safe, ~s(<button class="webui-button">#{props.label}</button>)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "button", label: props.label}
  end

  @impl true
  def default_state, do: %{}

  @impl true
  def handle_event(:handle_click, _payload, assigns), do: {:ok, assigns}
end
