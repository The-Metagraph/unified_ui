module Main exposing (main)

{-| Main entrypoint for web_ui Elm frontend.

This module provides the boot process and initial runtime setup
for the web_ui Elm application.

-}


import Browser
import Json.Decode as Decode
import Json.Encode as Encode
import WebUi.Elm.Runtime as Runtime



-- MAIN


main : Program Encode.Value Runtime.Model Runtime.Msg
main =
    Browser.element
        { init = Runtime.init
        , update = Runtime.update
        , view = Runtime.view
        , subscriptions = Runtime.subscriptions
        }
