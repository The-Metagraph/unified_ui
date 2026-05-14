defmodule LiveUi.Widgets.Components do
  @moduledoc """
  Native LiveUi component registry for the canonical widget-component catalog.
  """

  @type component_family ::
          :content_identity
          | :form_control
          | :row_artifact
          | :workflow_progress
          | :layer_callout
          | :redline_code
          | :composition_behavior

  @type component_contract :: %{
          module: module(),
          family: component_family(),
          assigns: [atom()],
          slots: [atom()],
          events: [atom()],
          local_state_keys: [atom()]
        }

  @content_identity_modules [
    LiveUi.Widgets.Components.InlineRichTextHeading,
    LiveUi.Widgets.Components.Disclosure,
    LiveUi.Widgets.Components.Kicker,
    LiveUi.Widgets.Components.Avatar,
    LiveUi.Widgets.Components.PresenceDot
  ]

  @form_control_modules [
    LiveUi.Widgets.Components.SegmentedButtonGroup,
    LiveUi.Widgets.Components.RuntimeFormShell,
    LiveUi.Widgets.Components.ChatComposer
  ]

  @row_artifact_modules [
    LiveUi.Widgets.Components.ListItemMultiColumn,
    LiveUi.Widgets.Components.ArtifactRow
  ]

  @workflow_progress_modules [
    LiveUi.Widgets.Components.PipelineStepperHorizontal,
    LiveUi.Widgets.Components.SegmentedProgressBar,
    LiveUi.Widgets.Components.WorkflowStageListVertical,
    LiveUi.Widgets.Components.MeterThin
  ]

  @layer_callout_modules [
    LiveUi.Widgets.Components.StickyFrostedHeader,
    LiveUi.Widgets.Components.SlideOverPanel,
    LiveUi.Widgets.Components.EventCallout
  ]

  @redline_code_modules [
    LiveUi.Widgets.Components.RedlineInline,
    LiveUi.Widgets.Components.CodeBlockSyntaxHighlighted
  ]

  @composition_behavior_modules [
    LiveUi.Widgets.Components.ListRepeat
  ]

  @contracts %{
    inline_rich_text_heading: %{
      module: LiveUi.Widgets.Components.InlineRichTextHeading,
      family: :content_identity,
      assigns: [:level, :segments],
      slots: [],
      events: [],
      local_state_keys: []
    },
    disclosure: %{
      module: LiveUi.Widgets.Components.Disclosure,
      family: :content_identity,
      assigns: [:summary, :open],
      slots: [:inner_block],
      events: [:disclosure],
      local_state_keys: [:open]
    },
    kicker: %{
      module: LiveUi.Widgets.Components.Kicker,
      family: :content_identity,
      assigns: [:items, :separator],
      slots: [],
      events: [],
      local_state_keys: []
    },
    avatar: %{
      module: LiveUi.Widgets.Components.Avatar,
      family: :content_identity,
      assigns: [:initials, :image_source, :size, :shape, :label],
      slots: [],
      events: [],
      local_state_keys: []
    },
    presence_dot: %{
      module: LiveUi.Widgets.Components.PresenceDot,
      family: :content_identity,
      assigns: [:presence, :size, :label],
      slots: [],
      events: [],
      local_state_keys: []
    },
    segmented_button_group: %{
      module: LiveUi.Widgets.Components.SegmentedButtonGroup,
      family: :form_control,
      assigns: [:options, :active_value, :disabled, :label, :option_attrs],
      slots: [],
      events: [:selection],
      local_state_keys: []
    },
    runtime_form_shell: %{
      module: LiveUi.Widgets.Components.RuntimeFormShell,
      family: :form_control,
      assigns: [:fields, :submit_label, :validation_state, :host_adapter_hints, :form_attrs],
      slots: [:inner_block],
      events: [:submit, :change],
      local_state_keys: []
    },
    chat_composer: %{
      module: LiveUi.Widgets.Components.ChatComposer,
      family: :form_control,
      assigns: [
        :name,
        :value,
        :placeholder,
        :rows,
        :send_label,
        :disabled,
        :form_attrs,
        :input_attrs,
        :send_attrs
      ],
      slots: [:tools],
      events: [:send, :change],
      local_state_keys: []
    },
    list_item_multi_column: %{
      module: LiveUi.Widgets.Components.ListItemMultiColumn,
      family: :row_artifact,
      assigns: [:row_identity, :columns, :active, :link_target, :row_attrs],
      slots: [:inner_block, :actions],
      events: [:row_activation],
      local_state_keys: []
    },
    artifact_row: %{
      module: LiveUi.Widgets.Components.ArtifactRow,
      family: :row_artifact,
      assigns: [:title, :meta, :row_identity, :active, :link_target, :link_label, :row_attrs],
      slots: [:inner_block, :actions],
      events: [:row_activation],
      local_state_keys: []
    },
    pipeline_stepper_horizontal: %{
      module: LiveUi.Widgets.Components.PipelineStepperHorizontal,
      family: :workflow_progress,
      assigns: [:steps, :active_index, :completed_indices, :step_attrs],
      slots: [],
      events: [:step_navigation],
      local_state_keys: []
    },
    segmented_progress_bar: %{
      module: LiveUi.Widgets.Components.SegmentedProgressBar,
      family: :workflow_progress,
      assigns: [:segments, :aggregate_progress, :label],
      slots: [],
      events: [],
      local_state_keys: []
    },
    workflow_stage_list_vertical: %{
      module: LiveUi.Widgets.Components.WorkflowStageListVertical,
      family: :workflow_progress,
      assigns: [:stages, :active_index, :stage_attrs],
      slots: [],
      events: [:step_navigation],
      local_state_keys: []
    },
    meter_thin: %{
      module: LiveUi.Widgets.Components.MeterThin,
      family: :workflow_progress,
      assigns: [:current, :minimum, :maximum, :label],
      slots: [],
      events: [],
      local_state_keys: []
    },
    sticky_frosted_header: %{
      module: LiveUi.Widgets.Components.StickyFrostedHeader,
      family: :layer_callout,
      assigns: [:title, :leading, :trailing],
      slots: [:inner_block],
      events: [],
      local_state_keys: []
    },
    slide_over_panel: %{
      module: LiveUi.Widgets.Components.SlideOverPanel,
      family: :layer_callout,
      assigns: [:open, :size, :label],
      slots: [:inner_block],
      events: [:panel],
      local_state_keys: [:open]
    },
    event_callout: %{
      module: LiveUi.Widgets.Components.EventCallout,
      family: :layer_callout,
      assigns: [:message, :eyebrow, :title, :callout_tone, :action_label, :action_attrs],
      slots: [:inner_block, :actions],
      events: [:inline_action],
      local_state_keys: []
    },
    redline_inline: %{
      module: LiveUi.Widgets.Components.RedlineInline,
      family: :redline_code,
      assigns: [:segments],
      slots: [],
      events: [],
      local_state_keys: []
    },
    code_block_syntax_highlighted: %{
      module: LiveUi.Widgets.Components.CodeBlockSyntaxHighlighted,
      family: :redline_code,
      assigns: [:language, :tokens],
      slots: [],
      events: [],
      local_state_keys: []
    },
    list_repeat: %{
      module: LiveUi.Widgets.Components.ListRepeat,
      family: :composition_behavior,
      assigns: [:repeat],
      slots: [:inner_block],
      events: [],
      local_state_keys: []
    }
  }

  @spec modules() :: [module()]
  def modules do
    content_identity_modules() ++
      form_control_modules() ++
      row_artifact_modules() ++
      workflow_progress_modules() ++
      layer_callout_modules() ++
      redline_code_modules() ++
      composition_behavior_modules()
  end

  @spec content_identity_modules() :: [module()]
  def content_identity_modules, do: @content_identity_modules

  @spec form_control_modules() :: [module()]
  def form_control_modules, do: @form_control_modules

  @spec row_artifact_modules() :: [module()]
  def row_artifact_modules, do: @row_artifact_modules

  @spec workflow_progress_modules() :: [module()]
  def workflow_progress_modules, do: @workflow_progress_modules

  @spec layer_callout_modules() :: [module()]
  def layer_callout_modules, do: @layer_callout_modules

  @spec redline_code_modules() :: [module()]
  def redline_code_modules, do: @redline_code_modules

  @spec composition_behavior_modules() :: [module()]
  def composition_behavior_modules, do: @composition_behavior_modules

  @spec contracts() :: %{atom() => component_contract()}
  def contracts, do: @contracts

  @spec contract(atom()) :: component_contract()
  def contract(kind), do: Map.fetch!(@contracts, kind)

  @spec module_for(atom()) :: module() | nil
  def module_for(kind) do
    case Map.fetch(@contracts, kind) do
      {:ok, %{module: module}} -> module
      :error -> nil
    end
  end
end
