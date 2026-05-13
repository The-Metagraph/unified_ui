defmodule LiveUi.Widgets.Portable do
  @moduledoc """
  Shared helpers and module registry for promoted portable widgets.
  """

  alias UnifiedIUR.Binding

  @semantic_modules [
    LiveUi.Widgets.Disclosure,
    LiveUi.Widgets.Kicker,
    LiveUi.Widgets.Avatar,
    LiveUi.Widgets.PresenceDot,
    LiveUi.Widgets.SegmentedButtonGroup,
    LiveUi.Widgets.ListItemMultiColumn,
    LiveUi.Widgets.ArtifactRow,
    LiveUi.Widgets.StickyHeader
  ]

  @workflow_modules [
    LiveUi.Widgets.PipelineStepperHorizontal,
    LiveUi.Widgets.SegmentedProgressBar,
    LiveUi.Widgets.WorkflowStageListVertical,
    LiveUi.Widgets.MeterThin,
    LiveUi.Widgets.SlideOverPanel,
    LiveUi.Widgets.EventCallout,
    LiveUi.Widgets.RedlineInline,
    LiveUi.Widgets.CodeBlockSyntaxHighlighted,
    LiveUi.Widgets.ChatComposer
  ]

  @spec modules() :: [module()]
  def modules, do: @semantic_modules ++ @workflow_modules

  @spec semantic_modules() :: [module()]
  def semantic_modules, do: @semantic_modules

  @spec workflow_modules() :: [module()]
  def workflow_modules, do: @workflow_modules

  @spec items(term()) :: [map()]
  def items(nil), do: []

  def items(%Binding{} = binding) do
    [%{id: "binding", label: text(binding), value: binding}]
  end

  def items(items) when is_map(items) do
    items
    |> Map.to_list()
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> items()
  end

  def items(items) when is_list(items) do
    Enum.map(items, fn
      {id, value} ->
        %{id: id, label: text(value), value: value}

      item when is_map(item) ->
        %{
          id: field(item, :id, field(item, :value, field(item, :label, "item"))),
          label: field(item, :label, field(item, :value, field(item, :id, "Item"))),
          value: field(item, :value, item)
        }

      item ->
        %{id: item, label: text(item), value: item}
    end)
  end

  def items(item), do: [%{id: "value", label: text(item), value: item}]

  @spec field(map(), atom(), term()) :: term()
  def field(map, key, default \\ nil) when is_map(map) do
    Map.get(map, key, Map.get(map, to_string(key), default))
  end

  @spec item_id(map()) :: String.t()
  def item_id(item), do: item |> field(:id, field(item, :label, "item")) |> text()

  @spec item_label(map()) :: String.t()
  def item_label(item), do: item |> field(:label, field(item, :value, "")) |> text()

  @spec item_value(map()) :: term()
  def item_value(item), do: field(item, :value)

  @spec active?(map(), term()) :: boolean()
  def active?(item, active_item),
    do: to_string(field(item, :id, field(item, :value))) == to_string(active_item)

  @spec text(term()) :: String.t()
  def text(nil), do: ""
  def text(%Binding{} = binding), do: row_binding_text(binding)
  def text(value) when is_binary(value), do: value
  def text(value) when is_atom(value), do: Atom.to_string(value)
  def text(value) when is_integer(value) or is_float(value), do: to_string(value)
  def text(value), do: inspect(value)

  defp row_binding_text(%Binding{source: :row_scope, scope: scope, path: path}) do
    "row:" <>
      ([scope, path]
       |> List.flatten()
       |> Enum.map(&to_string/1)
       |> Enum.join("."))
  end

  defp row_binding_text(%Binding{name: name, path: path}) do
    "binding:" <>
      ([name, path]
       |> List.flatten()
       |> Enum.reject(&is_nil/1)
       |> Enum.map(&to_string/1)
       |> Enum.join("."))
  end
end

