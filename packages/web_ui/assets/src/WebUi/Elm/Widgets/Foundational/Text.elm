module WebUi.Elm.Widgets.Foundational.Text exposing (view)

{-| Text widget for web_ui Elm frontend.

This module provides the view rendering for the native text widget.
-}

import Html exposing (Html, span, text)
import Html.Attributes exposing (class)


view : { value : String } -> Html msg
view props =
    span [ class "webui-text" ]
        [ text props.value
        ]
