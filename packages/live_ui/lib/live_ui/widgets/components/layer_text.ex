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
    <aside
      id={@id}
      aria-label={@label}
      aria-hidden={if @open, do: "false", else: "true"}
      class={@class}
      {@component_attrs}
    >
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
    assigns: [:message, :eyebrow, :title, :callout_tone, :action_label, :action_attrs],
    events: [:inline_action]

  LiveUi.Component.common_attrs()
  attr(:message, :string, required: true)
  attr(:eyebrow, :string, default: nil)
  attr(:title, :string, default: nil)
  attr(:callout_tone, :string, default: "info")
  attr(:action_label, :string, default: nil)
  attr(:action_attrs, :map, default: %{})
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
      <button :if={@action_label} type="button" {@action_attrs}><%= @action_label %></button>
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

defmodule LiveUi.Widgets.Components.TopStrip do
  @moduledoc """
  Native top shell strip with brand identity, context, theme controls, and mode navigation.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :top_strip,
    slots: [:inner_block],
    assigns: [:brand, :context, :theme, :pane_open]

  LiveUi.Component.common_attrs()
  attr(:brand, :string, default: "")
  attr(:context, :string, default: "")
  attr(:theme, :string, default: "light")
  attr(:pane_open, :boolean, default: false)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :top_strip, :layer_callout, %{
          "data-live-ui-shell-position" => "top",
          "data-live-ui-theme" => assigns.theme,
          "data-live-ui-pane-open" => assigns.pane_open
        })
      )

    ~H"""
    <header id={@id} class={@class} {@component_attrs}>
      <span :if={@brand != ""} data-live-ui-strip-brand><%= @brand %></span>
      <span :if={@context != ""} data-live-ui-strip-context><%= @context %></span>
      <div data-live-ui-strip-nav><%= render_slot(@inner_block) %></div>
    </header>
    """
  end
end

defmodule LiveUi.Widgets.Components.SidebarShell do
  @moduledoc """
  Native side navigation shell with collapsible state and section children.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :sidebar_shell,
    slots: [:inner_block],
    assigns: [:collapsed]

  LiveUi.Component.common_attrs()
  attr(:collapsed, :boolean, default: false)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :sidebar_shell, :layer_callout, %{
          "data-live-ui-shell-position" => "side",
          "data-live-ui-collapsed" => assigns.collapsed
        })
      )

    ~H"""
    <nav id={@id} class={@class} aria-hidden={if @collapsed, do: "true", else: "false"} {@component_attrs}>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end
end

defmodule LiveUi.Widgets.Components.SidebarSection do
  @moduledoc """
  Native labeled section group inside a sidebar shell with optional action and item children.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :sidebar_section,
    slots: [:inner_block],
    assigns: [:label, :action_glyph, :action_label, :action_attrs]

  LiveUi.Component.common_attrs()
  attr(:label, :string, required: true)
  attr(:action_glyph, :string, default: nil)
  attr(:action_label, :string, default: nil)
  attr(:action_attrs, :map, default: %{})
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :sidebar_section, :layer_callout)
      )

    ~H"""
    <section id={@id} class={@class} data-live-ui-shell-section="" {@component_attrs}>
      <header data-live-ui-section-header="">
        <span><%= @label %></span>
        <button
          :if={@action_label}
          type="button"
          data-live-ui-section-action=""
          aria-label={@action_label}
          {@action_attrs}
        ><%= if @action_glyph, do: @action_glyph, else: @action_label %></button>
      </header>
      <ul data-live-ui-section-items=""><%= render_slot(@inner_block) %></ul>
    </section>
    """
  end
end

defmodule LiveUi.Widgets.Components.SidebarItem do
  @moduledoc """
  Native navigable sidebar item with selected state, intent, and optional badge children.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :sidebar_item,
    slots: [:inner_block],
    assigns: [:label, :selected, :item_attrs]

  LiveUi.Component.common_attrs()
  attr(:label, :string, required: true)
  attr(:selected, :boolean, default: false)
  attr(:item_attrs, :map, default: %{})
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :sidebar_item, :layer_callout, %{
          "data-live-ui-selected" => assigns.selected
        })
      )

    ~H"""
    <li id={@id} class={@class} data-live-ui-shell-item="" {@component_attrs}>
      <button
        type="button"
        aria-current={if @selected, do: "page", else: "false"}
        {@item_attrs}
      >
        <span><%= @label %></span>
        <%= render_slot(@inner_block) %>
      </button>
    </li>
    """
  end
end

defmodule LiveUi.Widgets.Components.CommandPalette do
  @moduledoc """
  Native keyboard-driven command palette overlay with open state, filterable items, and children.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :command_palette,
    slots: [:inner_block],
    assigns: [:open, :items, :filter_attrs, :select_attrs],
    events: [:filter, :select]

  LiveUi.Component.common_attrs()
  attr(:open, :boolean, default: false)
  attr(:items, :list, default: [])
  attr(:filter_attrs, :map, default: %{})
  attr(:select_attrs, :map, default: %{})
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :command_palette, :layer_callout, %{
          "data-live-ui-palette-open" => assigns.open
        })
      )

    ~H"""
    <aside
      id={@id}
      role="dialog"
      aria-modal="true"
      aria-hidden={if @open, do: "false", else: "true"}
      class={@class}
      {@component_attrs}
    >
      <input
        type="search"
        data-live-ui-palette-input=""
        aria-label="Command filter"
        {@filter_attrs}
      />
      <ul data-live-ui-palette-items="">
        <li
          :for={item <- @items}
          data-live-ui-palette-item={Support.text(Support.fetch(item, :id))}
          data-live-ui-palette-active={Support.fetch(item, :active, false)}
          {Map.merge(@select_attrs, Support.attrs(item))}
        ><%= Support.label(item) %></li>
      </ul>
      <%= render_slot(@inner_block) %>
    </aside>
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
