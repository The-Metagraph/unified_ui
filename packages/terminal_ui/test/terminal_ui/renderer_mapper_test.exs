defmodule TerminalUi.RendererMapperTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Renderer
  alias UnifiedIUR.{Binding, Canvas, Element, Forms, Interaction, Layer, Layout}
  alias UnifiedIUR.Style
  alias UnifiedIUR.Widgets.{Advanced, Data, Feedback, Foundational, Input, Navigation}

  test "canonical foundational screens map into the native widget surface" do
    element =
      Layout.column(
        [
          Foundational.text("Workspace", id: "title"),
          Input.text_input(
            id: "query",
            placeholder: "Filter",
            binding: %{name: :query, value: "status:ok"},
            interaction: Interaction.submit(intent: :run_query)
          ),
          Foundational.button(
            "Save",
            id: "save",
            interaction: Interaction.click(intent: :save_workspace)
          ),
          Navigation.tabs(
            [%{id: :overview, label: "Overview"}, %{id: :details, label: "Details"}],
            id: "sections",
            active_item: :overview,
            binding: Binding.new(name: :active_section, value: :overview),
            interaction: Interaction.navigation(intent: :switch_section)
          )
        ],
        id: "screen",
        gap: :md
      )

    assert {:ok, widget} = Renderer.render(element)
    assert widget.kind == :column
    assert Enum.map(widget.children, & &1.kind) == [:text, :text_input, :button, :tabs]
    assert Enum.at(widget.children, 1).bindings == %{value: :query}
    assert Enum.at(widget.children, 2).events == %{keypress: %{intent: :save_workspace}}
    assert Enum.at(widget.children, 3).bindings == %{current: :active_section}
  end

  test "canonical renderer realizes CSS-derived style without parsing authored CSS" do
    element =
      Element.new(:widget, :text,
        id: "css-copy",
        attributes: %{
          content: "CSS-derived",
          style:
            Style.new(%{
              foreground: "#2563eb",
              background: "#eff6ff",
              border_color: "#1d4ed8",
              text: %{underline?: true},
              spacing: %{padding_top: "4px"},
              state_variants: %{focused: %{foreground: "#ffffff"}},
              extra: %{
                css: %{
                  properties: ["color"],
                  declarations: [%{selector: "#css-copy", property: "color"}]
                }
              }
            })
        }
      )

    assert {:ok, widget} = Renderer.render(element)

    assert widget.styles.fg == "#2563eb"
    assert widget.styles.bg == "#eff6ff"
    assert widget.styles.border == %{color: "#1d4ed8"}
    assert widget.styles.attrs == [:underline]
    assert widget.styles.padding == %{padding_top: "4px"}
    assert widget.styles.state_variants.focused.fg == "#ffffff"
    refute Map.has_key?(widget.styles, :css)
    refute inspect(widget.styles) =~ "declarations"
  end

  test "canonical screens mount through the same runtime realization model as native screens" do
    element =
      Layout.column(
        [
          Foundational.text("Workspace", id: "title"),
          Input.checkbox(
            id: "enabled",
            label_text: "Enabled",
            binding: %{name: :enabled, value: true},
            interaction: Interaction.change(intent: :toggle_enabled)
          ),
          Navigation.menu(
            [%{id: :home, label: "Home"}, %{id: :jobs, label: "Jobs"}],
            id: "menu",
            active_item: :home,
            binding: %{name: :current_menu, value: :home},
            interaction: Interaction.selection(intent: :select_menu)
          )
        ],
        id: "workspace"
      )

    assert {:ok, runtime_state} = TerminalUi.Runtime.mount_iur_screen(element, backend_mode: :raw)
    assert runtime_state.source_kind == :canonical
    assert runtime_state.root.kind == :column
    assert runtime_state.realization.validation_state == :foundational_ready

    assert runtime_state.realization.binding_index[:enabled] == [
             %{widget_id: "enabled", slot: :checked}
           ]

    assert runtime_state.realization.binding_index[:current_menu] == [
             %{widget_id: "menu", slot: :current}
           ]
  end

  test "unsupported canonical constructs and invalid bindings fail deterministically" do
    unsupported = Element.new(:widget, :calendar, id: "calendar")

    assert {:error, %TerminalUi.Renderer.Error{} = unsupported_error} =
             Renderer.render(unsupported)

    assert unsupported_error.reason == :unsupported_canonical_construct

    invalid_binding =
      Element.new(:widget, :text_input,
        id: "query",
        attributes: %{bindings: [%{invalid: true}]}
      )

    assert {:error, %TerminalUi.Renderer.Error{} = binding_error} =
             Renderer.render(invalid_binding)

    assert binding_error.reason == :invalid_canonical_bindings
  end

  test "advanced canonical widgets and layering reuse the native terminal surface" do
    element =
      Layer.overlay(
        Layout.split_pane(
          Layout.scroll_region(
            Data.table(
              [
                %{id: :service, label: "Service"},
                %{id: :status, label: "Status"}
              ],
              [
                %{id: :api, cells: ["API", "healthy"]},
                %{id: :worker, cells: ["Worker", "degraded"]}
              ],
              id: "ops-table",
              interaction: Interaction.selection(intent: :select_service)
            ),
            id: "ops-viewport",
            offset: 8
          ),
          Layout.column(
            [
              Advanced.command_palette(
                [
                  %{id: :reload, label: "Reload", value: :reload},
                  %{id: :restart, label: "Restart", value: :restart}
                ],
                id: "ops-palette",
                binding: %{name: :command_query, value: "re"},
                interaction: Interaction.command(intent: :run_command, command: :reload)
              ),
              Canvas.surface(
                [
                  %{kind: :cell, position: {0, 0}, text: "A"},
                  %{kind: :cell, position: {1, 0}, text: "B"}
                ],
                id: "ops-canvas",
                width: 20,
                height: 8
              ),
              Feedback.progress(id: "sync-progress", current: 3, total: 5, label: "Sync"),
              Advanced.cluster_dashboard(
                [
                  %{id: :node_a, status: :healthy},
                  %{id: :node_b, status: :degraded}
                ],
                id: "cluster-dashboard"
              )
            ],
            id: "ops-sidebar"
          ),
          id: "ops-split",
          ratio: 0.65
        ),
        [
          Layer.dialog(Foundational.text("Preferences", id: "dialog-copy"), id: "prefs-dialog"),
          Layer.context_menu(
            [%{id: :open_logs, label: "Open Logs"}, %{id: :restart, label: "Restart"}],
            id: "workspace-menu"
          )
        ],
        id: "workspace-overlay"
      )

    assert {:ok, widget} = Renderer.render(element)
    assert widget.kind == :overlay
    assert widget.slot_children.base |> List.first() |> Map.get(:kind) == :split_pane
    assert Enum.map(widget.slot_children.overlay, & &1.kind) == [:dialog, :context_menu]

    split_pane = widget.slot_children.base |> List.first()
    assert split_pane.slot_children.primary |> List.first() |> Map.get(:kind) == :viewport
    assert split_pane.slot_children.secondary |> List.first() |> Map.get(:kind) == :column

    sidebar = split_pane.slot_children.secondary |> List.first()

    assert Enum.map(sidebar.children, & &1.kind) == [
             :command_palette,
             :canvas,
             :progress,
             :cluster_dashboard
           ]

    assert Enum.at(sidebar.children, 0).bindings == %{query: :command_query}
  end

  test "canonical form controls and grouped fields map into the native form surface" do
    element =
      Forms.form_builder(
        [
          Forms.field_group(
            [
              Forms.field(
                Input.date_input(id: "start-date", name: :start_date),
                id: "date-field",
                label: "Start Date"
              ),
              Forms.field(
                Input.time_input(id: "start-time", name: :start_time),
                id: "time-field",
                label: "Start Time"
              ),
              Forms.field(
                Input.file_input(id: "avatar-file", name: :avatar, accept: [".png"]),
                id: "file-field",
                label: "Avatar"
              ),
              Forms.field(
                Input.pick_list(
                  [
                    %{id: :logs, label: "Logs", value: :logs},
                    %{id: :metrics, label: "Metrics", value: :metrics}
                  ],
                  id: "artifacts",
                  name: :artifacts
                ),
                id: "artifacts-field",
                label: "Artifacts"
              ),
              Forms.field(
                Input.slider(id: "volume-slider", name: :volume, value: 6),
                id: "volume-field",
                label: "Volume"
              )
            ],
            id: "schedule-group",
            legend: "Schedule"
          )
        ],
        id: "schedule-form",
        mode: :grouped,
        submit_intent: :save_schedule
      )

    assert {:ok, widget} = Renderer.render(element)
    assert widget.kind == :form_builder
    assert widget.attributes.mode == :grouped

    group = List.first(widget.children)
    assert group.kind == :field_group
    assert group.attributes.legend == "Schedule"

    assert Enum.map(group.children, & &1.kind) == [:field, :field, :field, :field, :field]

    assert Enum.map(group.children, fn field ->
             field.slot_children.control |> List.first() |> Map.get(:kind)
           end) == [:date_input, :time_input, :file_input, :pick_list, :slider]
  end

  test "advanced canonical screens mount through the same runtime with explicit terminal fallbacks" do
    element =
      Layer.overlay(
        Layout.split_pane(
          Layout.scroll_region(
            Data.tree_view(
              [
                %{
                  id: :root,
                  label: "Cluster",
                  expanded?: true,
                  children: [%{id: :api, label: "API"}]
                }
              ],
              id: "service-tree",
              interaction: Interaction.selection(intent: :select_service)
            ),
            id: "service-viewport",
            offset: 4
          ),
          Layout.column(
            [
              Canvas.surface(
                [
                  %{kind: :cell, position: {0, 0}, text: "X"},
                  %{kind: :cell, position: {1, 0}, text: "Y"}
                ],
                id: "topology-canvas",
                width: 12,
                height: 6
              ),
              Advanced.log_viewer(
                [%{id: "log-1", message: "Booted", severity: :info}],
                id: "cluster-log"
              )
            ],
            id: "cluster-sidebar"
          ),
          id: "cluster-split"
        ),
        [
          Layer.toast(Foundational.text("Saved", id: "save-copy"), id: "save-toast"),
          Layer.context_menu([%{id: :inspect, label: "Inspect"}], id: "cluster-menu")
        ],
        id: "cluster-overlay"
      )

    assert {:ok, runtime_state} = TerminalUi.Runtime.mount_iur_screen(element, backend_mode: :tty)
    assert runtime_state.source_kind == :canonical
    assert runtime_state.root.kind == :overlay
    assert runtime_state.validation_state == :advanced_runtime_ready
    assert runtime_state.realization.validation_state == :advanced_ready
    assert runtime_state.realization.diagnostics.capability_profile == :fallback_terminal

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "cluster-overlay" and fallback.fallback == :inline_overlay
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "service-viewport" and fallback.fallback == :paged_scroll
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "topology-canvas" and fallback.fallback == :ascii_canvas
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "cluster-menu" and fallback.fallback == :inline_menu_selection
           end)
  end

  test "missing advanced canonical layer slots fail with deterministic diagnostics" do
    broken_overlay = Element.new(:layer, :overlay, id: "broken-overlay")

    assert {:error, %TerminalUi.Renderer.Error{} = error} = Renderer.render(broken_overlay)

    assert error.reason == :unsupported_canonical_construct
    assert error.details.id == "broken-overlay"
    assert error.details.missing_slots == [:base]
  end
end
