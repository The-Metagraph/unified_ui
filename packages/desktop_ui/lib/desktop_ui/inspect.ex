defmodule DesktopUi.Inspect do
  @moduledoc """
  Maintainer-facing preview and inspection workflows for `desktop_ui` examples.
  """

  @spec preview(atom() | String.t()) :: {:ok, map()} | {:error, :unknown_example}
  def preview(id) do
    with {:ok, metadata} <- fetch_metadata(id) do
      {:ok,
       %{
         id: metadata.id,
         metadata: metadata,
         surface: preview_surface(metadata)
       }}
    end
  end

  @spec catalog() :: map()
  def catalog do
    %{
      examples: DesktopUi.Examples.catalog(),
      preview_surfaces: DesktopUi.Tooling.preview_surfaces(),
      package_overview: DesktopUi.Inspection.package_overview(),
      tooling_workflows: DesktopUi.Tooling.workflows()
    }
  end

  @spec render(atom() | String.t(), atom()) :: {:ok, String.t()} | {:error, term()}
  def render(id, format \\ :report) do
    with {:ok, preview} <- preview(id) do
      {:ok, format_preview(preview, format)}
    end
  end

  defp preview_surface(%{category: :native, id: :native_foundational}) do
    preview_native(DesktopUi.Examples.native_foundational_screen(), platform_target: :linux)
  end

  defp preview_surface(%{category: :native, id: :native_advanced_operations}) do
    preview_native(DesktopUi.Examples.native_advanced_operations_screen(),
      platform_target: :linux
    )
  end

  defp preview_surface(%{category: :native, id: :native_transport_review}) do
    preview_native(DesktopUi.Examples.native_transport_review(), platform_target: :linux)
  end

  defp preview_surface(%{category: :native, id: :native_styled_review}) do
    preview_native(DesktopUi.Examples.native_styled_review(),
      platform_target: :linux,
      theme: :high_contrast
    )
  end

  defp preview_surface(%{category: :canonical, id: :canonical_foundational}) do
    preview_canonical(DesktopUi.Examples.canonical_foundational_screen(), platform_target: :linux)
  end

  defp preview_surface(%{category: :canonical, id: :canonical_advanced_operations}) do
    preview_canonical(DesktopUi.Examples.canonical_advanced_operations_screen(),
      platform_target: :linux
    )
  end

  defp preview_surface(%{category: :canonical, id: :canonical_transport_review}) do
    preview_canonical(DesktopUi.Examples.canonical_transport_review(), platform_target: :linux)
  end

  defp preview_surface(%{category: :canonical, id: :canonical_styled_review}) do
    preview_canonical(DesktopUi.Examples.canonical_styled_review(),
      platform_target: :linux,
      theme: :high_contrast
    )
  end

  defp preview_surface(%{category: :mixed, id: :foundational_continuity}) do
    DesktopUi.Examples.foundational_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :advanced_continuity}) do
    DesktopUi.Examples.advanced_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :transport_flow_review}) do
    DesktopUi.Examples.transport_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :normalized_input_profiles}) do
    DesktopUi.Examples.normalized_input_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :styled_continuity_review}) do
    DesktopUi.Examples.styled_comparison()
  end

  defp preview_native(screen, opts) do
    {:ok, state} = DesktopUi.Runtime.mount_native_screen(screen, opts)
    DesktopUi.Inspection.runtime_snapshot(state)
  end

  defp preview_canonical(element, opts) do
    {:ok, state} = DesktopUi.Runtime.mount_iur_screen(element, opts)
    DesktopUi.Inspection.runtime_snapshot(state)
  end

  defp fetch_metadata(id) do
    case resolve_metadata(id) do
      nil -> {:error, :unknown_example}
      metadata -> {:ok, metadata}
    end
  end

  defp resolve_metadata(id) when is_atom(id), do: DesktopUi.Examples.metadata(id)

  defp resolve_metadata(id) when is_binary(id) do
    Enum.find(DesktopUi.Examples.catalog(), &(Atom.to_string(&1.id) == id))
  end

  defp resolve_metadata(_id), do: nil

  defp format_preview(preview, :report) do
    Kernel.inspect(preview, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp format_preview(preview, :metadata) do
    Kernel.inspect(preview.metadata, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp format_preview(preview, :comparison) do
    payload =
      case preview.metadata.category do
        :mixed ->
          %{id: preview.id, metadata: preview.metadata, surface: preview.surface}

        _other ->
          %{
            id: preview.id,
            metadata: preview.metadata,
            direct_native_and_canonical_runtime_behavior: preview.surface
          }
      end

    Kernel.inspect(payload, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp format_preview(preview, :diagnostics) do
    diagnostics =
      case preview.metadata.category do
        :mixed ->
          %{
            id: preview.id,
            category: preview.metadata.category,
            parity: Map.get(preview.surface, :parity, %{}),
            coverage: Map.get(preview.surface, :coverage, %{}),
            tooling_workflows: DesktopUi.Tooling.workflows(),
            transport_mappings: DesktopUi.Transport.diagnostics(),
            artifact_workflows: DesktopUi.Artifacts.diagnostics()
          }

        _other ->
          %{
            id: preview.id,
            category: preview.metadata.category,
            runtime: preview.surface.runtime,
            style: preview.surface.style,
            platform: preview.surface.platform,
            artifact_workflows: DesktopUi.Artifacts.workflow(preview.surface.platform.target)
          }
      end

    Kernel.inspect(diagnostics, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end
end
