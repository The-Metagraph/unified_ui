# Elm Binding Examples

These examples show how standard Elm event handlers map to the event catalog.

## Message Shape

```elm
type alias WidgetUiEvent =
    { eventType : String
    , widgetId : String
    , widgetKind : String
    , data : Json.Encode.Value
    }

type Msg
    = WidgetEvent WidgetUiEvent
    | NoOp
```

## Button Click

```elm
Html.button
    [ Html.Events.onClick
        (WidgetEvent
            { eventType = "unified.button.clicked"
            , widgetId = "save_button"
            , widgetKind = "button"
            , data = Json.Encode.object [ ( "action", Json.Encode.string "save" ) ]
            }
        )
    ]
    [ Html.text "Save" ]
```

## Input Change (`onInput`)

```elm
Html.input
    [ Html.Events.onInput
        (\value ->
            WidgetEvent
                { eventType = "unified.input.changed"
                , widgetId = "user_email"
                , widgetKind = "text_input"
                , data =
                    Json.Encode.object
                        [ ( "input_id", Json.Encode.string "user_email" )
                        , ( "value", Json.Encode.string value )
                        ]
                }
        )
    ]
    []
```

## Form Submit (`onSubmit`)

```elm
Html.form
    [ Html.Events.onSubmit
        (WidgetEvent
            { eventType = "unified.form.submitted"
            , widgetId = "login_form"
            , widgetKind = "form"
            , data = Json.Encode.object [ ( "form_id", Json.Encode.string "login_form" ) ]
            }
        )
    ]
    [ ... ]
```

## Custom Keyboard Decode (`on "keydown"`)

```elm
import Json.Decode as D

keyDownDecoder : String -> String -> D.Decoder Msg
keyDownDecoder widgetId widgetKind =
    D.map
        (\key ->
            WidgetEvent
                { eventType = "unified.action.requested"
                , widgetId = widgetId
                , widgetKind = widgetKind
                , data = Json.Encode.object [ ( "action", Json.Encode.string key ) ]
                }
        )
        (D.field "key" D.string)

Html.div
    [ Html.Events.on "keydown" (keyDownDecoder "table_1" "table") ]
    [ ... ]
```

## Window Resize Subscription (`Browser.Events.onResize`)

```elm
subscriptions : model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize
        (\width height ->
            WidgetEvent
                { eventType = "unified.viewport.resized"
                , widgetId = "main_viewport"
                , widgetKind = "viewport"
                , data =
                    Json.Encode.object
                        [ ( "width", Json.Encode.int width )
                        , ( "height", Json.Encode.int height )
                        ]
                }
        )
```

## Mapping Rule

When adding a new widget handler in Elm:

1. Pick an event type from [event_type_catalog.md](/Users/Pascal/code/unified/web_ui/specs/events/event_type_catalog.md).
2. Ensure payload keys satisfy that type's required fields.
3. Ensure `widget_id` and route-key fields are populated for dispatch compatibility.
