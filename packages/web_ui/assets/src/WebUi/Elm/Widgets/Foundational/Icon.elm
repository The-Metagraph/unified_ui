module WebUi.Elm.Widgets.Foundational.Icon exposing (view)

{-| Icon widget for web_ui Elm frontend.

This module provides the view rendering for the native icon widget.
-}

import Html exposing (Html, i, text)
import Html.Attributes exposing (class)


view : { name : String } -> Html msg
view props =
    i [ class "webui-icon" ]
        [ text props.name
        ]
