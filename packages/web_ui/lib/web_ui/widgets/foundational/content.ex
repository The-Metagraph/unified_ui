defmodule WebUi.Widgets.Foundational.Content do
  @moduledoc """
  Native content container widget for web_ui.
  """

  use WebUi.Widgets.Native.Widget

  @impl true
  def id, do: :content

  @impl true
  def metadata, do: %{name: "Content", family: :foundational, version: "1.0.0"}

  @impl true
  def props_schema, do: %{}

  @impl true
  def render_server(_props, opts) do
    children = Keyword.get(opts, :children, [])

    children_html =
      Enum.map_join(children, "\n", fn
        {:safe, html} -> html
        text when is_binary(text) -> text
        _ -> ""
      end)

    {:safe, ~s(<div class="webui-content">#{children_html}</div>)}
  end

  @impl true
  def render_frontend(_props, _opts) do
    %{type: "content"}
  end

  @impl true
  def default_state, do: %{}
end
