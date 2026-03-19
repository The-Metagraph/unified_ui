defmodule WebUi.Widgets.Foundational.Label do
  @moduledoc """
  Native label widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :label

  @impl true
  def metadata, do: %{name: "Label", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{value: {:string, required: true}, html_for: {:string, default: nil}}

  @impl true
  def render_server(props, _opts) do
    for_attr = case Map.get(props, :html_for) do
      nil -> ""
      id -> ~s( for="#{id}")
    end

    {:safe, ~s(<label class="webui-label"#{for_attr}>#{props.value}</label>)}
  end

  @impl true
  def render_frontend(props, _opts) do
    %{type: "label", value: props.value, html_for: Map.get(props, :html_for)}
  end

  @impl true
  def default_state, do: %{}
end
