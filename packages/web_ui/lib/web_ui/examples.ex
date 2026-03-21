defmodule WebUi.Examples do
  @moduledoc """
  Maintained direct-native and canonical example inputs for `web_ui`.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias WebUi.Widgets

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

  @spec comparison_examples() :: map()
  def comparison_examples do
    %{
      native: native_counter_screen(),
      canonical: canonical_welcome_screen(),
      native_foundational: native_foundational_screen(),
      canonical_foundational: canonical_foundational_screen(),
      foundational_continuity: foundational_comparison()
    }
  end

  @spec catalog() :: [map()]
  def catalog do
    [
      %{id: :canonical_foundational, summary: "Canonical foundational workspace"},
      %{id: :canonical_welcome, summary: "Canonical welcome message"},
      %{id: :foundational_continuity, summary: "Native and canonical foundational comparison"},
      %{id: :native_counter, summary: "Minimal native counter"},
      %{id: :native_foundational, summary: "Direct-native foundational workspace"}
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

  defp snapshot(widget_tree, frontend_tree) do
    %{
      widget_ids: collect_widget_ids(widget_tree),
      widget_kinds: collect_widget_kinds(widget_tree),
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

  defp collect_render_tags(node) when is_map(node) do
    [node.tag] ++
      (node.slots
       |> Enum.flat_map(& &1.children)
       |> Enum.flat_map(&collect_render_tags/1))
  end
end
