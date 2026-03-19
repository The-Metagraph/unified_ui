module WebUi.Elm.Widgets.Foundational.Spacer exposing (view)

{-| Spacer widget for web_ui Elm frontend.

This module provides the view rendering for the native spacer widget.
-}

import Html exposing (Html, div)
import Html.Attributes exposing (class, style)


sizeToPixels : String -> String
sizeToPixels size =
    case size of
        "xs" ->
            "4px"

        "sm" ->
            "8px"

        "md" ->
            "16px"

        "lg" ->
            "24px"

        _ ->
            "16px"


view : { size : String } -> Html msg
view props =
    div
        [ class "webui-spacer"
        , style "min-height" (sizeToPixels props.size)
        ]
        []
