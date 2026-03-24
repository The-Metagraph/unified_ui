defmodule DesktopUi.Examples do
  @moduledoc """
  Maintained foundational native and canonical examples for `desktop_ui`.
  """

  alias UnifiedIUR.Element

  @spec native_foundational_screen() :: map()
  def native_foundational_screen do
    %{
      id: "workspace-foundation",
      title: "Native Foundational Workspace",
      root:
        DesktopUi.Widgets.window("workspace-window", "Workspace", [
          DesktopUi.Widgets.column("workspace-layout", [
            DesktopUi.Widgets.content("workspace-header", [
              DesktopUi.Widgets.icon("workspace-icon", :workspace),
              DesktopUi.Widgets.label("workspace-label", "Workspace"),
              DesktopUi.Widgets.text("workspace-title", "Desktop Workspace")
            ]),
            DesktopUi.Widgets.text_input("query-input",
              value: "status:ok",
              binding: :query,
              placeholder: "Search workspace",
              on_submit: %{intent: :run_query}
            ),
            DesktopUi.Widgets.checkbox("alerts-toggle", "Alerts",
              checked: true,
              binding: :alerts_enabled
            ),
            DesktopUi.Widgets.tabs(
              "workspace-tabs",
              [
                %{id: :overview, label: "Overview"},
                %{id: :activity, label: "Activity"}
              ],
              current: :overview,
              binding: :section
            ),
            DesktopUi.Widgets.list(
              "workspace-results",
              [
                %{id: :alpha, label: "Alpha"},
                %{id: :beta, label: "Beta"}
              ],
              current: :alpha,
              binding: :selected_result
            ),
            DesktopUi.Widgets.row("workspace-actions", [
              DesktopUi.Widgets.command("refresh-command", "Refresh",
                shortcut: "Cmd+R",
                intent: :refresh_workspace
              ),
              DesktopUi.Widgets.button("save-button", "Save", intent: :save_workspace)
            ])
          ])
        ]),
      metadata: %{
        example_id: :native_foundational,
        source: :native,
        coverage: [
          :content_widgets,
          :action_widgets,
          :form_widgets,
          :navigation_widgets,
          :shared_runtime
        ],
        advanced_extensions: [:advanced_widgets, :transport_translation, :platform_artifacts]
      }
    }
  end

  @spec canonical_foundational_screen() :: Element.t()
  def canonical_foundational_screen do
    Element.new(:layout, :column,
      id: "workspace-layout",
      attributes: %{gap: 16},
      children: [
        Element.new(:widget, :content,
          id: "workspace-header",
          children: [
            Element.new(:widget, :icon,
              id: "workspace-icon",
              attributes: %{icon: :workspace, fallback_text: "[workspace]"}
            ),
            Element.new(:widget, :label,
              id: "workspace-label",
              attributes: %{content: "Workspace"}
            ),
            Element.new(:widget, :text,
              id: "workspace-title",
              attributes: %{content: "Desktop Workspace"}
            )
          ]
        ),
        Element.new(:widget, :text_input,
          id: "query-input",
          attributes: %{
            value: "status:ok",
            placeholder: "Search workspace",
            binding: %{name: :query, value: "status:ok"},
            interaction: %{family: :submit, intent: :run_query}
          }
        ),
        Element.new(:widget, :checkbox,
          id: "alerts-toggle",
          attributes: %{
            label: "Alerts",
            checked: true,
            binding: %{name: :alerts_enabled, value: true},
            interaction: %{family: :change, intent: :toggle_alerts}
          }
        ),
        Element.new(:widget, :tabs,
          id: "workspace-tabs",
          attributes: %{
            items: [
              %{id: :overview, label: "Overview"},
              %{id: :activity, label: "Activity"}
            ],
            current: :overview,
            binding: %{name: :section, value: :overview},
            interaction: %{family: :navigation, intent: :switch_section}
          }
        ),
        Element.new(:widget, :list,
          id: "workspace-results",
          attributes: %{
            items: [
              %{id: :alpha, label: "Alpha"},
              %{id: :beta, label: "Beta"}
            ],
            current: :alpha,
            binding: %{name: :selected_result, value: :alpha},
            interaction: %{family: :selection, intent: :select_result}
          }
        ),
        Element.new(:layout, :row,
          id: "workspace-actions",
          children: [
            Element.new(:widget, :command,
              id: "refresh-command",
              attributes: %{
                label: "Refresh",
                shortcut: "Cmd+R",
                interaction: %{family: :command, intent: :refresh_workspace}
              }
            ),
            Element.new(:widget, :button,
              id: "save-button",
              attributes: %{
                label: "Save",
                interaction: %{family: :click, intent: :save_workspace}
              }
            )
          ]
        )
      ]
    )
  end

  @spec foundational_comparison() :: map()
  def foundational_comparison do
    native_screen = native_foundational_screen()
    canonical_screen = canonical_foundational_screen()

    {:ok, native_state} =
      DesktopUi.Runtime.mount_native_screen(native_screen, platform_target: :linux)

    {:ok, canonical_state} =
      DesktopUi.Runtime.mount_iur_screen(canonical_screen, platform_target: :linux)

    %{
      id: :foundational_continuity,
      native_example_id: native_screen.metadata.example_id,
      canonical_example_id: :canonical_foundational,
      coverage: %{
        widget_families: [:content, :action, :input, :navigation, :layout, :window],
        display_constructs: [:column, :row, :content],
        advanced_extensions: native_screen.metadata.advanced_extensions
      },
      parity: %{
        shared_runtime_backbone?:
          native_state.realization.mode == canonical_state.realization.mode,
        focus_order_match?:
          trim_focus_order(native_state.focus.order) ==
            trim_focus_order(canonical_state.focus.order),
        body_kind_sequence_match?:
          body_kind_sequence(native_state.realization.tree) ==
            body_kind_sequence(canonical_state.realization.tree),
        binding_names_match?:
          native_state.screen.bindings.names == canonical_state.screen.bindings.names
      },
      native: native_state.realization,
      canonical: canonical_state.realization
    }
  end

  @spec native_ids() :: [atom()]
  def native_ids, do: [:native_foundational]

  @spec canonical_ids() :: [atom()]
  def canonical_ids, do: [:canonical_foundational]

  @spec comparison_ids() :: [atom()]
  def comparison_ids, do: [:foundational_continuity]

  defp trim_focus_order(ids) do
    Enum.reject(ids, &(&1 == "workspace-window"))
  end

  defp body_kind_sequence(tree) do
    tree
    |> root_for_sequence()
    |> flatten_kinds([])
  end

  defp flatten_kinds(node, acc) do
    Enum.reduce(Map.get(node, :children, []), acc ++ [node.kind], &flatten_kinds(&1, &2))
  end

  defp root_for_sequence(%{kind: :window, children: [child | _rest]}), do: child
  defp root_for_sequence(tree), do: tree
end
