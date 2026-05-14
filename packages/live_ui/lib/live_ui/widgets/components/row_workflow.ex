defmodule LiveUi.Widgets.Components.ListItemMultiColumn do
  @moduledoc """
  Native multi-column list row component.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :list_item_multi_column,
    slots: [:inner_block, :actions],
    assigns: [:row_identity, :columns, :active, :link_target],
    events: [:row_activation]

  LiveUi.Component.common_attrs()
  attr(:row_identity, :any, default: nil)
  attr(:columns, :list, default: [])
  attr(:active, :boolean, default: false)
  attr(:link_target, :string, default: nil)
  slot(:inner_block)
  slot(:actions)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :list_item_multi_column, :row_artifact, %{
          "data-live-ui-row-id" => assigns.row_identity,
          "data-live-ui-active" => assigns.active
        })
      )

    ~H"""
    <article id={@id} class={@class} {@component_attrs}>
      <a :if={@link_target} href={@link_target} data-live-ui-row-link=""><%= @link_target %></a>
      <div data-live-ui-row-columns="">
        <span :for={column <- @columns} data-live-ui-row-column={Support.id_value(column, "column")}>
          <%= Support.label(column) %>
        </span>
        <%= render_slot(@inner_block) %>
      </div>
      <footer :if={@actions != []} data-live-ui-row-actions=""><%= render_slot(@actions) %></footer>
    </article>
    """
  end
end

defmodule LiveUi.Widgets.Components.ArtifactRow do
  @moduledoc """
  Native artifact row component for review and workflow lists.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :artifact_row,
    slots: [:inner_block, :actions],
    assigns: [:title, :meta, :row_identity, :active, :link_target],
    events: [:row_activation]

  LiveUi.Component.common_attrs()
  attr(:title, :string, required: true)
  attr(:meta, :map, default: %{})
  attr(:row_identity, :any, default: nil)
  attr(:active, :boolean, default: false)
  attr(:link_target, :string, default: nil)
  slot(:inner_block)
  slot(:actions)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :artifact_row, :row_artifact, %{
          "data-live-ui-row-id" => assigns.row_identity,
          "data-live-ui-active" => assigns.active
        })
      )

    ~H"""
    <article id={@id} class={@class} {@component_attrs}>
      <h3><%= @title %></h3>
      <dl :if={map_size(@meta) > 0}>
        <%= for {key, value} <- Enum.sort_by(@meta, fn {key, _value} -> to_string(key) end) do %>
          <dt><%= key %></dt>
          <dd><%= value %></dd>
        <% end %>
      </dl>
      <div data-live-ui-artifact-body=""><%= render_slot(@inner_block) %></div>
      <footer :if={@actions != []} data-live-ui-artifact-actions=""><%= render_slot(@actions) %></footer>
    </article>
    """
  end
end

defmodule LiveUi.Widgets.Components.PipelineStepperHorizontal do
  @moduledoc """
  Native horizontal workflow stepper.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :pipeline_stepper_horizontal,
    assigns: [:steps, :active_index, :completed_indices],
    events: [:step_navigation]

  LiveUi.Component.common_attrs()
  attr(:steps, :list, default: [])
  attr(:active_index, :integer, default: 0)
  attr(:completed_indices, :list, default: [])

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :pipeline_stepper_horizontal, :workflow_progress)
      )

    ~H"""
    <ol id={@id} class={@class} {@component_attrs}>
      <li
        :for={{step, index} <- Enum.with_index(@steps)}
        aria-current={if index == @active_index, do: "step", else: nil}
        data-live-ui-step-state={step_state(step, index, @active_index, @completed_indices)}
      >
        <button type="button" disabled={Support.disabled?(step)}><%= Support.label(step) %></button>
      </li>
    </ol>
    """
  end

  defp step_state(step, index, active_index, completed_indices) do
    Support.fetch(step, :state) ||
      cond do
        index == active_index -> :active
        index in completed_indices -> :done
        true -> :pending
      end
  end
end

defmodule LiveUi.Widgets.Components.SegmentedProgressBar do
  @moduledoc """
  Native segmented progress component.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :segmented_progress_bar,
    assigns: [:segments, :aggregate_progress, :label]

  LiveUi.Component.common_attrs()
  attr(:segments, :list, default: [])
  attr(:aggregate_progress, :map, default: %{})
  attr(:label, :string, default: nil)

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:current, Support.fetch(assigns.aggregate_progress, :current, 0))
      |> assign(:maximum, Support.fetch(assigns.aggregate_progress, :maximum, 100))
      |> assign(
        :component_attrs,
        Support.component_attrs(assigns, :segmented_progress_bar, :workflow_progress)
      )

    ~H"""
    <div
      id={@id}
      role="progressbar"
      aria-label={@label}
      aria-valuemin="0"
      aria-valuemax={@maximum}
      aria-valuenow={@current}
      class={@class}
      {@component_attrs}
    >
      <span
        :for={segment <- @segments}
        data-live-ui-progress-segment={Support.label(segment)}
        data-live-ui-progress-state={Support.atom_name(Support.fetch(segment, :state, :default))}
        style={"--live-ui-segment-weight: #{Support.numeric(Support.fetch(segment, :weight, 1), 1)}"}
      ><%= Support.label(segment) %></span>
    </div>
    """
  end
end

defmodule LiveUi.Widgets.Components.WorkflowStageListVertical do
  @moduledoc """
  Native vertical workflow stage list.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :workflow_stage_list_vertical,
    assigns: [:stages, :active_index],
    events: [:step_navigation]

  LiveUi.Component.common_attrs()
  attr(:stages, :list, default: [])
  attr(:active_index, :integer, default: 0)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :workflow_stage_list_vertical, :workflow_progress)
      )

    ~H"""
    <ol id={@id} class={@class} {@component_attrs}>
      <li
        :for={{stage, index} <- Enum.with_index(@stages)}
        aria-current={if index == @active_index, do: "step", else: nil}
        data-live-ui-stage-state={Support.atom_name(Support.fetch(stage, :state, if(index == @active_index, do: :active, else: :pending)))}
      >
        <span><%= Support.label(stage) %></span>
      </li>
    </ol>
    """
  end
end

defmodule LiveUi.Widgets.Components.MeterThin do
  @moduledoc """
  Native thin meter component for compact status values.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :meter_thin,
    assigns: [:current, :minimum, :maximum, :label]

  LiveUi.Component.common_attrs()
  attr(:current, :float, default: 0.0)
  attr(:minimum, :float, default: 0.0)
  attr(:maximum, :float, default: 100.0)
  attr(:label, :string, default: nil)

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:percent, Support.percentage(assigns.current, assigns.minimum, assigns.maximum))
      |> assign(
        :component_attrs,
        Support.component_attrs(assigns, :meter_thin, :workflow_progress)
      )

    ~H"""
    <meter
      id={@id}
      min={@minimum}
      max={@maximum}
      value={@current}
      aria-label={@label}
      data-live-ui-meter-percent={@percent}
      class={@class}
      {@component_attrs}
    ><%= @label %></meter>
    """
  end
end
