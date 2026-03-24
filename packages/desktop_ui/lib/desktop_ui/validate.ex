defmodule DesktopUi.Validate do
  @moduledoc """
  Coverage, runtime, transport, artifact, and release-readiness validation
  workflows for `desktop_ui`.
  """

  @type mode :: :summary | :strict

  @spec example_coverage() :: map()
  def example_coverage do
    matrix = DesktopUi.Examples.coverage_matrix()

    checks = [
      check(:native_examples_present, DesktopUi.Examples.native_examples() != [], []),
      check(:canonical_examples_present, DesktopUi.Examples.canonical_examples() != [], []),
      check(:mixed_examples_present, DesktopUi.Examples.mixed_examples() != [], []),
      check(
        :foundational_review_present,
        Map.has_key?(matrix.workflows, :foundational_review),
        []
      ),
      check(:advanced_review_present, Map.has_key?(matrix.workflows, :advanced_review), []),
      check(:transport_review_present, Map.has_key?(matrix.workflows, :transport_review), []),
      check(:style_review_present, Map.has_key?(matrix.workflows, :style_review), []),
      check(
        :native_widget_families_present,
        Enum.all?(
          [:action, :content, :data, :input, :navigation, :operational, :visualization, :window],
          &(&1 in DesktopUi.Widgets.families())
        ),
        %{families: DesktopUi.Widgets.families()}
      ),
      check(
        :renderer_supports_key_canonical_kinds,
        Enum.all?(
          [:window, :table, :command_palette, :text_input, :button, :overlay, :multi_window],
          &(&1 in DesktopUi.Renderer.supported_kinds())
        ),
        %{supported_kinds: DesktopUi.Renderer.supported_kinds()}
      )
    ]

    report(:example_coverage, checks)
  end

  @spec runtime_behavior() :: map()
  def runtime_behavior do
    foundational = DesktopUi.Examples.foundational_comparison()
    advanced = DesktopUi.Examples.advanced_comparison()
    transport = DesktopUi.Examples.transport_comparison()
    normalized = DesktopUi.Examples.normalized_input_comparison()
    styled = DesktopUi.Examples.styled_comparison()

    checks = [
      check(
        :foundational_continuity,
        foundational.parity.focus_order_match?,
        foundational.parity
      ),
      check(:advanced_continuity, advanced.parity.shared_runtime_backbone?, advanced.parity),
      check(
        :transport_meaning_preserved,
        transport.parity.boundary_signal_types_match?,
        transport.parity
      ),
      check(
        :normalized_inputs_bounded,
        normalized.parity.platform_variation_bounded?,
        normalized.parity
      ),
      check(
        :styled_continuity_preserved,
        styled.parity.widget_identity_match? and styled.parity.style_resolution_match? and
          styled.parity.platform_semantics_match?,
        styled.parity
      )
    ]

    report(:runtime_behavior, checks)
  end

  @spec transport_validation() :: map()
  def transport_validation do
    native_event = [
      platform_target: :linux,
      input_family: :shortcut,
      shortcut: "ctrl-r",
      intent: :refresh_workspace,
      widget_id: "refresh-command",
      runtime_id: "desktop-ui:transport",
      screen: "transport-review"
    ]

    {:ok, translation} = DesktopUi.Transport.from_native_event(native_event)

    checks = [
      check(
        :native_event_validation,
        DesktopUi.Transport.validate_native_event(native_event) == :ok,
        []
      ),
      check(
        :translation_validation,
        DesktopUi.Transport.validate_translation(translation) == :ok,
        []
      ),
      check(
        :boundary_signal_validation,
        DesktopUi.Transport.validate_boundary_signal(translation.signal) == :ok,
        []
      ),
      check(
        :no_platform_leakage,
        DesktopUi.Transport.Diagnostics.validate_translation(translation) == :ok,
        []
      )
    ]

    report(:transport_validation, checks)
  end

  @spec artifact_validation() :: map()
  def artifact_validation do
    diagnostics = DesktopUi.Artifacts.diagnostics()
    boundary_policy = DesktopUi.Artifacts.boundary_policy()

    checks = [
      check(:all_targets_present, diagnostics.targets == [:windows, :macos, :linux], diagnostics),
      check(:no_invalid_targets, diagnostics.invalid_targets == [], diagnostics.invalid_targets),
      check(
        :boundary_policy_preserves_runtime_semantics,
        diagnostics.boundary_policy == boundary_policy and
          boundary_policy.transport_semantics_preserved,
        %{expected: boundary_policy, actual: diagnostics.boundary_policy}
      ),
      check(
        :explicit_packaging_per_target,
        Enum.all?(diagnostics.targets, &(DesktopUi.Artifacts.workflow(&1).packaging != [])),
        diagnostics.workflows
      )
    ]

    report(:artifact_validation, checks)
  end

  @spec tooling_surface() :: map()
  def tooling_surface do
    checks = [
      check(
        :inspect_surface_present,
        DesktopUi.Inspect in DesktopUi.Tooling.preview_surfaces(),
        []
      ),
      check(:validate_surface_present, exported?(DesktopUi.Validate, :release_readiness, 1), []),
      check(
        :example_preview_workflow_present,
        :example_preview in DesktopUi.Tooling.workflows(),
        %{workflows: DesktopUi.Tooling.workflows()}
      ),
      check(
        :package_validation_workflow_present,
        :package_validation in DesktopUi.Tooling.workflows(),
        %{workflows: DesktopUi.Tooling.workflows()}
      ),
      check(
        :mix_task_surface_present,
        Enum.all?(
          ["mix desktop_ui.inspect", "mix desktop_ui.validate"],
          &Enum.any?(DesktopUi.Tooling.mix_tasks(), fn task -> String.starts_with?(task, &1) end)
        ),
        %{mix_tasks: DesktopUi.Tooling.mix_tasks()}
      )
    ]

    report(:tooling_surface, checks)
  end

  @spec validation_report() :: map()
  def validation_report do
    sections = default_sections()
    Map.put(sections, :release_readiness, build_release_readiness(sections, :summary))
  end

  @spec validation_summary(map()) :: String.t()
  def validation_summary(report) when is_map(report) do
    [
      "DesktopUi validation summary",
      "  example coverage passing?: #{report.example_coverage.status == :pass}",
      "  runtime behavior passing?: #{report.runtime_behavior.status == :pass}",
      "  transport validation passing?: #{report.transport_validation.status == :pass}",
      "  artifact validation passing?: #{report.artifact_validation.status == :pass}",
      "  tooling surface passing?: #{report.tooling_surface.status == :pass}",
      "  release ready?: #{report.release_readiness.status == :pass}",
      "  failing sections: #{inspect(report.release_readiness.failing_sections)}"
    ]
    |> Enum.join("\n")
  end

  @spec release_gates() :: [map()]
  def release_gates do
    [
      gate(
        :example_coverage,
        "Maintain native, canonical, and mixed desktop example coverage.",
        :example_coverage
      ),
      gate(
        :runtime_behavior,
        "Keep shared runtime and continuity behavior reviewable and healthy.",
        :runtime_behavior
      ),
      gate(
        :transport_validation,
        "Keep transport translation and no-leakage guarantees explicit.",
        :transport_validation
      ),
      gate(
        :artifact_validation,
        "Keep platform artifact workflows explicit and bounded.",
        :artifact_validation
      ),
      gate(
        :tooling_surface,
        "Keep inspect and validate maintainer workflows available together.",
        :tooling_surface
      )
    ]
  end

  @spec release_readiness(mode()) :: {:ok, map()} | {:error, map()}
  def release_readiness(mode \\ :summary) do
    sections = default_sections()
    report = build_release_readiness(sections, mode)

    case {mode, report.findings} do
      {:strict, [_ | _]} -> {:error, report}
      _ -> {:ok, report}
    end
  end

  defp report(kind, checks) do
    findings =
      checks
      |> Enum.reject(& &1.ok?)
      |> Enum.map(fn check -> %{check: check.name, details: check.details} end)

    %{
      kind: kind,
      status: if(findings == [], do: :pass, else: :fail),
      checks: checks,
      findings: findings
    }
  end

  defp check(name, ok?, details) do
    %{name: name, ok?: ok?, details: details}
  end

  defp gate(id, description, section) do
    %{id: id, description: description, section: section}
  end

  defp exported?(module, function, arity) do
    Code.ensure_loaded?(module) and Enum.member?(module.__info__(:functions), {function, arity})
  end

  defp default_sections do
    %{
      example_coverage: example_coverage(),
      runtime_behavior: runtime_behavior(),
      transport_validation: transport_validation(),
      artifact_validation: artifact_validation(),
      tooling_surface: tooling_surface()
    }
  end

  defp build_release_readiness(sections, mode) do
    findings = sections |> Map.values() |> Enum.flat_map(& &1.findings)

    gates =
      Enum.map(release_gates(), fn gate ->
        section = Map.fetch!(sections, gate.section)
        Map.put(gate, :status, section.status)
      end)

    %{
      mode: mode,
      status: if(findings == [], do: :pass, else: :fail),
      gates: gates,
      findings: findings,
      failing_sections:
        sections
        |> Enum.filter(fn {_name, report} -> report.status != :pass end)
        |> Enum.map(fn {name, _report} -> name end)
        |> Enum.sort()
    }
  end
end
