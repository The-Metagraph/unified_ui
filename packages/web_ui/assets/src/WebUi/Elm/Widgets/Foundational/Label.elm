module WebUi.Elm.Widgets.Foundational.Label exposing (view)

{-| Label widget for web_ui Elm frontend.

This module provides the view rendering for the native label widget.
-}

import Html exposing (Html, label, text)
import Html.Attributes exposing (class, for)


view : { value : String, htmlFor : Maybe String } -> Html msg
view props =
    label
        (class "webui-label" :: maybeFor props.htmlFor)
        [ text props.value
        ]


maybeFor : Maybe String -> List (Html.Attribute msg)
maybeFor htmlFor =
    case htmlFor of
        Just id ->
            [ for id ]

        Nothing ->
            []
