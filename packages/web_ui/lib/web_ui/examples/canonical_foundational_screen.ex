defmodule WebUi.Examples.CanonicalFoundationalScreen do
  @moduledoc """
  Canonical foundational example rendered through the `web_ui` baseline IUR
  renderer.
  """

  alias UnifiedIUR.{Forms, Layout}
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Widgets.{Foundational, Input, Navigation}

  @spec element() :: UnifiedIUR.Element.t()
  def element do
    header =
      Foundational.content(
        [
          Foundational.text("Workspace", id: "workspace-title"),
          Navigation.tabs(
            [
              [id: :overview, label: "Overview", active?: true],
              [id: :activity, label: "Activity"]
            ],
            id: "workspace-tabs",
            active_item: :overview,
            interactions: [Interaction.navigation(intent: :switch_tab)]
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
                  value: "Pascal",
                  placeholder: "Search",
                  interactions: [Interaction.change(intent: :rename_query)]
                ),
                id: "query-field",
                name: :query,
                label: "Search Query",
                help: Foundational.text("Used for preview filtering", id: "query-input-help")
              ),
              Forms.field(
                Input.checkbox(
                  id: "alerts-checkbox",
                  name: :alerts,
                  value: true,
                  interactions: [Interaction.change(intent: :toggle_alerts)]
                ),
                id: "alerts-field",
                name: :alerts,
                label: "Alerts",
                help:
                  Foundational.text("Enable workspace notifications",
                    id: "alerts-checkbox-help"
                  )
              )
            ],
            id: "workspace-group",
            legend: "Workspace"
          )
        ],
        id: "workspace-form",
        submit_intent: :save_workspace
      )

    actions =
      Layout.row(
        [
          Foundational.button("Save",
            id: "save-button",
            interaction: Interaction.submit(intent: :save_workspace)
          )
        ],
        id: "workspace-actions",
        justify: :end
      )

    Layout.column([header, form, actions],
      id: "workspace-layout",
      gap: :lg,
      description: "Canonical foundational workspace"
    )
  end

  @spec render_view_state(keyword()) ::
          {:ok, WebUi.Server.ViewState.t()}
          | {:error, WebUi.Renderer.Error.t() | WebUi.Server.Error.t()}
  def render_view_state(opts \\ []) do
    WebUi.Renderer.render_view_state(
      element(),
      Keyword.merge([screen_id: :canonical_foundational, title: "Canonical Foundational"], opts)
    )
  end

  def metadata do
    %{
      id: :canonical_foundational,
      title: "Canonical Foundational",
      families: [:foundational, :input, :navigation],
      comparable_to: :native_foundational,
      summary: "Canonical foundational workspace rendered through web_ui."
    }
  end
end
