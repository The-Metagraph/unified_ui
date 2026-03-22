defmodule TerminalUi.Examples do
  @moduledoc """
  Maintained native and canonical examples for `terminal_ui`.
  """

  alias UnifiedIUR.{Canvas, Element, Interaction, Layer, Layout}
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

  @spec native_transport_screen() :: map()
  def native_transport_screen do
    %{
      id: "transport-native",
      title: "Native Transport Review",
      root:
        TerminalUi.Widgets.column("transport-root", [
          TerminalUi.Widgets.text("transport-title", "Transport Review"),
          TerminalUi.Widgets.text_input("command-input",
            value: "reload",
            binding: :command_query,
            placeholder: "Type a command"
          ),
          TerminalUi.Widgets.command_palette(
            "command-palette",
            [
              %{id: :reload, label: "Reload", value: :reload},
              %{id: :restart, label: "Restart", value: :restart}
            ],
            query: "re",
            binding: :command_query,
            current: :reload
          ),
          TerminalUi.Widgets.menu(
            "scope-menu",
            [
              %{id: :workspace, label: "Workspace"},
              %{id: :cluster, label: "Cluster"}
            ],
            current: :workspace,
            binding: :scope
          ),
          TerminalUi.Widgets.status("transport-status", "Ready", severity: :info)
        ]),
      metadata: %{
        example_id: :native_transport_review,
        source: :native,
        coverage: [
          :normalized_input,
          :local_native_handling,
          :canonical_boundary_translation
        ]
      }
    }
  end

  @spec canonical_transport_screen() :: UnifiedIUR.Element.t()
  def canonical_transport_screen do
    Layout.column(
      [
        Foundational.text("Transport Review", id: "transport-title"),
        Input.text_input(
          id: "command-input",
          value: "reload",
          binding: %{name: :command_query, value: "reload"},
          interaction: Interaction.submit(intent: :submit_command)
        ),
        Advanced.command_palette(
          [
            %{id: :reload, label: "Reload", value: :reload},
            %{id: :restart, label: "Restart", value: :restart}
          ],
          id: "command-palette",
          query: "re",
          binding: %{name: :command_query, value: "re"},
          interaction: Interaction.command(intent: :reload_workspace, command: :reload)
        ),
        Navigation.menu(
          [
            %{id: :workspace, label: "Workspace"},
            %{id: :cluster, label: "Cluster"}
          ],
          id: "scope-menu",
          active_item: :workspace,
          binding: %{name: :scope, value: :workspace},
          interaction: Interaction.selection(intent: :select_scope)
        ),
        Feedback.status("Ready", id: "transport-status", severity: :info)
      ],
      id: "transport-root",
      gap: :sm
    )
  end

  @spec native_styled_screen() :: map()
  def native_styled_screen do
    %{
      id: "styled-review",
      title: "Native Styled Review",
      theme: :high_contrast,
      root:
        TerminalUi.Widgets.column("styled-root", [
          TerminalUi.Widgets.text("styled-title", "Styled Workspace",
            theme: :high_contrast,
            semantic_role: :title,
            theme_tokens: %{text: [:text, :hero]}
          ),
          TerminalUi.Widgets.text_input("styled-query",
            value: "node:db",
            binding: :styled_query,
            theme: :high_contrast,
            variant: :outlined,
            style_refs: [:query_field]
          ),
          TerminalUi.Widgets.button("styled-save", "Deploy",
            theme: :high_contrast,
            variant: :accented,
            semantic_role: :primary_action
          ),
          TerminalUi.Widgets.status("styled-status", "Attention required",
            theme: :high_contrast,
            semantic_role: :status_warning,
            severity: :warning
          ),
          TerminalUi.Widgets.command_palette(
            "styled-palette",
            [
              %{id: :deploy, label: "Deploy", value: :deploy},
              %{id: :drain, label: "Drain", value: :drain}
            ],
            query: "de",
            binding: :styled_command,
            current: :deploy,
            theme: :high_contrast,
            variant: :dense
          ),
          TerminalUi.Widgets.canvas(
            "styled-canvas",
            [
              %{kind: :cell, position: %{x: 0, y: 0}, text: "A"},
              %{kind: :cell, position: %{x: 1, y: 0}, text: "B"}
            ],
            width: 12,
            height: 4,
            theme: :high_contrast,
            degradation: :ascii_canvas
          )
        ]),
      metadata: %{
        example_id: :native_styled_review,
        source: :native,
        coverage: [:native_styling, :theme_resolution, :capability_degradation, :inspection]
      }
    }
  end

  @spec canonical_styled_screen() :: UnifiedIUR.Element.t()
  def canonical_styled_screen do
    Element.new(:layout, :column,
      id: "styled-root",
      attributes: %{gap: :sm},
      children: [
        Element.new(:widget, :text,
          id: "styled-title",
          attributes: %{
            text: "Styled Workspace",
            theme: :high_contrast,
            style: %{semantic_role: :title, theme_tokens: %{text: [:text, :hero]}}
          }
        ),
        Element.new(:widget, :text_input,
          id: "styled-query",
          attributes: %{
            value: "node:db",
            theme: :high_contrast,
            style: %{variant: :outlined, style_refs: [:query_field]}
          }
        ),
        Element.new(:widget, :button,
          id: "styled-save",
          attributes: %{
            text: "Deploy",
            theme: :high_contrast,
            style: %{variant: :accented, semantic_role: :primary_action}
          }
        ),
        Element.new(:widget, :status,
          id: "styled-status",
          attributes: %{
            text: "Attention required",
            severity: :warning,
            theme: :high_contrast,
            style: %{semantic_role: :status_warning}
          }
        ),
        Element.new(:widget, :command_palette,
          id: "styled-palette",
          attributes: %{
            items: [
              %{id: :deploy, label: "Deploy", value: :deploy},
              %{id: :drain, label: "Drain", value: :drain}
            ],
            query: "de",
            theme: :high_contrast,
            style: %{variant: :dense}
          }
        ),
        Element.new(:widget, :canvas,
          id: "styled-canvas",
          attributes: %{
            operations: [
              %{kind: :cell, position: {0, 0}, text: "A"},
              %{kind: :cell, position: {1, 0}, text: "B"}
            ],
            width: 12,
            height: 4,
            theme: :high_contrast,
            style: %{degradation: :ascii_canvas}
          }
        )
      ]
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
      },
      %{
        id: :native_transport_review,
        mode: :native,
        summary: "Direct-native transport review screen",
        coverage: [:normalized_input, :local_native_handling, :canonical_boundary_translation],
        categories: [:forms, :navigation, :operational, :transport],
        artifact: native_transport_screen()
      },
      %{
        id: :native_styled_review,
        mode: :native,
        summary: "Direct-native styled and degradation-aware workspace",
        coverage: [:native_styling, :theme_resolution, :capability_degradation, :inspection],
        categories: [:content, :forms, :actions, :style, :degradation, :inspection],
        artifact: native_styled_screen()
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
      },
      %{
        id: :canonical_transport_review,
        mode: :canonical,
        summary: "Canonical transport review screen",
        coverage: [:normalized_input, :canonical_signal_translation, :shared_event_routing],
        categories: [:forms, :navigation, :operational, :transport],
        artifact: canonical_transport_screen()
      },
      %{
        id: :canonical_styled_review,
        mode: :canonical,
        summary: "Canonical styled and degradation-aware workspace",
        coverage: [:shared_theme_model, :canonical_styling, :inspection, :capability_degradation],
        categories: [:content, :forms, :actions, :style, :degradation, :inspection],
        artifact: canonical_styled_screen()
      }
    ]
  end

  @spec comparison_examples() :: map()
  def comparison_examples do
    %{
      foundational_continuity: foundational_comparison(),
      advanced_continuity: advanced_comparison(),
      advanced_capability_continuity: advanced_capability_comparison(),
      transport_flow_review: transport_flow_comparison(),
      normalized_input_profiles: normalized_input_comparison(),
      styled_continuity_review: styled_continuity_comparison(),
      styled_degradation_review: styled_degradation_comparison()
    }
  end

  @spec mixed_examples() :: [map()]
  def mixed_examples do
    catalog_by_category(:mixed)
  end

  @spec catalog() :: [map()]
  def catalog do
    catalog_entries()
    |> Enum.map(&decorate_catalog_entry/1)
  end

  @spec metadata(atom()) :: map() | nil
  def metadata(id) when is_atom(id) do
    Enum.find(catalog(), &(&1.id == id))
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
        layering: [:overlay, :dialog, :context_menu],
        transport: [:shortcut, :paste, :resize, :focus],
        style: [:theme, :variant, :semantic_role, :theme_tokens],
        degradation: [:glyph_set, :color_mode, :fallback_plan],
        inspection: [:runtime_snapshot, :style_nodes, :continuity_report]
      },
      workflows: %{
        foundational_review: [:native_foundational, :canonical_foundational],
        advanced_review: [
          :native_advanced_operations,
          :canonical_advanced_operations,
          :advanced_continuity
        ],
        transport_review: [
          :native_transport_review,
          :canonical_transport_review,
          :transport_flow_review,
          :normalized_input_profiles
        ],
        style_review: [
          :native_styled_review,
          :canonical_styled_review,
          :styled_continuity_review
        ],
        degradation_review: [:styled_degradation_review],
        parity_review: [:foundational_continuity, :advanced_continuity],
        capability_review: [:advanced_capability_continuity, :styled_degradation_review]
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
        ],
        transport_runtime_review: [
          :native_transport_review,
          :canonical_transport_review,
          :transport_flow_review,
          :normalized_input_profiles
        ],
        styled_workspace_review: [
          :native_styled_review,
          :canonical_styled_review,
          :styled_continuity_review,
          :styled_degradation_review
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

  @spec transport_flow_comparison() :: map()
  def transport_flow_comparison do
    {:ok, native_state} =
      TerminalUi.Runtime.mount_native_screen(native_transport_screen(), backend_mode: :raw)

    {:ok, canonical_state} =
      TerminalUi.Runtime.mount_iur_screen(canonical_transport_screen(), backend_mode: :raw)

    {:ok, native_local_state, native_local_route} =
      TerminalUi.Runtime.dispatch_native_event(native_state,
        input_family: :focus,
        boundary: :local,
        focus_target: "scope-menu",
        widget_id: "scope-menu",
        intent: :focus_scope_menu
      )

    {:ok, _native_boundary_state, native_boundary_route} =
      TerminalUi.Runtime.dispatch_native_event(native_local_state,
        input_family: :shortcut,
        shortcut: "ctrl-r",
        widget_id: "command-palette",
        intent: :reload_workspace
      )

    {:ok, _canonical_boundary_state, canonical_boundary_route} =
      TerminalUi.Runtime.dispatch_widget_interaction(
        canonical_state,
        "command-palette",
        :command,
        intent: :reload_workspace,
        runtime_event: "command:reload_workspace",
        payload: %{command: :reload}
      )

    %{
      id: :transport_flow_review,
      summary: "Compare local native handling and canonical boundary translation",
      coverage: [:transport_review, :local_native_handling, :canonical_boundary_translation],
      native_local: route_summary(native_local_route),
      native_boundary: route_summary(native_boundary_route),
      canonical_boundary: route_summary(canonical_boundary_route),
      parity: %{
        local_route_stays_local?: native_local_route.route == :local_runtime,
        boundary_routes_emit_signals?:
          not is_nil(native_boundary_route.translation.signal) and
            not is_nil(canonical_boundary_route.translation.signal),
        runtime_event_meaning_preserved?:
          native_boundary_route.family == canonical_boundary_route.family and
            native_boundary_route.translation.intent ==
              canonical_boundary_route.translation.intent
      }
    }
  end

  @spec normalized_input_comparison() :: map()
  def normalized_input_comparison do
    {:ok, raw_shortcut} =
      TerminalUi.Transport.from_native_event(
        backend_mode: :raw,
        input_family: :shortcut,
        shortcut: "ctrl-r",
        intent: :reload_workspace,
        widget_id: "command-palette",
        runtime_id: "terminal-ui:transport",
        screen: "transport"
      )

    {:ok, tty_shortcut} =
      TerminalUi.Transport.from_native_event(
        backend_mode: :tty,
        input_family: :shortcut,
        shortcut: "ctrl-r",
        intent: :reload_workspace,
        widget_id: "command-palette",
        runtime_id: "terminal-ui:transport",
        screen: "transport"
      )

    {:ok, raw_resize} =
      TerminalUi.Transport.from_native_event(
        backend_mode: :raw,
        input_family: :resize,
        width: 120,
        height: 40,
        boundary: :local,
        screen: "transport"
      )

    {:ok, tty_resize} =
      TerminalUi.Transport.from_native_event(
        backend_mode: :tty,
        input_family: :resize,
        width: 120,
        height: 40,
        boundary: :local,
        screen: "transport"
      )

    raw_shortcut_summary = route_summary(raw_shortcut)
    tty_shortcut_summary = route_summary(tty_shortcut)
    raw_resize_summary = route_summary(raw_resize)
    tty_resize_summary = route_summary(tty_resize)

    %{
      id: :normalized_input_profiles,
      summary: "Compare normalized input families across raw and tty backends",
      coverage: [:normalized_input, :capability_review],
      raw_shortcut: raw_shortcut_summary,
      tty_shortcut: tty_shortcut_summary,
      raw_resize: raw_resize_summary,
      tty_resize: tty_resize_summary,
      parity: %{
        shortcut_family_match?: raw_shortcut.family == tty_shortcut.family,
        resize_family_match?: raw_resize.family == tty_resize.family,
        boundary_local_split_visible?:
          raw_shortcut.boundary == :boundary and raw_resize.boundary == :local,
        tty_capability_handling_explicit?:
          tty_shortcut_summary.translation.backend_mode == :tty and
            tty_resize_summary.local_handling == :paged_resize
      }
    }
  end

  @spec styled_continuity_comparison() :: map()
  def styled_continuity_comparison do
    {:ok, native_state} =
      TerminalUi.Runtime.mount_native_screen(native_styled_screen(), backend_mode: :raw)

    {:ok, canonical_state} =
      TerminalUi.Runtime.mount_iur_screen(canonical_styled_screen(),
        backend_mode: :raw,
        theme: :high_contrast
      )

    continuity = TerminalUi.Continuity.compare(native_state, canonical_state)

    %{
      id: :styled_continuity_review,
      summary: "Compare styled native and canonical rendering through one shared style model",
      coverage: [:style_review, :inspection, :continuity],
      native: TerminalUi.Inspection.runtime_snapshot(native_state),
      canonical: TerminalUi.Inspection.runtime_snapshot(canonical_state),
      continuity: continuity.continuity,
      diagnostics: continuity.diagnostics,
      parity: %{
        widget_identity_match?: continuity.continuity.widget_identity_match?,
        theme_resolution_match?: continuity.continuity.theme_resolution_match?,
        style_resolution_match?: continuity.continuity.style_resolution_match?
      }
    }
  end

  @spec styled_degradation_comparison() :: map()
  def styled_degradation_comparison do
    {:ok, native_raw} =
      TerminalUi.Runtime.mount_native_screen(native_styled_screen(), backend_mode: :raw)

    {:ok, native_tty} =
      TerminalUi.Runtime.mount_native_screen(native_styled_screen(), backend_mode: :tty)

    {:ok, canonical_raw} =
      TerminalUi.Runtime.mount_iur_screen(canonical_styled_screen(),
        backend_mode: :raw,
        theme: :high_contrast
      )

    {:ok, canonical_tty} =
      TerminalUi.Runtime.mount_iur_screen(canonical_styled_screen(),
        backend_mode: :tty,
        theme: :high_contrast
      )

    native_capability = TerminalUi.Continuity.compare_capabilities(native_raw, native_tty)

    canonical_capability =
      TerminalUi.Continuity.compare_capabilities(canonical_raw, canonical_tty)

    native_tty_snapshot = TerminalUi.Inspection.runtime_snapshot(native_tty)
    canonical_tty_snapshot = TerminalUi.Inspection.runtime_snapshot(canonical_tty)

    %{
      id: :styled_degradation_review,
      summary: "Review explicit degradation decisions across rich and fallback terminals",
      coverage: [:degradation_review, :capability_review, :inspection],
      native_fallback: native_tty_snapshot.degradation,
      canonical_fallback: canonical_tty_snapshot.degradation,
      native_capability: native_capability.continuity,
      canonical_capability: canonical_capability.continuity,
      parity: %{
        glyph_fallback_explicit?:
          native_tty_snapshot.degradation.plan.glyph_set == :ascii and
            canonical_tty_snapshot.degradation.plan.glyph_set == :ascii,
        degradation_bounded?:
          native_capability.continuity.degradation_bounded? and
            canonical_capability.continuity.degradation_bounded?,
        inspection_surfaces_agree?:
          native_tty_snapshot.capabilities.diagnostics.degradation_plan.canvas_mode ==
            canonical_tty_snapshot.capabilities.diagnostics.degradation_plan.canvas_mode
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

  defp route_summary(route_result) do
    translation = Map.get(route_result, :translation, route_result)

    %{
      route: Map.get(route_result, :route, route_for_translation(translation)),
      family: Map.get(route_result, :family, translation.family),
      input_family: Map.get(route_result, :input_family, Map.get(translation, :input_family)),
      boundary: Map.get(route_result, :boundary, translation.boundary),
      runtime_event: Map.get(route_result, :runtime_event, translation.runtime_event),
      local_handling:
        Map.get(route_result, :local_handling, Map.get(translation, :local_handling)),
      signal_type:
        case Map.get(translation, :signal) do
          nil -> nil
          signal -> signal.type
        end,
      translation: translation
    }
  end

  defp route_for_translation(%{boundary: :boundary}), do: :canonical_boundary
  defp route_for_translation(_translation), do: :local_runtime

  defp catalog_by_category(category) do
    catalog()
    |> Enum.filter(&(&1.category == category))
  end

  defp decorate_catalog_entry(entry) do
    Map.merge(entry, %{
      artifact_names: artifact_names(entry.id),
      traceability: traceability(entry),
      coverage: example_coverage(entry.id)
    })
  end

  defp artifact_names(id) do
    base = "terminal_ui.examples.#{id}"

    %{
      preview: "#{base}.preview",
      inspection: "#{base}.inspection",
      validation: "#{base}.validation",
      comparison: "#{base}.comparison"
    }
  end

  defp traceability(entry) do
    %{
      package_specs: package_spec_surfaces(entry.category),
      runtime_obligations: runtime_obligations(entry.category),
      coverage_obligations: example_coverage(entry.id)
    }
  end

  defp package_spec_surfaces(:native), do: [:native_widgets, :runtime, :tooling]
  defp package_spec_surfaces(:canonical), do: [:iur_renderer, :runtime, :tooling]
  defp package_spec_surfaces(:mixed), do: [:transport, :capabilities, :tooling]

  defp runtime_obligations(:native), do: [:direct_native_reviewable, :shared_runtime]
  defp runtime_obligations(:canonical), do: [:canonical_reviewable, :shared_runtime]
  defp runtime_obligations(:mixed), do: [:continuity_reviewable, :capability_reviewable]

  defp example_coverage(id) do
    native_examples()
    |> Kernel.++(canonical_examples())
    |> Enum.find(&(&1.id == id))
    |> case do
      nil ->
        comparison_examples()
        |> Map.get(id, %{})
        |> Map.get(:coverage, [])

      example ->
        Map.get(example, :coverage, [])
    end
  end

  defp catalog_entries do
    [
      %{
        id: :native_foundational,
        category: :native,
        workflow: :foundational,
        parity_group: :foundational_review,
        parity_with: [:canonical_foundational, :foundational_continuity],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :canonical_foundational,
        category: :canonical,
        workflow: :foundational,
        parity_group: :foundational_review,
        parity_with: [:native_foundational, :foundational_continuity],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :foundational_continuity,
        category: :mixed,
        workflow: :foundational,
        parity_group: :foundational_review,
        parity_with: [:native_foundational, :canonical_foundational],
        capability_profiles: [:rich_terminal]
      },
      %{
        id: :native_advanced_operations,
        category: :native,
        workflow: :advanced,
        parity_group: :advanced_review,
        parity_with: [:canonical_advanced_operations, :advanced_continuity],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :canonical_advanced_operations,
        category: :canonical,
        workflow: :advanced,
        parity_group: :advanced_review,
        parity_with: [:native_advanced_operations, :advanced_continuity],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :advanced_continuity,
        category: :mixed,
        workflow: :advanced,
        parity_group: :advanced_review,
        parity_with: [:native_advanced_operations, :canonical_advanced_operations],
        capability_profiles: [:rich_terminal]
      },
      %{
        id: :advanced_capability_continuity,
        category: :mixed,
        workflow: :capability,
        parity_group: :advanced_review,
        parity_with: [:native_advanced_operations, :canonical_advanced_operations],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :native_transport_review,
        category: :native,
        workflow: :transport,
        parity_group: :transport_review,
        parity_with: [:canonical_transport_review, :transport_flow_review],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :canonical_transport_review,
        category: :canonical,
        workflow: :transport,
        parity_group: :transport_review,
        parity_with: [:native_transport_review, :transport_flow_review],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :transport_flow_review,
        category: :mixed,
        workflow: :transport,
        parity_group: :transport_review,
        parity_with: [:native_transport_review, :canonical_transport_review],
        capability_profiles: [:rich_terminal]
      },
      %{
        id: :normalized_input_profiles,
        category: :mixed,
        workflow: :transport,
        parity_group: :transport_review,
        parity_with: [:native_transport_review, :canonical_transport_review],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :native_styled_review,
        category: :native,
        workflow: :styling,
        parity_group: :styling_review,
        parity_with: [:canonical_styled_review, :styled_continuity_review],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :canonical_styled_review,
        category: :canonical,
        workflow: :styling,
        parity_group: :styling_review,
        parity_with: [:native_styled_review, :styled_continuity_review],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      },
      %{
        id: :styled_continuity_review,
        category: :mixed,
        workflow: :styling,
        parity_group: :styling_review,
        parity_with: [:native_styled_review, :canonical_styled_review],
        capability_profiles: [:rich_terminal]
      },
      %{
        id: :styled_degradation_review,
        category: :mixed,
        workflow: :capability,
        parity_group: :styling_review,
        parity_with: [:native_styled_review, :canonical_styled_review],
        capability_profiles: [:rich_terminal, :fallback_terminal]
      }
    ]
  end
end
