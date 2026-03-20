defmodule Mix.Tasks.Spec.Plancheck do
  use Mix.Task

  @shortdoc "Checks that a package plan fully covers its applicable requirements"
  @moduledoc """
  Checks package-scoped plan coverage using the machine-readable planning manifest.

      mix spec.plancheck web_ui
      mix spec.plancheck web_ui --refresh-state
  """

  @impl true
  def run(args) do
    Mix.Task.run("app.start", [])

    {opts, rest, invalid} =
      OptionParser.parse(args,
        strict: [refresh_state: :boolean, root: :string],
        aliases: [r: :root]
      )

    validate_args!(rest, invalid)
    package = List.first(rest)
    report = Unified.SpecCompliance.plancheck(package, opts)

    Mix.shell().info(
      "spec.plancheck package=#{package} status=#{report.status} applicable=#{report.summary.applicable_requirements} findings=#{report.summary.findings}"
    )

    Enum.each(report.findings, fn finding ->
      Mix.shell().info(format_finding(finding))
    end)

    if report.status == :fail do
      Mix.raise("Spec plancheck failed: #{length(report.findings)} finding(s)")
    end
  end

  defp validate_args!([_package], []), do: :ok

  defp validate_args!(rest, invalid) do
    invalid_flags = Enum.map(invalid, fn {flag, _value} -> flag end)
    extra_args = Enum.map(rest, &inspect/1)
    details = Enum.join(invalid_flags ++ extra_args, ", ")
    Mix.raise("Invalid arguments for spec.plancheck: #{details}")
  end

  defp format_finding(finding) do
    code = finding[:code] || finding["code"] || "finding"
    requirement_id = finding[:requirement_id] || finding["requirement_id"] || "-"
    message = finding[:message] || finding["message"] || ""
    "[ERROR] #{requirement_id} #{code} :: #{message}"
  end
end
