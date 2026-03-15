defmodule LiveUi.Export do
  @moduledoc """
  Review-friendly export helpers for maintained `live_ui` examples.
  """

  alias LiveUi.{Examples, Tooling}

  @type export_format :: :catalog | :metadata | :report | :html | :comparison | :diagnostics

  @spec catalog() :: String.t()
  def catalog do
    inspect_output(Examples.catalog())
  end

  @spec example(atom() | String.t(), export_format()) :: {:ok, String.t()} | {:error, term()}
  def example(id, format \\ :report) do
    with {:ok, example} <- resolve_example(id) do
      export(example, format)
    end
  end

  defp export(_example, :catalog), do: {:ok, catalog()}

  defp export(example, :metadata) do
    {:ok, inspect_output(example)}
  end

  defp export(example, :report) do
    with {:ok, inspection} <- Tooling.inspect_example(example.id) do
      {:ok, inspect_output(inspection)}
    end
  end

  defp export(example, :html) do
    with {:ok, inspection} <- Tooling.preview_example(example.id),
         {:ok, html} <- html_from_preview(inspection) do
      {:ok, html}
    end
  end

  defp export(example, :comparison) do
    exporter =
      case example.path do
        :mixed -> Tooling.inspect_example(example.id)
        _other -> Tooling.compare_example_pair(example.id)
      end

    with {:ok, output} <- exporter do
      {:ok, inspect_output(output)}
    end
  end

  defp export(example, :diagnostics) do
    exporter =
      case example.path do
        :mixed ->
          Tooling.inspect_example(example.id)

        _other ->
          Tooling.compare_example_pair(example.id)
      end

    with {:ok, output} <- exporter do
      {:ok, inspect_output(diagnostics_output(output))}
    end
  end

  defp diagnostics_output(%{diagnostics: diagnostics} = output) when is_list(diagnostics) do
    %{
      example: Map.get(output, :example),
      native_example: Map.get(output, :native_example),
      canonical_example: Map.get(output, :canonical_example),
      diagnostics: diagnostics
    }
  end

  defp diagnostics_output(%{result: result, example: example}) when is_map(result) do
    %{
      example: example,
      diagnostics:
        Map.take(result, [
          :diagnostics,
          :runtime_action,
          :native_boundary,
          :canonical_boundary
        ])
    }
  end

  defp html_from_preview(%{result: %{html: html}}) when is_binary(html), do: {:ok, html}
  defp html_from_preview(_preview), do: {:error, :html_not_available}

  defp resolve_example(id) do
    case Examples.find(id) do
      {:ok, example} -> {:ok, example}
      :error -> {:error, :unknown_example}
    end
  end

  defp inspect_output(value) do
    Kernel.inspect(value, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end
end
