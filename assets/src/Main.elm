port module Main exposing (main)

import Browser
import Html exposing (Html, button, code, div, h1, h2, input, li, p, span, text, ul)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode


port sendRuntimeCommand : Encode.Value -> Cmd msg


port runtimeEventReceived : (Decode.Value -> msg) -> Sub msg


type ConnectionState
    = Connecting
    | Connected
    | Errored


type alias RuntimeContext =
    { correlationId : String
    , requestId : String
    , topic : String
    }


type alias ViewState =
    { screen : String
    , uiError : Maybe String
    , notices : List String
    , lastEvent : Maybe String
    }


type alias Model =
    { connectionState : ConnectionState
    , runtimeContext : RuntimeContext
    , viewState : ViewState
    , count : Int
    , inputText : String
    , outboundQueue : List String
    }


type alias RuntimeEvent =
    { eventName : String
    , payload : Maybe Decode.Value
    , errorCode : Maybe String
    }


type Msg
    = RuntimeEventReceived Decode.Value
    | Increment
    | InputChanged String
    | RetryBootstrap


serverEventNames : List String
serverEventNames =
    [ "runtime.event.recv.v1"
    , "runtime.event.error.v1"
    , "runtime.event.pong.v1"
    ]


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { connectionState = Connecting
            , runtimeContext =
                { correlationId = "corr-local-dev"
                , requestId = "req-local-dev"
                , topic = "webui:runtime:v1"
                }
            , viewState =
                { screen = "connecting"
                , uiError = Nothing
                , notices = [ "bootstrap:started" ]
                , lastEvent = Nothing
                }
            , count = 0
            , inputText = ""
            , outboundQueue = []
            }
    in
    ( model, bootstrapCommands model.runtimeContext )


bootstrapCommands : RuntimeContext -> Cmd Msg
bootstrapCommands runtimeContext =
    Cmd.batch
        [ sendCommand (joinCommand runtimeContext.topic)
        , sendCommand (pingCommand runtimeContext)
        ]


sendCommand : Encode.Value -> Cmd Msg
sendCommand payload =
    sendRuntimeCommand payload


joinCommand : String -> Encode.Value
joinCommand topic =
    Encode.object
        [ ( "kind", Encode.string "ws_join" )
        , ( "topic", Encode.string topic )
        , ( "expected_events", Encode.list Encode.string serverEventNames )
        ]


pingCommand : RuntimeContext -> Encode.Value
pingCommand runtimeContext =
    Encode.object
        [ ( "kind", Encode.string "ws_push" )
        , ( "event_name", Encode.string "runtime.event.ping.v1" )
        , ( "payload"
          , Encode.object
                [ ( "correlation_id", Encode.string runtimeContext.correlationId )
                , ( "request_id", Encode.string runtimeContext.requestId )
                ]
          )
        ]


widgetEventCommand : Model -> Encode.Value
widgetEventCommand model =
    Encode.object
        [ ( "kind", Encode.string "ws_push" )
        , ( "event_name", Encode.string "runtime.event.send.v1" )
        , ( "payload"
          , Encode.object
                [ ( "event"
                  , Encode.object
                        [ ( "specversion", Encode.string "1.0" )
                        , ( "id", Encode.string "elm-local-event" )
                        , ( "source", Encode.string "web_ui/assets" )
                        , ( "type", Encode.string "unified.button.clicked" )
                        , ( "data"
                          , Encode.object
                                [ ( "widget_id", Encode.string "elm-counter" )
                                , ( "action", Encode.string "increment" )
                                , ( "count", Encode.int model.count )
                                , ( "input", Encode.string model.inputText )
                                ]
                          )
                        , ( "correlation_id", Encode.string model.runtimeContext.correlationId )
                        , ( "request_id", Encode.string model.runtimeContext.requestId )
                        ]
                  )
                ]
          )
        ]


runtimeEventDecoder : Decode.Decoder RuntimeEvent
runtimeEventDecoder =
    Decode.map3 RuntimeEvent
        (Decode.field "event_name" Decode.string)
        (Decode.maybe (Decode.field "payload" Decode.value))
        (Decode.maybe (Decode.at [ "payload", "error", "error_code" ] Decode.string))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RuntimeEventReceived raw ->
            applyRuntimeEvent raw model

        Increment ->
            let
                updated =
                    { model | count = model.count + 1 }
            in
            ( recordOutboundEvent "runtime.event.send.v1" updated
            , sendCommand (widgetEventCommand updated)
            )

        InputChanged newValue ->
            ( { model | inputText = newValue }, Cmd.none )

        RetryBootstrap ->
            let
                currentViewState =
                    model.viewState

                retried =
                    { model
                        | connectionState = Connecting
                        , viewState =
                            { currentViewState
                                | screen = "connecting"
                                , uiError = Nothing
                            }
                    }
            in
            ( appendNotice "bootstrap:retry" retried
            , bootstrapCommands retried.runtimeContext
            )


applyRuntimeEvent : Decode.Value -> Model -> ( Model, Cmd Msg )
applyRuntimeEvent raw model =
    case Decode.decodeValue runtimeEventDecoder raw of
        Ok runtimeEvent ->
            handleRuntimeEvent runtimeEvent model

        Err _ ->
            ( setRuntimeError "runtime.event.decode_failed" model, Cmd.none )


