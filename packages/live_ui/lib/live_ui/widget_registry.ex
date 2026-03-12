defmodule LiveUi.WidgetRegistry do
  @moduledoc """
  Widget registry mapping normalized descriptor kinds to renderer families.
  """

  use Phoenix.Component

  alias LiveUi.Components.BasicWidgets
  alias LiveUi.Components.DataViz
  alias LiveUi.Components.Extensions
  alias LiveUi.Components.Feedback
  alias LiveUi.Components.Forms
  alias LiveUi.Components.Layouts
  alias LiveUi.Components.Navigation

  @kind_to_module %{
    "alert_dialog" => Feedback,
    "bar_chart" => DataViz,
    "button" => BasicWidgets,
    "canvas" => DataViz,
    "chart" => DataViz,
    "column" => Forms,
    "command" => Navigation,
    "command_palette" => Navigation,
    "context_menu" => Navigation,
    "dialog" => Feedback,
    "dialog_button" => Feedback,
    "form_builder" => Forms,
    "form_field" => Forms,
    "gauge" => DataViz,
    "grid" => Layouts,
    "hbox" => Layouts,
    "label" => BasicWidgets,
    "line_chart" => DataViz,
    "log_viewer" => Extensions,
    "menu" => Navigation,
    "menu_item" => Navigation,
    "pick_list" => Forms,
    "pick_list_option" => Forms,
    "process_monitor" => Extensions,
    "sparkline" => DataViz,
    "split_pane" => Layouts,
    "stack" => Layouts,
    "stream_widget" => Extensions,
    "tab" => Navigation,
    "table" => Forms,
    "tabs" => Navigation,
    "text" => BasicWidgets,
    "text_input" => BasicWidgets,
    "toast" => Feedback,
    "tree_node" => Navigation,
    "tree_view" => Navigation,
    "vbox" => Layouts,
    "viewport" => Layouts,
    "zbox" => Layouts
  }

  @spec supported_kinds() :: [String.t()]
  def supported_kinds do
    @kind_to_module |> Map.keys() |> Enum.sort()
  end

  @spec supported_kind?(String.t() | atom()) :: boolean()
  def supported_kind?(kind) do
    Map.has_key?(@kind_to_module, normalize_kind(kind))
  end

  @spec renderer_for(String.t() | atom()) :: {:ok, module()} | :error
  def renderer_for(kind) do
    Map.fetch(@kind_to_module, normalize_kind(kind))
  end

  attr(:descriptor, :map, required: true)

  def render(%{descriptor: nil} = assigns) do
    ~H"""
    <div class="live-ui-empty"></div>
    """
  end

  def render(assigns) do
    descriptor = Map.new(assigns.descriptor)
    kind = normalize_kind(Map.get(descriptor, :kind, Map.get(descriptor, "kind")))
    assigns = assign(assigns, :descriptor, Map.put(descriptor, :kind, kind))

    ~H"""
    <%= case renderer_for(@descriptor.kind) do %>
      <% {:ok, LiveUi.Components.BasicWidgets} -> %>
        <LiveUi.Components.BasicWidgets.render descriptor={@descriptor} />
      <% {:ok, LiveUi.Components.Layouts} -> %>
        <LiveUi.Components.Layouts.render descriptor={@descriptor} />
      <% {:ok, LiveUi.Components.DataViz} -> %>
        <LiveUi.Components.DataViz.render descriptor={@descriptor} />
      <% {:ok, LiveUi.Components.Navigation} -> %>
        <LiveUi.Components.Navigation.render descriptor={@descriptor} />
      <% {:ok, LiveUi.Components.Feedback} -> %>
        <LiveUi.Components.Feedback.render descriptor={@descriptor} />
      <% {:ok, LiveUi.Components.Forms} -> %>
        <LiveUi.Components.Forms.render descriptor={@descriptor} />
      <% {:ok, LiveUi.Components.Extensions} -> %>
        <LiveUi.Components.Extensions.render descriptor={@descriptor} />
      <% :error -> %>
        <% raise ConfigurationError.new("unsupported widget kind", %{kind: inspect(@descriptor.kind)}) %>
    <% end %>
    """
  end

  defp normalize_kind(kind) when is_atom(kind), do: kind |> Atom.to_string() |> normalize_kind()
  defp normalize_kind(kind) when is_binary(kind), do: kind |> String.trim() |> String.downcase()
  defp normalize_kind(_kind), do: ""
end
