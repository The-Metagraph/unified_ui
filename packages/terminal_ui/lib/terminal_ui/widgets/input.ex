defmodule TerminalUi.Widgets.Input do
  @moduledoc """
  Foundational form controls for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:text_input, :checkbox, :radio_group, :select]
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Widget.new(:text_input,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :text_input], opts)
        ),
      state: Builder.state(opts, %{disabled: false, value: Keyword.get(opts, :value, "")}),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        value: Keyword.get(opts, :value, ""),
        placeholder: Keyword.get(opts, :placeholder, ""),
        submit_key: Keyword.get(opts, :submit_key, :enter)
      },
      events: Builder.events(change: opts[:on_change], submit: opts[:on_submit]),
      styles: Builder.styles(opts)
    )
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Widget.new(:checkbox,
      id: id,
      metadata: Builder.metadata(label, Keyword.merge([focusable: true, role: :checkbox], opts)),
      state: Builder.state(opts, %{checked: Keyword.get(opts, :checked, false)}),
      bindings: Builder.bindings(opts, %{checked: Keyword.get(opts, :binding)}),
      attributes: %{label: label},
      events: Builder.events(toggle: opts[:on_toggle], change: opts[:on_change]),
      styles: Builder.styles(opts)
    )
  end

  @spec radio_group(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def radio_group(id, options, opts \\ []) do
    Widget.new(:radio_group,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :radio_group], opts)
        ),
      state: Builder.state(opts, %{selected: Keyword.get(opts, :selected)}),
      bindings: Builder.bindings(opts, %{selected: Keyword.get(opts, :binding)}),
      attributes: %{options: Builder.normalize_items(options)},
      events: Builder.events(change: opts[:on_change], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec select(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Widget.new(:select,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :select], opts)
        ),
      state: Builder.state(opts, %{selected: Keyword.get(opts, :selected)}),
      bindings: Builder.bindings(opts, %{selected: Keyword.get(opts, :binding)}),
      attributes: %{
        options: Builder.normalize_items(options),
        prompt: Keyword.get(opts, :prompt, "Choose an option")
      },
      events: Builder.events(change: opts[:on_change], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
