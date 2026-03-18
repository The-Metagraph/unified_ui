defmodule WebUi.Widgets.Feedback do
  @moduledoc """
  Advanced feedback widgets for status-heavy and progress-heavy `web_ui`
  workflows.
  """

  alias WebUi.Widgets.Builder

  @kinds [:status, :progress, :inline_feedback]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec status(String.t(), keyword() | map()) :: WebUi.Widget.t()
  def status(text, opts \\ []) when is_binary(text) do
    opts = Builder.options(opts)

    Builder.widget(:status,
      id: Builder.require_id!(opts, :status),
      props: %{
        text: text,
        severity: Builder.option(opts, :severity, :info),
        status: Builder.option(opts, :status, :idle),
        icon: Builder.option(opts, :icon)
      },
      state: Builder.state(opts, [:disabled?, :loading?]),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :feedback})
    )
  end

  @spec progress(keyword() | map()) :: WebUi.Widget.t()
  def progress(opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:progress,
      id: Builder.require_id!(opts, :progress),
      props: %{
        current: Builder.option(opts, :current),
        total: Builder.option(opts, :total),
        indeterminate?: Builder.option(opts, :indeterminate?, false),
        label: Builder.option(opts, :label),
        severity: Builder.option(opts, :severity),
        status: Builder.option(opts, :status)
      },
      state: Builder.state(opts, [:disabled?, :loading?]),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :feedback})
    )
  end

  @spec inline_feedback(String.t(), keyword() | map()) :: WebUi.Widget.t()
  def inline_feedback(message, opts \\ []) when is_binary(message) do
    opts = Builder.options(opts)

    Builder.widget(:inline_feedback,
      id: Builder.require_id!(opts, :inline_feedback),
      props: %{
        title: Builder.option(opts, :title),
        message: message,
        severity: Builder.option(opts, :severity, :info),
        status: Builder.option(opts, :status)
      },
      state: Builder.state(opts, [:disabled?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, close: :close),
      metadata: Builder.metadata(opts, %{native_surface: :feedback})
    )
  end
end
