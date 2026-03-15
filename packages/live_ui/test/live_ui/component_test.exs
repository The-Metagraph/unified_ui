defmodule LiveUi.ComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "native widget metadata exposes shared assigns contract" do
    metadata = LiveUi.Component.metadata(LiveUi.Widgets.Text)

    assert metadata.family == :content
    assert metadata.name == :text
    assert :id in metadata.assigns
    assert :content in metadata.assigns
  end

  test "function components render through liveview-native boundaries" do
    html =
      render_component(&LiveUi.Widgets.Container.render/1, %{
        id: "root",
        inner_block: [
          %{
            __slot__: :inner_block,
            inner_block: fn _, _ ->
              Phoenix.HTML.raw(
                render_component(&LiveUi.Widgets.Text.render/1, %{
                  id: "greeting",
                  content: "Hello"
                })
              )
            end
          }
        ]
      })

    assert html =~ "data-live-ui-widget=\"container\""
    assert html =~ "data-live-ui-widget=\"text\""
    assert html =~ "Hello"
  end
end
