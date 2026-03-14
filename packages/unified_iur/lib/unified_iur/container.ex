defmodule UnifiedIUR.Container do
  @moduledoc """
  Canonical content-container constructors for foundational `UnifiedIUR`
  widget composition.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Widgets.Foundational

  @type child_input ::
          Child.t()
          | Element.t()
          | {Child.slot(), Element.t() | nil}
          | %{required(:slot) => Child.slot(), required(:element) => Element.t() | nil}
          | %{required(String.t()) => term()}

  @spec content([child_input()] | keyword(Element.t() | nil), keyword() | map()) :: Element.t()
  def content(children \\ [], opts \\ []) do
    Foundational.content(children, opts)
  end
end
