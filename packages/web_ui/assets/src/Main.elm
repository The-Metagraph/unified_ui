module Main exposing (main)

-- Main entrypoint for web_ui Elm frontend
-- This is a placeholder - actual implementation will come in later phases


main : Program () () Msg
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }



type Msg
    = NoOp
