defmodule DesktopUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for native `desktop_ui` widgets.
  """

  alias DesktopUi.Widget

  @spec families() :: [Widget.family()]
  def families do
    kinds()
    |> Enum.map(&Widget.family_for/1)
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec modules() :: [module()]
  def modules do
    [__MODULE__, Widget]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [:button, :column, :dialog, :menu, :row, :stack, :status, :text, :text_input, :window]
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_contract: :scaffold_ready,
      registration_surface: :scaffold_ready,
      direct_native_scaffold: :scaffold_ready
    }
  end
end
