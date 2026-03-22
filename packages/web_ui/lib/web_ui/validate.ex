defmodule WebUi.Validate do
  @moduledoc """
  Coverage, runtime, and release-readiness validation workflows for `web_ui`.
  """

  @type mode :: :summary | :strict
  @required_guides [
    "README.md",
    "guides/runtime_backbone.md",
    "guides/native_runtime_and_examples.md",
    "guides/canonical_rendering_and_transport.md",
    "guides/styling_and_inspection.md",
    "guides/maintainer_workflows.md"
  ]

  @spec example_coverage() :: map()
  def example_coverage do
    matrix = WebUi.Examples.coverage_matrix()
    missing_widget_kinds = WebUi.Widgets.kinds() -- WebUi.Renderer.supported_kinds()

    checks = [
      check(:native_examples_present, WebUi.Examples.native_examples() != [], []),
      check(:canonical_examples_present, WebUi.Examples.canonical_examples() != [], []),
      check(:mixed_examples_present, WebUi.Examples.mixed_examples() != [], []),
      check(:foundational_workflow_present, Map.has_key?(matrix.workflows, :foundational), []),
      check(:advanced_workflow_present, Map.has_key?(matrix.workflows, :advanced), []),
      check(:transport_workflow_present, Map.has_key?(matrix.workflows, :transport), []),
      check(:styling_workflow_present, Map.has_key?(matrix.workflows, :styling), []),
      check(:renderer_covers_widget_kinds, missing_widget_kinds == [], %{
        missing: missing_widget_kinds
      })
    ]

    report(:example_coverage, checks)
  end

  @spec runtime_behavior() :: map()
  def runtime_behavior do
    foundational = WebUi.Examples.foundational_comparison()
    advanced = WebUi.Examples.advanced_comparison()
    styling = WebUi.Examples.styling_comparison()
    transport = WebUi.Examples.mixed_transport_comparison()

    checks = [
      check(
        :foundational_continuity,
        foundational.continuity.widget_kinds_match?,
        foundational.continuity
      ),
      check(:advanced_continuity, advanced.continuity.widget_kinds_match?, advanced.continuity),
      check(
        :styling_continuity,
        styling.continuity.validation.status == :pass,
        styling.continuity
      ),
      check(
        :transport_server_authority,
        transport.continuity.server_authority_preserved?,
        transport.continuity
      ),
      check(
        :transport_boundary_divergence,
        transport.continuity.local_and_boundary_paths_diverge?,
        transport.continuity
      )
    ]

    report(:runtime_behavior, checks)
  end

  @spec tooling_surface() :: map()
  def tooling_surface do
    checks = [
      check(:inspect_surface_present, WebUi.Inspect in WebUi.Tooling.preview_surfaces(), []),
      check(:export_surface_present, exported?(WebUi.Export, :artifact, 1), []),
      check(
        :validate_surface_present,
        exported?(WebUi.Validate, :release_readiness, 1),
        []
      ),
      check(:inspection_workflow_present, :runtime_inspection in WebUi.Tooling.workflows(), []),
      check(
        :continuity_workflow_present,
        :continuity_diagnostics in WebUi.Tooling.workflows(),
        []
      )
    ]

    report(:tooling_surface, checks)
  end

  @spec documentation_surface() :: map()
  def documentation_surface do
    missing_docs =
      @required_guides
      |> Enum.reject(&File.exists?(Path.join(package_root(), &1)))

    undocumented_guides =
      @required_guides -- WebUi.Tooling.documentation_surface()

    checks = [
      check(:guide_files_present, missing_docs == [], %{missing: missing_docs}),
      check(:tooling_docs_surface_complete, undocumented_guides == [], %{
        missing: undocumented_guides
      }),
      check(:readme_present, File.exists?(Path.join(package_root(), "README.md")), [])
    ]

    report(:documentation_surface, checks)
  end

  @spec release_gates() :: [map()]
  def release_gates do
    [
      gate(
        :example_coverage,
        "Maintain native, canonical, and mixed example coverage for the package surface.",
        :example_coverage
      ),
      gate(
        :runtime_behavior,
        "Keep split-runtime behavior, continuity, and transport flows reviewable and healthy.",
        :runtime_behavior
      ),
      gate(
        :tooling_surface,
        "Keep preview, inspection, export, and validation workflows available together.",
        :tooling_surface
      ),
      gate(
        :documentation_surface,
        "Keep README and package guides aligned with the implemented package surface.",
        :documentation_surface
      )
    ]
  end

  @spec evolution_rules() :: [map()]
  def evolution_rules do
    [
      %{
        id: :new_widget_families_require_examples,
        description:
          "New widget families should ship with maintained native, canonical, or mixed examples."
      },
      %{
        id: :renderer_decisions_must_stay_explicit,
        description:
          "New widget kinds must either be mapped in the renderer or called out as intentionally unsupported."
      },
      %{
        id: :runtime_capabilities_require_boundary_review,
        description:
          "New runtime capabilities should keep Phoenix authority, Elm realization, and transport boundaries explicit."
      },
      %{
        id: :tooling_and_docs_move_with_surface,
        description:
          "When the package surface changes, inspection, validation, and documentation should move in the same change set."
      }
    ]
  end

  @spec release_readiness(mode()) :: {:ok, map()} | {:error, map()}
  def release_readiness(mode \\ :summary) do
    sections = %{
      example_coverage: example_coverage(),
      runtime_behavior: runtime_behavior(),
      tooling_surface: tooling_surface(),
      documentation_surface: documentation_surface()
    }

    findings =
      sections
      |> Map.values()
      |> Enum.flat_map(& &1.findings)

    gates =
      Enum.map(release_gates(), fn gate ->
        Map.put(gate, :status, sections[gate.section].status)
      end)

    report = %{
      mode: mode,
      status: if(findings == [], do: :pass, else: :fail),
      findings: findings,
      sections: sections,
      gates: gates,
      evolution_rules: evolution_rules()
    }

    case {mode, findings} do
      {:strict, [_ | _]} -> {:error, report}
      _ -> {:ok, report}
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
end
