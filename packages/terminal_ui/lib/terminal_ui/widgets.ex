defmodule TerminalUi.Widgets do
  @moduledoc """
  Native widget namespace for the `terminal_ui` Phase 1 scaffold.
  """

  @type family :: :content | :layout | :input | :navigation | :feedback

  @spec families() :: [family()]
  def families do
    [:content, :layout, :input, :navigation, :feedback]
  end

  @spec modules() :: [module()]
  def modules do
    [__MODULE__, TerminalUi.Widget]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [:text, :label, :button, :container, :column, :text_input, :menu, :dialog]
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_contract: :ready,
      registration_surface: :ready,
      direct_native_scaffold: :ready
    }
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: TerminalUi.Widget.t()
  def text(id, content, opts \\ []) do
    opts = Keyword.merge(opts, id: id, family: :content, kind: :text)

    TerminalUi.Widget.new(:text,
      id: id,
      family: :content,
      metadata: %{label: to_string(id), native_surface: true},
      attributes: %{content: content},
      styles: style_from_opts(opts)
    )
  end

  @spec label(String.t() | atom(), String.t(), keyword()) :: TerminalUi.Widget.t()
  def label(id, content, opts \\ []) do
    TerminalUi.Widget.new(:label,
      id: id,
      family: :content,
      metadata: %{label: to_string(id), role: :label, native_surface: true},
      attributes: %{content: content},
      styles: style_from_opts(opts)
    )
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: TerminalUi.Widget.t()
  def button(id, label, opts \\ []) do
    TerminalUi.Widget.new(:button,
      id: id,
      family: :content,
      metadata: %{label: label, role: :button, native_surface: true},
      state: %{disabled: Keyword.get(opts, :disabled, false)},
      attributes: %{label: label},
      events: normalize_event(opts[:on_press], :keypress),
      styles: style_from_opts(opts)
    )
  end

  @spec text_input(String.t() | atom(), keyword()) :: TerminalUi.Widget.t()
  def text_input(id, opts \\ []) do
    TerminalUi.Widget.new(:text_input,
      id: id,
      family: :input,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{
        value: Keyword.get(opts, :value, ""),
        placeholder: Keyword.get(opts, :placeholder, "")
      },
      events: normalize_event(opts[:on_change], :keypress),
      styles: style_from_opts(opts)
    )
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: TerminalUi.Widget.t()
  def menu(id, items, opts \\ []) do
    TerminalUi.Widget.new(:menu,
      id: id,
      family: :navigation,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{items: Enum.map(items, &Enum.into(&1, %{}))},
      events: normalize_event(opts[:on_navigate], :navigation),
      styles: style_from_opts(opts)
    )
  end

  @spec container(String.t() | atom(), [TerminalUi.Widget.t()], keyword()) ::
          TerminalUi.Widget.t()
  def container(id, children, opts \\ []) do
    TerminalUi.Widget.new(:container,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      slot_children: %{default: children},
      styles: style_from_opts(opts)
    )
  end

  @spec column(String.t() | atom(), [TerminalUi.Widget.t()], keyword()) :: TerminalUi.Widget.t()
  def column(id, children, opts \\ []) do
    TerminalUi.Widget.new(:column,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{gap: Keyword.get(opts, :gap, :sm)},
      slot_children: %{default: children},
      styles: style_from_opts(opts)
    )
  end

  @spec dialog(String.t() | atom(), [TerminalUi.Widget.t()], keyword()) :: TerminalUi.Widget.t()
  def dialog(id, children, opts \\ []) do
    TerminalUi.Widget.new(:dialog,
      id: id,
      family: :feedback,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      state: %{open: Keyword.get(opts, :open, true)},
      slot_children: %{content: children},
      events: normalize_event(opts[:on_dismiss], :dismiss),
      styles: style_from_opts(opts)
    )
  end

  defp normalize_event(nil, _key), do: %{}
  defp normalize_event(value, key), do: %{key => Enum.into(value, %{})}

  defp style_from_opts(opts) do
    %{}
    |> maybe_put(:fg, Keyword.get(opts, :fg))
    |> maybe_put(:bg, Keyword.get(opts, :bg))
    |> maybe_put(:attrs, Keyword.get(opts, :attrs))
    |> maybe_put(:semantic_role, Keyword.get(opts, :semantic_role))
    |> maybe_put(:degradation, Keyword.get(opts, :degradation))
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
