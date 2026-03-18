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
         :ok <- validate_runtime_widget_list(screen, widgets),
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

  defp validate_runtime_widget_list(screen, widgets) do
    Enum.reduce_while(widgets, :ok, fn widget, :ok ->
      case validate_runtime_widget(screen, widget) do
        :ok -> {:cont, :ok}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp validate_runtime_widget(screen, %Widget{} = widget) do
    with :ok <- validate_widget_shape(screen, widget),
         :ok <- validate_widget_children(screen, widget) do
      widget.slots
      |> Map.values()
      |> List.flatten()
      |> validate_nested_widgets(screen)
    end
  end

  defp validate_nested_widgets(widgets, screen) when is_list(widgets) do
    Enum.reduce_while(widgets, :ok, fn widget, :ok ->
      case validate_runtime_widget(screen, widget) do
        :ok -> {:cont, :ok}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp validate_widget_shape(screen, %Widget{kind: :viewport, id: id, slots: slots, props: props}) do
    cond do
      Map.get(slots, :content, []) == [] ->
        {:error,
         Error.invalid_display_configuration(screen, :viewport_requires_content, %{id: id})}

      not valid_offset?(Map.get(props, :offset)) ->
        {:error,
         Error.invalid_display_configuration(screen, :viewport_invalid_offset, %{
           id: id,
           offset: inspect(Map.get(props, :offset))
         })}

      true ->
        :ok
    end
  end

  defp validate_widget_shape(screen, %Widget{kind: :scroll_bar, id: id, props: props}) do
    cond do
      is_nil(Map.get(props, :viewport_ref)) and not is_nil(Map.get(props, :sync_group)) ->
        {:error,
         Error.invalid_display_configuration(screen, :scroll_bar_requires_viewport_ref, %{id: id})}

      true ->
        :ok
    end
  end

  defp validate_widget_shape(
         screen,
         %Widget{kind: :split_pane, id: id, slots: slots, props: props}
       ) do
    ratio = Map.get(props, :ratio)

    cond do
      Map.get(slots, :primary, []) == [] or Map.get(slots, :secondary, []) == [] ->
        {:error,
         Error.invalid_display_configuration(screen, :split_pane_requires_two_panes, %{id: id})}

      not is_number(ratio) or ratio <= 0 or ratio >= 1 ->
        {:error,
         Error.invalid_display_configuration(screen, :split_pane_invalid_ratio, %{
           id: id,
           ratio: inspect(ratio)
         })}

      true ->
        :ok
    end
  end

  defp validate_widget_shape(screen, %Widget{kind: :overlay, id: id, slots: slots}) do
    cond do
      Map.get(slots, :base, []) == [] ->
        {:error, Error.invalid_display_configuration(screen, :overlay_requires_base, %{id: id})}

      Map.get(slots, :layers, []) == [] ->
        {:error, Error.invalid_display_configuration(screen, :overlay_requires_layers, %{id: id})}

      Enum.any?(Map.get(slots, :layers, []), &(&1.kind == :overlay)) ->
        {:error,
         Error.invalid_display_configuration(screen, :overlay_does_not_allow_nested_overlay, %{
           id: id
         })}

      true ->
        :ok
    end
  end

  defp validate_widget_shape(screen, %Widget{kind: kind, id: id, slots: slots})
       when kind in [:dialog, :toast, :alert_dialog] do
    if Map.get(slots, :content, []) == [] do
      {:error,
       Error.invalid_display_configuration(screen, :layer_requires_content, %{id: id, kind: kind})}
    else
      :ok
    end
  end

  defp validate_widget_shape(screen, %Widget{kind: :context_menu, id: id, slots: slots}) do
    if Map.get(slots, :menu, []) == [] do
      {:error,
       Error.invalid_display_configuration(screen, :context_menu_requires_menu, %{id: id})}
    else
      :ok
    end
  end

  defp validate_widget_shape(_screen, _widget), do: :ok

  defp validate_widget_children(_screen, %Widget{}), do: :ok

  defp valid_offset?(%{x: x, y: y}) when is_integer(x) and is_integer(y), do: true
  defp valid_offset?(_other), do: false
end
