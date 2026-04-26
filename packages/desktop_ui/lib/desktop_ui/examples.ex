defmodule DesktopUi.Examples do
  @moduledoc """
  Maintained foundational and advanced native and canonical examples for `desktop_ui`.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  defmodule NavigationReview do
    defmodule HomeScreen do
      def render(_assigns), do: %{}
    end

    defmodule SettingsScreen do
      def render(_assigns), do: %{}
    end

    defmodule ReportsScreen do
      def render(_assigns), do: %{}
    end

    defmodule SettingsDialogScreen do
      def render(_assigns), do: %{}
    end

    defmodule Registry do
      @behaviour DesktopUi.Navigation.Registry

      @impl true
      def register do
        %{
          home: {HomeScreen, title: "Home"},
          settings: {SettingsScreen, title: "Settings"},
          reports: {ReportsScreen, title: "Reports"},
          settings_dialog: {SettingsDialogScreen, title: "Settings Dialog", modal_only?: true}
        }
      end

      @impl true
      def get_screen(:home), do: HomeScreen
      def get_screen(:settings), do: SettingsScreen
      def get_screen(:reports), do: ReportsScreen
      def get_screen(:settings_dialog), do: SettingsDialogScreen
      def get_screen(_), do: nil

      @impl true
      def screen_metadata(:home), do: %{title: "Home"}
      def screen_metadata(:settings), do: %{title: "Settings"}
      def screen_metadata(:reports), do: %{title: "Reports"}
      def screen_metadata(:settings_dialog), do: %{title: "Settings Dialog", modal_only?: true}
      def screen_metadata(_), do: %{}
    end
  end

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

  @spec native_advanced_operations_screen() :: map()
  def native_advanced_operations_screen do
    %{
      id: "operations-advanced",
      title: "Native Advanced Operations Workspace",
      root:
        DesktopUi.Layer.multi_window("operations-windows", [
          DesktopUi.Widgets.window("operations-window", "Operations", [
            DesktopUi.Layer.overlay(
              "operations-overlay",
              DesktopUi.Layout.split_pane(
                "operations-split",
                DesktopUi.Layout.viewport(
                  "services-viewport",
                  DesktopUi.Widgets.table(
                    "services-table",
                    [%{id: :service, label: "Service"}, %{id: :status, label: "Status"}],
                    [
                      %{id: :api, cells: ["API", "healthy"]},
                      %{id: :worker, cells: ["Worker", "degraded"]}
                    ],
                    selection_binding: :selected_service,
                    sort_key: :service
                  )
                ),
                DesktopUi.Widgets.column("operations-sidebar", [
                  DesktopUi.Widgets.command_palette(
                    "ops-palette",
                    [%{id: :reload, label: "Reload"}, %{id: :restart, label: "Restart"}],
                    query: "re",
                    query_binding: :command_query,
                    window_identity: :operations_window
                  ),
                  DesktopUi.Widgets.cluster_dashboard(
                    "cluster-health",
                    [%{id: :node_a, status: :healthy}, %{id: :node_b, status: :degraded}],
                    summary: %{healthy: 1, degraded: 1}
                  ),
                  DesktopUi.Widgets.gauge("cpu-gauge", value: 72, label: "CPU"),
                  DesktopUi.Layout.canvas_surface(
                    "topology-surface",
                    [
                      DesktopUi.Layout.absolute(
                        "node-a",
                        [
                          DesktopUi.Widgets.text("node-a-label", "A")
                        ],
                        x: 0,
                        y: 0
                      ),
                      DesktopUi.Layout.absolute(
                        "node-b",
                        [
                          DesktopUi.Widgets.text("node-b-label", "B")
                        ],
                        x: 8,
                        y: 3
                      )
                    ],
                    width: 20,
                    height: 10
                  )
                ]),
                ratio: 0.6
              ),
              [
                DesktopUi.Widgets.dialog("ops-dialog", "Runbook", [
                  DesktopUi.Widgets.text("dialog-copy", "Runbook loaded"),
                  DesktopUi.Widgets.button("dialog-close", "Close", intent: :close_dialog)
                ]),
                DesktopUi.Layer.context_menu(
                  "ops-menu",
                  DesktopUi.Widgets.button("ops-menu-anchor", "Actions", intent: :open_actions),
                  [
                    %{id: :restart_service, label: "Restart Service"},
                    %{id: :drain_node, label: "Drain Node"}
                  ],
                  open: true
                )
              ]
            )
          ]),
          DesktopUi.Widgets.window("details-window", "Details", [
            DesktopUi.Widgets.process_monitor(
              "process-monitor",
              [%{id: :beam, name: "beam.smp", status: :running}],
              selection_binding: :selected_process
            ),
            DesktopUi.Widgets.log_viewer(
              "details-log",
              [%{id: "entry-1", message: "Window ready", severity: :info}],
              query_binding: :details_query
            )
          ])
        ]),
      metadata: %{
        example_id: :native_advanced_operations,
        source: :native,
        coverage: [:advanced_widgets, :layered_runtime, :display_systems, :multiwindow_runtime],
        target_semantics: target_semantics()
      }
    }
  end

  @spec canonical_advanced_operations_screen() :: Element.t()
  def canonical_advanced_operations_screen do
    Element.new(:layer, :multi_window,
      id: "operations-windows",
      children: [
        Element.new(:widget, :window,
          id: "operations-window",
          attributes: %{title: "Operations"},
          children: [
            Element.new(:layer, :overlay,
              id: "operations-overlay",
              children: [
                Child.new(
                  :content,
                  Element.new(:layout, :split_pane,
                    id: "operations-split",
                    attributes: %{ratio: 0.6},
                    children: [
                      Child.new(
                        :primary,
                        Element.new(:layout, :viewport,
                          id: "services-viewport",
                          children: [
                            Child.new(
                              :content,
                              Element.new(:widget, :table,
                                id: "services-table",
                                attributes: %{
                                  columns: [
                                    %{id: :service, label: "Service"},
                                    %{id: :status, label: "Status"}
                                  ],
                                  rows: [
                                    %{id: :api, cells: ["API", "healthy"]},
                                    %{id: :worker, cells: ["Worker", "degraded"]}
                                  ],
                                  binding: %{name: :selected_service, value: :api},
                                  sort_key: :service
                                }
                              )
                            )
                          ]
                        )
                      ),
                      Child.new(
                        :secondary,
                        Element.new(:layout, :column,
                          id: "operations-sidebar",
                          children: [
                            Element.new(:widget, :command_palette,
                              id: "ops-palette",
                              attributes: %{
                                commands: [
                                  %{id: :reload, label: "Reload"},
                                  %{id: :restart, label: "Restart"}
                                ],
                                query: "re",
                                binding: %{name: :command_query, value: "re"},
                                interaction: %{family: :command, intent: :run_command}
                              }
                            ),
                            Element.new(:widget, :cluster_dashboard,
                              id: "cluster-health",
                              attributes: %{
                                nodes: [
                                  %{id: :node_a, status: :healthy},
                                  %{id: :node_b, status: :degraded}
                                ],
                                summary: %{healthy: 1, degraded: 1}
                              }
                            ),
                            Element.new(:widget, :gauge,
                              id: "cpu-gauge",
                              attributes: %{value: 72, label: "CPU"}
                            ),
                            Element.new(:layout, :canvas_surface,
                              id: "topology-surface",
                              attributes: %{width: 20, height: 10},
                              children: [
                                Element.new(:layout, :absolute,
                                  id: "node-a",
                                  attributes: %{x: 0, y: 0},
                                  children: [
                                    Element.new(:widget, :text,
                                      id: "node-a-label",
                                      attributes: %{content: "A"}
                                    )
                                  ]
                                ),
                                Element.new(:layout, :absolute,
                                  id: "node-b",
                                  attributes: %{x: 8, y: 3},
                                  children: [
                                    Element.new(:widget, :text,
                                      id: "node-b-label",
                                      attributes: %{content: "B"}
                                    )
                                  ]
                                )
                              ]
                            )
                          ]
                        )
                      )
                    ]
                  )
                ),
                Child.new(
                  :overlay,
                  Element.new(:widget, :dialog,
                    id: "ops-dialog",
                    attributes: %{title: "Runbook"}
                  )
                ),
                Child.new(
                  :overlay,
                  Element.new(:layer, :context_menu,
                    id: "ops-menu",
                    attributes: %{
                      items: [
                        %{id: :restart_service, label: "Restart Service"},
                        %{id: :drain_node, label: "Drain Node"}
                      ]
                    },
                    children: [
                      Child.new(
                        :anchor,
                        Element.new(:widget, :button,
                          id: "ops-menu-anchor",
                          attributes: %{label: "Actions"}
                        )
                      )
                    ]
                  )
                )
              ]
            )
          ]
        ),
        Element.new(:widget, :window,
          id: "details-window",
          attributes: %{title: "Details"},
          children: [
            Element.new(:widget, :process_monitor,
              id: "process-monitor",
              attributes: %{
                processes: [%{id: :beam, name: "beam.smp", status: :running}],
                binding: %{name: :selected_process, value: :beam}
              }
            ),
            Element.new(:widget, :log_viewer,
              id: "details-log",
              attributes: %{
                entries: [%{id: "entry-1", message: "Window ready", severity: :info}],
                binding: %{name: :details_query, value: "ready"}
              }
            )
          ]
        )
      ]
    )
  end

  @spec advanced_comparison() :: map()
  def advanced_comparison do
    native_screen = native_advanced_operations_screen()
    canonical_screen = canonical_advanced_operations_screen()

    {:ok, native_state} =
      DesktopUi.Runtime.mount_native_screen(native_screen, platform_target: :linux)

    {:ok, canonical_state} =
      DesktopUi.Runtime.mount_iur_screen(canonical_screen, platform_target: :linux)

    %{
      id: :advanced_continuity,
      native_example_id: native_screen.metadata.example_id,
      canonical_example_id: :canonical_advanced_operations,
      coverage: %{
        widget_families: [
          :data,
          :feedback,
          :visualization,
          :operational,
          :layout,
          :layer,
          :window
        ],
        display_constructs: [
          :viewport,
          :split_pane,
          :canvas_surface,
          :absolute,
          :overlay,
          :multi_window
        ],
        target_semantics: target_semantics()
      },
      parity: %{
        shared_runtime_backbone?:
          native_state.realization.mode == canonical_state.realization.mode,
        advanced_ready_match?:
          native_state.realization.validation_state == :advanced_ready and
            canonical_state.realization.validation_state == :advanced_ready,
        layer_count_match?:
          length(native_state.realization.layers) == length(canonical_state.realization.layers),
        viewport_count_match?:
          length(native_state.realization.viewport_regions) ==
            length(canonical_state.realization.viewport_regions),
        window_registry_match?:
          Enum.sort(native_state.windows.secondary_ids ++ [native_state.windows.primary]) ==
            Enum.sort(canonical_state.windows.secondary_ids ++ [canonical_state.windows.primary])
      },
      native: native_state.realization,
      canonical: canonical_state.realization
    }
  end

  @spec native_transport_review() :: map()
  def native_transport_review do
    %{
      id: "transport-review",
      title: "Native Transport Review",
      root:
        DesktopUi.Widgets.window("transport-window", "Transport Review", [
          DesktopUi.Widgets.column("transport-layout", [
            DesktopUi.Widgets.menu(
              "scope-menu",
              [
                %{id: :workspace, label: "Workspace"},
                %{id: :services, label: "Services"}
              ],
              current: :workspace,
              binding: :scope,
              shortcut: "Alt+S",
              on_navigate: %{intent: :navigate_scope},
              on_select: %{intent: :select_scope}
            ),
            DesktopUi.Widgets.text_input("command-input",
              value: "status:ok",
              binding: :command_query,
              placeholder: "Search workspace",
              on_change: %{intent: :change_query},
              on_submit: %{intent: :submit_query}
            ),
            DesktopUi.Widgets.command("refresh-command", "Refresh",
              shortcut: "Cmd+R",
              intent: :refresh_workspace
            ),
            DesktopUi.Widgets.process_monitor(
              "process-monitor",
              [%{id: :beam, name: "beam.smp", status: :running}],
              selection_binding: :selected_process,
              on_select: %{intent: :inspect_process}
            ),
            DesktopUi.Widgets.window_command("detach-window", "Detach Window",
              window_identity: :transport_window,
              intent: :detach_window
            )
          ])
        ]),
      metadata: %{
        example_id: :native_transport_review,
        source: :native,
        coverage: [
          :normalized_desktop_inputs,
          :canonical_boundary_events,
          :local_native_routing,
          :window_management
        ],
        target_semantics: target_semantics()
      }
    }
  end

  @spec canonical_transport_review() :: Element.t()
  def canonical_transport_review do
    Element.new(:widget, :window,
      id: "transport-window",
      attributes: %{title: "Transport Review"},
      children: [
        Element.new(:layout, :column,
          id: "transport-layout",
          children: [
            Element.new(:widget, :menu,
              id: "scope-menu",
              attributes: %{
                items: [
                  %{id: :workspace, label: "Workspace"},
                  %{id: :services, label: "Services"}
                ],
                current: :workspace,
                binding: %{name: :scope, value: :workspace},
                interaction: %{family: :navigation, intent: :navigate_scope}
              }
            ),
            Element.new(:widget, :text_input,
              id: "command-input",
              attributes: %{
                value: "status:ok",
                placeholder: "Search workspace",
                binding: %{name: :command_query, value: "status:ok"},
                interaction: %{family: :submit, intent: :submit_query}
              }
            ),
            Element.new(:widget, :command,
              id: "refresh-command",
              attributes: %{
                label: "Refresh",
                shortcut: "Cmd+R",
                interaction: %{family: :command, intent: :refresh_workspace}
              }
            ),
            Element.new(:widget, :process_monitor,
              id: "process-monitor",
              attributes: %{
                processes: [%{id: :beam, name: "beam.smp", status: :running}],
                binding: %{name: :selected_process, value: :beam},
                interaction: %{family: :selection, intent: :inspect_process}
              }
            ),
            Element.new(:widget, :window_command,
              id: "detach-window",
              attributes: %{
                label: "Detach Window",
                interaction: %{family: :command, intent: :detach_window}
              },
              metadata: %{window_identity: :transport_window}
            )
          ]
        )
      ]
    )
  end

  @spec transport_comparison() :: map()
  def transport_comparison do
    native_screen = native_transport_review()
    canonical_screen = canonical_transport_review()

    {:ok, native_state} =
      DesktopUi.Runtime.mount_native_screen(native_screen, platform_target: :linux)

    {:ok, canonical_state} =
      DesktopUi.Runtime.mount_iur_screen(canonical_screen, platform_target: :linux)

    {:ok, local_native_state, local_route} =
      DesktopUi.Runtime.dispatch_native_event(native_state,
        input_family: :focus,
        boundary: :local,
        focus_target: "scope-menu",
        widget_id: "scope-menu",
        intent: :focus_scope_menu
      )

    {:ok, native_boundary_state, native_boundary_route} =
      DesktopUi.Runtime.dispatch_native_event(local_native_state,
        input_family: :shortcut,
        shortcut: "cmd-r",
        widget_id: "refresh-command",
        intent: :refresh_workspace
      )

    {:ok, canonical_boundary_state, canonical_boundary_route} =
      DesktopUi.Runtime.dispatch_widget_interaction(
        canonical_state,
        "refresh-command",
        :command,
        intent: :refresh_workspace,
        runtime_event: "shortcut:refresh_workspace",
        payload: %{command: :refresh}
      )

    %{
      id: :transport_flow_review,
      native_example_id: native_screen.metadata.example_id,
      canonical_example_id: :canonical_transport_review,
      coverage: %{
        input_families: DesktopUi.Transport.input_families(),
        local_families: DesktopUi.Transport.local_default_families(),
        boundary_families: DesktopUi.Transport.boundary_crossing_families()
      },
      parity: %{
        local_focus_stays_local?:
          local_route.route == :local_runtime and local_route.translation.signal == nil,
        boundary_routes_match?:
          native_boundary_route.route == :canonical_boundary and
            canonical_boundary_route.route == :canonical_boundary,
        boundary_signal_types_match?:
          native_boundary_route.translation.signal.type ==
            canonical_boundary_route.translation.signal.type,
        normalized_input_family_match?:
          native_boundary_route.input_family == canonical_boundary_route.input_family
      },
      native_local: %{
        state: local_native_state,
        route: local_route
      },
      native_boundary: %{
        state: native_boundary_state,
        route: native_boundary_route
      },
      canonical_boundary: %{
        state: canonical_boundary_state,
        route: canonical_boundary_route
      }
    }
  end

  @spec native_styled_review() :: map()
  def native_styled_review do
    %{
      id: "styled-review",
      title: "Native Styled Review",
      root:
        DesktopUi.Widgets.window(
          "styled-window",
          "Styled Review",
          [
            DesktopUi.Widgets.content("styled-header", [
              DesktopUi.Widgets.label("styled-label", "Theme"),
              DesktopUi.Widgets.text("styled-title", "Desktop Styled Review",
                styles: [
                  theme_tokens: %{headline: [:text, :hero]}
                ]
              )
            ]),
            DesktopUi.Widgets.row("styled-actions", [
              DesktopUi.Widgets.button("styled-primary", "Approve",
                intent: :approve_change,
                styles: [
                  theme_tokens: %{primary: [:button, :primary]},
                  state_variants: %{focused: %{border: :focus_ring}}
                ]
              ),
              DesktopUi.Widgets.button("styled-secondary", "Later",
                intent: :defer_change,
                styles: [
                  theme_tokens: %{secondary: [:button, :secondary]}
                ]
              )
            ]),
            DesktopUi.Widgets.text("styled-status", "Pending Review",
              styles: [
                theme_tokens: %{status: [:status, :warning]}
              ]
            ),
            DesktopUi.Widgets.table(
              "styled-table",
              [%{id: :name, label: "Name"}, %{id: :status, label: "Status"}],
              [
                %{id: :desktop, cells: ["Desktop", "ready"]},
                %{id: :transport, cells: ["Transport", "review"]}
              ],
              styles: [
                theme_tokens: %{surface: [:surface, :panel]}
              ]
            )
          ],
          styles: [
            theme: :high_contrast,
            theme_tokens: %{chrome: [:surface, :elevated]}
          ]
        ),
      metadata: %{
        example_id: :native_styled_review,
        source: :native,
        coverage: [
          :style_primitives,
          :theme_resolution,
          :component_variants,
          :artifact_review_surface
        ],
        target_semantics: target_semantics()
      }
    }
  end

  @spec canonical_styled_review() :: Element.t()
  def canonical_styled_review do
    Element.new(:widget, :window,
      id: "styled-window",
      attributes: %{
        title: "Styled Review",
        styles: %{
          theme: :high_contrast,
          theme_tokens: %{chrome: [:surface, :elevated]}
        }
      },
      children: [
        Element.new(:widget, :content,
          id: "styled-header",
          children: [
            Element.new(:widget, :label,
              id: "styled-label",
              attributes: %{content: "Theme"}
            ),
            Element.new(:widget, :text,
              id: "styled-title",
              attributes: %{
                content: "Desktop Styled Review",
                styles: %{theme_tokens: %{headline: [:text, :hero]}}
              }
            )
          ]
        ),
        Element.new(:layout, :row,
          id: "styled-actions",
          children: [
            Element.new(:widget, :button,
              id: "styled-primary",
              attributes: %{
                label: "Approve",
                interaction: %{family: :click, intent: :approve_change},
                styles: %{
                  theme_tokens: %{primary: [:button, :primary]},
                  state_variants: %{focused: %{border: :focus_ring}}
                }
              }
            ),
            Element.new(:widget, :button,
              id: "styled-secondary",
              attributes: %{
                label: "Later",
                interaction: %{family: :click, intent: :defer_change},
                styles: %{theme_tokens: %{secondary: [:button, :secondary]}}
              }
            )
          ]
        ),
        Element.new(:widget, :text,
          id: "styled-status",
          attributes: %{
            content: "Pending Review",
            styles: %{theme_tokens: %{status: [:status, :warning]}}
          }
        ),
        Element.new(:widget, :table,
          id: "styled-table",
          attributes: %{
            columns: [%{id: :name, label: "Name"}, %{id: :status, label: "Status"}],
            rows: [
              %{id: :desktop, cells: ["Desktop", "ready"]},
              %{id: :transport, cells: ["Transport", "review"]}
            ],
            styles: %{theme_tokens: %{surface: [:surface, :panel]}}
          }
        )
      ]
    )
  end

  @spec styled_comparison() :: map()
  def styled_comparison do
    native_screen = native_styled_review()
    canonical_screen = canonical_styled_review()

    {:ok, native_state} =
      DesktopUi.Runtime.mount_native_screen(native_screen,
        platform_target: :linux,
        theme: :high_contrast
      )

    {:ok, canonical_state} =
      DesktopUi.Runtime.mount_iur_screen(canonical_screen,
        platform_target: :linux,
        theme: :high_contrast
      )

    continuity = DesktopUi.Continuity.compare(native_state, canonical_state)

    %{
      id: :styled_continuity_review,
      native_example_id: native_screen.metadata.example_id,
      canonical_example_id: :canonical_styled_review,
      coverage: %{
        style_hooks: DesktopUi.Style.widget_style_hooks(),
        theme_catalog: DesktopUi.Theme.catalog_ids(),
        artifact_targets: DesktopUi.Artifacts.target_platforms()
      },
      parity: %{
        widget_identity_match?: continuity.continuity.widget_identity_match?,
        style_resolution_match?: continuity.continuity.style_resolution_match?,
        platform_semantics_match?: continuity.continuity.platform_semantics_match?
      },
      native: continuity.native,
      canonical: continuity.canonical,
      diagnostics: continuity.diagnostics
    }
  end

  # Navigation Examples

  @spec basic_navigation_screen() :: map()
  def basic_navigation_screen do
    %{
      id: "basic-navigation",
      title: "Basic Navigation Example",
      root:
        DesktopUi.Widgets.window("nav-window", "Navigation Demo", [
          DesktopUi.Widgets.column("nav-layout", [
            DesktopUi.Widgets.content("nav-header", [
              DesktopUi.Widgets.label("nav-title", "Navigation Demo"),
              DesktopUi.Widgets.text(
                "nav-subtitle",
                "Demonstrates home, list, and detail screens"
              )
            ]),
            DesktopUi.Widgets.menu(
              "nav-menu",
              [
                %{id: :home, label: "Home"},
                %{id: :items, label: "Items"},
                %{id: :settings, label: "Settings"}
              ],
              current: :home,
              binding: :current_screen,
              on_navigate: %{family: :navigation, type: :navigate_to}
            ),
            DesktopUi.Widgets.content("nav-content", [
              DesktopUi.Widgets.text("nav-hint", "Select a screen from the menu above")
            ])
          ])
        ]),
      metadata: %{
        example_id: :basic_navigation,
        source: :native,
        coverage: [:navigation_widgets, :screen_navigation, :menu_navigation],
        navigation_pattern: :simple_menu,
        screens: [:home, :items, :settings]
      }
    }
  end

  @spec history_navigation_screen() :: map()
  def history_navigation_screen do
    %{
      id: "history-navigation",
      title: "History Navigation Example",
      root:
        DesktopUi.Widgets.window("history-window", "History Navigation", [
          DesktopUi.Widgets.column("history-layout", [
            DesktopUi.Widgets.content("history-header", [
              DesktopUi.Widgets.label("history-title", "History Navigation"),
              DesktopUi.Widgets.text("history-subtitle", "Demonstrates back/forward navigation")
            ]),
            DesktopUi.Widgets.row("history-nav-buttons", [
              DesktopUi.Widgets.button("back-button", "← Back",
                go_back: true,
                disabled: false
              ),
              DesktopUi.Widgets.button("forward-button", "Forward →",
                go_forward: true,
                disabled: true
              )
            ]),
            DesktopUi.Widgets.content("history-content", [
              DesktopUi.Widgets.text("history-trail", "History: Home > Items > Detail"),
              DesktopUi.Widgets.breadcrumbs(
                "history-breadcrumbs",
                [
                  %{id: :home, label: "Home"},
                  %{id: :items, label: "Items"},
                  %{id: :detail, label: "Item Details"}
                ],
                current: :detail
              )
            ])
          ])
        ]),
      metadata: %{
        example_id: :history_navigation,
        source: :native,
        coverage: [:navigation_widgets, :screen_navigation, :history_stack],
        navigation_pattern: :history_based,
        screens: [:home, :items, :detail]
      }
    }
  end

  @spec modal_navigation_screen() :: map()
  def modal_navigation_screen do
    %{
      id: "modal-navigation",
      title: "Modal Navigation Example",
      root:
        DesktopUi.Widgets.window("modal-window", "Modal Dialog Demo", [
          DesktopUi.Widgets.column("modal-layout", [
            DesktopUi.Widgets.content("modal-header", [
              DesktopUi.Widgets.label("modal-title", "Modal Dialog Demo"),
              DesktopUi.Widgets.text("modal-subtitle", "Demonstrates independent modal stack")
            ]),
            DesktopUi.Widgets.content("modal-content", [
              DesktopUi.Widgets.text("modal-hint", "Click button to open a modal dialog"),
              DesktopUi.Widgets.button("confirm-button", "Open Confirm Dialog",
                open_modal: :confirm_dialog
              ),
              DesktopUi.Widgets.button("settings-button", "Open Settings Modal",
                open_modal: :settings
              )
            ])
          ])
        ]),
      metadata: %{
        example_id: :modal_navigation,
        source: :native,
        coverage: [:navigation_widgets, :screen_navigation, :modal_stack],
        navigation_pattern: :modal_dialogs,
        screens: [:main, :confirm_dialog, :settings],
        modals: [:confirm_dialog, :settings]
      }
    }
  end

  @spec master_detail_navigation_screen() :: map()
  def master_detail_navigation_screen do
    %{
      id: "master-detail-navigation",
      title: "Master-Detail Navigation",
      root:
        DesktopUi.Widgets.window("master-detail-window", "Master-Detail View", [
          DesktopUi.Widgets.row("master-detail-layout", [
            # Master panel (list of items)
            DesktopUi.Widgets.column("master-panel", [
              DesktopUi.Widgets.content("master-header", [
                DesktopUi.Widgets.label("master-title", "Items")
              ]),
              DesktopUi.Widgets.list(
                "item-list",
                [
                  %{id: :item1, label: "Item 1"},
                  %{id: :item2, label: "Item 2"},
                  %{id: :item3, label: "Item 3"}
                ],
                current: :item1,
                binding: :selected_item,
                on_navigate: %{family: :navigation, type: :navigate_to, screen_id: :detail}
              )
            ]),
            # Detail panel (selected item details)
            DesktopUi.Widgets.column("detail-panel", [
              DesktopUi.Widgets.content("detail-header", [
                DesktopUi.Widgets.label("detail-title", "Details"),
                DesktopUi.Widgets.button("edit-button", "Edit",
                  navigate_to: :edit,
                  navigate_params: %{item_id: :item1}
                )
              ]),
              DesktopUi.Widgets.content("detail-content", [
                DesktopUi.Widgets.text("detail-name", "Item 1"),
                DesktopUi.Widgets.text("detail-desc", "Description for Item 1")
              ])
            ])
          ])
        ]),
      metadata: %{
        example_id: :master_detail_navigation,
        source: :native,
        coverage: [:navigation_widgets, :screen_navigation, :list_navigation],
        navigation_pattern: :master_detail,
        screens: [:master, :detail, :edit]
      }
    }
  end

  @spec navigation_transition_review() :: map()
  def navigation_transition_review do
    fixtures = navigation_fixtures()
    screen = navigation_review_screen()

    Enum.each(navigation_review_modules(), &Code.ensure_loaded?/1)

    {:ok, runtime_state} =
      DesktopUi.Runtime.mount_native_screen(screen,
        platform_target: :linux,
        screen_registry: NavigationReview.Registry,
        navigation_screen_id: :home
      )

    primary_window = runtime_state.windows.primary

    {:ok, after_navigate, navigate_route} =
      DesktopUi.Runtime.dispatch_native_event(
        runtime_state,
        family: :navigation,
        intent: fixtures.navigate.interaction.intent,
        widget_id: "settings-link",
        target: fixtures.navigate.descriptor.target,
        payload: fixtures.navigate.signal_data
      )

    {:ok, with_modal, modal_route} =
      DesktopUi.Runtime.dispatch_native_event(
        after_navigate,
        family: :navigation,
        intent: fixtures.modal.interaction.intent,
        widget_id: "settings-dialog-button",
        target: fixtures.modal.descriptor.target,
        payload: fixtures.modal.signal_data
      )

    {:ok, after_close, close_route} =
      DesktopUi.Runtime.dispatch_native_event(
        with_modal,
        family: :navigation,
        intent: :close_settings_modal,
        widget_id: "close-settings-dialog",
        target: close_modal_target()
      )

    {:ok, after_reports, reports_route} =
      DesktopUi.Runtime.dispatch_native_event(
        after_close,
        family: :navigation,
        intent: :open_reports_screen,
        widget_id: "reports-link",
        target: reports_target()
      )

    {:ok, after_back, back_route} =
      DesktopUi.Runtime.dispatch_native_event(
        after_reports,
        family: :navigation,
        intent: fixtures.back.interaction.intent,
        widget_id: "back-button",
        target: fixtures.back.descriptor.target,
        payload: fixtures.back.signal_data
      )

    {:ok, after_forward, forward_route} =
      DesktopUi.Runtime.dispatch_native_event(
        after_back,
        family: :navigation,
        intent: :go_forward,
        widget_id: "forward-button",
        target: forward_target()
      )

    {:ok, after_replace, replace_route} =
      DesktopUi.Runtime.dispatch_native_event(
        after_forward,
        family: :navigation,
        intent: fixtures.replace.interaction.intent,
        widget_id: "home-link",
        target: fixtures.replace.descriptor.target,
        payload: fixtures.replace.signal_data
      )

    expected_targets = navigation_fixture_targets(fixtures)

    route_summaries = %{
      navigate: navigation_route_summary(navigate_route),
      modal: navigation_route_summary(modal_route),
      close_modal: navigation_route_summary(close_route),
      reports: navigation_route_summary(reports_route),
      back: navigation_route_summary(back_route),
      forward: navigation_route_summary(forward_route),
      replace: navigation_route_summary(replace_route)
    }

    state_summaries = %{
      mounted: desktop_navigation_state_summary(runtime_state),
      after_navigate: desktop_navigation_state_summary(after_navigate),
      with_modal: desktop_navigation_state_summary(with_modal),
      after_close: desktop_navigation_state_summary(after_close),
      after_reports: desktop_navigation_state_summary(after_reports),
      after_back: desktop_navigation_state_summary(after_back),
      after_forward: desktop_navigation_state_summary(after_forward),
      after_replace: desktop_navigation_state_summary(after_replace)
    }

    %{
      id: :navigation_transition_review,
      summary:
        "Review canonical navigation transitions through the desktop screen registry and one shared window",
      coverage: [
        :canonical_navigation_transitions,
        :screen_registry,
        :history_stack,
        :modal_stack
      ],
      fixture_ids: navigation_fixture_ids(),
      fixture_targets: expected_targets,
      routes: route_summaries,
      states: state_summaries,
      parity: %{
        shared_fixture_targets_consumed?:
          Enum.all?(route_summaries, fn {step, summary} ->
            summary.target == expected_targets[step] and no_host_route_syntax?(summary.target)
          end),
        window_preserved_across_transitions?:
          Enum.all?(state_summaries, fn {_step, summary} ->
            summary.primary_window == primary_window
          end),
        registry_resolution_preserved?:
          state_summaries.after_navigate.title == "Settings" and
            state_summaries.after_reports.title == "Reports" and
            state_summaries.after_replace.title == "Home",
        history_semantics_preserved?:
          state_summaries.after_back.screen_id == "settings" and
            state_summaries.after_forward.screen_id == "reports" and
            state_summaries.after_replace.screen_id == "home" and
            state_summaries.after_replace.history_depth == 2,
        modal_stack_preserved?:
          state_summaries.with_modal.modal_depth == 1 and
            state_summaries.after_close.modal_depth == 0 and
            state_summaries.after_close.screen_id == "settings"
      }
    }
  end

  @spec normalized_input_comparison() :: map()
  def normalized_input_comparison do
    shortcut_profiles =
      DesktopUi.Platform.targets()
      |> Enum.map(fn target ->
        {:ok, normalized} =
          DesktopUi.Transport.normalize_native_event(
            platform_target: target,
            input_family: :shortcut,
            shortcut: if(target == :macos, do: "cmd-r", else: "ctrl-r"),
            widget_id: "refresh-command",
            runtime_id: "desktop-ui:transport",
            screen: "transport-review"
          )

        {target, normalized}
      end)
      |> Map.new()

    window_profiles =
      DesktopUi.Platform.targets()
      |> Enum.map(fn target ->
        {:ok, normalized} =
          DesktopUi.Transport.normalize_native_event(
            platform_target: target,
            input_family: :window,
            boundary: :local,
            window_action: :focus,
            window_id: "transport-window",
            runtime_id: "desktop-ui:transport",
            screen: "transport-review"
          )

        {target, normalized}
      end)
      |> Map.new()

    %{
      id: :normalized_input_profiles,
      parity: %{
        shortcut_family_match?:
          Enum.all?(shortcut_profiles, fn {_target, normalized} ->
            normalized.family == :command
          end),
        window_events_stay_local?:
          Enum.all?(window_profiles, fn {_target, normalized} ->
            normalized.boundary == :local and normalized.local_handling == :window_management
          end),
        local_boundary_split_visible?:
          Enum.all?(shortcut_profiles, fn {_target, normalized} ->
            normalized.boundary == :boundary
          end),
        platform_variation_bounded?:
          Enum.all?(DesktopUi.Platform.targets(), fn target ->
            shortcut_profiles[target].normalized_input.platform_target == target and
              window_profiles[target].normalized_input.platform_target == target
          end)
      },
      shortcut_profiles: shortcut_profiles,
      window_profiles: window_profiles
    }
  end

  @spec target_semantics() :: map()
  def target_semantics do
    contract = DesktopUi.Platform.capability_contract()

    DesktopUi.Platform.targets()
    |> Enum.map(fn target ->
      summary = DesktopUi.Platform.adapter_summary(target)

      {target,
       %{
         capabilities: summary.capabilities,
         menus: summary.menus,
         notifications: summary.notifications,
         shared_categories: contract.shared_categories,
         bounded_fallbacks: contract.bounded_fallbacks
       }}
    end)
    |> Map.new()
  end

  @spec metadata(atom()) :: map() | nil
  def metadata(id) when is_atom(id) do
    catalog()
    |> Enum.find(&(&1.id == id))
  end

  @spec native_examples() :: [map()]
  def native_examples, do: catalog_by_category(:native)

  @spec canonical_examples() :: [map()]
  def canonical_examples, do: catalog_by_category(:canonical)

  @spec mixed_examples() :: [map()]
  def mixed_examples, do: catalog_by_category(:mixed)

  @spec coverage_matrix() :: map()
  def coverage_matrix do
    catalog = catalog()

    %{
      categories: Enum.group_by(catalog, & &1.category, & &1.id),
      workflows: Enum.group_by(catalog, & &1.workflow, & &1.id),
      parity_groups:
        catalog
        |> Enum.group_by(& &1.parity_group, & &1.id)
        |> Map.delete(nil)
    }
  end

  @spec catalog() :: [map()]
  def catalog do
    catalog_entries()
    |> Enum.map(&decorate_catalog_entry/1)
  end

  @spec native_ids() :: [atom()]
  def native_ids,
    do: [
      :native_foundational,
      :native_advanced_operations,
      :native_transport_review,
      :native_styled_review,
      :basic_navigation,
      :history_navigation,
      :modal_navigation,
      :master_detail_navigation
    ]

  @spec canonical_ids() :: [atom()]
  def canonical_ids,
    do: [
      :canonical_foundational,
      :canonical_advanced_operations,
      :canonical_transport_review,
      :canonical_styled_review
    ]

  @spec comparison_ids() :: [atom()]
  def comparison_ids,
    do: [
      :foundational_continuity,
      :advanced_continuity,
      :transport_flow_review,
      :normalized_input_profiles,
      :styled_continuity_review,
      :navigation_transition_review
    ]

  defp catalog_by_category(category) do
    catalog()
    |> Enum.filter(&(&1.category == category))
  end

  defp decorate_catalog_entry(entry) do
    Map.merge(entry, %{
      traceability: traceability(entry),
      artifact_names: artifact_names(entry.id)
    })
  end

  defp artifact_names(id) do
    base = "desktop_ui.examples.#{id}"

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
      coverage_obligations: entry.coverage
    }
  end

  defp package_spec_surfaces(:native), do: [:native_widgets, :runtime, :tooling]
  defp package_spec_surfaces(:canonical), do: [:iur_renderer, :runtime, :tooling]
  defp package_spec_surfaces(:mixed), do: [:transport, :platform_artifacts, :tooling]

  defp runtime_obligations(:native), do: [:direct_native_reviewable, :shared_runtime]
  defp runtime_obligations(:canonical), do: [:canonical_reviewable, :shared_runtime]
  defp runtime_obligations(:mixed), do: [:continuity_reviewable, :platform_reviewable]

  defp catalog_entries do
    [
      %{
        id: :native_foundational,
        category: :native,
        workflow: :foundational_review,
        parity_group: :foundational_review,
        parity_with: [:canonical_foundational, :foundational_continuity],
        coverage: [
          :content_widgets,
          :action_widgets,
          :form_widgets,
          :navigation_widgets,
          :shared_runtime
        ]
      },
      %{
        id: :canonical_foundational,
        category: :canonical,
        workflow: :foundational_review,
        parity_group: :foundational_review,
        parity_with: [:native_foundational, :foundational_continuity],
        coverage: [:foundational_renderer, :shared_runtime, :widget_identity]
      },
      %{
        id: :foundational_continuity,
        category: :mixed,
        workflow: :foundational_review,
        parity_group: :foundational_review,
        parity_with: [:native_foundational, :canonical_foundational],
        coverage: [:continuity_review, :shared_runtime, :binding_alignment]
      },
      %{
        id: :native_advanced_operations,
        category: :native,
        workflow: :advanced_review,
        parity_group: :advanced_review,
        parity_with: [:canonical_advanced_operations, :advanced_continuity],
        coverage: [:advanced_widgets, :layered_runtime, :display_systems, :multiwindow_runtime]
      },
      %{
        id: :canonical_advanced_operations,
        category: :canonical,
        workflow: :advanced_review,
        parity_group: :advanced_review,
        parity_with: [:native_advanced_operations, :advanced_continuity],
        coverage: [:advanced_renderer, :layered_runtime, :multiwindow_runtime]
      },
      %{
        id: :advanced_continuity,
        category: :mixed,
        workflow: :advanced_review,
        parity_group: :advanced_review,
        parity_with: [:native_advanced_operations, :canonical_advanced_operations],
        coverage: [:continuity_review, :layer_alignment, :window_registry]
      },
      %{
        id: :native_transport_review,
        category: :native,
        workflow: :transport_review,
        parity_group: :transport_review,
        parity_with: [
          :canonical_transport_review,
          :transport_flow_review,
          :normalized_input_profiles
        ],
        coverage: [
          :canonical_boundary_events,
          :local_native_routing,
          :window_management,
          :normalized_desktop_inputs
        ]
      },
      %{
        id: :canonical_transport_review,
        category: :canonical,
        workflow: :transport_review,
        parity_group: :transport_review,
        parity_with: [:native_transport_review, :transport_flow_review],
        coverage: [:transport_renderer, :boundary_signal_translation, :shared_runtime]
      },
      %{
        id: :transport_flow_review,
        category: :mixed,
        workflow: :transport_review,
        parity_group: :transport_review,
        parity_with: [:native_transport_review, :canonical_transport_review],
        coverage: [:local_boundary_split, :signal_type_alignment, :normalized_input_families]
      },
      %{
        id: :normalized_input_profiles,
        category: :mixed,
        workflow: :transport_review,
        parity_group: :transport_review,
        parity_with: [:native_transport_review, :canonical_transport_review],
        coverage: [:platform_variation_bounded, :normalized_inputs, :window_management]
      },
      %{
        id: :native_styled_review,
        category: :native,
        workflow: :style_review,
        parity_group: :style_review,
        parity_with: [:canonical_styled_review, :styled_continuity_review],
        coverage: [
          :style_primitives,
          :theme_resolution,
          :component_variants,
          :artifact_review_surface
        ]
      },
      %{
        id: :canonical_styled_review,
        category: :canonical,
        workflow: :style_review,
        parity_group: :style_review,
        parity_with: [:native_styled_review, :styled_continuity_review],
        coverage: [:style_renderer, :theme_tokens, :shared_style_model]
      },
      %{
        id: :styled_continuity_review,
        category: :mixed,
        workflow: :style_review,
        parity_group: :style_review,
        parity_with: [:native_styled_review, :canonical_styled_review],
        coverage: [:style_continuity, :theme_alignment, :artifact_targets]
      },
      %{
        id: :navigation_transition_review,
        category: :mixed,
        workflow: :navigation_review,
        parity_group: :navigation_transition_review,
        parity_with: [
          :basic_navigation,
          :history_navigation,
          :modal_navigation,
          :master_detail_navigation
        ],
        coverage: [
          :canonical_navigation_transitions,
          :screen_registry,
          :history_stack,
          :modal_stack
        ]
      },
      # Navigation examples
      %{
        id: :basic_navigation,
        category: :native,
        workflow: :navigation_review,
        parity_group: nil,
        parity_with: [],
        coverage: [:navigation_widgets, :screen_navigation, :menu_navigation]
      },
      %{
        id: :history_navigation,
        category: :native,
        workflow: :navigation_review,
        parity_group: nil,
        parity_with: [],
        coverage: [:navigation_widgets, :screen_navigation, :history_stack]
      },
      %{
        id: :modal_navigation,
        category: :native,
        workflow: :navigation_review,
        parity_group: nil,
        parity_with: [],
        coverage: [:navigation_widgets, :screen_navigation, :modal_stack]
      },
      %{
        id: :master_detail_navigation,
        category: :native,
        workflow: :navigation_review,
        parity_group: nil,
        parity_with: [],
        coverage: [:navigation_widgets, :screen_navigation, :list_navigation]
      }
    ]
  end

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

  defp navigation_fixtures do
    %{
      navigate: BoundaryTransport.boundary_fixture!("screen_transition--settings_profile"),
      replace: BoundaryTransport.boundary_fixture!("replace_transition--home"),
      back: BoundaryTransport.boundary_fixture!("history_transition--back"),
      modal: BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")
    }
  end

  defp navigation_fixture_ids do
    [
      "screen_transition--settings_profile",
      "replace_transition--home",
      "history_transition--back",
      "modal_transition--settings_dialog"
    ]
  end

  defp navigation_fixture_targets(fixtures) do
    %{
      navigate: fixtures.navigate.descriptor.target,
      replace: fixtures.replace.descriptor.target,
      back: fixtures.back.descriptor.target,
      modal: fixtures.modal.descriptor.target,
      close_modal: close_modal_target(),
      reports: reports_target(),
      forward: forward_target()
    }
  end

  defp navigation_review_modules do
    [
      NavigationReview.HomeScreen,
      NavigationReview.SettingsScreen,
      NavigationReview.ReportsScreen,
      NavigationReview.SettingsDialogScreen,
      NavigationReview.Registry
    ]
  end

  defp navigation_review_screen do
    %{
      id: "desktop-navigation-review",
      title: "Desktop Navigation Review",
      root:
        DesktopUi.Widgets.window("desktop-navigation-window", "Desktop Navigation Review", [
          DesktopUi.Widgets.column("desktop-navigation-layout", [
            DesktopUi.Widgets.content("desktop-navigation-header", [
              DesktopUi.Widgets.label("desktop-navigation-title", "Desktop Navigation Review"),
              DesktopUi.Widgets.text(
                "desktop-navigation-subtitle",
                "Registered screens, history traversal, modal dialogs, and replacement transitions"
              )
            ]),
            DesktopUi.Widgets.row("desktop-navigation-actions", [
              DesktopUi.Widgets.button("settings-link", "Settings", navigate_to: :settings),
              DesktopUi.Widgets.button("reports-link", "Reports", navigate_to: :reports),
              DesktopUi.Widgets.button("home-link", "Replace With Home", replace_with: :home)
            ]),
            DesktopUi.Widgets.row("desktop-navigation-history", [
              DesktopUi.Widgets.button("back-button", "Back", go_back: true),
              DesktopUi.Widgets.button("forward-button", "Forward", go_forward: true)
            ]),
            DesktopUi.Widgets.row("desktop-navigation-modal", [
              DesktopUi.Widgets.button("settings-dialog-button", "Open Settings Dialog",
                open_modal: :settings_dialog,
                navigate_params: %{mode: :advanced}
              ),
              DesktopUi.Widgets.button("close-settings-dialog", "Close Settings Dialog",
                close_modal: true
              )
            ])
          ])
        ])
    }
  end

  defp reports_target do
    %{navigation: %{action: :navigate_to, screen: :reports, params: %{section: :daily}}}
  end

  defp forward_target do
    %{navigation: %{action: :go_forward}}
  end

  defp close_modal_target do
    %{navigation: %{action: :close_modal, modal: :settings_dialog}}
  end

  defp desktop_navigation_state_summary(state) do
    current_modal =
      case DesktopUi.Navigation.Integration.current_modal(state) do
        {id, _module, params} -> %{modal: id, params: params}
        nil -> nil
      end

    %{
      runtime_id: state.runtime_id,
      screen_id: state.screen_id,
      title: state.title,
      current_screen_module: state.current_screen_module,
      screen_params: state.screen_params,
      primary_window: state.windows.primary,
      history_depth: length(state.navigation_state.history),
      forward_depth: length(state.navigation_state.forward),
      modal_depth: length(state.navigation_state.modals),
      current_modal: current_modal
    }
  end

  defp navigation_route_summary(route_result) do
    translation = route_result.translation

    %{
      route: route_result.route,
      family: route_result.family,
      input_family: route_result.input_family,
      boundary: route_result.boundary,
      target: Map.get(translation, :target),
      signal_type:
        case Map.get(translation, :signal) do
          nil -> nil
          signal -> signal.type
        end
    }
  end

  defp no_host_route_syntax?(%{navigation: navigation}) when is_map(navigation) do
    not Map.has_key?(navigation, :route)
  end

  defp no_host_route_syntax?(_other), do: true

  defp root_for_sequence(%{kind: :window, children: [child | _rest]}), do: child
  defp root_for_sequence(tree), do: tree
end