defmodule LiveUi.Widgets.Disclosure do
  @moduledoc "Native disclosure widget."

  use LiveUi.Component,
    family: :semantic,
    name: :disclosure,
    slots: [:inner_block],
    events: [:toggle]

  LiveUi.Component.common_attrs()
  attr(:label, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:content_label, :string, default: nil)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <details
      id={@id}
      open={@open}
      data-live-ui-widget="disclosure"
      data-live-ui-open={@open}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <summary><%= @label %></summary>
      <div data-live-ui-disclosure-slot="content" aria-label={@content_label}>
        <%= render_slot(@inner_block) || @content_label %>
      </div>
    </details>
    """
  end
end

defmodule LiveUi.Widgets.Kicker do
  @moduledoc "Native semantic kicker widget."

  use LiveUi.Component, family: :semantic, name: :kicker

  LiveUi.Component.common_attrs()
  attr(:value, :string, required: true)
  attr(:icon, :string, default: nil)
  attr(:role, :string, default: "eyebrow")

  @impl true
  def render(assigns) do
    ~H"""
    <p
      id={@id}
      data-live-ui-widget="kicker"
      data-live-ui-kicker-role={@role}
      data-live-ui-icon={@icon}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    ><%= @value %></p>
    """
  end
end

defmodule LiveUi.Widgets.Avatar do
  @moduledoc "Native avatar widget."

  use LiveUi.Component, family: :semantic, name: :avatar

  LiveUi.Component.common_attrs()
  attr(:label, :string, required: true)
  attr(:initials, :string, default: nil)
  attr(:src, :string, default: nil)
  attr(:status, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <span
      id={@id}
      data-live-ui-widget="avatar"
      data-live-ui-avatar-status={@status}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      aria-label={@label}
      {@rest}
    >
      <%= if @src do %>
        <img src={@src} alt={@label} />
      <% else %>
        <span data-live-ui-avatar-initials><%= @initials || @label %></span>
      <% end %>
    </span>
    """
  end
end

defmodule LiveUi.Widgets.PresenceDot do
  @moduledoc "Native presence dot widget."

  use LiveUi.Component, family: :semantic, name: :presence_dot

  LiveUi.Component.common_attrs()
  attr(:status, :string, required: true)
  attr(:label, :string, default: nil)
  attr(:pulse, :boolean, default: false)

  @impl true
  def render(assigns) do
    ~H"""
    <span
      id={@id}
      role="status"
      aria-label={@label || @status}
      data-live-ui-widget="presence-dot"
      data-live-ui-presence-status={@status}
      data-live-ui-pulse={@pulse}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    ><%= @label || @status %></span>
    """
  end
end

defmodule LiveUi.Widgets.SegmentedButtonGroup do
  @moduledoc "Native segmented button group widget."

  use LiveUi.Component, family: :semantic, name: :segmented_button_group, events: [:selection]

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:items, :any, default: [])
  attr(:active_item, :any, default: nil)
  attr(:selection_mode, :string, default: "single")
  attr(:orientation, :string, default: "horizontal")

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      data-live-ui-widget="segmented-button-group"
      data-live-ui-selection-mode={@selection_mode}
      data-live-ui-orientation={@orientation}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <button
        :for={item <- Portable.items(@items)}
        type="button"
        data-live-ui-segment-id={Portable.item_id(item)}
        aria-pressed={Portable.active?(item, @active_item)}
      ><%= Portable.item_label(item) %></button>
    </div>
    """
  end
end

defmodule LiveUi.Widgets.ListItemMultiColumn do
  @moduledoc "Native multi-column list item widget."

  use LiveUi.Component, family: :semantic, name: :list_item_multi_column

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:label, :string, default: nil)
  attr(:columns, :any, required: true)
  attr(:value, :any, default: nil)
  attr(:status, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <article
      id={@id}
      data-live-ui-widget="list-item-multi-column"
      data-live-ui-status={@status}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <strong :if={@label}><%= @label %></strong>
      <span :if={@value} data-live-ui-list-item-value><%= Portable.text(@value) %></span>
      <span
        :for={column <- Portable.items(@columns)}
        data-live-ui-list-item-column={Portable.item_id(column)}
      ><%= Portable.item_label(column) %></span>
    </article>
    """
  end
