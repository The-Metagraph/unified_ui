defmodule UnifiedIUR.RuntimeParity do
  @moduledoc """
  Shared runtime parity fixtures and acceptance criteria for canonical widgets.
  """

  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Widgets.{Components, Foundational}

  @groups [
    :content,
    :identity,
    :form,
    :control,
    :row,
    :progress,
    :layer,
    :callout,
    :redline,
    :code,
    :composer,
    :repeated_rows
  ]

  @status_values [:full, :degraded, :unsupported]

  @minimum_behavior %{
    full: [
      :native_widget,
      :iur_renderer_mapping,
      :state_preservation,
      :accessibility_metadata,
      :interaction_translation,
      :safe_text_output
    ],
    degraded: [
      :explicit_degradation,
      :structure_preservation,
      :state_preservation,
      :accessibility_metadata,
      :interaction_translation,
      :safe_text_output
    ],
    unsupported: [:diagnostic]
  }

  @spec groups() :: [atom()]
  def groups, do: @groups

  @spec status_values() :: [atom()]
  def status_values, do: @status_values

  @spec minimum_behavior() :: map()
  def minimum_behavior, do: @minimum_behavior

  @spec fixtures() :: [map()]
  def fixtures do
    Enum.map(@groups, &fixture!/1)
  end

  @spec fixture!(atom() | String.t()) :: map()
  def fixture!(group_or_id)

  def fixture!(group) when group in @groups do
    build_fixture(group)
  end

  def fixture!(id) when is_binary(id) do
    case Enum.find(fixtures(), &(&1.id == id)) do
      nil -> raise ArgumentError, "unknown runtime parity fixture #{inspect(id)}"
      fixture -> fixture
    end
  end

  @spec acceptance_criteria() :: map()
  def acceptance_criteria do
    %{
      statuses: @status_values,
      minimum_behavior: @minimum_behavior,
      required_widget_kinds: Components.kinds(),
      required_fixture_groups: @groups,
      text_safety_groups: [:redline, :code],
      interaction_groups: [:form, :control, :row, :progress, :callout, :composer, :repeated_rows]
    }
  end

  @spec coverage_report(atom(), [atom()], keyword()) :: map()
  def coverage_report(runtime, supported_kinds, opts \\ []) when is_list(supported_kinds) do
    degraded_kinds = opts |> Keyword.get(:degraded_kinds, []) |> MapSet.new()
    supported_kinds = MapSet.new(supported_kinds)

    kinds =
      Components.kinds()
      |> Map.new(fn kind ->
        status =
          cond do
            MapSet.member?(degraded_kinds, kind) -> :degraded
            MapSet.member?(supported_kinds, kind) -> :full
            true -> :unsupported
          end

        {kind, %{status: status, minimum_behavior: Map.fetch!(@minimum_behavior, status)}}
      end)

    unsupported =
      kinds
      |> Enum.filter(fn {_kind, %{status: status}} -> status == :unsupported end)
      |> Enum.map(fn {kind, _summary} -> kind end)

    degraded =
      kinds
      |> Enum.filter(fn {_kind, %{status: status}} -> status == :degraded end)
      |> Enum.map(fn {kind, _summary} -> kind end)

    %{
      runtime: runtime,
      complete?: unsupported == [],
      degraded?: degraded != [],
      fixture_groups: @groups,
      kinds: kinds,
      degraded_kinds: Enum.sort(degraded),
      unsupported_kinds: Enum.sort(unsupported)
    }
  end

  defp build_fixture(:content) do
    element =
      Components.disclosure(
        "More",
        [
          Components.inline_rich_text_heading(:h2, [%{type: :text, value: "Runtime parity"}],
            id: "parity-content-heading"
          ),
          Components.kicker(["Spec", "Runtime"], id: "parity-content-kicker")
        ],
        id: "parity-content-disclosure",
        open?: true
      )

    fixture(:content, element,
      kinds: [:disclosure, :inline_rich_text_heading, :kicker],
      labels: ["More", "Runtime parity"],
      state: %{open?: true},
      children: %{default: 2}
    )
  end

  defp build_fixture(:identity) do
    element =
      Components.list_item_multi_column(
        [
          Components.avatar(id: "parity-avatar", initials: "PC", accessibility_label: "Pascal"),
          Components.presence_dot(:active, id: "parity-presence", accessibility_label: "Active")
        ],
        id: "parity-identity-row",
        row_identity: "identity"
      )

    fixture(:identity, element,
      kinds: [:list_item_multi_column, :avatar, :presence_dot],
      labels: ["Pascal", "Active"],
      state: %{presence: :active},
      children: %{default: 2}
    )
  end

  defp build_fixture(:form) do
    element =
      Components.runtime_form_shell(
        [%{name: :title, type: :text, label: "Title"}],
        id: "parity-form",
        submit_label: "Save",
        host_adapter_hints: %{live_ui: %{adapter: :phoenix_form}},
        interactions: [
          Interaction.submit(intent: :save_form, element_id: "parity-form"),
          Interaction.change(intent: :validate_form, element_id: "parity-form")
        ]
      )

    fixture(:form, element,
      kinds: [:runtime_form_shell],
      labels: ["Title", "Save"],
      interactions: [:submit, :change],
      state: %{validation: :runtime_owned}
    )
  end

  defp build_fixture(:control) do
    element =
      Components.segmented_button_group(
        [%{value: :open, label: "Open"}, %{value: :closed, label: "Closed"}],
        id: "parity-control",
        active_value: :open,
        interactions: [
          Interaction.selection(intent: :select_status, element_id: "parity-control")
        ]
      )

    fixture(:control, element,
      kinds: [:segmented_button_group],
      labels: ["Open", "Closed"],
      state: %{active_value: :open},
      interactions: [:selection]
    )
  end

  defp build_fixture(:row) do
    element =
      Components.artifact_row(
        "ADR",
        [Foundational.button("Open", id: "parity-row-open")],
        id: "parity-row",
        row_identity: "adr-1",
        meta: %{status: :accepted},
        interactions: [Interaction.click(intent: :open_artifact, element_id: "parity-row")]
      )

    fixture(:row, element,
      kinds: [:artifact_row],
      labels: ["ADR", "Open"],
      state: %{row_identity: "adr-1"},
      interactions: [:click],
      children: %{default: 1}
    )
  end

  defp build_fixture(:progress) do
    element =
      Components.workflow_stage_list_vertical(
        [
          %{id: :authored, label: "Authored", state: :done},
          %{id: :implemented, label: "Implemented", state: :active}
        ],
        id: "parity-progress",
        active_index: 1,
        interactions: [
          Interaction.navigation(intent: :select_stage, element_id: "parity-progress")
        ]
      )

    fixture(:progress, element,
      kinds: [:workflow_stage_list_vertical],
      labels: ["Authored", "Implemented"],
      state: %{active_index: 1},
      interactions: [:navigation]
    )
  end

  defp build_fixture(:layer) do
    element =
      Components.slide_over_panel(
        [Foundational.text("Panel body", id: "parity-panel-body")],
        id: "parity-panel",
        accessibility_label: "Details",
        open?: true,
        interactions: [Interaction.close(intent: :close_panel, element_id: "parity-panel")]
      )

    fixture(:layer, element,
      kinds: [:slide_over_panel],
      labels: ["Details"],
      state: %{open?: true, modal?: false},
      interactions: [:close],
      children: %{default: 1}
    )
  end

  defp build_fixture(:callout) do
    element =
      Components.event_callout(
        "Paused",
        [Foundational.button("Inspect", id: "parity-callout-action")],
        id: "parity-callout",
        tone: :warning,
        interactions: [Interaction.click(intent: :inspect_event, element_id: "parity-callout")]
      )

    fixture(:callout, element,
      kinds: [:event_callout],
      labels: ["Paused", "Inspect"],
      state: %{tone: :warning},
      interactions: [:click],
      children: %{default: 1}
    )
  end

  defp build_fixture(:redline) do
    element =
      Components.redline_inline(
        [%{state: :insert, text: "<script>safe redline</script>"}],
        id: "parity-redline"
      )

    fixture(:redline, element,
      kinds: [:redline_inline],
      safety: %{plain_text: true, malicious_text: "<script>safe redline</script>"}
    )
  end

  defp build_fixture(:code) do
    element =
      Components.code_block_syntax_highlighted(
        :elixir,
        [%{type: :keyword, text: "<defmodule>"}],
        id: "parity-code"
      )

    fixture(:code, element,
      kinds: [:code_block_syntax_highlighted],
      safety: %{plain_text: true, malicious_text: "<defmodule>"}
    )
  end

  defp build_fixture(:composer) do
    element =
      Components.chat_composer(
        [Foundational.button("Attach", id: "parity-composer-attach")],
        id: "parity-composer",
        value: "Draft",
        send_label: "Send",
        interactions: [
          Interaction.submit(intent: :send_message, element_id: "parity-composer"),
          Interaction.change(intent: :update_message, element_id: "parity-composer")
        ]
      )

    fixture(:composer, element,
      kinds: [:chat_composer],
      labels: ["Send", "Attach"],
      state: %{value: "Draft"},
      interactions: [:submit, :change],
      children: %{default: 1}
    )
  end

  defp build_fixture(:repeated_rows) do
    element =
      Components.list_repeat(nil,
        id: "parity-repeat",
        repeat_binding: :artifacts,
        hydrated?: true,
        row_count: 2,
        children: [
          Components.artifact_row("ADR 1", [], id: "parity-repeat:a1", row_identity: "a1"),
          Components.artifact_row("ADR 2", [], id: "parity-repeat:a2", row_identity: "a2")
        ]
      )

    fixture(:repeated_rows, element,
      kinds: [:list_repeat, :artifact_row],
      state: %{hydrated?: true, row_count: 2},
      children: %{default: 2}
    )
  end

  defp fixture(group, element, expected) do
    %{
      id: "components-runtime-parity--#{group}",
      group: group,
      element: element,
      expected: Map.new(expected),
      minimum_behavior: @minimum_behavior.full
    }
  end
end
