defmodule LiveUi.AshUiWidgetPortabilityPhase3IntegrationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.{Binding, Collection, Fixtures, Forms, Interaction, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Input, Semantic}

  @portable_markers [
    "disclosure",
    "kicker",
    "avatar",
    "presence-dot",
    "segmented-button-group",
    "list-item-multi-column",
    "artifact-row",
    "sticky-header",
    "pipeline-stepper-horizontal",
    "segmented-progress-bar",
    "workflow-stage-list-vertical",
    "meter-thin",
    "slide-over-panel",
    "event-callout",
    "redline-inline",
    "code-block-syntax-highlighted",
    "chat-composer",
    "repeated-collection"
  ]

  @native_cases [
    {LiveUi.Widgets.Disclosure, %{id: "native-disclosure", label: "Release notes", open: true},
     "disclosure"},
    {LiveUi.Widgets.Kicker, %{id: "native-kicker", value: "Workflow"}, "kicker"},
    {LiveUi.Widgets.Avatar, %{id: "native-avatar", label: "Pat", initials: "PC"}, "avatar"},
    {LiveUi.Widgets.PresenceDot, %{id: "native-presence", status: "online"}, "presence-dot"},
    {LiveUi.Widgets.SegmentedButtonGroup,
     %{id: "native-segments", items: [compact: "Compact"], active_item: :compact},
     "segmented-button-group"},
    {LiveUi.Widgets.ListItemMultiColumn,
     %{id: "native-list-item", label: "Artifact", columns: [name: "artifact.tar"]},
     "list-item-multi-column"},
    {LiveUi.Widgets.ArtifactRow,
     %{id: "native-artifact", title: "artifact.tar", artifact: %{id: "artifact-1"}},
     "artifact-row"},
    {LiveUi.Widgets.StickyHeader, %{id: "native-header", title: "Results"}, "sticky-header"},
    {LiveUi.Widgets.PipelineStepperHorizontal,
     %{id: "native-pipeline", steps: [:queued, :building], active_item: :building},
     "pipeline-stepper-horizontal"},
    {LiveUi.Widgets.SegmentedProgressBar,
     %{id: "native-progress", segments: [queued: 20, building: 80], current: 80},
     "segmented-progress-bar"},
    {LiveUi.Widgets.WorkflowStageListVertical,
     %{id: "native-stages", stages: [:plan, :build], active_item: :build},
     "workflow-stage-list-vertical"},
    {LiveUi.Widgets.MeterThin, %{id: "native-meter", current: 82}, "meter-thin"},
    {LiveUi.Widgets.SlideOverPanel, %{id: "native-panel", title: "Details", visible: true},
     "slide-over-panel"},
    {LiveUi.Widgets.EventCallout, %{id: "native-callout", message: "Build completed"},
     "event-callout"},
    {LiveUi.Widgets.RedlineInline,
     %{id: "native-redline", before_text: "Draft", after_text: "Ready"}, "redline-inline"},
    {LiveUi.Widgets.CodeBlockSyntaxHighlighted, %{id: "native-code", code: "IO.puts(\"ready\")"},
     "code-block-syntax-highlighted"},
    {LiveUi.Widgets.ChatComposer, %{id: "native-composer", placeholder: "Add a review note"},
     "chat-composer"},
    {LiveUi.Forms.HostFormShell, %{id: "native-host-form", validation_summary: "Host validates"},
     "host-form-shell"},
    {LiveUi.Widgets.RepeatedCollection,
     %{id: "native-collection", rows: [%{key: "artifact-1", index: 0}]}, "repeated-collection"}
  ]

  test "native widgets and canonical fixture render the promoted web surface" do
    for {module, assigns, marker} <- @native_cases do
      html = render_component(fn assigns -> apply(module, :render, [assigns]) end, assigns)

      assert html =~ ~s(data-live-ui-widget="#{marker}")
    end

    html =
      "portable_widgets--ash_ui_portability"
      |> Fixtures.fixture!()
      |> Map.fetch!(:element)
      |> render_iur()

    for marker <- @portable_markers do
      assert html =~ ~s(data-live-ui-widget="#{marker}")
    end

    assert html =~ ~s(id="portable-panel")
    assert html =~ ~s(aria-modal)
    assert html =~ ~s(data-live-ui-open)
    assert html =~ ~s(role="group")
    assert html =~ ~s(aria-pressed)
    assert html =~ ~s(id="portable-composer")
    assert html =~ ~s(data-live-ui-submit-intent="send_review")
    assert html =~ ~s(aria-label="Add a review note")
  end

  test "host form shell keeps submit validation and errors in runtime-owned lifecycle metadata" do
    form =
      Forms.host_form_shell(
        [
          Forms.form_field(
            Input.text_input(id: "display-name-input", name: :display_name),
            id: "display-name-field",
            label: "Display name"
          )
        ],
        id: "profile-shell",
        submit_intent: :save_profile,
        validation_summary: "Display name is required",
        validation: %{status: :invalid, errors: ["Display name is required"]},
        allow_partial?: false
      )

    html = render_iur(form)

    assert html =~ ~s(data-live-ui-widget="host-form-shell")
    assert html =~ ~s(data-live-ui-owner="host")
    assert html =~ ~s(data-live-ui-lifecycle="host_owned")
    assert html =~ ~s(aria-describedby="profile-shell-validation-summary")
    assert html =~ "Display name is required"
    assert html =~ ~s(phx-submit="canonical_submit_interaction")
    refute html =~ "ash_"

    interaction = decode_submit_interaction!(html)

    assert interaction.family == :submit
    assert interaction.intent == :save_profile
    assert interaction.source.element_id == "profile-shell"
    assert interaction.metadata.allow_partial? == false
  end

  test "repeated collection native and IUR paths preserve row identity and canonical payloads" do
    native_html =
      render_component(&LiveUi.Widgets.RepeatedCollection.render/1, %{
        id: "artifact-rows",
        rows: [%{key: "artifact-1", index: 0}],
        item_alias: "artifact",
        index_alias: "row",
        key_path: [:id]
      })

    iur_html =
      repeated_collection([%{id: "artifact-1", title: "artifact.tar"}])
      |> render_iur()

    assert native_html =~ ~s(data-live-ui-collection-row="artifact-1")
    assert iur_html =~ ~s(data-live-ui-collection-row="artifact-1")
    assert iur_html =~ ~s(data-live-ui-row-key-source="key_path")
    assert iur_html =~ ~s(id="artifact-summary-template-artifact-1")
    assert iur_html =~ "artifact.tar"
    refute iur_html =~ "unresolved_row_scope"
    refute iur_html =~ "phx-value-live_view"

    interaction = decode_click_interaction!(iur_html)

    assert interaction.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}
  end

  defp repeated_collection(items) do
    Collection.repeated_collection(
      Layout.row(
        [
          Semantic.list_item_multi_column(Binding.row_value(:artifact, :columns),
            id: "artifact-summary-template",
            label: "Artifact"
          ),
          Foundational.button("Open",
            id: "artifact-open-template",
            action: [
              intent: :open_artifact,
              mapping: %{
                artifact_id: Binding.row_value(:artifact, :id),
                row_index: Binding.row_index(:row)
              }
            ]
          )
        ],
        id: "artifact-row-template"
      ),
      id: "artifact-rows",
      source: [
        name: :artifacts,
        path: [:artifacts],
        value: Enum.map(items, &with_columns/1)
      ],
      item_alias: :artifact,
      index_alias: :row,
      key_path: [:id],
      empty_state: "No artifacts"
    )
  end

  defp with_columns(%{title: title} = item), do: Map.put_new(item, :columns, %{name: title})

  defp render_iur(element) do
    render_component(&LiveUi.Renderer.render/1, %{
      element: element,
      event_target: "#runtime-host"
    })
  end

  defp decode_submit_interaction!(html) do
    decode_interaction!(html, ~r/phx-value-submit-interaction="([^"]+)"/)
  end

  defp decode_click_interaction!(html) do
    decode_interaction!(html, ~r/phx-value-interaction="([^"]+)"/)
  end

  defp decode_interaction!(html, pattern) do
    [_, encoded] = Regex.run(pattern, html)

    encoded
    |> Base.url_decode64!(padding: false)
    |> :erlang.binary_to_term([:safe])
    |> Interaction.new()
  end
end