end

defmodule LiveUi.Widgets.ArtifactRow do
  @moduledoc "Native artifact row widget."

  use LiveUi.Component, family: :semantic, name: :artifact_row, events: [:click]

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:title, :string, required: true)
  attr(:artifact, :any, required: true)
  attr(:status, :string, default: nil)
  attr(:timestamp, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <article
      id={@id}
      data-live-ui-widget="artifact-row"
      data-live-ui-status={@status}
      data-live-ui-artifact={Portable.text(@artifact)}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <strong><%= @title %></strong>
      <time :if={@timestamp}><%= @timestamp %></time>
      <span :if={@status}><%= @status %></span>
    </article>
    """
  end
end

defmodule LiveUi.Widgets.StickyHeader do
  @moduledoc "Native sticky header widget."

  use LiveUi.Component, family: :semantic, name: :sticky_header

  LiveUi.Component.common_attrs()
  attr(:title, :string, required: true)
  attr(:stuck, :boolean, default: false)
  attr(:elevation, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <header
      id={@id}
      data-live-ui-widget="sticky-header"
      data-live-ui-stuck={@stuck}
      data-live-ui-elevation={@elevation}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    ><h2><%= @title %></h2></header>
    """
  end
end

defmodule LiveUi.Widgets.PipelineStepperHorizontal do
  @moduledoc "Native horizontal pipeline stepper widget."

  use LiveUi.Component, family: :workflow, name: :pipeline_stepper_horizontal

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:steps, :any, default: [])
  attr(:active_item, :any, default: nil)
  attr(:status, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <ol
      id={@id}
      data-live-ui-widget="pipeline-stepper-horizontal"
      data-live-ui-status={@status}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <li
        :for={step <- Portable.items(@steps)}
        data-live-ui-step-id={Portable.item_id(step)}
        aria-current={if Portable.active?(step, @active_item), do: "step"}
      ><%= Portable.item_label(step) %></li>
    </ol>
    """
  end
end

defmodule LiveUi.Widgets.SegmentedProgressBar do
  @moduledoc "Native segmented progress bar widget."

  use LiveUi.Component, family: :workflow, name: :segmented_progress_bar

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:segments, :any, default: [])
  attr(:current, :integer, default: 0)
  attr(:maximum, :integer, default: 100)
  attr(:label, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      role="progressbar"
      aria-valuenow={@current}
      aria-valuemax={@maximum}
      aria-label={@label}
      data-live-ui-widget="segmented-progress-bar"
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <span
        :for={segment <- Portable.items(@segments)}
        data-live-ui-progress-segment={Portable.item_id(segment)}
        data-live-ui-progress-value={Portable.text(Portable.item_value(segment))}
      ><%= Portable.item_label(segment) %></span>
    </div>
    """
  end
end

defmodule LiveUi.Widgets.WorkflowStageListVertical do
  @moduledoc "Native vertical workflow stage list widget."

  use LiveUi.Component, family: :workflow, name: :workflow_stage_list_vertical

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:stages, :any, default: [])
  attr(:active_item, :any, default: nil)
  attr(:status, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <ol
      id={@id}
      data-live-ui-widget="workflow-stage-list-vertical"
      data-live-ui-status={@status}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <li
        :for={stage <- Portable.items(@stages)}
        data-live-ui-stage-id={Portable.item_id(stage)}
        aria-current={if Portable.active?(stage, @active_item), do: "step"}
      ><%= Portable.item_label(stage) %></li>
    </ol>
    """
  end
end

defmodule LiveUi.Widgets.MeterThin do
  @moduledoc "Native thin meter widget."

  use LiveUi.Component, family: :workflow, name: :meter_thin

  LiveUi.Component.common_attrs()
  attr(:current, :integer, required: true)
  attr(:minimum, :integer, default: 0)
  attr(:maximum, :integer, default: 100)
  attr(:label, :string, default: nil)
  attr(:severity, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <meter
      id={@id}
      value={@current}
      min={@minimum}
      max={@maximum}
      aria-label={@label}
      data-live-ui-widget="meter-thin"
      data-live-ui-severity={@severity}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    ><%= @label %></meter>
    """
  end
end

defmodule LiveUi.Widgets.SlideOverPanel do
  @moduledoc "Native slide-over panel widget."

  use LiveUi.Component, family: :workflow, name: :slide_over_panel, slots: [:inner_block]

  LiveUi.Component.common_attrs()
  attr(:title, :string, default: nil)
  attr(:placement, :string, default: "end")
  attr(:visible, :boolean, default: false)
  attr(:modal, :boolean, default: true)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <aside
      id={@id}
      data-live-ui-widget="slide-over-panel"
      data-live-ui-placement={@placement}
      data-live-ui-visible={@visible}
      data-live-ui-modal={@modal}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      aria-modal={@modal}
      {@rest}
    >
      <h2 :if={@title}><%= @title %></h2>
      <div data-live-ui-panel-slot="content"><%= render_slot(@inner_block) %></div>
    </aside>
    """
  end
end

defmodule LiveUi.Widgets.EventCallout do
  @moduledoc "Native event callout widget."

  use LiveUi.Component, family: :workflow, name: :event_callout

  LiveUi.Component.common_attrs()
  attr(:message, :string, required: true)
  attr(:title, :string, default: nil)
  attr(:severity, :string, default: "info")
  attr(:timestamp, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <aside
      id={@id}
      role="status"
      data-live-ui-widget="event-callout"
      data-live-ui-severity={@severity}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <strong :if={@title}><%= @title %></strong>
      <p><%= @message %></p>
      <time :if={@timestamp}><%= @timestamp %></time>
    </aside>
    """
  end
end

defmodule LiveUi.Widgets.RedlineInline do
  @moduledoc "Native inline redline widget."

  use LiveUi.Component, family: :workflow, name: :redline_inline

  LiveUi.Component.common_attrs()
  attr(:before_text, :string, required: true)
  attr(:after_text, :string, required: true)
  attr(:label, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <span
      id={@id}
      aria-label={@label}
      data-live-ui-widget="redline-inline"
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    ><del><%= @before_text %></del> <ins><%= @after_text %></ins></span>
    """
  end
end

defmodule LiveUi.Widgets.CodeBlockSyntaxHighlighted do
  @moduledoc "Native syntax-highlighted code block widget."

  use LiveUi.Component, family: :workflow, name: :code_block_syntax_highlighted

  LiveUi.Component.common_attrs()
  attr(:code, :string, required: true)
  attr(:language, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:wrap, :boolean, default: false)

  @impl true
  def render(assigns) do
    ~H"""
    <pre
      id={@id}
      aria-label={@label}
      data-live-ui-widget="code-block-syntax-highlighted"
      data-live-ui-language={@language}
      data-live-ui-wrap={@wrap}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    ><code><%= @code %></code></pre>
    """
  end
end

defmodule LiveUi.Widgets.ChatComposer do
  @moduledoc "Native chat composer widget."

  use LiveUi.Component, family: :workflow, name: :chat_composer, events: [:submit, :change]

  alias LiveUi.Widgets.Portable

  LiveUi.Component.common_attrs()
  attr(:placeholder, :string, default: nil)
  attr(:submit_intent, :string, default: nil)
  attr(:actions, :any, default: [])
  attr(:multiline, :boolean, default: true)

  @impl true
  def render(assigns) do
    ~H"""
    <form
      id={@id}
      data-live-ui-widget="chat-composer"
      data-live-ui-submit-intent={@submit_intent}
      data-live-ui-multiline={@multiline}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <textarea name="message" placeholder={@placeholder} aria-label={@placeholder || "Message"}></textarea>
      <button
        :for={action <- Portable.items(@actions)}
        type="submit"
        name="action"
        value={Portable.item_id(action)}
      ><%= Portable.item_label(action) %></button>
    </form>
    """
  end
end
