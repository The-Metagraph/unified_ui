defmodule DesktopUi.Widgets.Builder do
  @moduledoc """
  Builder helpers for direct-native `desktop_ui` widgets.
  """

  alias DesktopUi.Widget

  @spec window(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def window(id, title, children \\ [], opts \\ []) do
    Widget.new(:window,
      id: id,
      metadata: %{focusable: true, window_role: Keyword.get(opts, :window_role, :primary)},
      attributes: %{window_title: title},
      styles: Map.new(Keyword.get(opts, :styles, [])),
      children: children
    )
  end

  @spec dialog(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def dialog(id, title, children \\ [], opts \\ []) do
    Widget.new(:dialog,
      id: id,
      metadata: %{focusable: true, window_role: :dialog},
      attributes: %{window_title: title},
      styles: Map.new(Keyword.get(opts, :styles, [])),
      children: children
    )
  end

  @spec column(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def column(id, children \\ [], opts \\ []) do
    Widget.new(:column,
      id: id,
      metadata: %{focusable: false},
      attributes: %{gap: Keyword.get(opts, :gap, 16)},
      styles: Map.new(Keyword.get(opts, :styles, [])),
      children: children
    )
  end

  @spec row(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def row(id, children \\ [], opts \\ []) do
    Widget.new(:row,
      id: id,
      metadata: %{focusable: false},
      attributes: %{gap: Keyword.get(opts, :gap, 12)},
      styles: Map.new(Keyword.get(opts, :styles, [])),
      children: children
    )
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Widget.new(:text,
      id: id,
      metadata: %{focusable: false},
      attributes: %{content: content},
      styles: Map.new(Keyword.get(opts, :styles, []))
    )
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Widget.new(:button,
      id: id,
      metadata: %{focusable: true},
      attributes: %{label: label},
      styles: Map.new(Keyword.get(opts, :styles, [])),
      events: %{click: %{intent: Keyword.get(opts, :intent, :activate)}}
    )
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Widget.new(:text_input,
      id: id,
      metadata: %{focusable: true},
      state: %{value: Keyword.get(opts, :value, "")},
      bindings: %{value: Keyword.get(opts, :binding, :value)},
      attributes: %{placeholder: Keyword.get(opts, :placeholder, "")},
      styles: Map.new(Keyword.get(opts, :styles, []))
    )
  end

  @spec menu(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Widget.new(:menu,
      id: id,
      metadata: %{focusable: true},
      attributes: %{items: Enum.map(items, &Map.new/1)},
      styles: Map.new(Keyword.get(opts, :styles, []))
    )
  end

  @spec status(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def status(id, label, opts \\ []) do
    Widget.new(:status,
      id: id,
      metadata: %{focusable: false},
      attributes: %{label: label},
      styles: Map.new(Keyword.get(opts, :styles, []))
    )
  end
end
