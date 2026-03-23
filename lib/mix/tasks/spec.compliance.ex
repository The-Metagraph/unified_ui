defmodule Mix.Tasks.Spec.Compliance do
  use Mix.Task

  alias Unified.SpecCompliance.Output

  @shortdoc "Checks package implementation compliance using conformance evidence"
  @moduledoc """
  Checks package-scoped implementation compliance using a conformance manifest.

      mix spec.compliance elm_ui
      mix spec.compliance elm_ui --no-run-commands
      mix spec.compliance elm_ui --refresh-state
      mix spec.compliance elm_ui --format json --output tmp/elm_ui-compliance.json
  """

  @impl true
  def run(args) do
    Mix.Task.run("app.start", [])

    {opts, rest, invalid} =
      OptionParser.parse(args,
        strict: [
          refresh_state: :boolean,
          run_commands: :boolean,
          root: :string,
          format: :string,
          output: :string
        ],
        aliases: [r: :root]
      )

    validate_args!(rest, invalid)
    package = List.first(rest)
    report = Unified.SpecCompliance.compliance(package, normalize_command_options(opts))
    format = format!(opts)
    content = Output.render(report, format)

    case Keyword.get(opts, :output) do
      nil ->
        Mix.shell().info(content)

      output_path ->
        absolute_path = Output.write!(content, output_path, Keyword.get(opts, :root, File.cwd!()))
        Mix.shell().info("wrote spec.compliance report to #{absolute_path}")
    end

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

  defp format!(opts) do
    case Keyword.get(opts, :format, "text") do
      "text" -> :text
      "json" -> :json
      other -> Mix.raise("Unsupported format for spec.compliance: #{inspect(other)}")
    end
  end
end
