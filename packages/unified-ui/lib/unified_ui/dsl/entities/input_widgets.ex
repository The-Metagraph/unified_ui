defmodule UnifiedUi.Dsl.Entities.InputWidgets do
  @moduledoc """
  Spark DSL entity definitions for advanced input widgets.

  This module defines:
  - pick_list_option (nested)
  - pick_list
  - form_field (nested)
  - form_builder
  """

  alias UnifiedIUR.Widgets

  @signal_type {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]}
  @field_types [:text, :password, :email, :number, :select, :checkbox]

  @pick_list_option_entity %Spark.Dsl.Entity{
    name: :pick_list_option,
    target: Widgets.PickListOption,
    args: [:value, :label],
    schema: [
      value: [
        type: :any,
        doc: "Option value returned on selection.",
        required: true
      ],
      label: [
        type: :string,
        doc: "Text shown for the option.",
        required: true
      ],
      id: [
        type: :atom,
        doc: "Optional unique identifier for the option.",
        required: false
      ],
      disabled: [
        type: :boolean,
        doc: "Whether the option is disabled.",
        required: false,
        default: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the option is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A selectable option within a pick list.
    """
  }

  @pick_list_entity %Spark.Dsl.Entity{
    name: :pick_list,
    target: Widgets.PickList,
    args: [:id, :options],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the pick list.",
        required: true
      ],
      options: [
        type: {:list, :any},
        doc: "List of options (tuples, maps, or nested pick_list_option entities).",
        required: true
      ],
      selected: [
        type: :any,
        doc: "Currently selected option value.",
        required: false
      ],
      placeholder: [
        type: :string,
        doc: "Placeholder text when no option is selected.",
        required: false
      ],
      searchable: [
        type: :boolean,
        doc: "Whether the list supports search input for filtering.",
        required: false,
        default: false
      ],
      on_select: [
        type: @signal_type,
        doc: "Signal emitted when an option is selected.",
        required: false
      ],
      allow_clear: [
        type: :boolean,
        doc: "Whether the current selection can be cleared.",
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
        doc: "Whether the pick list is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      opts: [@pick_list_option_entity]
    ],
    describe: """
    A pick list widget for selecting one value from a list of options.
    """
  }

  @form_field_entity %Spark.Dsl.Entity{
    name: :form_field,
    target: Widgets.FormField,
    args: [:name, :type],
    schema: [
      name: [
        type: :atom,
        doc: "Field name used in submitted form data.",
        required: true
      ],
      type: [
        type: {:one_of, @field_types},
        doc: "Field input type.",
        required: true
      ],
      label: [
        type: :string,
        doc: "Field label shown to the user.",
        required: false
      ],
      placeholder: [
        type: :string,
        doc: "Placeholder text for text-like field types.",
        required: false
      ],
      required: [
        type: :boolean,
        doc: "Whether the field is required.",
        required: false,
        default: false
      ],
      default: [
        type: :any,
        doc: "Default value for the field.",
        required: false
      ],
      options: [
        type: {:list, :any},
        doc: "Option list for :select fields.",
        required: false
      ],
      disabled: [
        type: :boolean,
        doc: "Whether the field is disabled.",
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
        doc: "Whether the field is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A single field descriptor used inside a form builder.
    """
  }

  @form_builder_entity %Spark.Dsl.Entity{
    name: :form_builder,
    target: Widgets.FormBuilder,
    args: [:id, :fields],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the form builder.",
        required: true
      ],
      fields: [
        type: {:list, :any},
        doc: "List of form field descriptors.",
        required: true
      ],
      action: [
        type: :atom,
        doc: "Optional action identifier for external routing.",
        required: false
      ],
      on_submit: [
        type: @signal_type,
        doc: "Signal emitted when the form is submitted.",
        required: false
      ],
      submit_label: [
        type: :string,
        doc: "Label for the submit button.",
        required: false,
        default: "Submit"
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the form is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      flds: [@form_field_entity]
    ],
    describe: """
    A dynamic form builder that composes multiple form fields.
    """
  }

  @doc false
  @spec pick_list_option_entity() :: Spark.Dsl.Entity.t()
  def pick_list_option_entity, do: @pick_list_option_entity

  @doc false
  @spec pick_list_entity() :: Spark.Dsl.Entity.t()
  def pick_list_entity, do: @pick_list_entity

  @doc false
  @spec form_field_entity() :: Spark.Dsl.Entity.t()
  def form_field_entity, do: @form_field_entity

  @doc false
  @spec form_builder_entity() :: Spark.Dsl.Entity.t()
  def form_builder_entity, do: @form_builder_entity
end
