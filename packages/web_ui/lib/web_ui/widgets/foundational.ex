defmodule WebUi.Widgets.Foundational do
  @moduledoc """
  Foundational native widgets for web_ui.

  This module provides core content and action widgets that can be used
  directly in web_ui applications. These widgets correspond to the
  foundational widget kinds in UnifiedIUR.

  ## Creating Widgets

  Use `WebUi.Widgets.Native.Widget.create/2` or `Widget.create/3` to create widget instances:

      {:ok, text_widget} = Widget.create(WebUi.Widgets.Foundational.Text, %{value: "Hello"})

      {:ok, button_widget} = Widget.create(WebUi.Widgets.Foundational.Button, %{label: "Click me"})

  ## Available Widgets

  ### Content Widgets
    * `WebUi.Widgets.Foundational.Text` - Text display
    * `WebUi.Widgets.Foundational.Label` - Accessible label
    * `WebUi.Widgets.Foundational.Icon` - Icon display
    * `WebUi.Widgets.Foundational.Image` - Image display

  ### Action Widgets
    * `WebUi.Widgets.Foundational.Button` - Clickable button
    * `WebUi.Widgets.Foundational.Link` - Navigation link

  ### Layout Widgets
    * `WebUi.Widgets.Foundational.Separator` - Horizontal separator
    * `WebUi.Widgets.Foundational.Spacer` - Vertical spacer
    * `WebUi.Widgets.Foundational.Content` - Content container
  """

  @doc "List all available foundational widget modules"
  def widgets do
    [
      WebUi.Widgets.Foundational.Text,
      WebUi.Widgets.Foundational.Label,
      WebUi.Widgets.Foundational.Icon,
      WebUi.Widgets.Foundational.Image,
      WebUi.Widgets.Foundational.Button,
      WebUi.Widgets.Foundational.Link,
      WebUi.Widgets.Foundational.Separator,
      WebUi.Widgets.Foundational.Spacer,
      WebUi.Widgets.Foundational.Content
    ]
  end
end
