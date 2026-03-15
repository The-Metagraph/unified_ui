defmodule LiveUi.Tooling do
  @moduledoc """
  Package-facing entrypoint for inspection and validation helpers.
  """

  alias Jido.Signal
  alias LiveUi.Examples
  alias LiveUi.Runtime.State
  alias UnifiedIUR.Element

  @required_example_paths [:native, :canonical, :mixed]
  @required_example_families [:input, :transport, :styling, :overlay, :operational]

  @type workflow ::
          :preview
          | :reference_examples
          | :inspection
          | :styling_inspection
          | :continuity_comparison
          | :export
          | :validation
          | :documentation

  @spec workflows() :: [workflow()]
  def workflows do
    [
      :preview,
      :reference_examples,
      :inspection,
      :styling_inspection,
      :continuity_comparison,
      :export,
      :validation,
      :documentation
    ]
  end

  @spec mix_tasks() :: [String.t()]
  def mix_tasks do
    [
      "mix live_ui.preview",
      "mix live_ui.inspect",
      "mix live_ui.export",
      "mix live_ui.validate"
    ]
  end

  @spec examples() :: [map()]
  def examples do
    Examples.catalog()
  end

  @spec governance_gates() :: map()
  def governance_gates do
    %{
      required_paths: @required_example_paths,
      required_example_families: @required_example_families,
      change_review_expectations: [
        :paired_native_and_canonical_example_review,
        :boundary_transport_review,
        :server_authority_review
      ],
      release_readiness_focus: [:example_health, :continuity_alignment, :boundary_transport]
    }
  end

  @spec validation_report() :: map()
  def validation_report do
    catalog = examples()
    example_health = example_health_report(catalog)
    example_coverage = example_coverage_report(catalog)
    continuity = continuity_report(catalog)
    transport = transport_report()
    runtime_authority = runtime_authority_report(catalog)

    report = %{
      example_health: example_health,
      example_coverage: example_coverage,
      continuity: continuity,
      transport: transport,
      runtime_authority: runtime_authority,
      governance_gates: governance_gates()
    }

    Map.put(report, :release_readiness, release_readiness_report(report))
  end

  @spec validation_summary(map()) :: String.t()
  def validation_summary(report) when is_map(report) do
    [
      "LiveUi validation summary",
      "  examples passing?: #{report.example_health.all_passing?}",
      "  example coverage complete?: #{report.example_coverage.complete?}",
      "  continuity aligned?: #{report.continuity.aligned?}",
      "  transport sound?: #{report.transport.sound?}",
      "  server authoritative?: #{report.runtime_authority.server_authoritative?}",
      "  release ready?: #{report.release_readiness.ready?}",
      "  failing examples: #{inspect(report.example_health.failing_ids)}",
      "  missing paths: #{inspect(report.example_coverage.missing_paths)}",
      "  missing families: #{inspect(report.example_coverage.missing_families)}",
      "  continuity failures: #{inspect(report.continuity.failing_ids)}",
      "  transport issues: #{inspect(report.transport.issues)}"
    ]
    |> Enum.join("\n")
  end

  @spec preview_example(atom() | String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def preview_example(id, opts \\ []) do
    inspect_example(id, opts)
  end

  @spec inspect_example(atom() | String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def inspect_example(id, opts \\ []) do
    with {:ok, example} <- resolve_example(id),
         {:ok, result} <- inspect_example_output(example, opts) do
      {:ok, %{example: example, result: result}}
    end
  end

  @spec compare_example_pair(atom() | String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def compare_example_pair(id, opts \\ []) do
    with {:ok, example} <- resolve_example(id),
         {:ok, native_example, canonical_example} <- continuity_pair(example),
         {:ok, report} <-
           compare_native_and_canonical(
             native_example.module,
             canonical_example.module.element(),
             opts
           ) do
      {:ok,
       %{
         example: example,
         native_example: native_example,
         canonical_example: canonical_example,
         report: report,
         diagnostics:
           Enum.map(report.diagnostics, fn diagnostic ->
             Map.merge(diagnostic, %{
               native_example: native_example.id,
               canonical_example: canonical_example.id,
               native_families: native_example.families,
               canonical_families: canonical_example.families
             })
           end)
       }}
    end
  end

  @spec inspect_native(module(), keyword()) :: {:ok, map()} | {:error, term()}
  def inspect_native(screen, opts \\ []) do
    with {:ok, runtime_state} <- LiveUi.Runtime.mount(screen, opts) do
      {:ok, snapshot(runtime_state, :native)}
    end
  end

  @spec inspect_canonical(Element.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def inspect_canonical(%Element{} = element, opts \\ []) do
    with {:ok, runtime_state} <- LiveUi.Runtime.mount_iur(element, opts) do
      {:ok, snapshot(runtime_state, :canonical)}
    end
  end

  @spec compare_native_and_canonical(module(), Element.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def compare_native_and_canonical(screen, %Element{} = element, opts \\ []) do
    native_opts = Keyword.get(opts, :native_opts, [])
    canonical_opts = Keyword.get(opts, :canonical_opts, [])

    with {:ok, native} <- inspect_native(screen, native_opts),
         {:ok, canonical} <- inspect_canonical(element, canonical_opts) do
      native_widgets = MapSet.new(native.widgets)
      canonical_widgets = MapSet.new(canonical.widgets)
      native_tones = MapSet.new(native.tones)
      canonical_tones = MapSet.new(canonical.tones)

      native_only_widgets =
        MapSet.difference(native_widgets, canonical_widgets) |> MapSet.to_list() |> Enum.sort()

      canonical_only_widgets =
        MapSet.difference(canonical_widgets, native_widgets) |> MapSet.to_list() |> Enum.sort()

      shared_widgets =
        MapSet.intersection(native_widgets, canonical_widgets) |> MapSet.to_list() |> Enum.sort()

      shared_tones =
        MapSet.intersection(native_tones, canonical_tones) |> MapSet.to_list() |> Enum.sort()

      diagnostics =
        []
        |> maybe_add_diagnostic(:native_only_behavior, native_only_widgets)
        |> maybe_add_diagnostic(:canonical_only_behavior, canonical_only_widgets)

      {:ok,
       %{
         native: native,
         canonical: canonical,
         shared_widgets: shared_widgets,
         native_only_widgets: native_only_widgets,
         canonical_only_widgets: canonical_only_widgets,
         shared_tones: shared_tones,
         diagnostics: diagnostics,
         continuity: %{
           widgets_aligned?: native_only_widgets == [] and canonical_only_widgets == [],
           tone_overlap?: shared_tones != [],
           runtime_model_aligned?:
             native.server_authoritative? and canonical.server_authoritative?
         }
       }}
    end
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__

  defp snapshot(%State{} = runtime_state, path) do
    html =
      runtime_state
      |> render_runtime()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    entries = widget_entries(html)

    %{
      path: path,
      mode: runtime_state.mode,
      screen: runtime_state.screen.id(),
      event_routes: Map.keys(runtime_state.event_routes) |> Enum.sort(),
      bridge_hooks: Enum.sort(runtime_state.bridge_hooks),
      widgets: Enum.map(entries, & &1.widget) |> Enum.uniq(),
      tones:
        entries |> Enum.map(& &1.tone) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort(),
      variants:
        entries |> Enum.map(& &1.variant) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort(),
      states:
        entries |> Enum.map(& &1.state) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort(),
      entries: entries,
      html: html,
      server_authoritative?: true
    }
  end

  defp render_runtime(%State{} = runtime_state) do
    LiveUi.Runtime.component().render(%{
      id: "tooling-runtime",
      runtime_state: runtime_state
    })
  end

  defp widget_entries(html) do
    ~r/<[^>]*data-live-ui-widget="[^"]+"[^>]*>/
    |> Regex.scan(html)
    |> Enum.map(fn [tag] ->
      %{
        id: attribute(tag, "id"),
        widget: attribute(tag, "data-live-ui-widget"),
        tone: attribute(tag, "data-live-ui-tone"),
        variant: attribute(tag, "data-live-ui-variant"),
        state: attribute(tag, "data-live-ui-state"),
        class: attribute(tag, "class")
      }
    end)
  end

  defp attribute(tag, name) do
    case Regex.run(~r/#{Regex.escape(name)}="([^"]+)"/, tag, capture: :all_but_first) do
      [value] -> value
      _ -> nil
    end
  end

  defp maybe_add_diagnostic(diagnostics, _reason, []), do: diagnostics

  defp maybe_add_diagnostic(diagnostics, reason, widgets) do
    diagnostics ++ [%{reason: reason, widgets: widgets}]
  end

  defp example_health_report(catalog) do
    results =
      Enum.map(catalog, fn example ->
        case inspect_example(example.id) do
          {:ok, inspection} ->
            %{id: example.id, path: example.path, ok?: true, result: inspection.result}

          {:error, reason} ->
            %{id: example.id, path: example.path, ok?: false, reason: reason}
        end
      end)

    failing_ids =
      results
      |> Enum.reject(& &1.ok?)
      |> Enum.map(& &1.id)

    %{
      total: length(results),
      results: results,
      failing_ids: failing_ids,
      all_passing?: failing_ids == []
    }
  end

  defp example_coverage_report(catalog) do
    present_paths =
      catalog
      |> Enum.map(& &1.path)
      |> Enum.uniq()
      |> Enum.sort()

    present_families =
      catalog
      |> Enum.flat_map(& &1.families)
      |> Enum.uniq()
      |> Enum.sort()

    missing_paths = @required_example_paths -- present_paths
    missing_families = @required_example_families -- present_families

    %{
      present_paths: present_paths,
      missing_paths: missing_paths,
      present_families: present_families,
      missing_families: missing_families,
      complete?: missing_paths == [] and missing_families == []
    }
  end

  defp continuity_report(catalog) do
    targets =
      Enum.filter(catalog, fn example ->
        example.path == :native and :continuity in example.families
      end)

    results =
      Enum.map(targets, fn example ->
        case compare_example_pair(example.id) do
          {:ok, comparison} ->
            report = comparison.report

            %{
              id: example.id,
              ok?:
                report.continuity.widgets_aligned? and report.continuity.tone_overlap? and
                  report.continuity.runtime_model_aligned?,
              report: report,
              diagnostics: comparison.diagnostics
            }

          {:error, reason} ->
            %{id: example.id, ok?: false, reason: reason, diagnostics: [%{reason: reason}]}
        end
      end)

    failing_ids =
      results
      |> Enum.reject(& &1.ok?)
      |> Enum.map(& &1.id)

    %{
      total: length(results),
      results: results,
      failing_ids: failing_ids,
      aligned?: failing_ids == []
    }
  end

  defp transport_report do
    with {:ok, boundary} <- LiveUi.Examples.MixedBoundaryTransport.compare_paths(),
         {:ok, styled} <- LiveUi.Examples.StyledContinuityComparison.compare() do
      issues =
        []
        |> maybe_issue(boundary.native_local.signal != nil, :local_transport_leakage)
        |> maybe_issue(
          not match?(%Signal{}, boundary.native_boundary.signal),
          :missing_native_boundary_signal
        )
        |> maybe_issue(
          not match?(%Signal{}, boundary.canonical_boundary.signal),
          :missing_canonical_boundary_signal
        )
        |> maybe_issue(
          boundary.runtime_action.runtime_event != "rename",
          :unexpected_runtime_event
        )
        |> maybe_issue(
          styled.boundary.runtime_action.runtime_event != "rename",
          :styled_runtime_event
        )

      %{
        sound?: issues == [],
        issues: issues,
        boundary_transport: boundary,
        styled_continuity_boundary: styled.boundary
      }
    else
      {:error, reason} ->
        %{sound?: false, issues: [reason]}
    end
  end

  defp runtime_authority_report(catalog) do
    results =
      catalog
      |> Enum.reject(&(&1.path == :mixed))
      |> Enum.map(fn example ->
        case inspect_example(example.id) do
          {:ok, inspection} ->
            %{
              id: example.id,
              server_authoritative?: Map.get(inspection.result, :server_authoritative?, false)
            }

          {:error, _reason} ->
            %{id: example.id, server_authoritative?: false}
        end
      end)

    %{
      results: results,
      server_authoritative?: Enum.all?(results, & &1.server_authoritative?)
    }
  end

  defp release_readiness_report(report) do
    criteria = [
      gate(
        :example_health,
        "All maintained examples inspect successfully.",
        report.example_health.all_passing?
      ),
      gate(
        :example_coverage,
        "Maintained examples cover the required paths and families.",
        report.example_coverage.complete?
      ),
      gate(
        :continuity,
        "Styled native and canonical continuity pairs stay aligned.",
        report.continuity.aligned?
      ),
      gate(
        :transport,
        "Boundary transport remains canonical-safe and predictable.",
        report.transport.sound?
      ),
      gate(
        :runtime_authority,
        "Inspectable native and canonical paths remain server-authoritative.",
        report.runtime_authority.server_authoritative?
      )
    ]

    %{
      ready?: Enum.all?(criteria, & &1.passed?),
      criteria: criteria,
      required_change_review: governance_gates().change_review_expectations
    }
  end

  defp gate(id, description, passed?) do
    %{id: id, description: description, passed?: passed?}
  end

  defp maybe_issue(issues, false, _reason), do: issues
  defp maybe_issue(issues, true, reason), do: issues ++ [reason]

  defp resolve_example(id) do
    case Examples.find(id) do
      {:ok, example} -> {:ok, example}
      :error -> {:error, :unknown_example}
    end
  end

  defp inspect_example_output(example, opts) do
    case example.path do
      :native ->
        inspect_native(example.module, opts)

      :canonical ->
        inspect_canonical(example.module.element(), opts)

      :mixed ->
        inspect_mixed(example.module)
    end
  end

  defp inspect_mixed(module) do
    cond do
      function_exported?(module, :compare, 0) -> module.compare()
      function_exported?(module, :compare_paths, 0) -> module.compare_paths()
      true -> {:error, :unsupported_mixed_example}
    end
  end

  defp continuity_pair(%{path: :native, comparable_to: comparable_to} = example)
       when not is_nil(comparable_to) do
    with {:ok, paired} <- resolve_example(comparable_to),
         true <- paired.path == :canonical do
      {:ok, example, paired}
    else
      false -> {:error, :invalid_comparison_pair}
      {:error, reason} -> {:error, reason}
    end
  end

  defp continuity_pair(%{path: :canonical, comparable_to: comparable_to} = example)
       when not is_nil(comparable_to) do
    with {:ok, paired} <- resolve_example(comparable_to),
         true <- paired.path == :native do
      {:ok, paired, example}
    else
      false -> {:error, :invalid_comparison_pair}
      {:error, reason} -> {:error, reason}
    end
  end

  defp continuity_pair(_example), do: {:error, :not_comparable_example}
end
