defmodule TerminalUi.Examples do
  @moduledoc """
  Maintained native and canonical examples for `terminal_ui`.
  """

  alias UnifiedIUR.{Canvas, Interaction, Layer, Layout}
  alias UnifiedIUR.Widgets.{Advanced, Data, Feedback, Foundational, Input, Navigation}

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
            ],
            current: :overview,
            binding: :section
          ),
          TerminalUi.Widgets.list(
            "results",
            [
              %{id: :alpha, label: "Alpha"},
              %{id: :beta, label: "Beta"}
            ],
            current: :alpha,
            binding: :selected_result
          ),
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

  @spec native_advanced_operations_screen() :: map()
  def native_advanced_operations_screen do
    %{
      id: "operations-advanced",
      title: "Native Advanced Operations Workspace",
      root:
        TerminalUi.Layer.overlay(
          "operations-overlay",
          TerminalUi.Layout.split_pane(
            "operations-split",
            TerminalUi.Layout.viewport(
              "service-viewport",
              TerminalUi.Widgets.column("service-panel", [
                TerminalUi.Widgets.text("services-title", "Services"),
                TerminalUi.Widgets.table(
                  "services-table",
                  [
                    %{id: :service, label: "Service"},
                    %{id: :status, label: "Status"}
                  ],
                  [
                    %{id: :api, cells: ["API", "healthy"]},
                    %{id: :worker, cells: ["Worker", "degraded"]}
                  ],
                  binding: :selected_service,
                  on_select: %{intent: :select_service}
                ),
                TerminalUi.Widgets.log_viewer(
                  "service-log",
                  [
                    %{id: "log-1", message: "Accepted connection", severity: :info},
                    %{id: "log-2", message: "Restart requested", severity: :warning}
                  ],
                  query: "severity:warning",
                  query_binding: :log_query
                )
              ]),
              offset_binding: :service_offset
            ),
            TerminalUi.Widgets.column("operations-sidebar", [
              TerminalUi.Widgets.command_palette(
                "ops-palette",
                [
                  %{id: :reload, label: "Reload", value: :reload},
                  %{id: :restart, label: "Restart", value: :restart}
                ],
                query: "re",
                binding: :command_query,
                current: :reload
              ),
              TerminalUi.Widgets.cluster_dashboard(
                "cluster-health",
                [
                  %{id: :node_a, status: :healthy},
                  %{id: :node_b, status: :degraded}
                ]
              ),
              TerminalUi.Widgets.gauge("cpu-gauge", value: 72, label: "CPU"),
              TerminalUi.Widgets.canvas(
                "topology-canvas",
                [
                  %{kind: :cell, position: %{x: 0, y: 0}, text: "A"},
                  %{kind: :cell, position: %{x: 1, y: 0}, text: "B"}
                ],
                width: 16,
                height: 8
              )
            ]),
            ratio: 0.6
          ),
          [
            TerminalUi.Widgets.dialog(
              "ops-dialog",
              [
                TerminalUi.Widgets.text("dialog-copy", "Runbook loaded"),
                TerminalUi.Widgets.button("dialog-close", "Close",
                  on_press: %{intent: :close_dialog}
                )
              ],
              open: true
            ),
            TerminalUi.Layer.context_menu(
              "ops-menu",
              TerminalUi.Widgets.button("ops-menu-anchor", "Actions"),
              [
                %{id: :restart_service, label: "Restart Service"},
                %{id: :drain_node, label: "Drain Node"}
              ]
            )
          ]
        ),
      metadata: %{
        example_id: :native_advanced_operations,
        source: :native,
        coverage: [
          :advanced_widgets,
          :layered_runtime,
          :display_systems,
          :capability_fallbacks
        ]
      }
    }
  end

  @spec canonical_advanced_operations_screen() :: UnifiedIUR.Element.t()
  def canonical_advanced_operations_screen do
    Layer.overlay(
      Layout.split_pane(
        Layout.scroll_region(
          Layout.column(
            [
              Foundational.text("Services", id: "services-title"),
              Data.table(
                [
                  %{id: :service, label: "Service"},
                  %{id: :status, label: "Status"}
                ],
                [
                  %{id: :api, cells: ["API", "healthy"]},
                  %{id: :worker, cells: ["Worker", "degraded"]}
                ],
                id: "services-table",
                binding: %{name: :selected_service, value: :api},
                interaction: Interaction.selection(intent: :select_service)
              ),
              Advanced.log_viewer(
                [
                  %{id: "log-1", message: "Accepted connection", severity: :info},
                  %{id: "log-2", message: "Restart requested", severity: :warning}
                ],
                id: "service-log"
              )
            ],
            id: "service-panel",
            gap: :sm
          ),
          id: "service-viewport",
          offset: 12
        ),
        Layout.column(
          [
            Advanced.command_palette(
              [
                %{id: :reload, label: "Reload", value: :reload},
                %{id: :restart, label: "Restart", value: :restart}
              ],
              id: "ops-palette",
              query: "re",
              binding: %{name: :command_query, value: "re"},
              interaction: Interaction.command(intent: :run_command, command: :reload)
            ),
            Advanced.cluster_dashboard(
              [
                %{id: :node_a, status: :healthy},
                %{id: :node_b, status: :degraded}
              ],
              id: "cluster-health"
            ),
            Feedback.gauge(id: "cpu-gauge", value: 72, label: "CPU"),
            Canvas.surface(
              [
                %{kind: :cell, position: {0, 0}, text: "A"},
                %{kind: :cell, position: {1, 0}, text: "B"}
              ],
              id: "topology-canvas",
              width: 16,
              height: 8
            )
          ],
          id: "operations-sidebar",
          gap: :sm
        ),
        id: "operations-split",
        ratio: 0.6
      ),
      [
        Layer.dialog(Foundational.text("Runbook loaded", id: "dialog-copy"),
          id: "ops-dialog",
          title: "Runbook"
        ),
        Layer.context_menu(
          [
            %{id: :restart_service, label: "Restart Service"},
            %{id: :drain_node, label: "Drain Node"}
          ],
          id: "ops-menu"
        )
      ],
      id: "operations-overlay"
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
      },
      %{
        id: :native_advanced_operations,
        mode: :native,
        summary: "Direct-native advanced operations workspace",
        coverage: [:advanced_widgets, :layered_runtime, :display_systems, :capability_fallbacks],
        categories: [:data, :visualization, :operational, :display, :layering],
        artifact: native_advanced_operations_screen()
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
      },
      %{
        id: :canonical_advanced_operations,
        mode: :canonical,
        summary: "Canonical advanced operations workspace",
        coverage: [:advanced_canonical_renderer, :shared_realization, :capability_fallbacks],
        categories: [:data, :visualization, :operational, :display, :layering],
        artifact: canonical_advanced_operations_screen()
      }
    ]
  end

  @spec comparison_examples() :: map()
  def comparison_examples do
    %{
      foundational_continuity: foundational_comparison(),
      advanced_continuity: advanced_comparison(),
      advanced_capability_continuity: advanced_capability_comparison()
    }
  end

  @spec coverage_matrix() :: map()
  def coverage_matrix do
    %{
      categories: %{
        content: [:text],
        forms: [:text_input, :checkbox],
        navigation: [:tabs, :list],
        actions: [:button],
        data: [:table, :log_viewer],
        visualization: [:gauge, :canvas],
        operational: [:command_palette, :cluster_dashboard],
        display: [:viewport, :split_pane],
        layering: [:overlay, :dialog, :context_menu]
      },
      workflows: %{
        foundational_review: [:native_foundational, :canonical_foundational],
        advanced_review: [
          :native_advanced_operations,
          :canonical_advanced_operations,
          :advanced_continuity
        ],
        parity_review: [:foundational_continuity, :advanced_continuity],
        capability_review: [:advanced_capability_continuity]
      },
      parity_groups: %{
        foundational_workspace: [
          :native_foundational,
          :canonical_foundational,
          :foundational_continuity
        ],
        advanced_operations_workspace: [
          :native_advanced_operations,
          :canonical_advanced_operations,
          :advanced_continuity,
          :advanced_capability_continuity
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

  @spec advanced_comparison() :: map()
  def advanced_comparison do
    {:ok, native_state} =
      TerminalUi.Runtime.mount_native_screen(native_advanced_operations_screen(),
        backend_mode: :raw
      )

    {:ok, canonical_state} =
      TerminalUi.Runtime.mount_iur_screen(canonical_advanced_operations_screen(),
        backend_mode: :raw
      )

    native_summary = runtime_summary(native_state)
    canonical_summary = runtime_summary(canonical_state)

    %{
      id: :advanced_continuity,
      summary: "Compare native and canonical advanced rendering",
      coverage: [:comparison_artifact, :advanced_canonical_renderer, :layered_runtime],
      native: native_summary,
      canonical: canonical_summary,
      parity: %{
        shared_runtime_backbone?:
          native_summary.validation_state == canonical_summary.validation_state,
        advanced_state_match?:
          native_summary.realization_validation_state ==
            canonical_summary.realization_validation_state,
        layered_roles_match?: native_summary.layer_roles == canonical_summary.layer_roles,
        display_kinds_match?: native_summary.display_kinds == canonical_summary.display_kinds
      }
    }
  end

  @spec advanced_capability_comparison() :: map()
  def advanced_capability_comparison do
    {:ok, native_raw} =
      TerminalUi.Runtime.mount_native_screen(native_advanced_operations_screen(),
        backend_mode: :raw
      )

    {:ok, native_tty} =
      TerminalUi.Runtime.mount_native_screen(native_advanced_operations_screen(),
        backend_mode: :tty
      )

    {:ok, canonical_raw} =
      TerminalUi.Runtime.mount_iur_screen(canonical_advanced_operations_screen(),
        backend_mode: :raw
      )

    {:ok, canonical_tty} =
      TerminalUi.Runtime.mount_iur_screen(canonical_advanced_operations_screen(),
        backend_mode: :tty
      )

    native_raw_summary = runtime_summary(native_raw)
    native_tty_summary = runtime_summary(native_tty)
    canonical_raw_summary = runtime_summary(canonical_raw)
    canonical_tty_summary = runtime_summary(canonical_tty)

    %{
      id: :advanced_capability_continuity,
      summary: "Compare advanced runtime behavior across rich and fallback terminals",
      coverage: [:capability_review, :layered_runtime, :capability_fallbacks],
      native_raw: native_raw_summary,
      native_tty: native_tty_summary,
      canonical_raw: canonical_raw_summary,
      canonical_tty: canonical_tty_summary,
      parity: %{
        native_semantics_stable?:
          native_raw_summary.semantic_kinds == native_tty_summary.semantic_kinds,
        canonical_semantics_stable?:
          canonical_raw_summary.semantic_kinds == canonical_tty_summary.semantic_kinds,
        tty_fallbacks_explicit?:
          native_tty_summary.fallbacks != [] and canonical_tty_summary.fallbacks != [],
        allowed_variation_bounded?:
          native_tty_summary.allowed_variation == canonical_tty_summary.allowed_variation
      }
    }
  end

  defp runtime_summary(runtime_state) do
    %{
      source_kind: runtime_state.source_kind,
      backend_mode: runtime_state.backend_mode,
      validation_state: runtime_state.validation_state,
      realization_validation_state: runtime_state.realization.validation_state,
      focus_order: runtime_state.realization.focus_order,
      cell_surface_kinds: Enum.map(runtime_state.realization.cell_surface, & &1.kind),
      semantic_kinds:
        runtime_state.realization.cell_surface
        |> Enum.map(& &1.kind)
        |> Enum.uniq()
        |> Enum.sort_by(&to_string/1),
      binding_names: runtime_state.screen.bindings.names,
      layer_roles:
        runtime_state.realization.layers
        |> Enum.map(& &1.role)
        |> Enum.sort_by(&to_string/1),
      display_kinds:
        runtime_state.realization.viewport_regions
        |> Enum.map(& &1.kind)
        |> Enum.uniq()
        |> Enum.sort_by(&to_string/1),
      fallbacks:
        runtime_state.realization.fallbacks
        |> Enum.map(& &1.fallback)
        |> Enum.uniq()
        |> Enum.sort_by(&to_string/1),
      capability_profile: runtime_state.realization.diagnostics.capability_profile,
      allowed_variation:
        runtime_state.realization.diagnostics.allowed_variation
        |> Enum.sort_by(&to_string/1)
    }
  end
end
