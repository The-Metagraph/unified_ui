defmodule TerminalUi.Examples do
  @moduledoc """
  Maintained foundational native and canonical examples for `terminal_ui`.
  """

  alias UnifiedIUR.{Interaction, Layout}
  alias UnifiedIUR.Widgets.{Data, Foundational, Input, Navigation}

  @spec native_foundational_screen() :: map()
  def native_foundational_screen do
    %{
      id: "workspace-foundation",
      title: "Native Foundational Workspace",
      root:
        TerminalUi.Widgets.column("workspace-foundation", [
          TerminalUi.Widgets.text("workspace-title", "Workspace"),
          TerminalUi.Widgets.text_input("query", value: "status:ok", binding: :query),
          TerminalUi.Widgets.checkbox("alerts", "Alerts", checked: true, binding: :alerts),
          TerminalUi.Widgets.tabs(
            "sections",
            [
              %{id: :overview, label: "Overview"},
              %{id: :activity, label: "Activity"}
            ], current: :overview, binding: :section),
          TerminalUi.Widgets.list(
            "results",
            [
              %{id: :alpha, label: "Alpha"},
              %{id: :beta, label: "Beta"}
            ], current: :alpha, binding: :selected_result),
          TerminalUi.Widgets.button("save", "Save", on_press: %{intent: :save_workspace})
        ]),
      metadata: %{
        example_id: :native_foundational,
        source: :native,
        coverage: [:foundational_widgets, :native_runtime, :focus_traversal]
      }
    }
  end

  @spec canonical_foundational_screen() :: UnifiedIUR.Element.t()
  def canonical_foundational_screen do
    Layout.column(
      [
        Foundational.text("Workspace", id: "workspace-title"),
        Input.text_input(
          id: "query",
          value: "status:ok",
          binding: %{name: :query, value: "status:ok"},
          interaction: Interaction.submit(intent: :run_query)
        ),
        Input.checkbox(
          id: "alerts",
          label_text: "Alerts",
          checked?: true,
          binding: %{name: :alerts, value: true},
          interaction: Interaction.change(intent: :toggle_alerts)
        ),
        Navigation.tabs(
          [
            %{id: :overview, label: "Overview"},
            %{id: :activity, label: "Activity"}
          ],
          id: "sections",
          active_item: :overview,
          binding: %{name: :section, value: :overview},
          interaction: Interaction.navigation(intent: :switch_section)
        ),
        Data.list(
          [
            %{id: :alpha, label: "Alpha", selected?: true},
            %{id: :beta, label: "Beta"}
          ],
          id: "results",
          binding: %{name: :selected_result, value: :alpha},
          interaction: Interaction.selection(intent: :select_result)
        ),
        Foundational.button(
          "Save",
          id: "save",
          interaction: Interaction.click(intent: :save_workspace)
        )
      ],
      id: "workspace-foundation",
      gap: :md
    )
  end

  @spec native_examples() :: [map()]
  def native_examples do
    [
      %{
        id: :native_foundational,
        mode: :native,
        summary: "Direct-native foundational workspace screen",
        coverage: [:foundational_widgets, :native_runtime, :focus_traversal],
        categories: [:content, :forms, :navigation, :actions],
        artifact: native_foundational_screen()
      }
    ]
  end

  @spec canonical_examples() :: [map()]
  def canonical_examples do
    [
      %{
        id: :canonical_foundational,
        mode: :canonical,
        summary: "Canonical foundational workspace screen",
        coverage: [:canonical_renderer, :shared_realization, :bindings],
        categories: [:content, :forms, :navigation, :actions],
        artifact: canonical_foundational_screen()
      }
    ]
  end

  @spec comparison_examples() :: map()
  def comparison_examples do
    %{
      foundational_continuity: foundational_comparison()
    }
  end

  @spec coverage_matrix() :: map()
  def coverage_matrix do
    %{
      categories: %{
        content: [:text],
        forms: [:text_input, :checkbox],
        navigation: [:tabs, :list],
        actions: [:button]
      },
      workflows: %{
        foundational_review: [:native_foundational, :canonical_foundational],
        parity_review: [:foundational_continuity]
      },
      parity_groups: %{
        foundational_workspace: [
          :native_foundational,
          :canonical_foundational,
          :foundational_continuity
        ]
      }
    }
  end

  @spec foundational_comparison() :: map()
  def foundational_comparison do
    {:ok, native_state} =
      TerminalUi.Runtime.mount_native_screen(native_foundational_screen(), backend_mode: :raw)

    {:ok, canonical_state} =
      TerminalUi.Runtime.mount_iur_screen(canonical_foundational_screen(), backend_mode: :raw)

    native_summary = runtime_summary(native_state)
    canonical_summary = runtime_summary(canonical_state)

    %{
      id: :foundational_continuity,
      summary: "Compare native and canonical foundational rendering",
      coverage: [:comparison_artifact, :canonical_renderer, :shared_realization],
      native: native_summary,
      canonical: canonical_summary,
      parity: %{
        focus_order_match?: native_summary.focus_order == canonical_summary.focus_order,
        cell_surface_kinds_match?:
          native_summary.cell_surface_kinds == canonical_summary.cell_surface_kinds,
        shared_runtime_backbone?:
          native_summary.validation_state == canonical_summary.validation_state
      }
    }
  end

  defp runtime_summary(runtime_state) do
    %{
      source_kind: runtime_state.source_kind,
      validation_state: runtime_state.validation_state,
      focus_order: runtime_state.realization.focus_order,
      cell_surface_kinds: Enum.map(runtime_state.realization.cell_surface, & &1.kind),
      binding_names: runtime_state.screen.bindings.names
    }
  end
end
