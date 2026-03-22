defmodule WebUi.Export do
  @moduledoc """
  Review-friendly export helpers for `web_ui` example workflows.
  """

  @spec artifact(atom()) :: {:ok, map()} | {:error, :unknown_example}
  def artifact(id) when is_atom(id) do
    with {:ok, preview} <- WebUi.Inspect.preview(id) do
      {:ok,
       %{
         id: id,
         artifact_names: preview.metadata.artifact_names,
         metadata: preview.metadata,
         payload: preview.surface
       }}
    end
  end

  @spec catalog() :: [map()]
  def catalog do
    WebUi.Examples.catalog()
    |> Enum.map(fn metadata ->
      %{
        id: metadata.id,
        artifact_names: metadata.artifact_names,
        category: metadata.category,
        workflow: metadata.workflow
      }
    end)
  end
end
