defmodule Mix.Tasks.Spec.Compliance.Ci do
  use Mix.Task

  alias Unified.SpecCompliance.Output

  @shortdoc "Runs changed-package plan and compliance checks for CI"
  @moduledoc """
  Runs package-scoped plan and implementation compliance for changed packages.

      mix spec.compliance.ci --base origin/main
      mix spec.compliance.ci --changed-file packages/live_ui/lib/live_ui.ex
      mix spec.compliance.ci --base origin/main --format json --output tmp/spec-compliance-ci.json
  """

  @impl true
  def run(args) do
    Mix.Task.run("app.start", [])

    {opts, rest, invalid} =
      OptionParser.parse(args,
        strict: [
          base: :string,
          head: :string,
          changed_file: :keep,
          refresh_state: :boolean,
          run_commands: :boolean,
          root: :string,
          format: :string,
          output: :string
        ],
        aliases: [r: :root]
      )

    validate_args!(rest, invalid)
    report = Unified.SpecCompliance.ci(normalize_command_options(opts))
    format = format!(opts)
    content = Output.render(report, format)

    case Keyword.get(opts, :output) do
      nil ->
        Mix.shell().info(content)

      output_path ->
        absolute_path = Output.write!(content, output_path, Keyword.get(opts, :root, File.cwd!()))
        Mix.shell().info("wrote spec.compliance.ci report to #{absolute_path}")
    end

    if report.status == :fail do
      Mix.raise("Spec compliance CI failed: #{length(report.findings)} finding(s)")
    end
  end

  defp validate_args!([], []), do: :ok

  defp validate_args!(rest, invalid) do
    invalid_flags = Enum.map(invalid, fn {flag, _value} -> flag end)
    extra_args = Enum.map(rest, &inspect/1)
    details = Enum.join(invalid_flags ++ extra_args, ", ")
    Mix.raise("Invalid arguments for spec.compliance.ci: #{details}")
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
      other -> Mix.raise("Unsupported format for spec.compliance.ci: #{inspect(other)}")
    end
  end
end
