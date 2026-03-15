defmodule UnifiedUi.Tooling do
  @moduledoc """
  Maintainer-facing tooling helpers for example inspection, export, diagnostics,
  and release review workflows.
  """

  alias UnifiedUi.{Compiler, Examples, Export, Info}

  @shared_specs [
    ".spec/specs/architecture.spec.md",
    ".spec/specs/dsl_iur_symbiosis.spec.md",
    ".spec/specs/unified-ui/package.spec.md",
    ".spec/specs/unified-ui/tooling.spec.md"
  ]

  @construct_specs %{
    foundational_visual: [".spec/specs/unified-ui/widgets.spec.md"],
    input: [".spec/specs/unified-ui/widgets.spec.md", ".spec/specs/unified-ui/signals.spec.md"],
    navigation: [
      ".spec/specs/unified-ui/widgets.spec.md",
      ".spec/specs/unified-ui/signals.spec.md"
    ],
    forms: [".spec/specs/unified-ui/widgets.spec.md", ".spec/specs/unified-ui/signals.spec.md"],
    data: [".spec/specs/unified-ui/widgets.spec.md"],
    feedback: [".spec/specs/unified-ui/widgets.spec.md"],
    advanced: [
      ".spec/specs/unified-ui/widgets.spec.md",
      ".spec/specs/unified-ui/display_systems.spec.md"
    ],
    layout: [".spec/specs/unified-ui/display_systems.spec.md"],
    display: [".spec/specs/unified-ui/display_systems.spec.md"],
    overlay: [".spec/specs/unified-ui/display_systems.spec.md"],
    canvas: [".spec/specs/unified-ui/display_systems.spec.md"],
    themes: [".spec/specs/unified-ui/theming.spec.md"],
    signals: [".spec/specs/unified-ui/signals.spec.md", ".spec/specs/unified-ui/compiler.spec.md"]
  }

  @type inspection_result :: {:ok, map()} | {:error, map()}

  @spec example_catalog() :: [map()]
  def example_catalog do
    Examples.catalog()
  end

  @spec coverage_report() :: map()
  def coverage_report do
    Examples.coverage_report()
  end

  @spec coverage_summary() :: String.t()
  def coverage_summary do
    coverage_report()
    |> inspect_term()
  end

  @spec inspect_example(atom()) :: inspection_result() | :error
  def inspect_example(id) when is_atom(id) do
    with {:ok, example} <- Examples.example(id),
         {:ok, report} <- inspect_module(example.module) do
      {:ok,
       report
       |> Map.put(:example, Map.drop(example, [:module]))
       |> Map.put(:review_artifact, example.review_artifact)}
    end
  end

  @spec inspect_module(module()) :: inspection_result()
  def inspect_module(module) when is_atom(module) do
    try do
      composition = Info.composition_summary(module)
      module_summary = Info.inspect_module(module)
      compiler_report = Compiler.inspection(module)
      construct_families = composition |> collect_construct_families() |> Enum.sort()

      {:ok,
       %{
         module: module,
         authored: module_summary,
         compiler: compiler_report,
         construct_families: construct_families,
         signal_coverage: signal_coverage(module_summary.signal_catalog),
         related_examples: related_examples(construct_families, module),
         related_specs: related_specs(construct_families)
       }}
    rescue
      error ->
        {:error, diagnostic_report(module, error)}
    end
  end

  @spec module_diagnostics(module()) :: map()
  def module_diagnostics(module) when is_atom(module) do
    case inspect_module(module) do
      {:ok, report} ->
        %{
          status: :ok,
          module: module,
          construct_families: report.construct_families,
          related_examples: Enum.map(report.related_examples, & &1.id),
          related_specs: report.related_specs,
          summary: report.compiler.summary,
          signal_coverage: report.signal_coverage
        }

      {:error, diagnostics} ->
        diagnostics
    end
  end

  @spec diagnostics_summary(module()) :: String.t()
  def diagnostics_summary(module) when is_atom(module) do
    module
    |> module_diagnostics()
    |> render_diagnostics()
  end

  @spec diff_examples(atom(), atom()) :: {:ok, map()} | :error
  def diff_examples(left_id, right_id) when is_atom(left_id) and is_atom(right_id) do
    with {:ok, left} <- Examples.example(left_id),
         {:ok, right} <- Examples.example(right_id) do
      {:ok,
       diff_modules(left.module, right.module)
       |> Map.put(:left_example, left_id)
       |> Map.put(:right_example, right_id)}
    end
  end

  @spec diff_modules(module(), module()) :: map()
  def diff_modules(left_module, right_module)
      when is_atom(left_module) and is_atom(right_module) do
    {:ok, left} = inspect_module(left_module)
    {:ok, right} = inspect_module(right_module)

    constructs =
      (left.construct_families ++ right.construct_families)
      |> Enum.uniq()
      |> Enum.sort()

    %{
      left: left_module,
      right: right_module,
      snapshot_changed?: left.compiler.snapshot != right.compiler.snapshot,
      changes: %{
        widget_kinds:
          delta(
            left.compiler.listing.compiled.widget_kinds,
            right.compiler.listing.compiled.widget_kinds
          ),
        layout_kinds:
          delta(
            left.compiler.listing.compiled.layout_kinds,
            right.compiler.listing.compiled.layout_kinds
          ),
        layer_kinds:
          delta(
            left.compiler.listing.compiled.layer_kinds,
            right.compiler.listing.compiled.layer_kinds
          ),
        signal_ids: delta(left.compiler.listing.signals.ids, right.compiler.listing.signals.ids),
        binding_names:
          delta(left.compiler.listing.bindings.names, right.compiler.listing.bindings.names),
        theme_ids:
          delta(left.compiler.listing.themes.theme_ids, right.compiler.listing.themes.theme_ids)
      },
      related_specs: related_specs(constructs)
    }
  end

  @spec render_diagnostics(map()) :: String.t()
  def render_diagnostics(%{status: :ok} = diagnostics) do
    [
      "UnifiedUi diagnostics",
      "status: ok",
      "module: #{inspect(diagnostics.module)}",
      "construct families: #{inspect(diagnostics.construct_families)}",
      "related examples: #{inspect(diagnostics.related_examples)}",
      "related specs: #{inspect(diagnostics.related_specs)}",
      "signal families: #{inspect(diagnostics.signal_coverage.families)}",
      "binding names: #{inspect(diagnostics.signal_coverage.binding_names)}"
    ]
    |> Enum.join("\n")
  end

  def render_diagnostics(%{status: :error} = diagnostics) do
    [
      "UnifiedUi diagnostics",
      "status: error",
      "module: #{inspect(diagnostics.module)}",
      "error kind: #{inspect(diagnostics.error)}",
      "message: #{diagnostics.message}",
      "related examples: #{inspect(diagnostics.related_examples)}",
      "related specs: #{inspect(diagnostics.related_specs)}",
      "hints: #{inspect(diagnostics.hints)}"
    ]
    |> Enum.join("\n")
  end

  @spec export_example(atom(), Export.export_format()) :: {:ok, String.t()} | :error
  def export_example(id, format \\ :inspection) when is_atom(id) do
    Export.example(id, format)
  end

  @spec export_module(module(), Export.export_format()) :: {:ok, String.t()} | {:error, map()}
  def export_module(module, format \\ :inspection) when is_atom(module) do
    Export.module(module, format)
  end

  defp signal_coverage(signal_catalog) do
    %{
      namespace: signal_catalog.namespace,
      mode: signal_catalog.mode,
      binding_names:
        signal_catalog.bindings
        |> Enum.map(& &1.id)
        |> sort_terms(),
      interaction_ids:
        signal_catalog.interactions
        |> Enum.map(& &1.id)
        |> sort_terms(),
      families:
        signal_catalog.interactions
        |> Enum.map(& &1.family)
        |> Enum.uniq()
        |> Enum.sort(),
      target_bindings:
        signal_catalog.interactions
        |> Enum.flat_map(fn interaction ->
          binding_refs =
            interaction
            |> Map.get(:binding_refs, [])
            |> List.wrap()
            |> Enum.map(&Map.get(&1, :id, &1["id"]))

          target_binding =
            interaction
            |> Map.get(:target_intent, %{})
            |> Map.get(:binding)
            |> List.wrap()

          binding_refs ++ target_binding
        end)
        |> sort_terms()
    }
  end

  defp related_examples(construct_families, exclude_module) do
    Examples.catalog()
    |> Enum.reject(&(&1.module == exclude_module))
    |> Enum.filter(fn example ->
      Enum.any?(example.constructs, &(&1 in construct_families))
    end)
    |> Enum.map(&Map.drop(&1, [:module]))
  end

  defp related_specs(construct_families) do
    construct_specs =
      construct_families
      |> Enum.flat_map(&Map.get(@construct_specs, &1, []))

    (@shared_specs ++ construct_specs)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp collect_construct_families(nodes) do
    Enum.flat_map(nodes, fn node ->
      [node.family | collect_construct_families(Map.get(node, :children, []))]
    end)
    |> Enum.uniq()
  end

  defp diagnostic_report(module, error) do
    %{
      status: :error,
      module: module,
      error: error.__struct__,
      message: Exception.message(error),
      related_examples: Enum.map(Examples.catalog(), & &1.id),
      related_specs: @shared_specs,
      hints: [
        "review the compiler inspection and signal summaries for a nearby maintained example",
        "check the construct-specific package specs linked in related_specs",
        "use UnifiedUi.Tooling.diff_examples/2 to compare the changed authored surface against a maintained reference"
      ]
    }
  end

  defp inspect_term(term) do
    inspect(term, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp delta(left, right) do
    %{
      added: sort_terms(right -- left),
      removed: sort_terms(left -- right),
      unchanged: sort_terms(left -- (left -- right))
    }
  end

  defp sort_terms(terms) do
    terms
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end
end
