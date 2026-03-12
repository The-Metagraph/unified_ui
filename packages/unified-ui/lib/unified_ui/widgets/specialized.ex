defmodule UnifiedUi.Widgets.Canvas do
  @moduledoc """
  Specialized widget for custom drawing operations.
  """

  @type draw_fun :: (UnifiedUi.Widgets.DrawingContext.t() -> term())

  defstruct [
    :id,
    :width,
    :height,
    :draw,
    :on_click,
    :on_hover,
    :style,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          width: integer() | nil,
          height: integer() | nil,
          draw: draw_fun() | nil,
          on_click: atom() | {atom(), map()} | nil,
          on_hover: atom() | {atom(), map()} | nil,
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.Canvas do
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :canvas,
      id: widget.id,
      width: widget.width,
      height: widget.height,
      draw: widget.draw,
      on_click: widget.on_click,
      on_hover: widget.on_hover,
      style: widget.style,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.Command do
  @moduledoc """
  A single command entry used by command palette widgets.
  """

  defstruct [
    :id,
    :label,
    :description,
    :shortcut,
    keywords: [],
    disabled: false,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          label: String.t() | nil,
          description: String.t() | nil,
          shortcut: String.t() | nil,
          keywords: [String.t()],
          disabled: boolean(),
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.Command do
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :command,
      id: widget.id,
      label: widget.label,
      description: widget.description,
      shortcut: widget.shortcut,
      keywords: widget.keywords,
      disabled: widget.disabled,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.CommandPalette do
  @moduledoc """
  Searchable command palette widget for command discovery and execution.
  """

  alias UnifiedUi.Widgets.Command

  defstruct [
    :id,
    :placeholder,
    :trigger_shortcut,
    :on_select,
    :style,
    commands: [],
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          commands: [Command.t()],
          placeholder: String.t() | nil,
          trigger_shortcut: String.t() | nil,
          on_select: atom() | {atom(), map()} | nil,
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.CommandPalette do
  def children(%UnifiedUi.Widgets.CommandPalette{commands: commands}) when is_list(commands),
    do: commands

  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :command_palette,
      id: widget.id,
      placeholder: widget.placeholder,
      trigger_shortcut: widget.trigger_shortcut,
      on_select: widget.on_select,
      style: widget.style,
      visible: widget.visible
    }
  end
end
