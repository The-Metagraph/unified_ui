defmodule UnifiedIUR.Widgets.SemanticTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Validate
  alias UnifiedIUR.Widgets.Semantic

  test "exposes portable semantic and micro-interaction widget kinds" do
    assert [
             :disclosure,
             :kicker,
             :avatar,
             :presence_dot,
             :segmented_button_group,
             :list_item_multi_column,
             :artifact_row,
             :sticky_header
           ] == Semantic.kinds()
  end

  test "builds compact semantic widgets with canonical content, state, and style hooks" do
    disclosure =
      Semantic.disclosure("Release notes",
        id: "release-notes",
        open?: true,
        content_label: "Expanded release notes",
        accessibility_label: "Release notes disclosure",
        style_refs: [:summary_toggle]
      )

    kicker = Semantic.kicker("Workflow", id: "workflow-kicker", icon: :sparkles)

    avatar =
      Semantic.avatar("Pat Charbon", id: "assignee-avatar", initials: "PC", status: :online)

    presence = Semantic.presence_dot(:online, id: "assignee-presence", label: "Assignee online")
    header = Semantic.sticky_header("Results", id: "result-header", stuck?: true)

    assert %Element{
             kind: :disclosure,
             attributes: %{
               disclosure: %{
                 label: "Release notes",
                 open?: true,
                 content_label: "Expanded release notes"
               },
               accessibility: %{label: "Release notes disclosure"},
               theme: %{component: :disclosure}
             }
           } = disclosure

    assert %Element{kind: :kicker, attributes: %{kicker: %{value: "Workflow", icon: :sparkles}}} =
             kicker

    assert %Element{
             kind: :avatar,
             attributes: %{avatar: %{label: "Pat Charbon", initials: "PC", status: :online}}
           } = avatar

    assert %Element{
             kind: :presence_dot,
             attributes: %{presence: %{status: :online, label: "Assignee online"}}
           } = presence

    assert %Element{
             kind: :sticky_header,
             attributes: %{sticky_header: %{title: "Results", stuck?: true}}
           } = header

    for widget <- [disclosure, kicker, avatar, presence, header] do
      assert :ok = Validate.element(widget)
    end
  end

  test "normalizes list item, segmented control, and artifact row values deterministically" do
    segmented =
      Semantic.segmented_button_group(
        %{detailed: "Detailed", compact: "Compact"},
        id: "view-modes",
        active_item: :compact,
        selection_intent: :change_view_mode
      )

    list_item =
      Semantic.list_item_multi_column(
        [name: "artifact.tar", status: "ready", size: "42 KB"],
        id: "artifact-item",
        label: "Build artifact",
        status: :ready
      )

    artifact =
      Semantic.artifact_row(
        %{kind: :tarball, id: "artifact-1"},
        "artifact.tar",
        id: "build-artifact",
        status: :ready,
        timestamp: "2026-05-13T10:30:00Z",
        action_intent: :download_artifact
      )

    assert %Element{
             attributes: %{
               segments: %{
                 items: [
                   %{id: :compact, label: "Compact", value: "Compact"},
                   %{id: :detailed, label: "Detailed", value: "Detailed"}
                 ],
                 active_item: :compact
               },
               interactions: [%Interaction{family: :selection, intent: :change_view_mode}]
             }
           } = segmented

    assert %Element{
             attributes: %{
               list_item: %{
                 columns: [
                   %{id: :name, label: "artifact.tar", value: "artifact.tar"},
                   %{id: :status, label: "ready", value: "ready"},
                   %{id: :size, label: "42 KB", value: "42 KB"}
                 ],
                 label: "Build artifact",
                 status: :ready
               }
             }
           } = list_item

    assert %Element{
             attributes: %{
               artifact: %{
                 value: %{id: "artifact-1", kind: :tarball},
                 title: "artifact.tar",
                 status: :ready,
                 timestamp: "2026-05-13T10:30:00Z",
                 action_intent: :download_artifact
               },
               interactions: [%Interaction{family: :click, intent: :download_artifact}]
             }
           } = artifact

    for widget <- [segmented, list_item, artifact] do
      assert :ok = Validate.element(widget)
    end
  end
end
