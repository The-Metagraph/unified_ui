defmodule Mix.Tasks.Spec.Plancheck do
  use Mix.Task

  alias Unified.SpecCompliance.Output

  @shortdoc "Checks that a package plan fully covers its applicable requirements"
  @moduledoc """
  Checks package-scoped plan coverage using the machine-readable planning manifest.

      mix spec.plancheck web_ui
      mix spec.plancheck web_ui --refresh-state
      mix spec.plancheck web_ui --format json --output tmp/web_ui-plancheck.json
  """

  @impl true
  def run(args) do
    Mix.Task.run("app.start", [])

    {opts, rest, invalid} =
      OptionParser.parse(args,
        strict: [refresh_state: :boolean, root: :string, format: :string, output: :string],
        aliases: [r: :root]
      )

    validate_args!(rest, invalid)
    package = List.first(rest)
    report = Unified.SpecCompliance.plancheck(package, opts)
    format = format!(opts)
    content = Output.render(report, format)

    case Keyword.get(opts, :output) do
      nil ->
        Mix.shell().info(content)

      output_path ->
        absolute_path = Output.write!(content, output_path, Keyword.get(opts, :root, File.cwd!()))
        Mix.shell().info("wrote spec.plancheck report to #{absolute_path}")
    end

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

  defp format!(opts) do
    case Keyword.get(opts, :format, "text") do
      "text" -> :text
      "json" -> :json
      other -> Mix.raise("Unsupported format for spec.plancheck: #{inspect(other)}")
    end
  end
end
