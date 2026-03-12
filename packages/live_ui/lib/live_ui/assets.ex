defmodule LiveUi.Assets do
  @moduledoc """
  Host-facing asset manifest for JavaScript hooks used by advanced widgets.
  """

  @asset_root Path.expand("../../assets/js", __DIR__)
  @entrypoint "live_ui"
  @import_path "../../deps/live_ui/assets/js/live_ui"

  @hooks %{
    "canvas" => "LiveUi.Canvas",
    "command_palette" => "LiveUi.CommandPalette",
    "split_pane" => "LiveUi.SplitPane",
    "viewport" => "LiveUi.Viewport"
  }

  @spec hooks() :: %{required(String.t()) => String.t()}
  def hooks, do: @hooks

  @spec hook_name(String.t() | atom()) :: String.t() | nil
  def hook_name(kind) do
    Map.get(@hooks, normalize_kind(kind))
  end

  @spec javascript_entrypoint() :: String.t()
  def javascript_entrypoint, do: @entrypoint

  @spec javascript_entrypoint_path() :: String.t()
  def javascript_entrypoint_path, do: Path.join(@asset_root, "#{@entrypoint}.js")

  @spec javascript_import_path() :: String.t()
  def javascript_import_path, do: @import_path

  defp normalize_kind(kind) when is_atom(kind), do: kind |> Atom.to_string() |> normalize_kind()
  defp normalize_kind(kind) when is_binary(kind), do: kind |> String.trim() |> String.downcase()
  defp normalize_kind(_kind), do: ""
end
