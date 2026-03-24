defmodule DesktopUi.Runtime.Window do
  @moduledoc """
  Window registration scaffold for `desktop_ui`.
  """

  alias DesktopUi.Runtime.Screen

  @spec register(Screen.t(), keyword()) :: map()
  def register(%Screen{} = screen, opts \\ []) do
    %{
      id: Keyword.get(opts, :window_id, "window:#{screen.id}"),
      title: screen.title,
      role: screen.root.kind,
      focus_order: focus_order(screen.root),
      platform_target: screen.platform_target,
      lifecycle: :registered
    }
  end

  @spec primary_focus_target(map()) :: String.t() | nil
  def primary_focus_target(window) when is_map(window) do
    window
    |> focus_order()
    |> List.first()
  end

  @spec focus_order(map()) :: [String.t()]
  def focus_order(%{focus_order: focus_order}) when is_list(focus_order), do: focus_order

  def focus_order(%DesktopUi.Widget{} = root) do
    root
    |> collect_focus_order([])
    |> Enum.uniq()
  end

  defp collect_focus_order(%DesktopUi.Widget{} = widget, acc) do
    acc =
      if Map.get(widget.metadata, :focusable, false) do
        acc ++ [to_string(widget.id)]
      else
        acc
      end

    Enum.reduce(widget.children, acc, &collect_focus_order/2)
  end
end
