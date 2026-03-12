defmodule UnifiedUi.Dsl.Entities.DialogFeedback do
  @moduledoc """
  Spark DSL Entity definitions for dialog and feedback widgets.

  This module defines DSL entities for:
  - dialog_button (nested)
  - dialog
  - alert_dialog
  - toast
  """

  alias UnifiedIUR.Widgets
  alias UnifiedUi.Dsl.Entities.{DataViz, InputWidgets, Navigation, Tables}
  alias UnifiedUi.Dsl.Entities.Widgets, as: WidgetEntities

  @signal_type {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]}

  @dialog_button_entity %Spark.Dsl.Entity{
    name: :dialog_button,
    target: Widgets.DialogButton,
    args: [:label],
    schema: [
      label: [
        type: :string,
        doc: "The text displayed on the dialog button.",
        required: true
      ],
      id: [
        type: :atom,
        doc: "Optional unique identifier for the dialog button.",
        required: false
      ],
      action: [
        type: @signal_type,
        doc: "Signal to emit when the button is clicked.",
        required: false
      ],
      role: [
        type: {:one_of, [:default, :confirm, :cancel, :destructive]},
        doc: "Semantic role for styling and behavior hints.",
        required: false,
        default: :default
      ],
      disabled: [
        type: :boolean,
        doc: "Whether the button is disabled.",
        required: false,
        default: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the button is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A button used within dialog widgets.

    Dialog buttons support role metadata so renderers can distinguish
    primary, cancel, and destructive actions.
    """
  }

  @dialog_content_entities [
    WidgetEntities.button_entity(),
    WidgetEntities.text_entity(),
    WidgetEntities.label_entity(),
    WidgetEntities.text_input_entity(),
    DataViz.gauge_entity(),
    DataViz.sparkline_entity(),
    DataViz.bar_chart_entity(),
    DataViz.line_chart_entity(),
    Tables.table_entity(),
    Navigation.menu_entity(),
    Navigation.context_menu_entity(),
    Navigation.tabs_entity(),
    Navigation.tree_view_entity(),
    InputWidgets.pick_list_entity(),
    InputWidgets.form_builder_entity()
  ]

  @dialog_entity %Spark.Dsl.Entity{
    name: :dialog,
    target: Widgets.Dialog,
    args: [:id, :title, :content],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the dialog.",
        required: true
      ],
      title: [
        type: :string,
        doc: "Dialog title text.",
        required: true
      ],
      content: [
        type: :any,
        doc: "Dialog content. Can also be supplied via nested entities.",
        required: true
      ],
      buttons: [
        type: {:list, :any},
        doc: "Optional list of dialog buttons.",
        required: false
      ],
      on_close: [
        type: @signal_type,
        doc: "Signal to emit when the dialog is closed.",
        required: false
      ],
      width: [
        type: :integer,
        doc: "Optional dialog width hint.",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Optional dialog height hint.",
        required: false
      ],
      closable: [
        type: :boolean,
        doc: "Whether the dialog can be closed by the user.",
        required: false,
        default: true
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the dialog is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      content: @dialog_content_entities,
      buttons: [@dialog_button_entity]
    ],
    describe: """
    A modal dialog container.

    Dialog content can be declared as an argument or via nested entities.
    Buttons can be provided through the `buttons` option or a nested block.
    """
  }

  @alert_dialog_entity %Spark.Dsl.Entity{
    name: :alert_dialog,
    target: Widgets.AlertDialog,
    args: [:id, :title, :message],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the alert dialog.",
        required: true
      ],
      title: [
        type: :string,
        doc: "Alert dialog title text.",
        required: true
      ],
      message: [
        type: :string,
        doc: "Alert message text.",
        required: true
      ],
      severity: [
        type: {:one_of, [:info, :success, :warning, :error]},
        doc: "Severity level used for styling.",
        required: false,
        default: :info
      ],
      on_confirm: [
        type: @signal_type,
        doc: "Signal emitted when the confirm action is triggered.",
        required: false
      ],
      on_cancel: [
        type: @signal_type,
        doc: "Signal emitted when the cancel action is triggered.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the alert dialog is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    An alert dialog with severity and confirm/cancel handlers.
    """
  }

  @toast_entity %Spark.Dsl.Entity{
    name: :toast,
    target: Widgets.Toast,
    args: [:id, :message],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the toast.",
        required: true
      ],
      message: [
        type: :string,
        doc: "Toast message text.",
        required: true
      ],
      severity: [
        type: {:one_of, [:info, :success, :warning, :error]},
        doc: "Severity level used for styling.",
        required: false,
        default: :info
      ],
      duration: [
        type: :integer,
        doc: "Auto-dismiss duration in milliseconds. 0 disables auto-dismiss.",
        required: false,
        default: 3000
      ],
      on_dismiss: [
        type: @signal_type,
        doc: "Signal emitted when the toast is dismissed.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the toast is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A transient notification toast widget.
    """
  }

  @doc false
  @spec dialog_button_entity() :: Spark.Dsl.Entity.t()
  def dialog_button_entity, do: @dialog_button_entity

  @doc false
  @spec dialog_entity() :: Spark.Dsl.Entity.t()
  def dialog_entity, do: @dialog_entity

  @doc false
  @spec alert_dialog_entity() :: Spark.Dsl.Entity.t()
  def alert_dialog_entity, do: @alert_dialog_entity

  @doc false
  @spec toast_entity() :: Spark.Dsl.Entity.t()
  def toast_entity, do: @toast_entity
end
