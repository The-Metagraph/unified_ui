defmodule UnifiedIUR.Widgets.PickListOption do
  @moduledoc """
  Option descriptor used by pick list widgets.
  """

  defstruct [:value, :label, :id, disabled: false, visible: true]

  @type t :: %__MODULE__{
          value: any(),
          label: String.t() | nil,
          id: atom() | nil,
          disabled: boolean(),
          visible: boolean()
        }
end

defmodule UnifiedIUR.Widgets.PickList do
  @moduledoc """
  Pick list widget for selecting one value from available options.
  """

  @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

  defstruct [
    :id,
    :options,
    :selected,
    :placeholder,
    :on_select,
    :style,
    searchable: false,
    allow_clear: false,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          options: [UnifiedIUR.Widgets.PickListOption.t()] | nil,
          selected: any(),
          placeholder: String.t() | nil,
          searchable: boolean(),
          on_select: signal() | nil,
          allow_clear: boolean(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defmodule UnifiedIUR.Widgets.FormField do
  @moduledoc """
  Form field descriptor used by form builder widgets.
  """

  @type field_type :: :text | :password | :email | :number | :select | :checkbox

  defstruct [
    :name,
    :type,
    :label,
    :placeholder,
    :default,
    :options,
    :style,
    required: false,
    disabled: false,
    visible: true
  ]

  @type t :: %__MODULE__{
          name: atom() | nil,
          type: field_type() | nil,
          label: String.t() | nil,
          placeholder: String.t() | nil,
          required: boolean(),
          default: any(),
          options: [any()] | nil,
          disabled: boolean(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defmodule UnifiedIUR.Widgets.FormBuilder do
  @moduledoc """
  Dynamic form widget that renders and submits a collection of form fields.
  """

  @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

  defstruct [
    :id,
    :fields,
    :action,
    :on_submit,
    :style,
    submit_label: "Submit",
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          fields: [UnifiedIUR.Widgets.FormField.t()] | nil,
          action: atom() | nil,
          on_submit: signal() | nil,
          submit_label: String.t(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.PickListOption do
  def children(_option), do: []

  def metadata(option) do
    %{
      type: :pick_list_option,
      id: option.id,
      value: option.value,
      label: option.label,
      disabled: option.disabled,
      visible: option.visible
    }
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.PickList do
  import UnifiedIUR.ElementHelpers

  def children(pick_list), do: pick_list.options || []

  def metadata(pick_list) do
    %{
      type: :pick_list,
      id: pick_list.id,
      selected: pick_list.selected,
      placeholder: pick_list.placeholder,
      searchable: pick_list.searchable,
      on_select: pick_list.on_select,
      allow_clear: pick_list.allow_clear,
      visible: pick_list.visible
    }
    |> build_metadata(style: pick_list.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.FormField do
  import UnifiedIUR.ElementHelpers

  def children(_field), do: []

  def metadata(field) do
    %{
      type: :form_field,
      name: field.name,
      field_type: field.type,
      label: field.label,
      placeholder: field.placeholder,
      required: field.required,
      default: field.default,
      options: field.options,
      disabled: field.disabled,
      visible: field.visible
    }
    |> build_metadata(style: field.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.FormBuilder do
  import UnifiedIUR.ElementHelpers

  def children(form_builder), do: form_builder.fields || []

  def metadata(form_builder) do
    %{
      type: :form_builder,
      id: form_builder.id,
      action: form_builder.action,
      on_submit: form_builder.on_submit,
      submit_label: form_builder.submit_label,
      visible: form_builder.visible
    }
    |> build_metadata(style: form_builder.style)
  end
end
