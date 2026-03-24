defmodule DesktopUi.Widget do
  @moduledoc """
  Native renderer-facing widget representation for `desktop_ui`.
  """

  @type family :: :content | :action | :layout | :input | :navigation | :feedback | :window

  @type t :: %__MODULE__{
          id: String.t() | atom() | nil,
          family: family(),
          kind: atom(),
          metadata: map(),
          state: map(),
          slots: [atom() | String.t()],
          slot_children: %{optional(atom() | String.t()) => [t()]},
          styles: map(),
          events: map(),
          children: [t()]
        }

  defstruct id: nil,
            family: :content,
            kind: :text,
            metadata: %{},
            state: %{},
            slots: [:default],
            slot_children: %{},
            styles: %{},
            events: %{},
            children: []

  @spec contract() :: map()
  def contract do
    %{
      metadata: [:label, :description, :role, :variant, :focusable, :window_role, :shortcut],
      state: [:disabled, :focused, :open, :active, :selected],
      slots: [:default, :header, :content, :footer, :overlay],
      styles: [:fg, :bg, :padding, :border, :theme, :variant],
      events: [:click, :focus, :blur, :shortcut, :close, :resize]
    }
  end

  @spec family_for(atom()) :: family()
  def family_for(kind) when kind in [:window, :dialog], do: :window
  def family_for(kind) when kind in [:column, :row, :stack], do: :layout
  def family_for(kind) when kind in [:button], do: :action
  def family_for(kind) when kind in [:text_input], do: :input
  def family_for(kind) when kind in [:menu], do: :navigation
  def family_for(kind) when kind in [:status], do: :feedback
  def family_for(_kind), do: :content
end
