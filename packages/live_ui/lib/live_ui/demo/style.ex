defmodule LiveUi.Demo.Style do
  @moduledoc """
  Shared style helpers for the package-local `live_ui` demo.
  """

  @theme LiveUi.Theme.default()

  @spec shell() :: map()
  def shell do
    LiveUi.Style.component_assigns(:screen_shell,
      theme: @theme,
      variant: :workspace,
      class: "live-ui-demo-shell"
    )
  end

  @spec panel(String.t() | nil) :: map()
  def panel(class \\ nil) do
    LiveUi.Style.component_assigns(:box,
      theme: @theme,
      variant: :panel,
      class: merge_classes(["live-ui-demo-panel", class])
    )
  end

  @spec text(String.t() | nil, keyword()) :: map()
  def text(class \\ nil, opts \\ []) do
    LiveUi.Style.component_assigns(:text,
      theme: @theme,
      tone: Keyword.get(opts, :tone),
      class: merge_classes(["live-ui-demo-text", class])
    )
  end

  @spec button(String.t() | nil, keyword()) :: map()
  def button(class \\ nil, opts \\ []) do
    LiveUi.Style.component_assigns(:button,
      theme: @theme,
      variant: Keyword.get(opts, :variant, :solid),
      state: Keyword.get(opts, :state),
      class: merge_classes(["live-ui-demo-button", class])
    )
  end

  @spec layout(atom(), String.t() | nil) :: map()
  def layout(component, class \\ nil) do
    LiveUi.Style.component_assigns(component,
      theme: @theme,
      class: merge_classes(["live-ui-demo-#{component}", class])
    )
  end

  defp merge_classes(classes) do
    classes
    |> List.flatten()
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(" ")
    |> case do
      "" -> nil
      value -> value
    end
  end
end

