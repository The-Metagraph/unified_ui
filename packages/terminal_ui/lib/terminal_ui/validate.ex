defmodule TerminalUi.Validate do
  @moduledoc """
  Coverage, runtime, transport, and capability validation workflows for
  `terminal_ui`.
  """

  @type mode :: :summary | :strict

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

  @spec validation_report() :: map()
  def validation_report do
    %{
      example_coverage: example_coverage(),
      renderer_determinism: renderer_determinism(),
      runtime_behavior: runtime_behavior(),
      transport_validation: transport_validation(),
      capability_behavior: capability_behavior(),
      tooling_surface: tooling_surface()
    }
  end

  @spec validation_summary(map()) :: String.t()
  def validation_summary(report) when is_map(report) do
    [
      "TerminalUi validation summary",
      "  example coverage passing?: #{report.example_coverage.status == :pass}",
      "  renderer deterministic?: #{report.renderer_determinism.status == :pass}",
      "  runtime behavior passing?: #{report.runtime_behavior.status == :pass}",
      "  transport validation passing?: #{report.transport_validation.status == :pass}",
      "  capability behavior passing?: #{report.capability_behavior.status == :pass}",
      "  tooling surface passing?: #{report.tooling_surface.status == :pass}",
      "  failing sections: #{inspect(failing_sections(report))}"
    ]
    |> Enum.join("\n")
  end

  @spec validate(mode()) :: {:ok, map()} | {:error, map()}
  def validate(mode \\ :summary) do
    report = validation_report()

    case {mode, failing_sections(report)} do
      {:strict, [_ | _] = failing} -> {:error, Map.put(report, :failing_sections, failing)}
      {_mode, failing} -> {:ok, Map.put(report, :failing_sections, failing)}
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

  defp failing_sections(report) do
    report
    |> Enum.filter(fn {_section, result} ->
      is_map(result) and Map.get(result, :status) == :fail
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp exported?(module, function, arity) do
    Code.ensure_loaded?(module) and Enum.member?(module.__info__(:functions), {function, arity})
  end
end
