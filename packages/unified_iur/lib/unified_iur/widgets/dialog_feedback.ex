defmodule UnifiedIUR.Widgets.DialogButton do
  @moduledoc """
  Button descriptor used by dialog widgets.
  """

  @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}
  @type role :: :default | :confirm | :cancel | :destructive

  defstruct [
    :label,
    :id,
    :action,
    :style,
    role: :default,
    disabled: false,
    visible: true
  ]

  @type t :: %__MODULE__{
          label: String.t() | nil,
          id: atom() | nil,
          action: signal() | nil,
          role: role(),
          disabled: boolean(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defmodule UnifiedIUR.Widgets.Dialog do
  @moduledoc """
  Modal dialog widget with optional nested content and action buttons.
  """

  @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}
  @type content :: any()

  defstruct [
    :id,
    :title,
    :content,
    :buttons,
    :on_close,
    :width,
    :height,
    :style,
    closable: true,
    modal: true,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          title: String.t() | nil,
          content: content(),
          buttons: [UnifiedIUR.Widgets.DialogButton.t()] | nil,
          on_close: signal() | nil,
          width: integer() | nil,
          height: integer() | nil,
          closable: boolean(),
          modal: boolean(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defmodule UnifiedIUR.Widgets.AlertDialog do
  @moduledoc """
  Alert dialog widget with severity and confirm/cancel handlers.
  """

  @type severity :: :info | :success | :warning | :error
  @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

  defstruct [
    :id,
    :title,
    :message,
    :on_confirm,
    :on_cancel,
    :style,
    severity: :info,
    closable: true,
    modal: true,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          title: String.t() | nil,
          message: String.t() | nil,
          severity: severity(),
          on_confirm: signal() | nil,
          on_cancel: signal() | nil,
          closable: boolean(),
          modal: boolean(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defmodule UnifiedIUR.Widgets.Toast do
  @moduledoc """
  Toast widget for transient notifications.
  """

  @type severity :: :info | :success | :warning | :error
  @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

  defstruct [
    :id,
    :message,
    :on_dismiss,
    :style,
    severity: :info,
    duration: 3000,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          message: String.t() | nil,
          severity: severity(),
          duration: integer(),
          on_dismiss: signal() | nil,
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.DialogButton do
  import UnifiedIUR.ElementHelpers

  def children(_button), do: []

  def metadata(button) do
    %{
      type: :dialog_button,
      id: button.id,
      label: button.label,
      action: button.action,
      role: button.role,
      disabled: button.disabled,
      visible: button.visible
    }
    |> build_metadata(style: button.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Dialog do
  import UnifiedIUR.ElementHelpers

  def children(dialog) do
    content_children =
      case dialog.content do
        nil -> []
        content when is_list(content) -> content
        content -> [content]
      end

    content_children ++ (dialog.buttons || [])
  end

  def metadata(dialog) do
    %{
      type: :dialog,
      id: dialog.id,
      title: dialog.title,
      on_close: dialog.on_close,
      width: dialog.width,
      height: dialog.height,
      closable: dialog.closable,
      modal: dialog.modal,
      visible: dialog.visible
    }
    |> build_metadata(style: dialog.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.AlertDialog do
  import UnifiedIUR.ElementHelpers

  def children(_alert), do: []

  def metadata(alert) do
    %{
      type: :alert_dialog,
      id: alert.id,
      title: alert.title,
      message: alert.message,
      severity: alert.severity,
      on_confirm: alert.on_confirm,
      on_cancel: alert.on_cancel,
      closable: alert.closable,
      modal: alert.modal,
      visible: alert.visible
    }
    |> build_metadata(style: alert.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Toast do
  import UnifiedIUR.ElementHelpers

  def children(_toast), do: []

  def metadata(toast) do
    %{
      type: :toast,
      id: toast.id,
      message: toast.message,
      severity: toast.severity,
      duration: toast.duration,
      on_dismiss: toast.on_dismiss,
      visible: toast.visible
    }
    |> build_metadata(style: toast.style)
  end
end
