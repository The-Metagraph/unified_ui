defmodule UnifiedExamples.Shared.AppReadme do
  @moduledoc """
  Per-app README generation and synchronization checks for the standalone example suite.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.InteractionDemo

  @spec path(String.t() | atom()) :: String.t()
  def path(directory) do
    directory
    |> normalize_directory()
    |> then(&Path.join([Shared.suite_root(), &1, "README.md"]))
  end

  @spec expected_contents(String.t() | atom()) :: String.t()
  def expected_contents(directory) do
    entry = Catalog.entry!(directory)
    interaction_demo = entry.interaction_demo

    example_name =
      entry.widget |> Atom.to_string() |> String.replace("_", " ") |> Macro.camelize()

    """
    # Unified Examples #{example_name}

    This standalone Phoenix LiveView app demonstrates the `#{entry.widget}` widget through the shared example-suite DSL template, theme, and style profile.

    It uses #{storytelling_sentence(InteractionDemo.storytelling(interaction_demo))} so reviewers can understand both the browser-visible outcome and the canonical signal meaning.

    ## Run

    From this directory:

    `mix deps.get`
    `mix phx.server`

    The app mounts at `http://127.0.0.1:4000/` by default. Override the port with
    `PORT=4100 mix phx.server`.

    ## Try It

    #{interaction_demo.idle_prompt}

    #{trigger_hint(interaction_demo)}

    ## Expect

    #{interaction_demo.outcome}

    The browser should keep both the `Meaningful Interaction Story` panel and the
    `Canonical Signal Preview` panel visible while you review the example.

    ## Validate

    `mix test`

    Shared suite support lives in `../shared`.
    """
    |> String.trim()
    |> Kernel.<>("\n")
  end

  @spec report() :: map()
  def report do
    directories = Catalog.directories()

    mismatched_directories =
      Enum.reject(directories, fn directory ->
        File.exists?(path(directory)) and
          File.read!(path(directory)) == expected_contents(directory)
      end)

    %{
      checked_directories: directories,
      mismatched_directories: mismatched_directories,
      synchronized?: mismatched_directories == []
    }
  end

  @spec sync(String.t() | atom()) :: :ok
  def sync(directory) do
    File.write!(path(directory), expected_contents(directory))
  end

  @spec sync_all() :: :ok
  def sync_all do
    Enum.each(Catalog.directories(), &sync/1)
  end

  defp storytelling_sentence(:source_driven) do
    "source-driven interaction storytelling"
  end

  defp storytelling_sentence(:target_driven) do
    "target-driven interaction storytelling"
  end

  defp trigger_hint(%{trigger_label: nil}), do: ""
  defp trigger_hint(%{trigger_label: ""}), do: ""

  defp trigger_hint(%{trigger_label: label}) do
    "If the example uses the shared trigger, click `#{label}`."
  end

  defp normalize_directory(directory) when is_atom(directory), do: Atom.to_string(directory)
  defp normalize_directory(directory) when is_binary(directory), do: directory
end
