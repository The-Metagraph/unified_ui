defmodule TerminalUi.Validate do
  @moduledoc """
  Coverage, runtime, transport, and capability validation workflows for
  `terminal_ui`.
  """

  @type mode :: :summary | :strict
  @required_guides [
    "README.md",
    "guides/runtime_backbone.md",
    "guides/native_runtime_and_examples.md",
    "guides/canonical_rendering_and_transport.md",
    "guides/styling_capabilities_and_inspection.md",
    "guides/maintainer_workflows.md"
  ]

  @spec example_coverage() :: map()
  def example_coverage do
    matrix = TerminalUi.Examples.coverage_matrix()

    checks = [
      check(:native_examples_present, length(TerminalUi.Examples.native_examples()) > 0, []),
      check(
        :canonical_examples_present,
        length(TerminalUi.Examples.canonical_examples()) > 0,
        []
      ),
      check(:mixed_examples_present, length(TerminalUi.Examples.mixed_examples()) > 0, []),
      check(
        :required_widget_families_registered,
        Enum.all?(
          [
            :action,
            :content,
            :data,
            :feedback,
            :input,
            :layout,
            :navigation,
            :operational,
            :visualization
          ],
          &(&1 in TerminalUi.Widgets.families())
        ),
        %{families: TerminalUi.Widgets.families()}
      ),
      check(
        :foundational_review_present,
        Map.has_key?(matrix.workflows, :foundational_review),
        []
      ),
      check(:advanced_review_present, Map.has_key?(matrix.workflows, :advanced_review), []),
      check(:transport_review_present, Map.has_key?(matrix.workflows, :transport_review), []),
      check(:style_review_present, Map.has_key?(matrix.workflows, :style_review), []),
      check(
        :capability_review_present,
        Map.has_key?(matrix.workflows, :capability_review),
        []
      ),
      check(
        :renderer_supports_declared_kinds,
        TerminalUi.Renderer.required_canonical_kinds() -- TerminalUi.Renderer.supported_kinds() ==
          [],
        %{
          missing:
            TerminalUi.Renderer.required_canonical_kinds() --
              TerminalUi.Renderer.supported_kinds()
        }
      ),
      check(
        :promoted_portable_widget_support,
        TerminalUi.Tooling.portable_widget_report().complete?,
        %{report: TerminalUi.Tooling.portable_widget_report()}
      )
    ]

    report(:example_coverage, checks)
  end

  @spec renderer_determinism() :: map()
  def renderer_determinism do
    foundational = TerminalUi.Examples.canonical_foundational_screen()
    advanced = TerminalUi.Examples.canonical_advanced_operations_screen()

    {:ok, foundational_once} = TerminalUi.Renderer.render(foundational, backend_mode: :raw)
    {:ok, foundational_twice} = TerminalUi.Renderer.render(foundational, backend_mode: :raw)
    {:ok, advanced_once} = TerminalUi.Renderer.render(advanced, backend_mode: :raw)
    {:ok, advanced_twice} = TerminalUi.Renderer.render(advanced, backend_mode: :raw)

    checks = [
      check(:foundational_mapping_deterministic, foundational_once == foundational_twice, []),
      check(:advanced_mapping_deterministic, advanced_once == advanced_twice, []),
      check(:supported_kind_surface_present, TerminalUi.Renderer.supported_kinds() != [], []),
      check(
        :rendered_widget_summary_stable,
        TerminalUi.Info.widget_summary(foundational_once) ==
          TerminalUi.Info.widget_summary(foundational_twice),
        []
      )
    ]

    report(:renderer_determinism, checks)
  end

  @spec runtime_behavior() :: map()
  def runtime_behavior do
    foundational = TerminalUi.Examples.foundational_comparison()
    advanced = TerminalUi.Examples.advanced_comparison()
    transport = TerminalUi.Examples.transport_flow_comparison()
    normalized = TerminalUi.Examples.normalized_input_comparison()
    styled = TerminalUi.Examples.styled_continuity_comparison()
    degradation = TerminalUi.Examples.styled_degradation_comparison()
    capability = TerminalUi.Examples.advanced_capability_comparison()

    checks = [
      check(
        :foundational_continuity,
        foundational.parity.focus_order_match?,
        foundational.parity
      ),
      check(:advanced_continuity, advanced.parity.shared_runtime_backbone?, advanced.parity),
      check(
        :transport_meaning_preserved,
        transport.parity.runtime_event_meaning_preserved?,
        transport.parity
      ),
      check(
        :normalized_terminal_inputs_explicit,
        normalized.parity.tty_capability_handling_explicit?,
        normalized.parity
      ),
      check(
        :styled_continuity_preserved,
        styled.parity.widget_identity_match? and styled.parity.theme_resolution_match? and
          styled.parity.style_resolution_match?,
        styled.parity
      ),
      check(
        :degradation_boundaries_preserved,
        degradation.parity.glyph_fallback_explicit? and degradation.parity.degradation_bounded? and
          degradation.parity.inspection_surfaces_agree?,
        degradation.parity
      ),
      check(
        :capability_fallbacks_bounded,
        capability.parity.native_semantics_stable? and
          capability.parity.canonical_semantics_stable? and
          capability.parity.tty_fallbacks_explicit? and
          capability.parity.allowed_variation_bounded?,
        capability.parity
      )
    ]

    report(:runtime_behavior, checks)
  end

  @spec transport_validation() :: map()
  def transport_validation do
    native_event = [
      backend_mode: :raw,
      input_family: :shortcut,
      shortcut: "ctrl-r",
      intent: :reload_workspace,
      widget_id: "command-palette",
      runtime_id: "terminal-ui:transport",
      screen: "transport"
    ]

    {:ok, translation} = TerminalUi.Transport.from_native_event(native_event)

    checks = [
      check(
        :native_event_validation,
        TerminalUi.Transport.validate_native_event(native_event) == :ok,
        []
      ),
      check(
        :translation_validation,
        TerminalUi.Transport.validate_translation(translation) == :ok,
        []
      ),
      check(
        :boundary_signal_validation,
        TerminalUi.Transport.validate_boundary_signal(translation.signal) == :ok,
        []
      ),
      check(
        :no_backend_leakage,
        TerminalUi.Transport.Diagnostics.validate_translation(translation) == :ok,
        []
      )
    ]

    report(:transport_validation, checks)
  end

  @spec capability_behavior() :: map()
  def capability_behavior do
    raw = TerminalUi.Capabilities.snapshot(backend_mode: :raw)
    tty = TerminalUi.Capabilities.snapshot(backend_mode: :tty)

    checks = [
      check(:raw_profile_detected, raw.degradation_profile == :rich_terminal, raw),
      check(:tty_profile_detected, tty.degradation_profile == :fallback_terminal, tty),
      check(:unicode_degradation_explicit, tty.glyph_set == :ascii, tty),
      check(:color_degradation_explicit, tty.color_mode == :limited_color, tty),
      check(
        :keyboard_alternatives_exposed,
        tty.keyboard_alternatives != [],
        %{keyboard_alternatives: tty.keyboard_alternatives}
      )
    ]

    report(:capability_behavior, checks)
  end

  @spec tooling_surface() :: map()
  def tooling_surface do
    checks = [
      check(
        :inspect_surface_present,
        TerminalUi.Inspect in TerminalUi.Tooling.preview_surfaces(),
        []
      ),
      check(:validate_surface_present, exported?(TerminalUi.Validate, :validation_report, 0), []),
      check(
        :preview_workflow_present,
        :example_preview in TerminalUi.Tooling.workflows(),
        %{workflows: TerminalUi.Tooling.workflows()}
      ),
      check(
        :validation_workflow_present,
        :package_validation in TerminalUi.Tooling.workflows(),
        %{workflows: TerminalUi.Tooling.workflows()}
      ),
      check(
        :mix_task_surface_present,
        Enum.all?(
          ["mix terminal_ui.inspect", "mix terminal_ui.validate"],
          &(&1 in TerminalUi.Tooling.mix_tasks())
        ),
        %{mix_tasks: TerminalUi.Tooling.mix_tasks()}
      )
    ]

    report(:tooling_surface, checks)
  end

  @spec documentation_surface() :: map()
  def documentation_surface do
    missing_docs =
      @required_guides
      |> Enum.reject(&File.exists?(Path.join(package_root(), &1)))

    undocumented_guides = @required_guides -- TerminalUi.Tooling.documentation_surface()

    checks = [
      check(:guide_files_present, missing_docs == [], %{missing: missing_docs}),
      check(:tooling_docs_surface_complete, undocumented_guides == [], %{
        missing: undocumented_guides
      }),
      check(:readme_present, File.exists?(Path.join(package_root(), "README.md")), [])
    ]

    report(:documentation_surface, checks)
  end

  @spec validation_report() :: map()
  def validation_report do
    sections = %{
      example_coverage: example_coverage(),
      renderer_determinism: renderer_determinism(),
      runtime_behavior: runtime_behavior(),
      transport_validation: transport_validation(),
      capability_behavior: capability_behavior(),
      tooling_surface: tooling_surface(),
      documentation_surface: documentation_surface()
    }

    Map.put(sections, :release_readiness, build_release_readiness(sections))
  end

  @spec validation_summary(map()) :: String.t()
  def validation_summary(report) when is_map(report) do
    [
      "TerminalUi validation summary",
      "  example coverage passing?: #{report.example_coverage.status == :pass}",
      "  renderer deterministic?: #{report.renderer_determinism.status == :pass}",
      "  runtime behavior passing?: #{report.runtime_behavior.status == :pass}",
      "  portable widget support passing?: #{portable_widget_status(report) == :pass}",
      "  transport validation passing?: #{report.transport_validation.status == :pass}",
      "  capability behavior passing?: #{report.capability_behavior.status == :pass}",
      "  tooling surface passing?: #{report.tooling_surface.status == :pass}",
      "  documentation surface passing?: #{report.documentation_surface.status == :pass}",
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
        "Maintain native, canonical, and mixed example coverage for the terminal package surface.",
        :example_coverage
      ),
      gate(
        :renderer_and_runtime_behavior,
        "Keep renderer determinism, shared runtime behavior, and capability-aware continuity healthy.",
        :runtime_behavior
      ),
      gate(
        :portable_widget_support,
        "Keep promoted widgets and repeated collection fallback coverage explicit.",
        :example_coverage
      ),
      gate(
        :transport_translation,
        "Keep normalized terminal input handling and canonical boundary translation explicit and leak-free.",
        :transport_validation
      ),
      gate(
        :capability_degradation,
        "Keep rich-terminal and fallback-terminal behavior bounded and reviewable.",
        :capability_behavior
      ),
      gate(
        :tooling_surface,
        "Keep inspect, validate, reference, and maintainer workflow surfaces available together.",
        :tooling_surface
      ),
      gate(
        :documentation_surface,
        "Keep package guides aligned with the shared runtime, canonical renderer, and capability model.",
        :documentation_surface
      )
    ]
  end

  @spec evolution_rules() :: [map()]
  def evolution_rules do
    [
      %{
        id: :new_widget_families_require_examples_and_validation,
        description:
          "New widget families should ship with maintained examples and updated validation coverage."
      },
      %{
        id: :renderer_changes_preserve_shared_runtime,
        description:
          "Canonical renderer changes should continue to flow through the same native runtime, styling, degradation, and transport model."
      },
      %{
        id: :capability_changes_require_degradation_review,
        description:
          "Backend or capability changes should keep fallback behavior explicit and bounded rather than implicit."
      },
      %{
        id: :terminal_ui_not_dsl_or_iur_owner,
        description:
          "Changes in terminal_ui must remain subordinate to upstream UnifiedUi and UnifiedIUR contracts instead of redefining them locally."
      },
      %{
        id: :tooling_and_docs_move_with_surface,
        description:
          "When the package surface changes, tooling, validation, and docs should move in the same change set."
      }
    ]
  end

  @spec release_readiness(mode()) :: {:ok, map()} | {:error, map()}
  def release_readiness(mode \\ :summary) do
    report = validation_report()
    release = report.release_readiness

    case {mode, release.status} do
      {:strict, :fail} -> {:error, release}
      _other -> {:ok, release}
    end
  end

  @spec validate(mode()) :: {:ok, map()} | {:error, map()}
  def validate(mode \\ :summary) do
    report = validation_report()

    case {mode, report.release_readiness.status} do
      {:strict, :fail} -> {:error, report}
      _other -> {:ok, report}
    end
  end

  defp report(kind, checks) do
    findings =
      checks
      |> Enum.reject(& &1.ok?)
      |> Enum.map(fn check ->
        %{
          check: check.name,
          details: check.details
        }
      end)

    %{
      kind: kind,
      status: if(findings == [], do: :pass, else: :fail),
      checks: checks,
      findings: findings
    }
  end

  defp check(name, ok?, details) do
    %{
      name: name,
      ok?: ok?,
      details: details
    }
  end

  defp build_release_readiness(sections) do
    failing =
      sections
      |> Enum.filter(fn {section, result} ->
        section != :release_readiness and is_map(result) and Map.get(result, :status) == :fail
      end)
      |> Enum.map(&elem(&1, 0))

    %{
      status: if(failing == [], do: :pass, else: :fail),
      failing_sections: failing,
      gates:
        Enum.map(release_gates(), fn gate ->
          Map.put(gate, :status, sections[gate.section].status)
        end),
      evolution_rules: evolution_rules()
    }
  end

  defp gate(id, description, section) do
    %{
      id: id,
      description: description,
      section: section
    }
  end

  defp exported?(module, function, arity) do
    Code.ensure_loaded?(module) and Enum.member?(module.__info__(:functions), {function, arity})
  end

  defp package_root do
    Path.expand("../..", __DIR__)
  end

  defp portable_widget_status(report) do
    report.example_coverage.checks
    |> Enum.find(&(&1.name == :promoted_portable_widget_support))
    |> case do
      %{ok?: true} -> :pass
      _other -> :fail
    end
  end
end
