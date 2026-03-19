module WebUi.Elm.Widgets.Foundational.Image exposing (view)

{-| Image widget for web_ui Elm frontend.

This module provides the view rendering for the native image widget.
-}

import Html exposing (Html, img)
import Html.Attributes exposing (alt, class, src)


view : { source : String, altText : String } -> Html msg
view props =
    img
        [ src props.source
        , alt props.altText
        , class "webui-image"
        ]
        []
