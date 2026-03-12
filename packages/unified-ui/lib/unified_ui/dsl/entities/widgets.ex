defmodule UnifiedUi.Dsl.Entities.Widgets do
  @moduledoc """
  Spark DSL Entity definitions for basic widgets.

  This module defines the DSL entities for the foundational widgets:
  button, text, label, and text_input.

  Each entity specifies:
  - Required arguments (args)
  - Optional options (schema)
  - Target struct for storing the parsed DSL data
  - Documentation for users

  ## Usage

  These entities are automatically available when using `UnifiedUi.Dsl`:

      defmodule MyApp.MyScreen do
        use UnifiedUi.Dsl

        ui do
          # Widgets can be used here (in Phase 2.2 when layout entities are added)
        end
      end
  """

  alias UnifiedIUR.Widgets

  @state_ref_type {:tuple, [:atom, :atom]}

  @button_entity %Spark.Dsl.Entity{
    name: :button,
    target: Widgets.Button,
    args: [:label],
    schema: [
      label: [
        type: {:or, [:string, @state_ref_type]},
        doc: "The text to display on the button, or `{:state, :key}`.",
        required: true
      ],
      id: [
        type: :atom,
        doc: "Unique identifier for the button.",
        required: false
      ],
      on_click: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when clicked. Can be an atom (signal name),
        a tuple {signal_name, payload}, or an MFA tuple {Module, :function, args}.
        """,
        required: false
      ],
      disabled: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the button is disabled, or `{:state, :key}`.",
        required: false,
        default: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the button is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A clickable button with a label.

    Buttons are the primary way for users to trigger actions in your UI.
    They can be disabled, styled, and configured to emit signals when clicked.
    """
  }

  @text_entity %Spark.Dsl.Entity{
    name: :text,
    target: Widgets.Text,
    args: [:content],
    schema: [
      content: [
        type: {:or, [:string, @state_ref_type]},
        doc: "The text content to display, or `{:state, :key}`.",
        required: true
      ],
      id: [
        type: :atom,
        doc: "Unique identifier for the text element.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the text is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    Displays text content.

    Text widgets are the simplest way to display information to users.
    They support styling and can be given identifiers for referencing.
    """
  }

  @label_entity %Spark.Dsl.Entity{
    name: :label,
    target: Widgets.Label,
    args: [:for, :text],
    schema: [
      for: [
        type: :atom,
        doc: "The id of the input this label is associated with.",
        required: true
      ],
      text: [
        type: {:or, [:string, @state_ref_type]},
        doc: "The label text to display, or `{:state, :key}`.",
        required: true
      ],
      id: [
        type: :atom,
        doc: "Unique identifier for the label.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the label is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A label for a form input.

    Labels associate descriptive text with form input widgets,
    improving accessibility and usability. The `for` attribute
    should match the `id` of the corresponding input widget.
    """
  }

  @text_input_entity %Spark.Dsl.Entity{
    name: :text_input,
    target: Widgets.TextInput,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the input.",
        required: true
      ],
      value: [
        type: {:or, [:string, @state_ref_type]},
        doc: "Initial value for the input, or `{:state, :key}`.",
        required: false
      ],
      placeholder: [
        type: :string,
        doc: "Placeholder text displayed when input is empty.",
        required: false
      ],
      type: [
        type: {:one_of, [:text, :password, :email, :number, :tel]},
        doc: """
        The type of input. Valid values: :text, :password, :email, :number, :tel.
        """,
        required: false,
        default: :text
      ],
      on_change: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when value changes. Can be an atom (signal name),
        a tuple {signal_name, payload}, or an MFA tuple {Module, :function, args}.
        """,
        required: false
      ],
      on_submit: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit on Enter key. Can be an atom (signal name),
        a tuple {signal_name, payload}, or an MFA tuple {Module, :function, args}.
        """,
        required: false
      ],
      form_id: [
        type: :atom,
        doc: """
        Optional form identifier to group this input with a form for data collection.
        Inputs sharing the same form_id can be collected together using
        UnifiedUi.Dsl.FormHelpers.collect_form_data/2.
        """,
        required: false
      ],
      disabled: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the input is disabled, or `{:state, :key}`.",
        required: false,
        default: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the input is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A text input field for user data entry.

    Text inputs allow users to enter and edit text data. They support
    various input types for different data formats and can emit signals
    when values change or when the user submits the input.
    """
  }

  @doc false
  @spec button_entity() :: Spark.Dsl.Entity.t()
  def button_entity, do: @button_entity

  @doc false
  @spec text_entity() :: Spark.Dsl.Entity.t()
  def text_entity, do: @text_entity

  @doc false
  @spec label_entity() :: Spark.Dsl.Entity.t()
  def label_entity, do: @label_entity

  @doc false
  @spec text_input_entity() :: Spark.Dsl.Entity.t()
  def text_input_entity, do: @text_input_entity
end
