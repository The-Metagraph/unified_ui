defmodule WebUi.Server.ViewState do
  @moduledoc """
  Authoritative server-side view-state generation for the `web_ui` scaffold.
  """

  alias WebUi.Frontend
  alias WebUi.Server.Error
  alias WebUi.Server.RenderModel
  alias WebUi.Widget
  alias WebUi.Widgets

  @type t :: %{
          screen: %{
            id: String.t() | atom(),
            title: String.t(),
            module: module(),
            mode: atom()
          },
          assigns: map(),
          widgets: [Widget.t()],
          widget_summaries: [map()],
          render_tree: [map()],
          bridge: map(),
          revision: non_neg_integer()
        }

  @spec build(module(), map(), keyword()) :: {:ok, t()} | {:error, Error.t()}
  def build(screen, assigns, opts \\ []) when is_atom(screen) and is_map(assigns) do
    with {:ok, widgets} <- normalize_widgets(screen, screen.view(assigns)),
         {:ok, frontend_boot} <- normalize_frontend_boot(screen, screen.frontend_boot()) do
      revision = Keyword.get(opts, :revision, 0)
      mode = Keyword.get(opts, :mode, :native)

      from_widgets(
        %{id: screen.id(), title: screen.title(), module: screen, mode: mode},
        assigns,
        widgets,
        frontend_boot,
        revision: revision,
        mode: mode
      )
    end
  end

  @spec from_widgets(map(), map(), [Widget.t() | map() | keyword()], map() | keyword(), keyword()) ::
          {:ok, t()} | {:error, Error.t()}
  def from_widgets(screen, assigns, widgets, frontend_boot, opts \\ [])
      when is_map(screen) and is_map(assigns) do
    with {:ok, widgets} <- normalize_widgets(screen, widgets),
         {:ok, frontend_boot} <- normalize_frontend_boot(screen, frontend_boot) do
      revision = Keyword.get(opts, :revision, 0)
      mode = Keyword.get(opts, :mode, Map.get(screen, :mode, :native))

      {:ok,
       %{
         screen: %{
           id: Map.get(screen, :id),
           title: Map.get(screen, :title, "Untitled"),
           module: Map.get(screen, :module, __MODULE__),
           mode: mode
         },
         assigns: assigns,
         widgets: widgets,
         widget_summaries: Enum.map(widgets, &Widget.summary/1),
         render_tree: Enum.map(widgets, &RenderModel.build/1),
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
      case Widgets.normalize(widget) do
        {:ok, normalized} -> {:cont, {:ok, [normalized | acc]}}
        {:error, _reason} -> {:halt, {:error, Error.invalid_widget(screen, widget)}}
      end
    end)
    |> case do
      {:ok, normalized} -> {:ok, Enum.reverse(normalized)}
      {:error, error} -> {:error, error}
    end
  end

  defp normalize_widgets(screen, other), do: {:error, Error.invalid_view(screen, other)}

  defp normalize_frontend_boot(_screen, boot) when is_map(boot), do: {:ok, Map.new(boot)}
  defp normalize_frontend_boot(_screen, boot) when is_list(boot), do: {:ok, Enum.into(boot, %{})}

  defp normalize_frontend_boot(screen, other),
    do: {:error, Error.invalid_frontend_boot(screen, other)}
end
