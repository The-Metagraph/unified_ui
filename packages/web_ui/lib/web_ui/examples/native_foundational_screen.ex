defmodule WebUi.Examples.NativeFoundationalScreen do
  @moduledoc """
  Review-friendly direct-native foundational screen covering content, form, and
  navigation widgets.
  """

  use WebUi.Server.Screen, id: :native_foundational, title: "Native Foundational"

  alias WebUi.Widgets.{Forms, Foundational, Input, Layout, Navigation}

  @impl true
  def mount_defaults do
    %{query: "Pascal", alerts?: true, active_tab: :overview, saved?: false}
  end

  @impl true
  def event_routes do
    %{
      "rename_query" => :rename_query,
      "toggle_alerts" => :toggle_alerts,
      "switch_tab" => :switch_tab,
      "save_workspace" => :save_workspace
    }
  end

  @impl true
  def view(assigns) do
    header =
      Foundational.content(
        [
          Foundational.text("Workspace", id: "workspace-title"),
          Navigation.tabs(
            [
              [id: :overview, label: "Overview", active?: assigns.active_tab == :overview],
              [id: :activity, label: "Activity", active?: assigns.active_tab == :activity]
            ],
            id: "workspace-tabs",
            active_item: assigns.active_tab,
            navigation: "switch_tab"
          )
        ],
        id: "workspace-header",
        presentation: :banner
      )

    form =
      Forms.form_builder(
        [
          Forms.field_group(
            [
              Forms.field(
                Input.text_input(
                  id: "query-input",
                  name: :query,
                  value: assigns.query,
                  placeholder: "Search",
                  change: "rename_query"
                ),
                id: "query-field",
                name: :query,
                label: "Search Query",
                help: "Used for preview filtering"
              ),
              Forms.field(
                Input.checkbox(
                  id: "alerts-checkbox",
                  name: :alerts,
                  value: assigns.alerts?,
                  checked?: assigns.alerts?,
                  change: "toggle_alerts"
                ),
                id: "alerts-field",
                name: :alerts,
                label: "Alerts",
                help: "Enable workspace notifications"
              )
            ],
            id: "workspace-group",
            legend: "Workspace"
          )
        ],
        id: "workspace-form",
        submit: "save_workspace"
      )

    actions =
      Layout.row(
        [
          Foundational.button("Save", id: "save-button", click: "save_workspace")
        ],
        id: "workspace-actions",
        justify: :end
      )

    [
      Layout.column([header, form, actions],
        id: "workspace-layout",
        gap: :lg
      )
    ]
  end

  @impl true
  def handle_event(:rename_query, %{"query" => query}, assigns),
    do: {:ok, %{assigns | query: query}}

  def handle_event(:toggle_alerts, %{"alerts" => alerts}, assigns) do
    {:ok, %{assigns | alerts?: alerts in [true, "true", "on", 1]}}
  end

  def handle_event(:switch_tab, %{"tab" => tab}, assigns) do
    active_tab =
      case tab do
        "activity" -> :activity
        :activity -> :activity
        _other -> :overview
      end

    {:ok, %{assigns | active_tab: active_tab}}
  end

  def handle_event(:save_workspace, _payload, assigns), do: {:ok, %{assigns | saved?: true}}

  @impl true
  def frontend_boot do
    %{entry: :native_foundational, comparable_to: :canonical_foundational}
  end

  def metadata do
    %{
      id: :native_foundational,
      title: title(),
      families: [:foundational, :input, :navigation],
      comparable_to: :canonical_foundational,
      summary: "Direct-native foundational workspace example."
    }
  end
end
