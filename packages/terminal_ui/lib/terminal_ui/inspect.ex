defmodule TerminalUi.Inspect do
  @moduledoc """
  Maintainer-facing preview and inspection workflows for `terminal_ui` examples.
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
      examples: TerminalUi.Examples.catalog(),
      preview_surfaces: TerminalUi.Tooling.preview_surfaces(),
      package_overview: TerminalUi.Inspection.package_overview()
    }
  end

  @spec render(atom() | String.t(), atom()) :: {:ok, String.t()} | {:error, term()}
  def render(id, format \\ :report) do
    with {:ok, preview} <- preview(id) do
      {:ok, format_preview(preview, format)}
    end
  end

  defp preview_surface(%{category: :native, id: :native_foundational}) do
    preview_native(TerminalUi.Examples.native_foundational_screen(), backend_mode: :raw)
  end

  defp preview_surface(%{category: :native, id: :native_advanced_operations}) do
    preview_native(TerminalUi.Examples.native_advanced_operations_screen(), backend_mode: :raw)
  end

  defp preview_surface(%{category: :native, id: :native_transport_review}) do
    preview_native(TerminalUi.Examples.native_transport_screen(), backend_mode: :raw)
  end

  defp preview_surface(%{category: :native, id: :native_styled_review}) do
    preview_native(TerminalUi.Examples.native_styled_screen(), backend_mode: :raw)
  end

  defp preview_surface(%{category: :canonical, id: :canonical_foundational}) do
    preview_canonical(TerminalUi.Examples.canonical_foundational_screen(), backend_mode: :raw)
  end

  defp preview_surface(%{category: :canonical, id: :canonical_advanced_operations}) do
    preview_canonical(TerminalUi.Examples.canonical_advanced_operations_screen(),
      backend_mode: :raw
    )
  end

  defp preview_surface(%{category: :canonical, id: :canonical_transport_review}) do
    preview_canonical(TerminalUi.Examples.canonical_transport_screen(), backend_mode: :raw)
  end

  defp preview_surface(%{category: :canonical, id: :canonical_styled_review}) do
    preview_canonical(
      TerminalUi.Examples.canonical_styled_screen(),
      backend_mode: :raw,
      theme: :high_contrast
    )
  end

  defp preview_surface(%{category: :mixed, id: :foundational_continuity}) do
    TerminalUi.Examples.foundational_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :advanced_continuity}) do
    TerminalUi.Examples.advanced_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :advanced_capability_continuity}) do
    TerminalUi.Examples.advanced_capability_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :transport_flow_review}) do
    TerminalUi.Examples.transport_flow_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :normalized_input_profiles}) do
    TerminalUi.Examples.normalized_input_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :styled_continuity_review}) do
    TerminalUi.Examples.styled_continuity_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :styled_degradation_review}) do
    TerminalUi.Examples.styled_degradation_comparison()
  end

  defp preview_surface(%{category: :mixed, id: :navigation_transition_review}) do
    TerminalUi.Examples.navigation_transition_review()
  end

  defp preview_native(screen, opts) do
    {:ok, state} = TerminalUi.Runtime.mount_native_screen(screen, opts)
    TerminalUi.Inspection.runtime_snapshot(state)
  end

  defp preview_canonical(element, opts) do
    {:ok, state} = TerminalUi.Runtime.mount_iur_screen(element, opts)
    TerminalUi.Inspection.runtime_snapshot(state)
  end

  defp fetch_metadata(id) do
    case resolve_metadata(id) do
      nil -> {:error, :unknown_example}
      metadata -> {:ok, metadata}
    end
  end

  defp resolve_metadata(id) when is_atom(id), do: TerminalUi.Examples.metadata(id)

  defp resolve_metadata(id) when is_binary(id) do
    Enum.find(TerminalUi.Examples.catalog(), &(Atom.to_string(&1.id) == id))
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
          %{
            id: preview.id,
            metadata: preview.metadata,
            surface: preview.surface
          }

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
            coverage: Map.get(preview.surface, :coverage, []),
            transport_mappings: TerminalUi.Transport.diagnostics(),
            capability_assumptions: TerminalUi.Capabilities.diagnostics()
          }

        _other ->
          %{
            id: preview.id,
            category: preview.metadata.category,
            runtime: preview.surface.runtime,
            capabilities: preview.surface.capabilities,
            degradation: preview.surface.degradation,
            style: preview.surface.style,
            transport_mappings: TerminalUi.Transport.diagnostics()
          }
      end

    Kernel.inspect(diagnostics, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end
end
