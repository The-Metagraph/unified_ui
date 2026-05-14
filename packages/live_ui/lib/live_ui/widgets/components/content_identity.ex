defmodule LiveUi.Widgets.Components.InlineRichTextHeading do
  @moduledoc """
  Native rich inline heading component backed by plain text segments.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :inline_rich_text_heading,
    assigns: [:level, :segments]

  LiveUi.Component.common_attrs()
  attr(:level, :string, default: "h2")
  attr(:segments, :list, default: [])

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:heading_level, heading_level(assigns.level))
      |> assign(
        :component_attrs,
        Support.component_attrs(assigns, :inline_rich_text_heading, :content_identity)
      )

    ~H"""
    <div
      id={@id}
      role="heading"
      aria-level={@heading_level}
      class={@class}
      {@component_attrs}
    >
      <span
        :for={segment <- @segments}
        data-live-ui-rich-segment={Support.atom_name(Support.fetch(segment, :type, :text))}
      ><%= Support.text(Support.fetch(segment, :value, Support.fetch(segment, :text))) %></span>
    </div>
    """
  end

  defp heading_level("h" <> value), do: value

  defp heading_level(value) when value in [:h1, :h2, :h3, :h4, :h5, :h6],
    do: value |> to_string() |> String.trim_leading("h")

  defp heading_level(value) when is_integer(value), do: value
  defp heading_level(_value), do: 2
end

defmodule LiveUi.Widgets.Components.Disclosure do
  @moduledoc """
  Native disclosure component with bounded open state metadata.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :disclosure,
    slots: [:inner_block],
    assigns: [:summary, :open],
    events: [:disclosure],
    local_state_keys: [:open]

  LiveUi.Component.common_attrs()
  attr(:summary, :string, required: true)
  attr(:open, :boolean, default: false)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :disclosure, :content_identity, %{
          "data-live-ui-open" => assigns.open
        })
      )

    ~H"""
    <details id={@id} open={@open} class={@class} {@component_attrs}>
      <summary><%= @summary %></summary>
      <div data-live-ui-disclosure-slot="body"><%= render_slot(@inner_block) %></div>
    </details>
    """
  end
end

defmodule LiveUi.Widgets.Components.Kicker do
  @moduledoc """
  Native kicker label component for compact context trails.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :kicker,
    assigns: [:items, :separator]

  LiveUi.Component.common_attrs()
  attr(:items, :list, default: [])
  attr(:separator, :string, default: "/")

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :kicker, :content_identity)
      )

    ~H"""
    <p id={@id} data-live-ui-kicker-count={length(@items)} class={@class} {@component_attrs}>
      <%= for {item, index} <- Enum.with_index(@items) do %>
        <span data-live-ui-kicker-item={index}><%= item %></span>
        <span :if={index < length(@items) - 1} aria-hidden="true"><%= @separator %></span>
      <% end %>
    </p>
    """
  end
end

defmodule LiveUi.Widgets.Components.Avatar do
  @moduledoc """
  Native avatar component with image and initials fallbacks.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :avatar,
    assigns: [:initials, :image_source, :size, :shape, :label]

  LiveUi.Component.common_attrs()
  attr(:initials, :string, default: nil)
  attr(:image_source, :string, default: nil)
  attr(:size, :string, default: "medium")
  attr(:shape, :string, default: "round")
  attr(:label, :string, default: nil)

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:resolved_label, assigns.label || assigns.initials || "Avatar")
      |> assign(
        :component_attrs,
        Support.component_attrs(assigns, :avatar, :content_identity, %{
          "data-live-ui-avatar-size" => assigns.size,
          "data-live-ui-avatar-shape" => assigns.shape
        })
      )

    ~H"""
    <span id={@id} role="img" aria-label={@resolved_label} class={@class} {@component_attrs}>
      <img :if={@image_source} src={@image_source} alt="" />
      <span :if={!@image_source} data-live-ui-avatar-fallback="initials"><%= @initials %></span>
    </span>
    """
  end
end

defmodule LiveUi.Widgets.Components.PresenceDot do
  @moduledoc """
  Native presence indicator component with accessible state labels.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :presence_dot,
    assigns: [:presence, :size, :label]

  LiveUi.Component.common_attrs()
  attr(:presence, :string, default: "offline")
  attr(:size, :string, default: "medium")
  attr(:label, :string, default: nil)

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:resolved_label, assigns.label || "Presence #{Support.text(assigns.presence)}")
      |> assign(
        :component_attrs,
        Support.component_attrs(assigns, :presence_dot, :content_identity, %{
          "data-live-ui-presence" => assigns.presence,
          "data-live-ui-presence-size" => assigns.size
        })
      )

    ~H"""
    <span
      id={@id}
      role="status"
      aria-label={@resolved_label}
      class={@class}
      {@component_attrs}
    >
      <span aria-hidden="true"></span>
    </span>
    """
  end
end
