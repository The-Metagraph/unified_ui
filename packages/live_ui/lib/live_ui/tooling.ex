defmodule LiveUi.Tooling do
  @moduledoc """
  Package-facing entrypoint for inspection and validation helpers.
  """

  alias LiveUi.Examples
  alias LiveUi.Runtime.State
  alias UnifiedIUR.Element

  @type workflow ::
          :reference_examples
          | :inspection
          | :styling_inspection
          | :continuity_comparison
          | :validation
          | :documentation

  @spec workflows() :: [workflow()]
  def workflows do
    [
      :reference_examples,
      :inspection,
      :styling_inspection,
      :continuity_comparison,
      :validation,
      :documentation
    ]
  end

  @spec examples() :: [map()]
  def examples do
    Examples.catalog()
  end

  @spec inspect_native(module(), keyword()) :: {:ok, map()} | {:error, term()}
  def inspect_native(screen, opts \\ []) do
    with {:ok, runtime_state} <- LiveUi.Runtime.mount(screen, opts) do
      {:ok, snapshot(runtime_state, :native)}
    end
  end

  @spec inspect_canonical(Element.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def inspect_canonical(%Element{} = element, opts \\ []) do
    with {:ok, runtime_state} <- LiveUi.Runtime.mount_iur(element, opts) do
      {:ok, snapshot(runtime_state, :canonical)}
    end
  end

  @spec compare_native_and_canonical(module(), Element.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def compare_native_and_canonical(screen, %Element{} = element, opts \\ []) do
    native_opts = Keyword.get(opts, :native_opts, [])
    canonical_opts = Keyword.get(opts, :canonical_opts, [])

    with {:ok, native} <- inspect_native(screen, native_opts),
         {:ok, canonical} <- inspect_canonical(element, canonical_opts) do
      native_widgets = MapSet.new(native.widgets)
      canonical_widgets = MapSet.new(canonical.widgets)
      native_tones = MapSet.new(native.tones)
      canonical_tones = MapSet.new(canonical.tones)

      native_only_widgets =
        MapSet.difference(native_widgets, canonical_widgets) |> MapSet.to_list() |> Enum.sort()

      canonical_only_widgets =
        MapSet.difference(canonical_widgets, native_widgets) |> MapSet.to_list() |> Enum.sort()

      shared_widgets =
        MapSet.intersection(native_widgets, canonical_widgets) |> MapSet.to_list() |> Enum.sort()

      shared_tones =
        MapSet.intersection(native_tones, canonical_tones) |> MapSet.to_list() |> Enum.sort()

      diagnostics =
        []
        |> maybe_add_diagnostic(:native_only_behavior, native_only_widgets)
        |> maybe_add_diagnostic(:canonical_only_behavior, canonical_only_widgets)

      {:ok,
       %{
         native: native,
         canonical: canonical,
         shared_widgets: shared_widgets,
         native_only_widgets: native_only_widgets,
         canonical_only_widgets: canonical_only_widgets,
         shared_tones: shared_tones,
         diagnostics: diagnostics,
         continuity: %{
           widgets_aligned?: native_only_widgets == [] and canonical_only_widgets == [],
           tone_overlap?: shared_tones != [],
           runtime_model_aligned?:
             native.server_authoritative? and canonical.server_authoritative?
         }
       }}
    end
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__

  defp snapshot(%State{} = runtime_state, path) do
    html =
      runtime_state
      |> render_runtime()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    entries = widget_entries(html)

    %{
      path: path,
      mode: runtime_state.mode,
      screen: runtime_state.screen.id(),
      event_routes: Map.keys(runtime_state.event_routes) |> Enum.sort(),
      bridge_hooks: Enum.sort(runtime_state.bridge_hooks),
      widgets: Enum.map(entries, & &1.widget) |> Enum.uniq(),
      tones:
        entries |> Enum.map(& &1.tone) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort(),
      variants:
        entries |> Enum.map(& &1.variant) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort(),
      states:
        entries |> Enum.map(& &1.state) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort(),
      entries: entries,
      html: html,
      server_authoritative?: true
    }
  end

  defp render_runtime(%State{} = runtime_state) do
    LiveUi.Runtime.component().render(%{
      id: "tooling-runtime",
      runtime_state: runtime_state
    })
  end

  defp widget_entries(html) do
    ~r/<[^>]*data-live-ui-widget="[^"]+"[^>]*>/
    |> Regex.scan(html)
    |> Enum.map(fn [tag] ->
      %{
        id: attribute(tag, "id"),
        widget: attribute(tag, "data-live-ui-widget"),
        tone: attribute(tag, "data-live-ui-tone"),
        variant: attribute(tag, "data-live-ui-variant"),
        state: attribute(tag, "data-live-ui-state"),
        class: attribute(tag, "class")
      }
    end)
  end

  defp attribute(tag, name) do
    case Regex.run(~r/#{Regex.escape(name)}="([^"]+)"/, tag, capture: :all_but_first) do
      [value] -> value
      _ -> nil
    end
  end

  defp maybe_add_diagnostic(diagnostics, _reason, []), do: diagnostics

  defp maybe_add_diagnostic(diagnostics, reason, widgets) do
    diagnostics ++ [%{reason: reason, widgets: widgets}]
  end
end
