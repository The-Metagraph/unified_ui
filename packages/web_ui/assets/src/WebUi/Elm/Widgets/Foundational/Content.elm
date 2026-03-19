module WebUi.Elm.Widgets.Foundational.Content exposing (view)

{-| Content widget for web_ui Elm frontend.

This module provides the view rendering for the native content container widget.
-}

import Html exposing (Html, div)
import Html.Attributes exposing (class)


view : { children : List (Html msg) } -> Html msg
view props =
    div [ class "webui-content" ]
        props.children
