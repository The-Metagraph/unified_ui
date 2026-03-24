defmodule DesktopUi.Examples do
  @moduledoc """
  Maintained foundational and advanced native and canonical examples for `desktop_ui`.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child

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

  @spec native_ids() :: [atom()]
  def native_ids,
    do: [:native_foundational, :native_advanced_operations, :native_transport_review]

  @spec canonical_ids() :: [atom()]
  def canonical_ids,
    do: [:canonical_foundational, :canonical_advanced_operations, :canonical_transport_review]

  @spec comparison_ids() :: [atom()]
  def comparison_ids,
    do: [
      :foundational_continuity,
      :advanced_continuity,
      :transport_flow_review,
      :normalized_input_profiles
    ]

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
