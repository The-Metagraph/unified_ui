defmodule DesktopUi.Validate do
  @moduledoc """
  Coverage, runtime, transport, artifact, and release-readiness validation
  workflows for `desktop_ui`.
  """

  @type mode :: :summary | :strict
  @required_guides [
    "README.md",
    "guides/runtime_backbone.md",
    "guides/native_runtime_and_examples.md",
    "guides/canonical_rendering_and_transport.md",
    "guides/styling_platforms_and_artifacts.md",
    "guides/maintainer_workflows.md"
  ]
  @required_traceability_targets [
    ".spec/specs/architecture.spec.md",
    ".spec/specs/platform_runtimes.spec.md",
    ".spec/specs/signal_transport.spec.md",
    ".spec/specs/desktop_ui/package.spec.md",
    ".spec/specs/desktop_ui/structure.spec.md",
    ".spec/specs/desktop_ui/native_widgets.spec.md",
    ".spec/specs/desktop_ui/runtime.spec.md",
    ".spec/specs/desktop_ui/sdl3_runtime_rendering.spec.md",
    ".spec/specs/desktop_ui/iur_renderer.spec.md",
    ".spec/specs/desktop_ui/transport.spec.md",
    ".spec/specs/desktop_ui/platform_artifacts.spec.md",
    ".spec/specs/desktop_ui/tooling.spec.md",
    ".spec/planning/desktop_ui/spec-traceability.json",
    ".spec/planning/desktop_ui/spec-traceability.md"
  ]
  @required_root_subjects [
    ".spec/specs/architecture.spec.md",
    ".spec/specs/platform_runtimes.spec.md",
    ".spec/specs/signal_transport.spec.md"
  ]
  @required_package_subjects [
    ".spec/specs/desktop_ui/package.spec.md",
    ".spec/specs/desktop_ui/structure.spec.md",
    ".spec/specs/desktop_ui/native_widgets.spec.md",
    ".spec/specs/desktop_ui/runtime.spec.md",
    ".spec/specs/desktop_ui/sdl3_runtime_rendering.spec.md",
    ".spec/specs/desktop_ui/iur_renderer.spec.md",
    ".spec/specs/desktop_ui/transport.spec.md",
    ".spec/specs/desktop_ui/platform_artifacts.spec.md",
    ".spec/specs/desktop_ui/tooling.spec.md"
  ]

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

  @spec sdl3_adapter_surface() :: map()
  def sdl3_adapter_surface do
    adapter_surface = DesktopUi.Inspection.sdl3_adapter_surface()

    checks = [
      check(
        :sdl3_modules_present,
        Enum.all?(
          [
            DesktopUi.Sdl3,
            DesktopUi.Sdl3.App,
            DesktopUi.Sdl3.Host,
            DesktopUi.Sdl3.PortHost,
            DesktopUi.Sdl3.Protocol,
            DesktopUi.Sdl3.Lifecycle,
            DesktopUi.Sdl3.Window,
            DesktopUi.Sdl3.RenderPlan,
            DesktopUi.Sdl3.Renderer,
            DesktopUi.Sdl3.Events,
            DesktopUi.Sdl3.Text,
            DesktopUi.Sdl3.Images
          ],
          &Code.ensure_loaded?/1
        ),
        %{modules: DesktopUi.Sdl3.modules()}
      ),
      check(
        :host_boundary_present,
        adapter_surface.validation_state.host == :port_host_ready and
          adapter_surface.host.transport == :port,
        %{host: adapter_surface.host, validation_state: adapter_surface.validation_state}
      ),
      check(
        :framed_protocol_present,
        adapter_surface.validation_state.protocol == :framed_protocol_ready and
          adapter_surface.protocol.framing == :desktop_ui_sdl3_frame,
        %{protocol: adapter_surface.protocol, validation_state: adapter_surface.validation_state}
      ),
      check(
        :renderer_first_backend_bounded,
        adapter_surface.renderer.first_backend == :sdl_renderer and
          adapter_surface.renderer.future_backend == :sdl_gpu,
        %{renderer: adapter_surface.renderer}
      ),
      check(
        :adapter_skeleton_not_overstated,
        adapter_surface.renderer_completeness == :skeleton and
          adapter_surface.renderer.placeholder_draw_operations_allowed,
        %{renderer: adapter_surface.renderer, completeness: adapter_surface.renderer_completeness}
      ),
      check(
        :resource_seams_present,
        adapter_surface.validation_state.text == :text_resource_ready and
          adapter_surface.validation_state.images == :image_resource_ready,
        %{validation_state: adapter_surface.validation_state}
      )
    ]

    report(:sdl3_adapter_surface, checks)
  end

  @spec documentation_surface() :: map()
  def documentation_surface do
    missing_docs =
      @required_guides
      |> Enum.reject(&File.exists?(Path.join(package_root(), &1)))

    undocumented_guides = @required_guides -- DesktopUi.Tooling.documentation_surface()

    checks = [
      check(:guide_files_present, missing_docs == [], %{missing: missing_docs}),
      check(:tooling_docs_surface_complete, undocumented_guides == [], %{
        missing: undocumented_guides
      }),
      check(:readme_present, File.exists?(Path.join(package_root(), "README.md")), [])
    ]

    report(:documentation_surface, checks)
  end

  @spec traceability_targets() :: [String.t()]
  def traceability_targets do
    @required_traceability_targets
  end

  @spec traceability_alignment() :: map()
  def traceability_alignment do
    manifest_path =
      Path.join(workspace_root(), ".spec/planning/desktop_ui/spec-traceability.json")

    markdown_path = Path.join(workspace_root(), ".spec/planning/desktop_ui/spec-traceability.md")

    manifest_result = read_traceability_manifest(manifest_path)

    checks = [
      check(
        :traceability_files_present,
        Enum.all?(@required_traceability_targets, &File.exists?(Path.join(workspace_root(), &1))),
        %{
          missing:
            Enum.reject(
              @required_traceability_targets,
              &File.exists?(Path.join(workspace_root(), &1))
            )
        }
      ),
      check(:traceability_manifest_parses, match?({:ok, _}, manifest_result), %{
        manifest_path: manifest_path
      }),
      check(
        :traceability_package_identity,
        traceability_package_identity?(manifest_result),
        %{expected_package: "desktop_ui"}
      ),
      check(
        :root_subjects_referenced,
        traceability_includes_sources?(manifest_result, @required_root_subjects),
        %{missing: traceability_missing_sources(manifest_result, @required_root_subjects)}
      ),
      check(
        :package_subjects_referenced,
        traceability_includes_sources?(manifest_result, @required_package_subjects),
        %{missing: traceability_missing_sources(manifest_result, @required_package_subjects)}
      ),
      check(
        :traceability_direct_prefix_present,
        traceability_includes_direct_prefix?(manifest_result, "desktop_ui."),
        %{expected_prefix: "desktop_ui."}
      ),
      check(:traceability_markdown_present, File.exists?(markdown_path), %{path: markdown_path})
    ]

    report(:traceability_alignment, checks)
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
      "  SDL3 adapter surface passing?: #{report.sdl3_adapter_surface.status == :pass}",
      "  tooling surface passing?: #{report.tooling_surface.status == :pass}",
      "  documentation surface passing?: #{report.documentation_surface.status == :pass}",
      "  traceability alignment passing?: #{report.traceability_alignment.status == :pass}",
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
        :sdl3_adapter_surface,
        "Keep the SDL3 adapter seam explicit, discoverable, and bounded while native rendering remains skeletal.",
        :sdl3_adapter_surface
      ),
      gate(
        :tooling_surface,
        "Keep inspect and validate maintainer workflows available together.",
        :tooling_surface
      ),
      gate(
        :documentation_surface,
        "Keep README and package guides aligned with the implemented desktop runtime surface.",
        :documentation_surface
      ),
      gate(
        :traceability_alignment,
        "Keep root and package traceability aligned with desktop_ui planning and release checks.",
        :traceability_alignment
      )
    ]
  end

  @spec evolution_rules() :: [map()]
  def evolution_rules do
    [
      %{
        id: :sdl3_renderer_first_backend,
        description:
          "SDL_Renderer remains the first concrete backend while future SDL_GPU work must preserve the same render-plan, event, and runtime semantics."
      },
      %{
        id: :desktop_ui_not_dsl_or_iur_owner,
        description:
          "`desktop_ui` consumes authored DSL output and canonical IUR input, but does not own either contract."
      },
      %{
        id: :upstream_changes_require_traceability_review,
        description:
          "When UnifiedUi or UnifiedIUR behavior changes, planning traceability, renderer behavior, and validation should move in the same change set."
      },
      %{
        id: :runtime_transport_and_artifacts_stay_aligned,
        description:
          "Desktop runtime, transport translation, and artifact policies should evolve together so target-specific behavior stays bounded."
      },
      %{
        id: :tooling_docs_and_traceability_move_with_surface,
        description:
          "When the package surface changes, examples, inspection, validation, docs, and traceability should stay synchronized."
      }
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
      sdl3_adapter_surface: sdl3_adapter_surface(),
      tooling_surface: tooling_surface(),
      documentation_surface: documentation_surface(),
      traceability_alignment: traceability_alignment()
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
      evolution_rules: evolution_rules(),
      failing_sections:
        sections
        |> Enum.filter(fn {_name, report} -> report.status != :pass end)
        |> Enum.map(fn {name, _report} -> name end)
        |> Enum.sort()
    }
  end

  defp read_traceability_manifest(path) do
    with {:ok, body} <- File.read(path),
         {:ok, manifest} <- JSON.decode(body) do
      {:ok, manifest}
    end
  end

  defp traceability_package_identity?({:ok, %{"package" => package}}), do: package == "desktop_ui"
  defp traceability_package_identity?(_result), do: false

  defp traceability_includes_sources?({:ok, manifest}, expected_sources) do
    traceability_missing_sources({:ok, manifest}, expected_sources) == []
  end

  defp traceability_includes_sources?(_result, _expected_sources), do: false

  defp traceability_missing_sources({:ok, %{"mappings" => mappings}}, expected_sources) do
    source_files =
      mappings
      |> Enum.map(& &1["source_file"])
      |> Enum.uniq()

    expected_sources -- source_files
  end

  defp traceability_missing_sources(_result, expected_sources), do: expected_sources

  defp traceability_includes_direct_prefix?({:ok, %{"applicability" => applicability}}, prefix) do
    applicability
    |> Map.get("direct_prefixes", [])
    |> Enum.member?(prefix)
  end

  defp traceability_includes_direct_prefix?(_result, _prefix), do: false

  defp package_root do
    Path.expand("../..", __DIR__)
  end

  defp workspace_root do
    Path.expand("../../../..", __DIR__)
  end
end
