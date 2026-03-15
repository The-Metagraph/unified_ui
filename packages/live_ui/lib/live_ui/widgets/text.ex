defmodule LiveUi.Widgets.Text do
  @moduledoc """
  Baseline native text widget.
  """

  use LiveUi.Component, family: :content, name: :text, assigns: [:content]

  LiveUi.Component.common_attrs()
  attr(:content, :string, required: true)

  @impl true
  def render(assigns) do
    ~H"""
    <span id={@id} data-live-ui-widget="text" class={@class} {@rest}><%= @content %></span>
    """
  end
end
