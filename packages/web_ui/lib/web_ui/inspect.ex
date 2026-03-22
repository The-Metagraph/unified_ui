defmodule WebUi.Inspect do
  @moduledoc """
  Maintainer-facing preview and inspection workflows for `web_ui` examples.
  """

  @spec preview(atom()) :: {:ok, map()} | {:error, :unknown_example}
  def preview(id) when is_atom(id) do
    with {:ok, metadata} <- fetch_metadata(id) do
      {:ok,
       %{
         id: id,
         metadata: metadata,
         surface: preview_surface(metadata)
       }}
    end
  end

  @spec catalog() :: map()
  def catalog do
    %{
      examples: WebUi.Examples.catalog(),
      preview_surfaces: WebUi.Tooling.preview_surfaces(),
      package_overview: WebUi.Inspection.package_overview()
    }
  end

  @spec runtime(atom()) :: {:ok, map()} | {:error, :unknown_example}
  def runtime(id) when is_atom(id) do
    with {:ok, preview} <- preview(id) do
      {:ok, preview.surface}
    end
  end

  defp preview_surface(%{category: :native, id: :native_counter}) do
    preview_native(WebUi.Examples.native_counter_screen(), %{})
  end

  defp preview_surface(%{category: :native, id: :native_foundational}) do
    preview_native(WebUi.Examples.native_foundational_screen(), %{})
  end

  defp preview_surface(%{category: :native, id: :native_transport}) do
    preview_native(WebUi.Examples.native_transport_screen(), %{})
  end

  defp preview_surface(%{category: :native, id: :native_advanced}) do
    preview_native(WebUi.Examples.native_advanced_screen(), %{})
  end

  defp preview_surface(%{category: :native, id: :native_styling}) do
    preview_native(
      WebUi.Examples.native_styling_screen(),
      %{focused_id: "style-query", editing_ids: ["style-query"]}
    )
  end

  defp preview_surface(%{category: :canonical, id: :canonical_welcome}) do
    preview_canonical(WebUi.Examples.canonical_welcome_screen(), %{})
  end

  defp preview_surface(%{category: :canonical, id: :canonical_foundational}) do
    preview_canonical(WebUi.Examples.canonical_foundational_screen(), %{})
  end

  defp preview_surface(%{category: :canonical, id: :canonical_transport}) do
    preview_canonical(WebUi.Examples.canonical_transport_screen(), %{})
  end

  defp preview_surface(%{category: :canonical, id: :canonical_advanced}) do
    preview_canonical(WebUi.Examples.canonical_advanced_screen(), %{})
  end

  defp preview_surface(%{category: :canonical, id: :canonical_styling}) do
    preview_canonical(
      WebUi.Examples.canonical_styling_screen(),
      %{theme: :midnight, focused_id: "style-query", editing_ids: ["style-query"]}
    )
  end

  defp preview_surface(%{category: :mixed, id: :foundational_continuity}) do
    WebUi.Examples.foundational_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :advanced_continuity}) do
    WebUi.Examples.advanced_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :mixed_transport}) do
    WebUi.Examples.mixed_transport_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :styling_continuity}) do
    WebUi.Examples.styling_comparison()
  end

  defp preview_native(screen, local_state) do
    {:ok, state} = WebUi.Runtime.mount_native_screen(screen)
    {:ok, snapshot} = WebUi.Inspection.runtime_snapshot(state, local_state)
    snapshot
  end

  defp preview_canonical(element, opts) do
    {runtime_opts, local_state} = split_preview_opts(opts)
    {:ok, state} = WebUi.Runtime.mount_iur_screen(element, runtime_opts)
    {:ok, snapshot} = WebUi.Inspection.runtime_snapshot(state, local_state)
    snapshot
  end

  defp split_preview_opts(opts) do
    local_state = Map.take(opts, [:focused_id, :editing_ids])
    runtime_opts = Keyword.take(Enum.into(opts, []), [:theme])
    {runtime_opts, local_state}
  end

  defp fetch_metadata(id) do
    case WebUi.Examples.metadata(id) do
      nil -> {:error, :unknown_example}
      metadata -> {:ok, metadata}
    end
  end
end
