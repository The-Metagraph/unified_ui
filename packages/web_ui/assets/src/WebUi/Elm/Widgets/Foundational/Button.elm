module WebUi.Elm.Widgets.Foundational.Button exposing (view)

{-| Button widget for web_ui Elm frontend.

This module provides the view rendering for the native button widget.
-}

import Html exposing (Html, button, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


view :
    { label : String
    , onClick : Maybe msg
    }
    -> Html msg
view props =
    case props.onClick of
        Just onClickMsg ->
            button [ class "webui-button", onClick onClickMsg ]
                [ text props.label
                ]

        Nothing ->
            button [ class "webui-button", Html.Attributes.disabled True ]
                [ text props.label
                ]
