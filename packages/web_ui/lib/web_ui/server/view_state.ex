defmodule WebUi.Server.ViewState do
  @moduledoc """
  Authoritative server-side view-state generation for the `web_ui` scaffold.
  """

  alias WebUi.Frontend
  alias WebUi.Server.Error

  @type t :: %{
          screen: %{
            id: atom(),
            title: String.t(),
            module: module(),
            mode: atom()
          },
          assigns: map(),
          widgets: [map()],
          widget_summaries: [map()],
          bridge: map(),
          revision: non_neg_integer()
        }

  @spec build(module(), map(), keyword()) :: {:ok, t()} | {:error, Error.t()}
  def build(screen, assigns, opts \\ []) when is_atom(screen) and is_map(assigns) do
    with {:ok, widgets} <- normalize_widgets(screen, screen.view(assigns)),
         {:ok, frontend_boot} <- normalize_frontend_boot(screen, screen.frontend_boot()) do
      revision = Keyword.get(opts, :revision, 0)
      mode = Keyword.get(opts, :mode, :native)

      {:ok,
       %{
         screen: %{
           id: screen.id(),
           title: screen.title(),
           module: screen,
           mode: mode
         },
         assigns: assigns,
         widgets: widgets,
         widget_summaries: Enum.map(widgets, &widget_summary/1),
         bridge: %{
           assets_root: Frontend.assets_root(),
           entry_module: Frontend.entry_module(),
           boot: frontend_boot
         },
         revision: revision
       }}
    end
  end

  defp normalize_widgets(screen, widgets) when is_list(widgets) do
    widgets
    |> Enum.reduce_while({:ok, []}, fn widget, {:ok, acc} ->
      case normalize_widget(screen, widget) do
        {:ok, normalized} -> {:cont, {:ok, acc ++ [normalized]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp normalize_widgets(screen, other), do: {:error, Error.invalid_view(screen, other)}

  defp normalize_widget(screen, widget) when is_list(widget) do
    screen
    |> normalize_widget(Enum.into(widget, %{}))
  end

  defp normalize_widget(_screen, %{id: id, kind: kind} = widget) do
    {:ok,
     %{
       id: id,
       kind: kind,
       props: normalize_map(Map.get(widget, :props, %{})),
       slots: normalize_map(Map.get(widget, :slots, %{})),
       style: normalize_map(Map.get(widget, :style, %{})),
       events: normalize_map(Map.get(widget, :events, %{})),
       metadata: normalize_map(Map.get(widget, :metadata, %{}))
     }}
  end

  defp normalize_widget(screen, %{"id" => id, "kind" => kind} = widget) do
    normalize_widget(screen, %{id: id, kind: kind, props: Map.get(widget, "props", %{})})
  end

  defp normalize_widget(screen, other), do: {:error, Error.invalid_widget(screen, other)}

  defp normalize_frontend_boot(_screen, boot) when is_map(boot), do: {:ok, Map.new(boot)}
  defp normalize_frontend_boot(_screen, boot) when is_list(boot), do: {:ok, Enum.into(boot, %{})}

  defp normalize_frontend_boot(screen, other),
    do: {:error, Error.invalid_frontend_boot(screen, other)}

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})
  defp normalize_map(_other), do: %{}

  defp widget_summary(widget) do
    %{
      id: widget.id,
      kind: widget.kind,
      event_names: widget.events |> Map.keys() |> Enum.sort(),
      slot_names: widget.slots |> Map.keys() |> Enum.sort()
    }
  end
end
