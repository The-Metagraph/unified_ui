defmodule WebUi.Server.RenderModel do
  @moduledoc """
  Deterministic server-side render model generation for foundational `web_ui`
  widgets.
  """

  alias WebUi.Widget
  alias WebUi.Widgets

  @spec build(Widget.t()) :: map()
  def build(%Widget{} = widget) do
    semantics = build_semantics(widget)

    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      component: widget.kind,
      dom: %{
        tag: dom_tag(widget.kind),
        role: dom_role(widget.kind),
        attributes: dom_attributes(widget)
      },
      props: widget.props,
      state: widget.state,
      style_hooks: widget.style_hooks,
      events: widget.events,
      semantics: semantics,
      interactions: %{
        interactive?: widget.kind in interactive_kinds() or map_size(widget.events) > 0,
        focusable?: widget.kind in focusable_kinds(),
        editable?: widget.kind in editable_kinds(),
        navigable?: widget.kind in navigable_kinds()
      },
      slots: build_slots(widget.slots),
      diagnostics: %{
        event_names: widget.events |> Map.keys() |> Enum.sort(),
        slot_names: widget.slots |> Map.keys() |> Enum.map(&to_string/1) |> Enum.sort(),
        content_metrics: semantics.metrics
      }
    }
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    Widgets.kinds()
  end

  defp build_slots(slots) do
    slots
    |> Enum.sort_by(fn {slot, _children} -> to_string(slot) end)
    |> Enum.map(fn {slot, children} ->
      %{
        name: slot,
        children: children |> normalize_slot_children() |> Enum.map(&build/1)
      }
    end)
  end

  defp normalize_slot_children(nil), do: []
  defp normalize_slot_children(%Widget{} = widget), do: [widget]

  defp normalize_slot_children(children) when is_list(children) do
    case Widgets.normalize_many(children) do
      {:ok, widgets} -> widgets
      {:error, _reason} -> []
    end
  end

  defp dom_tag(:text), do: "span"
  defp dom_tag(:label), do: "label"
  defp dom_tag(:icon), do: "span"
  defp dom_tag(:image), do: "img"
  defp dom_tag(:button), do: "button"
  defp dom_tag(:link), do: "a"
  defp dom_tag(:separator), do: "hr"
  defp dom_tag(:spacer), do: "div"
  defp dom_tag(:content), do: "section"
  defp dom_tag(:text_input), do: "input"
  defp dom_tag(:checkbox), do: "input"
  defp dom_tag(:select), do: "select"
  defp dom_tag(:menu), do: "nav"
  defp dom_tag(:tabs), do: "div"
  defp dom_tag(:row), do: "div"
  defp dom_tag(:column), do: "div"
  defp dom_tag(:form_builder), do: "form"
  defp dom_tag(:field_group), do: "fieldset"
  defp dom_tag(:field), do: "div"
  defp dom_tag(:table), do: "table"
  defp dom_tag(:tree_view), do: "ul"
  defp dom_tag(:markdown_viewer), do: "article"
  defp dom_tag(:log_viewer), do: "pre"
  defp dom_tag(:status), do: "output"
  defp dom_tag(:progress), do: "progress"
  defp dom_tag(:inline_feedback), do: "aside"
  defp dom_tag(:gauge), do: "meter"
  defp dom_tag(:sparkline), do: "canvas"
  defp dom_tag(:bar_chart), do: "canvas"
  defp dom_tag(:line_chart), do: "canvas"
  defp dom_tag(:canvas), do: "canvas"
  defp dom_tag(:stream_widget), do: "section"
  defp dom_tag(:process_monitor), do: "section"
  defp dom_tag(:cluster_dashboard), do: "section"
  defp dom_tag(:command_palette), do: "section"
  defp dom_tag(:supervision_tree_viewer), do: "ul"
  defp dom_tag(_kind), do: "div"

  defp dom_role(:text), do: "text"
  defp dom_role(:label), do: "label"
  defp dom_role(:button), do: "button"
  defp dom_role(:link), do: "link"
  defp dom_role(:text_input), do: "textbox"
  defp dom_role(:checkbox), do: "checkbox"
  defp dom_role(:select), do: "listbox"
  defp dom_role(:menu), do: "navigation"
  defp dom_role(:tabs), do: "tablist"
  defp dom_role(:row), do: "group"
  defp dom_role(:column), do: "group"
  defp dom_role(:form_builder), do: "form"
  defp dom_role(:field_group), do: "group"
  defp dom_role(:field), do: "group"
  defp dom_role(:table), do: "table"
  defp dom_role(:tree_view), do: "tree"
  defp dom_role(:markdown_viewer), do: "document"
  defp dom_role(:log_viewer), do: "log"
  defp dom_role(:status), do: "status"
  defp dom_role(:progress), do: "progressbar"
  defp dom_role(:inline_feedback), do: "alert"
  defp dom_role(:gauge), do: "meter"
  defp dom_role(:sparkline), do: "img"
  defp dom_role(:bar_chart), do: "img"
  defp dom_role(:line_chart), do: "img"
  defp dom_role(:canvas), do: "graphics-document"
  defp dom_role(:stream_widget), do: "feed"
  defp dom_role(:process_monitor), do: "region"
  defp dom_role(:cluster_dashboard), do: "region"
  defp dom_role(:command_palette), do: "combobox"
  defp dom_role(:supervision_tree_viewer), do: "tree"
  defp dom_role(_kind), do: "presentation"

  defp dom_attributes(%Widget{} = widget) do
    %{
      id: widget.id,
      class_tokens: Enum.map(widget.style_hooks, &to_string/1),
      disabled: Map.get(widget.state, :disabled?, false)
    }
    |> maybe_put(:href, Map.get(widget.props, :href))
    |> maybe_put(:value, Map.get(widget.props, :value))
    |> maybe_put(:name, Map.get(widget.props, :name))
    |> maybe_put(:for, Map.get(widget.props, :for))
    |> maybe_put(:placeholder, Map.get(widget.props, :placeholder))
    |> maybe_put(:orientation, Map.get(widget.props, :orientation))
    |> maybe_put(:active_item, Map.get(widget.props, :active_item))
    |> maybe_put(:selection_mode, Map.get(widget.props, :selection_mode))
    |> maybe_put(:sort_key, get_in(widget.props, [:sorting, :key]))
    |> maybe_put(:sort_direction, get_in(widget.props, [:sorting, :direction]))
    |> maybe_put(:page, get_in(widget.props, [:pagination, :page]))
    |> maybe_put(:page_size, get_in(widget.props, [:pagination, :page_size]))
    |> maybe_put(:query, Map.get(widget.props, :query))
    |> maybe_put(:severity, Map.get(widget.props, :severity))
    |> maybe_put(:status, Map.get(widget.props, :status))
    |> maybe_put(:current, Map.get(widget.props, :current))
    |> maybe_put(:total, Map.get(widget.props, :total))
    |> maybe_put(:metric_value, Map.get(widget.props, :value))
    |> maybe_put(:width, Map.get(widget.props, :width))
    |> maybe_put(:height, Map.get(widget.props, :height))
  end

  defp interactive_kinds do
    [
      :button,
      :link,
      :text_input,
      :checkbox,
      :select,
      :menu,
      :tabs,
      :form_builder,
      :table,
      :tree_view,
      :log_viewer,
      :stream_widget,
      :process_monitor,
      :command_palette,
      :supervision_tree_viewer
    ]
  end

  defp focusable_kinds do
    [
      :button,
      :link,
      :text_input,
      :checkbox,
      :select,
      :menu,
      :tabs,
      :table,
      :tree_view,
      :log_viewer,
      :command_palette,
      :supervision_tree_viewer
    ]
  end

  defp editable_kinds do
    [:text_input, :checkbox, :select, :command_palette]
  end

  defp navigable_kinds do
    [:link, :menu, :tabs, :tree_view, :command_palette, :supervision_tree_viewer]
  end

  defp build_semantics(%Widget{} = widget) do
    %{
      selection_mode: Map.get(widget.props, :selection_mode),
      sorting: empty_map_to_nil(Map.get(widget.props, :sorting, %{})),
      filters: Map.get(widget.props, :filters, []),
      pagination: empty_map_to_nil(Map.get(widget.props, :pagination, %{})),
      metrics: content_metrics(widget),
      capabilities: %{
        document?: widget.family == :document,
        data_view?: widget.family in [:data, :document],
        visual?: widget.family == :visualization,
        diagnostic?: widget.family == :operational
      }
    }
  end

  defp content_metrics(%Widget{kind: :table, props: props}) do
    %{columns: length(Map.get(props, :columns, [])), rows: length(Map.get(props, :rows, []))}
  end

  defp content_metrics(%Widget{kind: kind, props: props})
       when kind in [:tree_view, :supervision_tree_viewer] do
    %{nodes: count_tree_nodes(Map.get(props, :nodes, []))}
  end

  defp content_metrics(%Widget{kind: :markdown_viewer, props: props}) do
    source = Map.get(props, :source, "")
    %{anchors: length(Map.get(props, :anchors, [])), characters: String.length(source)}
  end

  defp content_metrics(%Widget{kind: kind, props: props})
       when kind in [:log_viewer, :stream_widget] do
    %{entries: length(Map.get(props, :entries, []))}
  end

  defp content_metrics(%Widget{kind: :process_monitor, props: props}) do
    %{processes: length(Map.get(props, :processes, []))}
  end

  defp content_metrics(%Widget{kind: :cluster_dashboard, props: props}) do
    %{nodes: length(Map.get(props, :nodes, []))}
  end

  defp content_metrics(%Widget{kind: :command_palette, props: props}) do
    %{commands: length(Map.get(props, :commands, []))}
  end

  defp content_metrics(%Widget{kind: kind, props: props})
       when kind in [:sparkline, :bar_chart, :line_chart] do
    %{series: length(Map.get(props, :series, []))}
  end

  defp content_metrics(%Widget{kind: :canvas, props: props}) do
    %{operations: length(Map.get(props, :operations, []))}
  end

  defp content_metrics(%Widget{kind: kind, props: props})
       when kind in [:status, :inline_feedback] do
    %{characters: props |> Map.values() |> Enum.find("", &is_binary/1) |> String.length()}
  end

  defp content_metrics(%Widget{kind: kind, props: props}) when kind in [:progress, :gauge] do
    %{
      current: Map.get(props, :current, Map.get(props, :value)),
      total: Map.get(props, :total, Map.get(props, :max))
    }
  end

  defp content_metrics(_widget), do: %{}

  defp count_tree_nodes(nodes) when is_list(nodes) do
    Enum.reduce(nodes, 0, fn node, acc ->
      acc + 1 + count_tree_nodes(Map.get(node, :children, []))
    end)
  end

  defp count_tree_nodes(_other), do: 0

  defp empty_map_to_nil(map) when map in [%{}, nil], do: nil
  defp empty_map_to_nil(map), do: map

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
