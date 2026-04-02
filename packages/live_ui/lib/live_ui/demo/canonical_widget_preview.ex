defmodule LiveUi.Demo.CanonicalWidgetPreview do
  @moduledoc false

  alias UnifiedIUR.{Interaction, Layout, Layer}
  alias UnifiedIUR.Widgets.{Advanced, Data, Foundational, Input, Navigation}

  @spec element(map(), map() | nil, String.t()) :: UnifiedIUR.Element.t() | nil
  def element(%{id: id}, demo_state, id_base) when is_binary(id_base) do
    demo_state = LiveUi.Demo.WidgetPreviewState.ensure_defaults(demo_state)

    case id do
      :button -> button_preview(demo_state, id_base)
      :link -> link_preview(demo_state, id_base)
      :text_input -> text_input_preview(demo_state, id_base)
      :toggle -> toggle_preview(demo_state, id_base)
      :select -> select_preview(demo_state, id_base)
      :menu -> menu_preview(demo_state, id_base)
      :tabs -> tabs_preview(demo_state, id_base)
      :list -> list_preview(demo_state, id_base)
      :table -> table_preview(demo_state, id_base)
      :tree_view -> tree_preview(demo_state, id_base)
      :context_menu -> context_menu_preview(demo_state, id_base)
      :command_palette -> command_palette_preview(demo_state, id_base)
      _other -> nil
    end
  end

  defp button_preview(demo_state, id_base) do
    clicks = demo_state.button.clicks

    preview_column(
      [
        Foundational.button("Run Widget Action",
          id: sample_id(id_base, "button"),
          action: [intent: :widget_demo_button]
        ),
        preview_text("Clicks recorded: #{clicks}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp link_preview(demo_state, id_base) do
    clicks = demo_state.link.clicks

    preview_column(
      [
        Foundational.link("Trigger link interaction", "#",
          id: sample_id(id_base, "link"),
          interaction: Interaction.navigation(intent: :widget_demo_link)
        ),
        preview_text("Link activations: #{clicks}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp text_input_preview(demo_state, id_base) do
    value = demo_state.text_input.value

    preview_column(
      [
        Input.text_input(
          id: sample_id(id_base, "text-input"),
          name: "widget_name",
          value: value,
          placeholder: "Widget name",
          interaction:
            Interaction.change(
              intent: :widget_demo_text_input,
              binding: :widget_name
            )
        ),
        preview_text("Current value: #{value}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp toggle_preview(demo_state, id_base) do
    checked? = demo_state.toggle.checked

    preview_column(
      [
        Input.toggle(
          id: sample_id(id_base, "toggle"),
          name: "widget_enabled",
          value: checked?,
          interaction:
            Interaction.change(
              intent: :widget_demo_toggle,
              binding: :widget_enabled
            )
        ),
        preview_text("Toggle state: #{on_off(checked?)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp select_preview(demo_state, id_base) do
    current_value = demo_state.select.value

    preview_column(
      [
        Input.select(
          [
            %{id: "foundational", value: "foundational", label: "Foundational"},
            %{id: "display", value: "display", label: "Display", selected?: current_value == "display"},
            %{id: "overlay", value: "overlay", label: "Overlay"}
          ],
          id: sample_id(id_base, "select"),
          name: "widget_category",
          interaction:
            Interaction.change(
              intent: :widget_demo_select,
              binding: :widget_category
            )
        ),
        preview_text("Selected category: #{titleize(current_value)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp menu_preview(demo_state, id_base) do
    active_item = demo_state.menu.active

    preview_column(
      [
        Navigation.menu(
          [
            %{id: "overview", label: "Overview"},
            %{id: "insights", label: "Insights"},
            %{id: "settings", label: "Settings"}
          ],
          id: sample_id(id_base, "menu"),
          active_item: active_item,
          interaction: Interaction.click(intent: :widget_demo_menu)
        ),
        preview_text("Active item: #{titleize(active_item)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp tabs_preview(demo_state, id_base) do
    active_item = demo_state.tabs.active

    preview_column(
      [
        Navigation.tabs(
          [
            %{id: "surface", label: "Surface"},
            %{id: "state", label: "State"},
            %{id: "signals", label: "Signals"}
          ],
          id: sample_id(id_base, "tabs"),
          active_item: active_item,
          interaction: Interaction.selection(intent: :widget_demo_tabs)
        ),
        preview_text("Active tab: #{titleize(active_item)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp list_preview(demo_state, id_base) do
    selected_item = demo_state.list.selected

    preview_column(
      [
        Data.list(
          [
            %{
              id: "button",
              label: "Button",
              description: "Primary action surface",
              selected?: selected_item == "button"
            },
            %{
              id: "tabs",
              label: "Tabs",
              description: "Section navigation",
              selected?: selected_item == "tabs"
            },
            %{
              id: "toast",
              label: "Toast",
              description: "Transient feedback",
              selected?: selected_item == "toast"
            }
          ],
          id: sample_id(id_base, "list"),
          selection_mode: :single,
          interaction: Interaction.selection(intent: :widget_demo_list)
        ),
        preview_text("Selected row: #{titleize(selected_item)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp table_preview(demo_state, id_base) do
    selected_row = demo_state.table.selected

    preview_column(
      [
        Data.table(
          [
            %{id: "widget", label: "Widget"},
            %{id: "family", label: "Family"},
            %{id: "events", label: "Events"}
          ],
          [
            %{id: "button", cells: ["Button", "Content", "Click"], selected?: selected_row == "button"},
            %{id: "tabs", cells: ["Tabs", "Navigation", "Navigate"], selected?: selected_row == "tabs"},
            %{id: "toast", cells: ["Toast", "Overlay", "None"], selected?: selected_row == "toast"}
          ],
          id: sample_id(id_base, "table"),
          interaction: Interaction.selection(intent: :widget_demo_table)
        ),
        preview_text("Selected row: #{titleize(selected_row)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp tree_preview(demo_state, id_base) do
    selected_node = demo_state.tree_view.selected

    preview_column(
      [
        Data.tree_view(
          [
            %{
              id: "widgets",
              label: "Widgets",
              expanded?: true,
              children: [
                %{id: "content", label: "Content", selected?: selected_node == "content"},
                %{id: "overlay", label: "Overlay", selected?: selected_node == "overlay"}
              ]
            }
          ],
          id: sample_id(id_base, "tree-view"),
          selection_mode: :single,
          interaction: Interaction.selection(intent: :widget_demo_tree)
        ),
        preview_text("Selected node: #{titleize(selected_node)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp context_menu_preview(demo_state, id_base) do
    active_item = demo_state.context_menu.active

    preview_column(
      [
        Layer.context_menu(
          [
            %{id: "inspect", label: "Inspect"},
            %{id: "duplicate", label: "Duplicate"},
            %{id: "archive", label: "Archive"}
          ],
          id: sample_id(id_base, "context-menu"),
          active_item: active_item,
          anchor: %{x: 24, y: 24},
          interaction: Interaction.click(intent: :widget_demo_context_menu)
        ),
        preview_text("Selected action: #{titleize(active_item)}", sample_id(id_base, "status"))
      ],
      id_base
    )
  end

  defp command_palette_preview(demo_state, id_base) do
    query = demo_state.command_palette.query
    active_item = demo_state.command_palette.active

    preview_column(
      [
        Advanced.command_palette(
          [
            %{id: "widgets", label: "Open widgets", active: active_item == "widgets"},
            %{id: "workspace", label: "Toggle workspace", active: active_item == "workspace"},
            %{id: "validate", label: "Run validation", active: active_item == "validate"}
          ],
          id: sample_id(id_base, "command-palette"),
          query: query,
          active_command: active_item,
          interactions: [
            Interaction.change(
              intent: :widget_demo_command_query,
              binding: :command_query
            ),
            Interaction.selection(intent: :widget_demo_command_palette)
          ]
        ),
        preview_text(
          "Active command: #{titleize(active_item)} | Query: #{query}",
          sample_id(id_base, "status")
        )
      ],
      id_base
    )
  end

  defp preview_column(children, id_base) do
    Layout.column(children, id: sample_id(id_base, "column"), gap: :sm)
  end

  defp preview_text(text, id) do
    Foundational.text(text,
      id: id,
      style: %{foreground: "#cbd5e1"}
    )
  end

  defp sample_id(id_base, suffix), do: "#{id_base}-#{suffix}"

  defp on_off(true), do: "On"
  defp on_off(false), do: "Off"

  defp titleize(value) when is_binary(value) do
    value
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp titleize(value) when is_atom(value), do: value |> Atom.to_string() |> titleize()
  defp titleize(nil), do: "None"
end
