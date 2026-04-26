defmodule TerminalUi.Widgets.Foundational do
  @moduledoc """
  Foundational content and action widgets for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder
  alias TerminalUi.Widgets.Navigation, as: NavigationWidget

  @spec kinds() :: [atom()]
  def kinds do
    [:text, :label, :icon, :image, :spacer, :separator, :button, :toggle, :link, :command]
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Widget.new(:text,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :text)),
      attributes: %{content: content},
      styles: Builder.styles(opts)
    )
  end

  @spec label(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def label(id, content, opts \\ []) do
    Widget.new(:label,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.put(opts, :role, Keyword.get(opts, :role, :label))
        ),
      attributes: %{content: content},
      styles: Builder.styles(opts)
    )
  end

  @spec icon(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def icon(id, name, opts \\ []) do
    Widget.new(:icon,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :icon), %{
          degradation: Keyword.get(opts, :degradation, :ascii_fallback)
        }),
      attributes: %{
        name: to_string(name),
        fallback_text: Keyword.get(opts, :fallback_text, to_string(name))
      },
      styles: Builder.styles(opts)
    )
  end

  @spec image(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def image(id, src, opts \\ []) do
    Widget.new(:image,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :image), %{
          degradation: Keyword.get(opts, :degradation, :placeholder)
        }),
      attributes: %{
        src: src,
        alt: Keyword.get(opts, :alt, keyword_label(id, opts)),
        fallback_text: Keyword.get(opts, :fallback_text, "[image]")
      },
      styles: Builder.styles(opts)
    )
  end

  @spec spacer(String.t() | atom(), keyword()) :: Widget.t()
  def spacer(id, opts \\ []) do
    Widget.new(:spacer,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :spacer)),
      attributes: %{size: Keyword.get(opts, :size, :sm)},
      styles: Builder.styles(opts)
    )
  end

  @spec separator(String.t() | atom(), keyword()) :: Widget.t()
  def separator(id, opts \\ []) do
    Widget.new(:separator,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :separator)),
      attributes: %{orientation: Keyword.get(opts, :orientation, :horizontal)},
      styles: Builder.styles(opts)
    )
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    keypress_event = NavigationWidget.event_payload(opts) || opts[:on_press]
    command_event = if(is_nil(NavigationWidget.event_payload(opts)), do: opts[:on_command], else: nil)

    Widget.new(:button,
      id: id,
      metadata: Builder.metadata(label, Keyword.merge([focusable: true, role: :button], opts)),
      state: Builder.state(opts, %{disabled: false}),
      attributes: %{label: label},
      events: Builder.events(keypress: keypress_event, command: command_event),
      styles: Builder.styles(opts)
    )
  end

  @spec toggle(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toggle(id, label, opts \\ []) do
    Widget.new(:toggle,
      id: id,
      metadata: Builder.metadata(label, Keyword.merge([focusable: true, role: :toggle], opts)),
      state: Builder.state(opts, %{checked: Keyword.get(opts, :checked, false)}),
      bindings: Builder.bindings(opts, %{checked: Keyword.get(opts, :binding)}),
      attributes: %{label: label},
      events: Builder.events(toggle: opts[:on_toggle], change: opts[:on_change]),
      styles: Builder.styles(opts)
    )
  end

  @spec link(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def link(id, label, target, opts \\ []) do
    activate_event = NavigationWidget.event_payload(opts) || opts[:on_follow]

    Widget.new(:link,
      id: id,
      metadata: Builder.metadata(label, Keyword.merge([focusable: true, role: :link], opts)),
      state: Builder.state(opts, %{disabled: false}),
      attributes: %{label: label, target: target},
      events: Builder.events(activate: activate_event),
      styles: Builder.styles(opts)
    )
  end

  @spec command(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def command(id, label, opts \\ []) do
    command_name = Keyword.get(opts, :command, id)
    command_event =
      NavigationWidget.event_payload(opts) ||
        opts[:on_command] ||
        %{command: command_name, source: :terminal_ui}

    Widget.new(:command,
      id: id,
      metadata:
        Builder.metadata(
          label,
          Keyword.merge([focusable: true, role: :command, command: command_name], opts)
        ),
      state: Builder.state(opts, %{disabled: false}),
      attributes: %{label: label, command: command_name},
      events: Builder.events(command: command_event),
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
