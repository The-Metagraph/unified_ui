module WebUi.Elm.Runtime exposing (Model, Msg, init, update, view, subscriptions)

{-| Runtime module for web_ui Elm frontend.

This module provides the core runtime model, update loop, and
view rendering for the Elm application.

-}

import Html exposing (Html, div, text)
import Json.Decode as Decode
import Json.Encode as Encode



-- MODEL


type alias Model =
    { hydration : HydrationState
    , assigns : Assigns
    , ready : Bool
    }


type alias HydrationState =
    { schema : Schema
    , version : String
    , checksum : String
    }


type alias Schema =
    Encode.Value


type alias Assigns =
    Encode.Value



-- INIT


init : Encode.Value -> ( Model, Cmd Msg )
init flags =
    case decodeHydration flags of
        Ok hydration ->
            ( { hydration = hydration
              , assigns = Encode.null
              , ready = True
              }
            , Cmd.none
            )

        Err _ ->
            ( { hydration = emptyHydration()
              , assigns = Encode.null
              , ready = False
              }
            , Cmd.none
            )



-- UPDATE


type Msg
    = NoOp
    | ReceiveServerUpdate String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ReceiveServerUpdate json ->
            case Decode.decodeString Decode.value json of
                Ok updated ->
                    ( { model | assigns = updated }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    if model.ready then
        div []
            [ text "WebUi Elm Runtime"
            , viewDebugInfo model
            ]

    else
        div []
            [ text "Failed to initialize WebUi runtime"
            ]


viewDebugInfo : Model -> Html Msg
viewDebugInfo model =
    div [ Html.Attributes.style "margin-top" "1rem" ]
        [ text <|
            "Version: "
                ++ model.hydration.version
                ++ ", Checksum: "
                ++ String.left 8 model.hydration.checksum
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- HELPERS


decodeHydration : Encode.Value -> Result Decode.Error HydrationState
decodeHydration value =
    Decode.decodeValue hydrationDecoder value


hydrationDecoder : Decode.Decoder HydrationState
hydrationDecoder =
    Decode.map3 HydrationState
        (Decode.field "schema" Decode.value)
        (Decode.field "version" Decode.string)
        (Decode.field "checksum" Decode.string)


emptyHydration : HydrationState
emptyHydration =
    { schema = Encode.null
    , version = "0.0.0"
    , checksum = ""
    }
