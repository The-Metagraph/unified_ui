defmodule WebUi.Widgets do
  @moduledoc """
  Minimal directly usable native widget surface for `web_ui`.
  """

  alias WebUi.Widget

  @type family :: Widget.family()

  @spec families() :: [family()]
  def families do
    [:content, :layout, :interaction]
  end

  @spec modules() :: [module()]
  def modules do
    [WebUi.Widget]
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Widget.new(:text,
      id: id,
      metadata: %{label: "text"},
      attributes: %{content: content},
      styles: Keyword.get(opts, :styles, %{})
    )
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Widget.new(:button,
      id: id,
      metadata: %{label: label, role: :action},
      state: %{disabled: Keyword.get(opts, :disabled, false)},
      attributes: %{label: label},
      styles: Keyword.get(opts, :styles, %{}),
      events: build_events(opts)
    )
  end

  @spec stack(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def stack(id, children, opts \\ []) do
    Widget.new(:stack,
      id: id,
      metadata: %{label: "stack"},
      slots: [:default],
      attributes: %{direction: Keyword.get(opts, :direction, :column)},
      styles: Keyword.get(opts, :styles, %{}),
      children: children
    )
  end

  @spec panel(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def panel(id, title, children, opts \\ []) do
    Widget.new(:panel,
      id: id,
      metadata: %{label: title, role: :panel},
      slots: [:header, :body],
      attributes: %{title: title},
      styles: Keyword.get(opts, :styles, %{}),
      children: children
    )
  end

  @spec screen(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: map()
  def screen(id, title, children, opts \\ []) do
    %{
      id: id,
      title: title,
      root:
        stack("#{id}-root", children, direction: :column, styles: Keyword.get(opts, :styles, %{})),
      metadata: %{
        bridge: Keyword.get(opts, :bridge, :phoenix_elm),
        source: Keyword.get(opts, :source, :native)
      }
    }
  end

  defp build_events(opts) do
    opts
    |> Keyword.take([:on_click, :on_submit, :on_change, :on_navigate])
    |> Enum.map(fn {key, value} ->
      event_name =
        case key do
          :on_click -> :click
          :on_submit -> :submit
          :on_change -> :change
          :on_navigate -> :navigation
        end

      {event_name, Map.new(value)}
    end)
    |> Map.new()
  end
end
