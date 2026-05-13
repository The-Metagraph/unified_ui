defmodule UnifiedUi.Compiler.Inspection do
  @moduledoc """
  Maintainer-facing inspection helpers for compiled `UnifiedUi` artifacts.
  """

  alias UnifiedIUR.{Inspect, Reference}
  alias UnifiedUi.Compiler
  alias UnifiedUi.Compiler.Result
  alias UnifiedUi.Info

  @type report :: %{
          module: module(),
          authoring_surface: map(),
          summary: map(),
          listing: map(),
          render_tree: String.t(),
          snapshot: keyword()
        }

  @spec report(module(), keyword() | map()) :: report()
  def report(module, opts \\ []) when is_atom(module) do
    module
    |> Compiler.compile!(opts)
    |> result()
  end

  @spec result(Result.t()) :: report()
  def result(%Result{} = result) do
    %{
      module: result.module,
      authoring_surface: Info.authoring_surface_summary(result.module),
      summary: Result.summary(result),
      listing: Result.listing(result),
      render_tree: Inspect.render_tree(result.iur),
      snapshot: Reference.snapshot(result.iur)
    }
  end

  @spec render(module() | Result.t(), keyword() | map()) :: String.t()
  def render(module, opts \\ [])

  def render(module, opts) when is_atom(module) do
    module
    |> report(opts)
    |> render_report()
  end

  def render(%Result{} = result, _opts) do
    result
    |> result()
    |> render_report()
  end

  defp render_report(report) do
    listing = report.listing
    summary = report.summary

    [
      "UnifiedUi compiler inspection",
      "module: #{inspect(report.module)}",
      "identity: #{inspect(summary.identity_id)}",
      "root: #{inspect(summary.root_id)}",
      "mode: #{inspect(summary.mode)}",
      "default theme: #{inspect(summary.default_theme)}",
      "authored ids: #{format_list(listing.authored.authored_ids)}",
      "authored families: #{format_list(report.authoring_surface.families)}",
      "authored widgets: #{format_widget_contracts(report.authoring_surface.widgets)}",
      "repeated collections: #{format_repeated_collections(report.authoring_surface.repeated_collections)}",
      "row-scope refs: #{format_list(report.authoring_surface.row_scope_refs)}",
      "widget kinds: #{format_list(listing.compiled.widget_kinds)}",
      "layout kinds: #{format_list(listing.compiled.layout_kinds)}",
      "composite kinds: #{format_list(listing.compiled.composite_kinds)}",
      "layer kinds: #{format_list(listing.compiled.layer_kinds)}",
      "display systems: #{format_display_systems(listing.compiled.display_systems)}",
      "theme ids: #{format_list(listing.themes.theme_ids)}",
      "style refs: #{format_list(listing.themes.style_ref_ids)}",
      "binding names: #{format_list(listing.bindings.names)}",
      "signal families: #{format_list(listing.signals.families)}",
      "signal intents: #{format_list(listing.signals.intents)}",
      "trace authored->compiled: #{format_traces(listing.trace.authored_to_compiled)}",
      "render tree:",
      report.render_tree
    ]
    |> Enum.join("\n")
  end

  defp format_display_systems(display_systems) do
    [
      "layered?=#{display_systems.layered?}",
      "viewport?=#{display_systems.viewport?}",
      "canvas?=#{display_systems.canvas?}",
      "layer=#{format_list(display_systems.layer_kinds)}",
      "viewport=#{format_list(display_systems.viewport_kinds)}",
      "canvas=#{format_list(display_systems.canvas_kinds)}"
    ]
    |> Enum.join(", ")
  end

  defp format_traces([]), do: "[]"

  defp format_traces(traces) do
    traces
    |> Enum.map(fn trace ->
      "#{trace.authored_id}->#{trace.compiled_id}[#{trace.type}:#{trace.kind}]"
    end)
    |> format_list()
  end

  defp format_list([]), do: "[]"

  defp format_list(items) do
    items
    |> Enum.map(&inspect/1)
    |> Enum.join(", ")
    |> then(&"[#{&1}]")
  end

  defp format_widget_contracts([]), do: "[]"

  defp format_widget_contracts(widgets) do
    widgets
    |> Enum.map(fn widget ->
      [
        "#{widget.id}[#{widget.family}:#{widget.kind}]",
        "required=#{format_list(Map.get(widget, :required_fields, []))}",
        "slots=#{format_list(Map.get(widget, :optional_slots, []))}",
        "state=#{format_list(Map.get(widget, :state_fields, []))}",
        "interactions=#{format_list(Map.get(widget, :interaction_refs, []))}",
        "bindings=#{format_list(Map.get(widget, :binding_refs, []))}"
      ]
      |> Enum.join(" ")
    end)
    |> Enum.join("; ")
    |> then(&"[#{&1}]")
  end

  defp format_repeated_collections([]), do: "[]"

  defp format_repeated_collections(collections) do
    collections
    |> Enum.map(fn collection ->
      template = Map.get(collection, :child_template, %{})

      "#{collection.id} source=#{inspect(collection.collection_source)} aliases=#{inspect({collection.item_alias, collection.index_alias})} key=#{inspect(collection.key_path)} template=#{inspect(Map.take(template, [:id, :family, :kind]))}"
    end)
    |> Enum.join("; ")
    |> then(&"[#{&1}]")
  end
end
