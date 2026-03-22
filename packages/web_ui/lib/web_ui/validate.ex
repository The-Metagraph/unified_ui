defmodule WebUi.Validate do
  @moduledoc """
  Coverage, runtime, and release-readiness validation workflows for `web_ui`.
  """

  @type mode :: :summary | :strict

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

  @spec release_readiness(mode()) :: {:ok, map()} | {:error, map()}
  def release_readiness(mode \\ :summary) do
    sections = %{
      example_coverage: example_coverage(),
      runtime_behavior: runtime_behavior(),
      tooling_surface: tooling_surface()
    }

    findings =
      sections
      |> Map.values()
      |> Enum.flat_map(& &1.findings)

    report = %{
      mode: mode,
      status: if(findings == [], do: :pass, else: :fail),
      findings: findings,
      sections: sections
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

  defp exported?(module, function, arity) do
    Code.ensure_loaded?(module) and Enum.member?(module.__info__(:functions), {function, arity})
  end
end
