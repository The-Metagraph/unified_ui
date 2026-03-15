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
    [
      LiveUi.Widgets.Text,
      LiveUi.Widgets.Container,
      LiveUi.Widgets.ScreenShell
    ]
  end

  @spec metadata() :: [LiveUi.Component.Metadata.t()]
  def metadata do
    Enum.map(modules(), &LiveUi.Component.metadata/1)
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