handleRuntimeEvent : RuntimeEvent -> Model -> ( Model, Cmd Msg )
handleRuntimeEvent runtimeEvent model =
    case runtimeEvent.eventName of
        "runtime.event.pong.v1" ->
            ( model
                |> setConnected
                |> appendNotice "transport:pong"
                |> setLastEvent runtimeEvent.eventName
            , Cmd.none
            )

        "runtime.event.recv.v1" ->
            ( model
                |> appendNotice "runtime:event:recv"
                |> setLastEvent runtimeEvent.eventName
            , Cmd.none
            )

        "runtime.event.error.v1" ->
            let
                errorCode =
                    Maybe.withDefault "runtime.unknown_error" runtimeEvent.errorCode
            in
            ( setRuntimeError errorCode model
                |> setLastEvent runtimeEvent.eventName
            , Cmd.none
            )

        _ ->
            ( model
                |> appendNotice ("runtime:event:ignored:" ++ runtimeEvent.eventName)
                |> setLastEvent runtimeEvent.eventName
            , Cmd.none
            )


setConnected : Model -> Model
setConnected model =
    let
        currentViewState =
            model.viewState
    in
    { model
        | connectionState = Connected
        , viewState =
            { currentViewState
                | screen = "ready"
                , uiError = Nothing
            }
    }


setRuntimeError : String -> Model -> Model
setRuntimeError errorCode model =
    let
        currentViewState =
            model.viewState
    in
    { model
        | connectionState = Errored
        , viewState =
            { currentViewState
                | screen = "error"
                , uiError = Just errorCode
            }
    }


setLastEvent : String -> Model -> Model
setLastEvent eventName model =
    let
        currentViewState =
            model.viewState
    in
    { model
        | viewState =
            { currentViewState
                | lastEvent = Just eventName
            }
    }


appendNotice : String -> Model -> Model
appendNotice notice model =
    let
        currentViewState =
            model.viewState
    in
    { model
        | viewState =
            { currentViewState
                | notices = notice :: currentViewState.notices
            }
    }


recordOutboundEvent : String -> Model -> Model
recordOutboundEvent eventName model =
    { model
        | outboundQueue = eventName :: model.outboundQueue
    }


statusLabel : ConnectionState -> String
statusLabel state =
    case state of
        Connecting ->
            "connecting"

        Connected ->
            "connected"

        Errored ->
            "error"


statusBadgeClass : ConnectionState -> String
statusBadgeClass state =
    case state of
        Connecting ->
            "badge badge-warning"

        Connected ->
            "badge badge-success"

        Errored ->
            "badge badge-error"


view : Model -> Html Msg
view model =
    let
        latestNotices =
            model.viewState.notices
                |> List.take 5
    in
    div [ class "min-h-screen bg-base-200 p-8" ]
        [ div [ class "mx-auto max-w-4xl space-y-6" ]
            [ div [ class "hero rounded-box bg-base-100 shadow-xl" ]
                [ div [ class "hero-content text-center" ]
                    [ div [ class "max-w-2xl space-y-4" ]
                        [ span [ class "badge badge-primary badge-outline" ] [ text "Elm Runtime Bridge" ]
                        , h1 [ class "text-4xl font-bold" ] [ text "WebUi Transport Dev Harness" ]
                        , p [ class "text-base-content/70" ]
                            [ text "This Elm app emits runtime commands through ports and receives simulated transport events from JS." ]
                        ]
                    ]
                ]
            , div [ class "grid gap-6 md:grid-cols-2" ]
                [ div [ class "card bg-base-100 shadow-lg" ]
                    [ div [ class "card-body gap-4" ]
                        [ h2 [ class "card-title" ] [ text "Runtime Status" ]
                        , div [ class "flex items-center gap-3" ]
                            [ span [ class (statusBadgeClass model.connectionState) ] [ text (statusLabel model.connectionState) ]
                            , span [ class "text-sm text-base-content/70" ] [ text ("screen=" ++ model.viewState.screen) ]
                            ]
                        , p [ class "text-sm" ] [ text ("topic=" ++ model.runtimeContext.topic) ]
                        , p [ class "text-sm" ]
                            [ text
                                ("last_event="
                                    ++ Maybe.withDefault "none" model.viewState.lastEvent
                                )
                            ]
                        , case model.viewState.uiError of
                            Nothing ->
                                text ""

                            Just errorCode ->
                                div [ class "alert alert-error text-sm" ]
                                    [ text ("error=" ++ errorCode) ]
                        , button [ class "btn btn-outline btn-sm", onClick RetryBootstrap ] [ text "Retry Bootstrap" ]
                        ]
                    ]
                , div [ class "card bg-base-100 shadow-lg" ]
                    [ div [ class "card-body gap-4" ]
                        [ h2 [ class "card-title" ] [ text "Widget Dispatch" ]
                        , input
                            [ type_ "text"
                            , class "input input-bordered w-full"
                            , placeholder "Type payload data"
                            , value model.inputText
                            , onInput InputChanged
                            ]
                            []
                        , div [ class "flex items-center gap-3" ]
                            [ button [ class "btn btn-primary", onClick Increment ] [ text "Dispatch Event" ]
                            , code [ class "text-sm" ] [ text ("count=" ++ String.fromInt model.count) ]
                            ]
                        , p [ class "text-xs text-base-content/70" ]
                            [ text "Dispatch emits runtime.event.send.v1 through sendRuntimeCommand port." ]
                        ]
                    ]
                ]
            , div [ class "card bg-base-100 shadow-lg" ]
                [ div [ class "card-body" ]
                    [ h2 [ class "card-title" ] [ text "Recent Notices" ]
                    , ul [ class "menu menu-sm bg-base-200 rounded-box" ]
                        (List.map (\notice -> li [] [ text notice ]) latestNotices)
                    ]
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    runtimeEventReceived RuntimeEventReceived


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
