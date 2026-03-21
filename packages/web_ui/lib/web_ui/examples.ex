defmodule WebUi.Examples do
  @moduledoc """
  Maintained direct-native and canonical example inputs for `web_ui`.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias WebUi.Widgets

  @display_kinds [:viewport, :scroll_bar, :split_pane]
  @layer_kinds [:overlay, :dialog, :toast, :alert_dialog, :context_menu]

  @spec native_counter_screen() :: map()
  def native_counter_screen do
    Widgets.screen("native-counter", "Native Counter", [
      Widgets.text(:count, "0", styles: %{tone: :accent}),
      Widgets.button(:increment, "Increment",
        on_click: %{family: :click, intent: :increment, boundary: :local}
      )
    ])
  end

  @spec canonical_welcome_screen() :: Element.t()
  def canonical_welcome_screen do
    Element.new(:widget, :text,
      id: "welcome-message",
      attributes: %{content: "Welcome to web_ui"}
    )
  end

  @spec native_foundational_screen() :: map()
  def native_foundational_screen do
    %{
      id: "workspace-layout",
      title: "Native Foundational",
      root:
        Widgets.column("workspace-layout", [
          Widgets.content("workspace-header", [
            Widgets.text("workspace-title", "Workspace"),
            Widgets.tabs(
              "workspace-tabs",
              [
                [id: :overview, label: "Overview", active: true],
                [id: :activity, label: "Activity"]
              ],
              active_item: :overview,
              on_navigate: %{intent: :switch_tab}
            )
          ]),
          Widgets.form(
            "workspace-form",
            [
              Widgets.field_group(
                "workspace-group",
                [
                  Widgets.field(
                    "query-field",
                    Widgets.text_input("query-input",
                      name: :query,
                      value: "Pascal",
                      placeholder: "Search",
                      on_change: %{intent: :rename_query}
                    ),
                    name: :query,
                    label: "Search Query",
                    help: "Used for preview filtering"
                  ),
                  Widgets.field(
                    "alerts-field",
                    Widgets.checkbox("alerts-checkbox", "Alerts",
                      name: :alerts,
                      checked: true,
                      on_change: %{intent: :toggle_alerts}
                    ),
                    name: :alerts,
                    label: "Alerts",
                    help: "Enable workspace notifications"
                  )
                ],
                legend: "Workspace"
              )
            ],
            on_submit: %{intent: :save_workspace}
          ),
          Widgets.row(
            "workspace-actions",
            [
              Widgets.button("save-button", "Save", on_click: %{intent: :save_workspace})
            ],
            justify: :end
          )
        ]),
      metadata: %{source: :native_foundational, bridge: :phoenix_elm}
    }
  end

  @spec canonical_foundational_screen() :: Element.t()
  def canonical_foundational_screen do
    Element.new(:layout, :column,
      id: "workspace-layout",
      children: [
        Element.new(:widget, :content,
          id: "workspace-header",
          children: [
            Element.new(:widget, :text,
              id: "workspace-title",
              attributes: %{content: "Workspace"}
            ),
            Element.new(:widget, :tabs,
              id: "workspace-tabs",
              attributes: %{
                active_item: :overview,
                items: [
                  %{id: :overview, label: "Overview", active: true},
                  %{id: :activity, label: "Activity"}
                ]
              }
            )
          ]
        ),
        Element.new(:composite, :form,
          id: "workspace-form",
          children: [
            Element.new(:composite, :field_group,
              id: "workspace-group",
              attributes: %{legend: "Workspace"},
              children: [
                Element.new(:composite, :field,
                  id: "query-field",
                  attributes: %{name: :query},
                  children: [
                    Child.new(
                      :label,
                      Element.new(:widget, :label,
                        id: "query-field-label",
                        attributes: %{content: "Search Query"}
                      )
                    ),
                    Child.new(
                      :control,
                      Element.new(:widget, :text_input,
                        id: "query-input",
                        attributes: %{name: :query, value: "Pascal", placeholder: "Search"}
                      )
                    ),
                    Child.new(
                      :help,
                      Element.new(:widget, :text,
                        id: "query-input-help",
                        attributes: %{content: "Used for preview filtering"}
                      )
                    )
                  ]
                ),
                Element.new(:composite, :field,
                  id: "alerts-field",
                  attributes: %{name: :alerts},
                  children: [
                    Child.new(
                      :label,
                      Element.new(:widget, :label,
                        id: "alerts-field-label",
                        attributes: %{content: "Alerts"}
                      )
                    ),
                    Child.new(
                      :control,
                      Element.new(:widget, :checkbox,
                        id: "alerts-checkbox",
                        attributes: %{name: :alerts, checked: true, label: "Alerts"}
                      )
                    ),
                    Child.new(
                      :help,
                      Element.new(:widget, :text,
                        id: "alerts-checkbox-help",
                        attributes: %{content: "Enable workspace notifications"}
                      )
                    )
                  ]
                )
              ]
            )
          ]
        ),
        Element.new(:layout, :row,
          id: "workspace-actions",
          attributes: %{justify: :end},
          children: [
            Element.new(:widget, :button,
              id: "save-button",
              attributes: %{label: "Save"}
            )
          ]
        )
      ]
    )
  end

  @spec native_transport_screen() :: map()
  def native_transport_screen do
    Widgets.screen(
      "transport-workspace",
      "Native Transport Workspace",
      [
        Widgets.content("transport-header", [
          Widgets.text("transport-title", "Transport Workspace"),
          Widgets.inline_feedback(
            "transport-feedback",
            "Direct native usage keeps this workflow local."
          )
        ]),
        Widgets.form(
          "transport-form",
          [
            Widgets.field_group(
              "transport-group",
              [
                Widgets.field(
                  "transport-query-field",
                  Widgets.text_input("transport-query-input",
                    name: :query,
                    value: "status:ready",
                    placeholder: "Filter nodes",
                    on_change: %{family: :change, intent: :refine_query, boundary: :local}
                  ),
                  name: :query,
                  label: "Query"
                )
              ],
              legend: "Transport Filter"
            )
          ],
          on_submit: %{family: :submit, intent: :save_workspace, boundary: :local}
        ),
        Widgets.row(
          "transport-actions",
          [
            Widgets.button("preview-button", "Preview",
              on_click: %{family: :open, intent: :open_preview, boundary: :local}
            ),
            Widgets.button("save-button", "Save Workspace",
              on_click: %{family: :submit, intent: :save_workspace, boundary: :local}
            )
          ],
          justify: :end,
          gap: :md
        )
      ],
      source: :native_transport,
      bridge: :phoenix_elm
    )
  end

  @spec canonical_transport_screen() :: Element.t()
  def canonical_transport_screen do
    Element.new(:layout, :column,
      id: "transport-workspace",
      attributes: %{gap: :md},
      children: [
        Element.new(:widget, :content,
          id: "transport-header",
          children: [
            Element.new(:widget, :text,
              id: "transport-title",
              attributes: %{content: "Transport Workspace"}
            ),
            Element.new(:widget, :inline_feedback,
              id: "transport-feedback",
              attributes: %{
                message: "Canonical rendering crosses the boundary for the same workflow."
              }
            )
          ]
        ),
        Element.new(:composite, :form,
          id: "transport-form",
          children: [
            Element.new(:composite, :field_group,
              id: "transport-group",
              attributes: %{legend: "Transport Filter"},
              children: [
                Element.new(:composite, :field,
                  id: "transport-query-field",
                  attributes: %{name: :query},
                  children: [
                    Child.new(
                      :label,
                      Element.new(:widget, :label,
                        id: "transport-query-label",
                        attributes: %{content: "Query"}
                      )
                    ),
                    Child.new(
                      :control,
                      Element.new(:widget, :text_input,
                        id: "transport-query-input",
                        attributes: %{
                          name: :query,
                          value: "status:ready",
                          placeholder: "Filter nodes"
                        }
                      )
                    )
                  ]
                )
              ]
            )
          ]
        ),
        Element.new(:layout, :row,
          id: "transport-actions",
          attributes: %{justify: :end, gap: :md},
          children: [
            Element.new(:widget, :button,
              id: "preview-button",
              attributes: %{label: "Preview"}
            ),
            Element.new(:widget, :button,
              id: "save-button",
              attributes: %{label: "Save Workspace"}
            )
          ]
        )
      ]
    )
  end

  @spec native_advanced_screen() :: map()
  def native_advanced_screen do
    %{
      id: "advanced-operations",
      title: "Native Advanced Operations",
      root:
        Widgets.column(
          "advanced-operations",
          [
            Widgets.content("advanced-header", [
              Widgets.text("advanced-title", "Operations Workspace"),
              Widgets.status("cluster-status", "Watching cluster", severity: :info)
            ]),
            WebUi.Layer.overlay(
              "operations-overlay",
              WebUi.Layout.split_pane(
                "operations-split",
                WebUi.Layout.viewport(
                  "log-viewport",
                  Widgets.log_viewer(
                    "ops-log-viewer",
                    [
                      [
                        id: "log-1",
                        message: "Accepted connection",
                        severity: :info,
                        timestamp: "2026-03-21T09:00:00Z"
                      ],
                      [
                        id: "log-2",
                        message: "Replica promoted",
                        severity: :warning,
                        timestamp: "2026-03-21T09:02:00Z"
                      ]
                    ],
                    follow: true
                  ),
                  offset: {0, 120},
                  height: 24,
                  sync_group: :logs
                ),
                Widgets.column(
                  "operations-secondary",
                  [
                    Widgets.table(
                      "cluster-table",
                      [
                        [id: :name, label: "Name", sortable: true],
                        [id: :status, label: "Status"]
                      ],
                      [
                        [id: "node-a", cells: ["Node A", "healthy"]],
                        [id: "node-b", cells: ["Node B", "degraded"]]
                      ],
                      sort_key: :name,
                      sort_direction: :asc
                    ),
                    Widgets.row(
                      "operations-metrics",
                      [
                        Widgets.progress("deploy-progress",
                          current: 3,
                          total: 5,
                          label: "Deploy"
                        ),
                        Widgets.gauge("cluster-gauge", value: 72, label: "Cluster Health"),
                        Widgets.sparkline("throughput-sparkline", [12, 16, 18, 17])
                      ],
                      gap: :lg
                    ),
                    Widgets.bar_chart("requests-chart", [
                      [id: :requests, label: "Requests", values: [12, 18, 16]],
                      [id: :errors, label: "Errors", values: [1, 0, 2]]
                    ]),
                    Widgets.command_palette(
                      "ops-command-palette",
                      [
                        [id: :deploy, label: "Deploy", value: :deploy],
                        [id: :rollback, label: "Rollback", value: :rollback]
                      ],
                      query: "deploy"
                    ),
                    Widgets.canvas(
                      "cluster-canvas",
                      [
                        [kind: :cell, position: {0, 0}, text: "A", style_refs: [:accent]],
                        [kind: :cell, position: {1, 0}, text: "B"]
                      ],
                      width: 20,
                      height: 10
                    ),
                    Widgets.cluster_dashboard(
                      "cluster-dashboard",
                      [
                        [id: "node-a", status: :healthy],
                        [id: "node-b", status: :degraded]
                      ],
                      summary: %{healthy: 1, degraded: 1}
                    )
                  ],
                  gap: :lg
                ),
                ratio: 0.6
              ),
              [
                WebUi.Layer.dialog(
                  "inspect-dialog",
                  Widgets.content("dialog-content", [
                    Widgets.markdown_viewer("dialog-doc", "# Inspect\n\nNode A is healthy.")
                  ]),
                  title: "Inspect Node",
                  modal: true
                ),
                WebUi.Layer.toast(
                  "deploy-toast",
                  Widgets.text("toast-copy", "Deploy complete"),
                  placement: :top_end
                )
              ],
              on_dismiss: %{intent: :dismiss_overlay}
            ),
            WebUi.Layout.scroll_bar("log-scrollbar",
              viewport_ref: "log-viewport",
              viewport_size: 24,
              content_size: 120,
              sync_group: :logs
            )
          ],
          gap: :lg
        ),
      metadata: %{source: :native_advanced, bridge: :phoenix_elm}
    }
  end

  @spec canonical_advanced_screen() :: Element.t()
  def canonical_advanced_screen do
    Element.new(:layout, :column,
      id: "advanced-operations",
      attributes: %{gap: :lg},
      children: [
        Element.new(:widget, :content,
          id: "advanced-header",
          children: [
            Element.new(:widget, :text,
              id: "advanced-title",
              attributes: %{content: "Operations Workspace"}
            ),
            Element.new(:widget, :status,
              id: "cluster-status",
              attributes: %{text: "Watching cluster", severity: :info}
            )
          ]
        ),
        Element.new(:layer, :overlay,
          id: "operations-overlay",
          attributes: %{events: %{dismiss: %{intent: :dismiss_overlay}}},
          children: [
            Child.new(
              :base,
              Element.new(:layout, :split_pane,
                id: "operations-split",
                attributes: %{ratio: 0.6},
                children: [
                  Child.new(
                    :primary,
                    Element.new(:layout, :viewport,
                      id: "log-viewport",
                      attributes: %{offset: %{x: 0, y: 120}, height: 24, sync_group: :logs},
                      children: [
                        Child.new(
                          :content,
                          Element.new(:widget, :log_viewer,
                            id: "ops-log-viewer",
                            attributes: %{
                              entries: [
                                %{
                                  id: "log-1",
                                  message: "Accepted connection",
                                  severity: :info,
                                  timestamp: "2026-03-21T09:00:00Z"
                                },
                                %{
                                  id: "log-2",
                                  message: "Replica promoted",
                                  severity: :warning,
                                  timestamp: "2026-03-21T09:02:00Z"
                                }
                              ],
                              follow: true
                            }
                          )
                        )
                      ]
                    )
                  ),
                  Child.new(
                    :secondary,
                    Element.new(:layout, :column,
                      id: "operations-secondary",
                      attributes: %{gap: :lg},
                      children: [
                        Element.new(:widget, :table,
                          id: "cluster-table",
                          attributes: %{
                            columns: [
                              %{id: :name, label: "Name", sortable: true},
                              %{id: :status, label: "Status"}
                            ],
                            rows: [
                              %{id: "node-a", cells: ["Node A", "healthy"]},
                              %{id: "node-b", cells: ["Node B", "degraded"]}
                            ],
                            sort_key: :name,
                            sort_direction: :asc
                          }
                        ),
                        Element.new(:layout, :row,
                          id: "operations-metrics",
                          attributes: %{gap: :lg},
                          children: [
                            Element.new(:widget, :progress,
                              id: "deploy-progress",
                              attributes: %{current: 3, total: 5, label: "Deploy"}
                            ),
                            Element.new(:widget, :gauge,
                              id: "cluster-gauge",
                              attributes: %{value: 72, label: "Cluster Health"}
                            ),
                            Element.new(:widget, :sparkline,
                              id: "throughput-sparkline",
                              attributes: %{series: [[12, 16, 18, 17]]}
                            )
                          ]
                        ),
                        Element.new(:widget, :bar_chart,
                          id: "requests-chart",
                          attributes: %{
                            series: [
                              %{id: :requests, label: "Requests", values: [12, 18, 16]},
                              %{id: :errors, label: "Errors", values: [1, 0, 2]}
                            ]
                          }
                        ),
                        Element.new(:widget, :command_palette,
                          id: "ops-command-palette",
                          attributes: %{
                            commands: [
                              %{id: :deploy, label: "Deploy", value: :deploy},
                              %{id: :rollback, label: "Rollback", value: :rollback}
                            ],
                            query: "deploy"
                          }
                        ),
                        Element.new(:widget, :canvas,
                          id: "cluster-canvas",
                          attributes: %{
                            operations: [
                              %{
                                kind: :cell,
                                position: %{x: 0, y: 0},
                                text: "A",
                                style_refs: [:accent]
                              },
                              %{kind: :cell, position: %{x: 1, y: 0}, text: "B"}
                            ],
                            width: 20,
                            height: 10
                          }
                        ),
                        Element.new(:widget, :cluster_dashboard,
                          id: "cluster-dashboard",
                          attributes: %{
                            nodes: [
                              %{id: "node-a", status: :healthy},
                              %{id: "node-b", status: :degraded}
                            ],
                            summary: %{healthy: 1, degraded: 1}
                          }
                        )
                      ]
                    )
                  )
                ]
              )
            ),
            Child.new(
              :layers,
              Element.new(:layer, :dialog,
                id: "inspect-dialog",
                attributes: %{title: "Inspect Node", modal: true},
                children: [
                  Child.new(
                    :content,
                    Element.new(:widget, :content,
                      id: "dialog-content",
                      children: [
                        Element.new(:widget, :markdown_viewer,
                          id: "dialog-doc",
                          attributes: %{source: "# Inspect\n\nNode A is healthy."}
                        )
                      ]
                    )
                  )
                ]
              )
            ),
            Child.new(
              :layers,
              Element.new(:layer, :toast,
                id: "deploy-toast",
                attributes: %{placement: :top_end},
                children: [
                  Child.new(
                    :content,
                    Element.new(:widget, :text,
                      id: "toast-copy",
                      attributes: %{content: "Deploy complete"}
                    )
                  )
                ]
              )
            )
          ]
        ),
        Element.new(:widget, :scroll_bar,
          id: "log-scrollbar",
          attributes: %{
            viewport_ref: "log-viewport",
            viewport_size: 24,
            content_size: 120,
            sync_group: :logs
          }
        )
      ]
    )
  end

  @spec comparison_examples() :: map()
  def comparison_examples do
    %{
      native: native_counter_screen(),
      canonical: canonical_welcome_screen(),
      native_foundational: native_foundational_screen(),
      canonical_foundational: canonical_foundational_screen(),
      foundational_continuity: foundational_comparison(),
      native_transport: native_transport_screen(),
      canonical_transport: canonical_transport_screen(),
      mixed_transport: mixed_transport_comparison(),
      native_advanced: native_advanced_screen(),
      canonical_advanced: canonical_advanced_screen(),
      advanced_continuity: advanced_comparison()
    }
  end

  @spec catalog() :: [map()]
  def catalog do
    [
      %{id: :canonical_foundational, summary: "Canonical foundational workspace"},
      %{id: :canonical_advanced, summary: "Canonical advanced operations workspace"},
      %{id: :canonical_transport, summary: "Canonical transport-focused workspace"},
      %{id: :canonical_welcome, summary: "Canonical welcome message"},
      %{id: :advanced_continuity, summary: "Native and canonical advanced comparison"},
      %{id: :foundational_continuity, summary: "Native and canonical foundational comparison"},
      %{id: :mixed_transport, summary: "Native and canonical transport workflow comparison"},
      %{id: :native_advanced, summary: "Direct-native advanced operations workspace"},
      %{id: :native_counter, summary: "Minimal native counter"},
      %{id: :native_foundational, summary: "Direct-native foundational workspace"},
      %{id: :native_transport, summary: "Direct-native transport-focused workspace"}
    ]
  end

  @spec foundational_comparison() :: map()
  def foundational_comparison do
    {:ok, native_state} = WebUi.Runtime.mount_native_screen(native_foundational_screen())
    {:ok, native_frontend} = WebUi.Runtime.hydrate_frontend(native_state)

    {:ok, canonical_state} = WebUi.Runtime.mount_iur_screen(canonical_foundational_screen())
    {:ok, canonical_frontend} = WebUi.Runtime.hydrate_frontend(canonical_state)

    native = snapshot(native_state.rendered_tree, native_frontend.tree)
    canonical = snapshot(canonical_state.rendered_tree, canonical_frontend.tree)

    %{
      native: native,
      canonical: canonical,
      continuity: %{
        widget_kinds_match?: native.widget_kinds == canonical.widget_kinds,
        render_tags_match?: native.render_tags == canonical.render_tags,
        shared_ids:
          native.widget_ids
          |> Enum.filter(&(&1 in canonical.widget_ids))
          |> Enum.uniq()
          |> Enum.sort()
      }
    }
  end

  @spec advanced_comparison() :: map()
  def advanced_comparison do
    {:ok, native_state} = WebUi.Runtime.mount_native_screen(native_advanced_screen())
    {:ok, native_frontend} = WebUi.Runtime.hydrate_frontend(native_state)

    {:ok, canonical_state} = WebUi.Runtime.mount_iur_screen(canonical_advanced_screen())
    {:ok, canonical_frontend} = WebUi.Runtime.hydrate_frontend(canonical_state)

    native = snapshot(native_state.rendered_tree, native_frontend.tree)
    canonical = snapshot(canonical_state.rendered_tree, canonical_frontend.tree)

    %{
      native: native,
      canonical: canonical,
      continuity: %{
        widget_kinds_match?: native.widget_kinds == canonical.widget_kinds,
        render_tags_match?: native.render_tags == canonical.render_tags,
        display_kinds_match?: native.display_kinds == canonical.display_kinds,
        layer_kinds_match?: native.layer_kinds == canonical.layer_kinds,
        shared_ids:
          native.widget_ids
          |> Enum.filter(&(&1 in canonical.widget_ids))
          |> Enum.uniq()
          |> Enum.sort()
      }
    }
  end

  @spec mixed_transport_comparison() :: map()
  def mixed_transport_comparison do
    {:ok, native_state} =
      WebUi.Runtime.mount_native_screen(native_transport_screen(), runtime_id: "native-transport")

    {:ok, native_frontend} = WebUi.Runtime.hydrate_frontend(native_state)

    {:ok, native_frontend_after_dispatch, native_event_message} =
      WebUi.FrontendRuntime.dispatch_interaction(native_frontend,
        family: :submit,
        intent: :save_workspace,
        boundary: :local,
        widget_id: "save-button",
        payload: %{mode: :draft}
      )

    {:ok, native_state_after_event, native_ack} =
      WebUi.Runtime.handle_frontend_event(native_state, native_event_message)

    {:ok, canonical_state} =
      WebUi.Runtime.mount_iur_screen(
        canonical_transport_screen(),
        runtime_id: "canonical-transport"
      )

    {:ok, canonical_frontend} = WebUi.Runtime.hydrate_frontend(canonical_state)

    {:ok, canonical_frontend_after_dispatch, canonical_event_message} =
      WebUi.FrontendRuntime.dispatch_interaction(canonical_frontend,
        family: :submit,
        intent: :save_workspace,
        widget_id: "save-button",
        payload: %{mode: :commit}
      )

    {:ok, canonical_state_after_event, canonical_ack} =
      WebUi.Runtime.handle_frontend_event(canonical_state, canonical_event_message)

    %{
      native: %{
        screen_id: native_state_after_event.screen_id,
        boundary: native_event_message.metadata.boundary,
        mode: List.last(native_state_after_event.event_log).mode,
        ack: native_ack.payload,
        frontend_scope: native_frontend_after_dispatch.local_state.flash.scope
      },
      canonical: %{
        screen_id: canonical_state_after_event.screen_id,
        boundary: canonical_event_message.metadata.boundary,
        mode: List.last(canonical_state_after_event.event_log).mode,
        ack: canonical_ack.payload,
        signal_type: canonical_state_after_event.last_boundary_signal.type,
        frontend_scope: canonical_frontend_after_dispatch.local_state.flash.scope
      },
      continuity: %{
        same_family?: native_ack.payload.family == canonical_ack.payload.family,
        same_intent?: native_ack.payload.intent == canonical_ack.payload.intent,
        local_and_boundary_paths_diverge?:
          native_event_message.metadata.boundary == :local and
            canonical_event_message.metadata.boundary == :boundary,
        server_authority_preserved?:
          native_ack.payload.server_authority and canonical_ack.payload.server_authority
      }
    }
  end

  defp snapshot(widget_tree, frontend_tree) do
    %{
      widget_ids: collect_widget_ids(widget_tree),
      widget_kinds: collect_widget_kinds(widget_tree),
      display_kinds: collect_filtered_kinds(widget_tree, @display_kinds),
      layer_kinds: collect_filtered_kinds(widget_tree, @layer_kinds),
      render_tags: collect_render_tags(frontend_tree)
    }
  end

  defp collect_widget_ids(%WebUi.Widget{} = widget) do
    [to_string(widget.id)] ++
      (widget.slot_children
       |> Map.values()
       |> List.flatten()
       |> Enum.flat_map(&collect_widget_ids/1))
  end

  defp collect_widget_kinds(%WebUi.Widget{} = widget) do
    [widget.kind] ++
      (widget.slot_children
       |> Map.values()
       |> List.flatten()
       |> Enum.flat_map(&collect_widget_kinds/1))
  end

  defp collect_filtered_kinds(%WebUi.Widget{} = widget, allowed) do
    widget
    |> collect_widget_kinds()
    |> Enum.filter(&(&1 in allowed))
  end

  defp collect_render_tags(node) when is_map(node) do
    [node.tag] ++
      (node.slots
       |> Enum.flat_map(& &1.children)
       |> Enum.flat_map(&collect_render_tags/1))
  end
end
