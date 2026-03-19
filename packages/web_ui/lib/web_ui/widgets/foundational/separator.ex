defmodule WebUi.Widgets.Foundational.Separator do
  @moduledoc """
  Native separator widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :separator

  @impl true
  def metadata, do: %{name: "Separator", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{}

  @impl true
  def render_server(_props, _opts) do
    {:safe, ~s(<hr class="webui-separator" />)}
  end

  @impl true
  def render_frontend(_props, _opts) do
    %{type: "separator"}
  end

  @impl true
  def default_state, do: %{}
end
