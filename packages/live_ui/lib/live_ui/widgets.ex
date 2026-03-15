defmodule LiveUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for native widget modules.
  """

  @type family :: :content | :input | :navigation | :feedback | :layout | :overlay

  @type widget_module :: module()

  @spec families() :: [family()]
  def families do
    [:content, :input, :navigation, :feedback, :layout, :overlay]
  end

  @spec modules() :: [widget_module()]
  def modules do
    foundational_modules() ++ input_modules() ++ navigation_modules()
  end

  @spec metadata() :: [LiveUi.Component.Metadata.t()]
  def metadata do
    Enum.map(modules(), &LiveUi.Component.metadata/1)
  end

  @spec foundational_modules() :: [widget_module()]
  def foundational_modules do
    LiveUi.Widgets.Foundational.modules()
  end

  @spec input_modules() :: [widget_module()]
  def input_modules do
    LiveUi.Widgets.Input.modules()
  end

  @spec navigation_modules() :: [widget_module()]
  def navigation_modules do
    LiveUi.Widgets.Navigation.modules()
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
