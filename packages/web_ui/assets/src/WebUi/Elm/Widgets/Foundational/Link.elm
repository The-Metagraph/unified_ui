module WebUi.Elm.Widgets.Foundational.Link exposing (view)

{-| Link widget for web_ui Elm frontend.

This module provides the view rendering for the native link widget.
-}

import Html exposing (Html, a, text)
import Html.Attributes exposing (class, href)


view : { label : String, target : String } -> Html msg
view props =
    a [ href props.target, class "webui-link" ]
        [ text props.label
        ]
