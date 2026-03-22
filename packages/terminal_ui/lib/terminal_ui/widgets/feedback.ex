defmodule TerminalUi.Widgets.Feedback do
  @moduledoc """
  Advanced overlay and feedback widgets for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:dialog, :toast, :alert_dialog, :progress, :status]
  end

  @spec dialog(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def dialog(id, children, opts \\ []) do
    Widget.new(:dialog,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.merge([role: :dialog], opts), %{
          overlay_role: :dialog,
          capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal)
        }),
      state:
        Builder.state(opts, %{
          open: Keyword.get(opts, :open, true),
          phase: Keyword.get(opts, :phase, :active)
        }),
      slot_children: %{content: children},
      events: Builder.events(dismiss: opts[:on_dismiss], close: opts[:on_close]),
      styles: Builder.styles(opts)
    )
  end

  @spec toast(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toast(id, message, opts \\ []) do
    Widget.new(:toast,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :toast), %{
          overlay_role: :toast,
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :inline_feedback)
        }),
      state:
        Builder.state(opts, %{
          open: Keyword.get(opts, :open, true),
          severity: Keyword.get(opts, :severity, :info)
        }),
      attributes: %{message: message, timeout_ms: Keyword.get(opts, :timeout_ms, 3_000)},
      events: Builder.events(close: opts[:on_close]),
      styles: Builder.styles(opts)
    )
  end

  @spec alert_dialog(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def alert_dialog(id, message, children, opts \\ []) do
    Widget.new(:alert_dialog,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :alert_dialog), %{
          overlay_role: :alert_dialog,
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :modal_prompt)
        }),
      state:
        Builder.state(opts, %{
          open: Keyword.get(opts, :open, true),
          severity: Keyword.get(opts, :severity, :warning)
        }),
      attributes: %{message: message},
      slot_children: %{content: children},
      events: Builder.events(close: opts[:on_close], dismiss: opts[:on_dismiss]),
      styles: Builder.styles(opts)
    )
  end

  @spec progress(String.t() | atom(), keyword()) :: Widget.t()
  def progress(id, opts \\ []) do
    Widget.new(:progress,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :progress)),
      state:
        Builder.state(opts, %{
          progress: Keyword.get(opts, :current),
          loading: Keyword.get(opts, :loading, false),
          severity: Keyword.get(opts, :severity)
        }),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        current: Keyword.get(opts, :current),
        total: Keyword.get(opts, :total),
        indeterminate: Keyword.get(opts, :indeterminate, false),
        label: Keyword.get(opts, :label)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec status(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def status(id, text, opts \\ []) do
    Widget.new(:status,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :status)),
      state:
        Builder.state(opts, %{
          severity: Keyword.get(opts, :severity, :info),
          active: Keyword.get(opts, :active, true)
        }),
      attributes: %{
        text: text,
        icon: Keyword.get(opts, :icon),
        status: Keyword.get(opts, :status, :idle)
      },
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
