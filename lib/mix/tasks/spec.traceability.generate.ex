defmodule Mix.Tasks.Spec.Traceability.Generate do
  use Mix.Task

  alias Unified.SpecCompliance.Output

  @shortdoc "Generates the markdown traceability mirror for a package"
  @moduledoc """
  Generates `.spec/planning/<package>/spec-traceability.md` from the
  authoritative JSON planning manifest.

      mix spec.traceability.generate elm_ui
      mix spec.traceability.generate live_ui
  """

  @impl true
  def run(args) do
    Mix.Task.run("app.start", [])

    {opts, rest, invalid} =
      OptionParser.parse(args,
        strict: [root: :string],
        aliases: [r: :root]
      )

    validate_args!(rest, invalid)
    package = List.first(rest)
    report = Unified.SpecCompliance.generate_traceability(package, opts)
    Mix.shell().info(Output.render(report, :text))

    if report.status == :fail do
      Mix.raise("Traceability generation failed: #{length(report.findings)} finding(s)")
    end
  end

  defp validate_args!([_package], []), do: :ok

  defp validate_args!(rest, invalid) do
    invalid_flags = Enum.map(invalid, fn {flag, _value} -> flag end)
    extra_args = Enum.map(rest, &inspect/1)
    details = Enum.join(invalid_flags ++ extra_args, ", ")
    Mix.raise("Invalid arguments for spec.traceability.generate: #{details}")
  end
end
