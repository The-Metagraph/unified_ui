defmodule TerminalUi.Widgets.Input do
  @moduledoc """
  Foundational form controls for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [
      :text_input,
      :numeric_input,
      :checkbox,
      :radio_group,
      :select,
      :pick_list,
      :slider,
      :date_input,
      :time_input,
      :file_input
    ]
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

  @spec numeric_input(String.t() | atom(), keyword()) :: Widget.t()
  def numeric_input(id, opts \\ []) do
    Widget.new(:numeric_input,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :numeric_input], opts)
        ),
      state: Builder.state(opts, %{disabled: false, value: Keyword.get(opts, :value)}),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        value: Keyword.get(opts, :value),
        placeholder: Keyword.get(opts, :placeholder, ""),
        min: Keyword.get(opts, :min),
        max: Keyword.get(opts, :max),
        step: Keyword.get(opts, :step, 1)
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

  @spec pick_list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def pick_list(id, options, opts \\ []) do
    Widget.new(:pick_list,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :pick_list], opts)
        ),
      state: Builder.state(opts, %{selected: Keyword.get(opts, :selected)}),
      bindings: Builder.bindings(opts, %{selected: Keyword.get(opts, :binding)}),
      attributes: %{
        options: Builder.normalize_items(options),
        multiple: Keyword.get(opts, :multiple, true),
        prompt: Keyword.get(opts, :prompt, "Choose one or more")
      },
      events: Builder.events(change: opts[:on_change], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec slider(String.t() | atom(), keyword()) :: Widget.t()
  def slider(id, opts \\ []) do
    Widget.new(:slider,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :slider], opts)
        ),
      state: Builder.state(opts, %{value: Keyword.get(opts, :value, 0)}),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        value: Keyword.get(opts, :value, 0),
        min: Keyword.get(opts, :min, 0),
        max: Keyword.get(opts, :max, 100),
        step: Keyword.get(opts, :step, 1)
      },
      events: Builder.events(change: opts[:on_change], focus: opts[:on_focus]),
      styles: Builder.styles(opts)
    )
  end

  @spec date_input(String.t() | atom(), keyword()) :: Widget.t()
  def date_input(id, opts \\ []) do
    Widget.new(:date_input,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :date_input], opts)
        ),
      state: Builder.state(opts, %{disabled: false, value: Keyword.get(opts, :value)}),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        value: Keyword.get(opts, :value),
        min: Keyword.get(opts, :min),
        max: Keyword.get(opts, :max),
        format: Keyword.get(opts, :format, :iso8601)
      },
      events: Builder.events(change: opts[:on_change], submit: opts[:on_submit]),
      styles: Builder.styles(opts)
    )
  end

  @spec time_input(String.t() | atom(), keyword()) :: Widget.t()
  def time_input(id, opts \\ []) do
    Widget.new(:time_input,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :time_input], opts)
        ),
      state: Builder.state(opts, %{disabled: false, value: Keyword.get(opts, :value)}),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        value: Keyword.get(opts, :value),
        min: Keyword.get(opts, :min),
        max: Keyword.get(opts, :max),
        step: Keyword.get(opts, :step),
        format: Keyword.get(opts, :format, :iso8601)
      },
      events: Builder.events(change: opts[:on_change], submit: opts[:on_submit]),
      styles: Builder.styles(opts)
    )
  end

  @spec file_input(String.t() | atom(), keyword()) :: Widget.t()
  def file_input(id, opts \\ []) do
    Widget.new(:file_input,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :file_input], opts)
        ),
      state: Builder.state(opts, %{disabled: false, value: Keyword.get(opts, :value)}),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        accept: List.wrap(Keyword.get(opts, :accept, [])),
        multiple: Keyword.get(opts, :multiple, false),
        capture: Keyword.get(opts, :capture)
      },
      events: Builder.events(change: opts[:on_change], focus: opts[:on_focus]),
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
