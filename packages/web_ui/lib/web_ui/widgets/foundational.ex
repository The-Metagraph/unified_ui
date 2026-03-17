defmodule WebUi.Widgets.Foundational do
  @moduledoc """
  Direct-use foundational widgets for baseline `web_ui` screens.
  """

  alias WebUi.Widgets.Builder

  @kinds [:text, :label, :icon, :image, :button, :link, :separator, :spacer, :content]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec text(String.t(), keyword() | map()) :: WebUi.Widget.t()
  def text(content, opts \\ []) when is_binary(content) do
    opts = Builder.options(opts)

    Builder.widget(:text,
      id: Builder.require_id!(opts, :text),
      props: %{
        content: content,
        presentation: Builder.option(opts, :presentation, :inline)
      },
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational})
    )
  end

  @spec label(String.t(), keyword() | map()) :: WebUi.Widget.t()
  def label(content, opts \\ []) when is_binary(content) do
    opts = Builder.options(opts)

    Builder.widget(:label,
      id: Builder.require_id!(opts, :label),
      props: %{
        content: content,
        for: Builder.option(opts, :for),
        relationship: Builder.option(opts, :relationship, :label)
      },
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational})
    )
  end

  @spec icon(atom() | String.t(), keyword() | map()) :: WebUi.Widget.t()
  def icon(name, opts \\ []) when is_atom(name) or is_binary(name) do
    opts = Builder.options(opts)

    Builder.widget(:icon,
      id: Builder.require_id!(opts, :icon),
      props: %{
        name: name,
        set: Builder.option(opts, :set),
        fallback_text: Builder.option(opts, :fallback_text)
      },
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational})
    )
  end

  @spec image(String.t(), keyword() | map()) :: WebUi.Widget.t()
  def image(src, opts \\ []) when is_binary(src) do
    opts = Builder.options(opts)

    Builder.widget(:image,
      id: Builder.require_id!(opts, :image),
      props: %{
        src: src,
        alt: Builder.option(opts, :alt, ""),
        fit: Builder.option(opts, :fit, :cover)
      },
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational})
    )
  end

  @spec button(String.t(), keyword() | map()) :: WebUi.Widget.t()
  def button(label, opts \\ []) when is_binary(label) do
    opts = Builder.options(opts)

    Builder.widget(:button,
      id: Builder.require_id!(opts, :button),
      props: %{
        label: label,
        variant: Builder.option(opts, :variant, :primary)
      },
      state: Builder.state(opts, [:disabled?, :active?, :pressed?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, click: :click),
      metadata: Builder.metadata(opts, %{native_surface: :foundational, action?: true})
    )
  end

  @spec link(String.t(), String.t(), keyword() | map()) :: WebUi.Widget.t()
  def link(label, href, opts \\ []) when is_binary(label) and is_binary(href) do
    opts = Builder.options(opts)

    Builder.widget(:link,
      id: Builder.require_id!(opts, :link),
      props: %{
        label: label,
        href: href,
        external?: Builder.option(opts, :external?, false)
      },
      state: Builder.state(opts, [:disabled?, :current?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, click: :click),
      metadata: Builder.metadata(opts, %{native_surface: :foundational, navigation?: true})
    )
  end

  @spec separator(keyword() | map()) :: WebUi.Widget.t()
  def separator(opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:separator,
      id: Builder.require_id!(opts, :separator),
      props: %{
        orientation: Builder.option(opts, :orientation, :horizontal),
        decorative?: Builder.option(opts, :decorative?, true)
      },
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational})
    )
  end

  @spec spacer(keyword() | map()) :: WebUi.Widget.t()
  def spacer(opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:spacer,
      id: Builder.require_id!(opts, :spacer),
      props: %{
        size: Builder.option(opts, :size, :md),
        grow: Builder.option(opts, :grow, 0),
        min: Builder.option(opts, :min),
        max: Builder.option(opts, :max)
      },
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational})
    )
  end

  @spec content([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def content(children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:content,
      id: Builder.require_id!(opts, :content),
      props: %{
        role: Builder.option(opts, :role, :content),
        presentation: Builder.option(opts, :presentation, :body)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :foundational, container?: true})
    )
  end
end
