module WebUi.Elm.Widgets.Foundational.Separator exposing (view)

{-| Separator widget for web_ui Elm frontend.

This module provides the view rendering for the native separator widget.
-}

import Html exposing (Html, hr)
import Html.Attributes exposing (class)


view : {} -> Html msg
view _ =
    hr [ class "webui-separator" ] []
