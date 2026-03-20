defmodule Mix.Tasks.Spec.Compliance do
  use Mix.Task

  @shortdoc "Checks package implementation compliance using conformance evidence"
  @moduledoc """
  Checks package-scoped implementation compliance using a conformance manifest.

      mix spec.compliance web_ui
      mix spec.compliance web_ui --no-run-commands
      mix spec.compliance web_ui --refresh-state
  """

  @impl true
  def run(args) do
    Mix.Task.run("app.start", [])

    {opts, rest, invalid} =
      OptionParser.parse(args,
        strict: [refresh_state: :boolean, run_commands: :boolean, root: :string],
        aliases: [r: :root]
      )

    validate_args!(rest, invalid)
    package = List.first(rest)
    report = Unified.SpecCompliance.compliance(package, normalize_command_options(opts))

    Mix.shell().info(
      "spec.compliance package=#{package} status=#{report.status} applicable=#{report.summary.applicable_requirements} findings=#{report.summary.findings}"
    )

    Enum.each(report.findings, fn finding ->
      Mix.shell().info(format_finding(finding))
    end)

    if report.status == :fail do
      Mix.raise("Spec compliance failed: #{length(report.findings)} finding(s)")
    end
  end

  defp validate_args!([_package], []), do: :ok

  defp validate_args!(rest, invalid) do
    invalid_flags = Enum.map(invalid, fn {flag, _value} -> flag end)
    extra_args = Enum.map(rest, &inspect/1)
    details = Enum.join(invalid_flags ++ extra_args, ", ")
    Mix.raise("Invalid arguments for spec.compliance: #{details}")
  end

  defp normalize_command_options(opts) do
    case Keyword.fetch(opts, :run_commands) do
      {:ok, _value} -> opts
      :error -> Keyword.put(opts, :run_commands, true)
    end
  end

  defp format_finding(finding) do
    code = finding[:code] || finding["code"] || "finding"
    requirement_id = finding[:requirement_id] || finding["requirement_id"] || "-"
    message = finding[:message] || finding["message"] || ""
    "[ERROR] #{requirement_id} #{code} :: #{message}"
  end
end
