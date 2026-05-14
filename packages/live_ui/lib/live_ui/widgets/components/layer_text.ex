defmodule LiveUi.Widgets.Components.StickyFrostedHeader do
  @moduledoc """
  Native sticky header component with token-addressable frosted styling.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :sticky_frosted_header,
    slots: [:inner_block],
    assigns: [:title, :leading, :trailing]

  LiveUi.Component.common_attrs()
  attr(:title, :string, default: nil)
  attr(:leading, :list, default: [])
  attr(:trailing, :list, default: [])
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :sticky_frosted_header, :layer_callout, %{
          "data-live-ui-position" => "sticky",
          "data-live-ui-visual-effect" => "frosted"
        })
      )

    ~H"""
    <header id={@id} class={@class} {@component_attrs}>
      <nav :if={@leading != []} data-live-ui-header-slot="leading">
        <span :for={item <- @leading}><%= item %></span>
      </nav>
      <h2 :if={@title}><%= @title %></h2>
      <div data-live-ui-header-slot="content"><%= render_slot(@inner_block) %></div>
      <nav :if={@trailing != []} data-live-ui-header-slot="trailing">
        <span :for={item <- @trailing}><%= item %></span>
      </nav>
    </header>
    """
  end
end

defmodule LiveUi.Widgets.Components.SlideOverPanel do
  @moduledoc """
  Native non-modal slide-over panel.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :slide_over_panel,
    slots: [:inner_block],
    assigns: [:open, :size, :label],
    events: [:panel],
    local_state_keys: [:open]

  LiveUi.Component.common_attrs()
  attr(:open, :boolean, default: false)
  attr(:size, :string, default: "medium")
  attr(:label, :string, default: nil)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :slide_over_panel, :layer_callout, %{
          "data-live-ui-open" => assigns.open,
          "data-live-ui-panel-size" => assigns.size
        })
      )

    ~H"""
    <aside id={@id} aria-label={@label} aria-hidden={!@open} class={@class} {@component_attrs}>
      <%= render_slot(@inner_block) %>
    </aside>
    """
  end
end

defmodule LiveUi.Widgets.Components.EventCallout do
  @moduledoc """
  Native event callout component for workflow annotations.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :event_callout,
    slots: [:inner_block, :actions],
    assigns: [:message, :eyebrow, :title, :callout_tone],
    events: [:inline_action]

  LiveUi.Component.common_attrs()
  attr(:message, :string, required: true)
  attr(:eyebrow, :string, default: nil)
  attr(:title, :string, default: nil)
  attr(:callout_tone, :string, default: "info")
  slot(:inner_block)
  slot(:actions)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :event_callout, :layer_callout, %{
          "data-live-ui-callout-tone" => assigns.callout_tone
        })
      )

    ~H"""
    <aside id={@id} class={@class} {@component_attrs}>
      <p :if={@eyebrow} data-live-ui-callout-eyebrow=""><%= @eyebrow %></p>
      <h3 :if={@title}><%= @title %></h3>
      <p><%= @message %></p>
      <div data-live-ui-callout-body=""><%= render_slot(@inner_block) %></div>
      <footer :if={@actions != []}><%= render_slot(@actions) %></footer>
    </aside>
    """
  end
end

defmodule LiveUi.Widgets.Components.RedlineInline do
  @moduledoc """
  Native inline redline renderer for plain text review segments.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :redline_inline,
    assigns: [:segments]

  LiveUi.Component.common_attrs()
  attr(:segments, :list, default: [])

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :redline_inline, :redline_code)
      )

    ~H"""
    <span id={@id} class={@class} {@component_attrs}>
      <span
        :for={segment <- @segments}
        data-live-ui-redline-state={Support.atom_name(Support.fetch(segment, :state, :unchanged))}
      ><%= Support.text(Support.fetch(segment, :text)) %></span>
    </span>
    """
  end
end

defmodule LiveUi.Widgets.Components.CodeBlockSyntaxHighlighted do
  @moduledoc """
  Native pre-tokenized code block renderer for plain text code tokens.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :code_block_syntax_highlighted,
    assigns: [:language, :tokens]

  LiveUi.Component.common_attrs()
  attr(:language, :string, default: "text")
  attr(:tokens, :list, default: [])

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :code_block_syntax_highlighted, :redline_code, %{
          "data-live-ui-code-language" => assigns.language
        })
      )

    ~H"""
    <pre id={@id} class={@class} {@component_attrs}><code><span
        :for={token <- @tokens}
        data-live-ui-code-token={Support.atom_name(Support.fetch(token, :type, :text))}
      ><%= Support.text(Support.fetch(token, :text)) %></span></code></pre>
    """
  end
end

defmodule LiveUi.Widgets.Components.ListRepeat do
  @moduledoc """
  Native wrapper for already-hydrated list-repeat child output.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :list_repeat,
    slots: [:inner_block],
    assigns: [:repeat]

  LiveUi.Component.common_attrs()
  attr(:repeat, :map, default: %{})
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :list_repeat, :composition_behavior, %{
          "data-live-ui-repeat-binding" => Support.fetch(assigns.repeat, :binding_id),
          "data-live-ui-repeat-row-count" => Support.fetch(assigns.repeat, :row_count, 0)
        })
      )

    ~H"""
    <div id={@id} class={@class} {@component_attrs}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
