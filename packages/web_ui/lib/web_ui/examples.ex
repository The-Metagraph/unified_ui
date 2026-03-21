defmodule WebUi.Examples do
  @moduledoc """
  Maintained direct-native and canonical example inputs for `web_ui`.
  """

  alias UnifiedIUR.Element
  alias WebUi.Widgets

  @spec native_counter_screen() :: map()
  def native_counter_screen do
    Widgets.screen(:native_counter, "Native Counter", [
      Widgets.text(:count, "0", styles: %{tone: :accent}),
      Widgets.button(:increment, "Increment",
        on_click: %{family: :click, intent: :increment, boundary: :local}
      )
    ])
  end

  @spec canonical_welcome_screen() :: Element.t()
  def canonical_welcome_screen do
    Element.new(:widget, :text,
      id: :welcome_message,
      attributes: %{content: "Welcome to web_ui"}
    )
  end

  @spec comparison_examples() :: map()
  def comparison_examples do
    %{
      native: native_counter_screen(),
      canonical: canonical_welcome_screen()
    }
  end
end
