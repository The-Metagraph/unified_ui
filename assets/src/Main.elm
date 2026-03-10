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
    , sessionId : Maybe String
    , clientId : Maybe String
    , userId : Maybe String
    , traceId : Maybe String
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


canonicalWidgetEventTypes : List String
canonicalWidgetEventTypes =
    [ "unified.action.requested"
    , "unified.button.clicked"
    , "unified.canvas.pointer.changed"
    , "unified.chart.point_hovered"
    , "unified.chart.point_selected"
    , "unified.command.executed"
    , "unified.element.blurred"
    , "unified.element.focused"
    , "unified.form.submitted"
    , "unified.input.changed"
    , "unified.item.selected"
    , "unified.item.toggled"
    , "unified.link.clicked"
    , "unified.menu.action_selected"
    , "unified.overlay.closed"
    , "unified.overlay.confirmed"
    , "unified.scroll.changed"
    , "unified.split.collapse_changed"
    , "unified.split.resized"
    , "unified.tab.changed"
    , "unified.tab.closed"
    , "unified.table.row_selected"
    , "unified.table.sorted"
    , "unified.toast.cleared"
    , "unified.toast.dismissed"
    , "unified.tree.node_selected"
    , "unified.tree.node_toggled"
    , "unified.view.changed"
    , "unified.viewport.resized"
    ]


canonicalWidgetEventPayloadKeys : List String
canonicalWidgetEventPayloadKeys =
    [ "action"
    , "action_id"
    , "button_id"
    , "collapsed"
    , "column"
    , "command_id"
    , "direction"
    , "expanded"
    , "field"
    , "form_id"
    , "href"
    , "id"
    , "index"
    , "input_id"
    , "item_id"
    , "node_id"
    , "pane_id"
    , "panes"
    , "phase"
    , "point"
    , "position"
    , "row_index"
    , "route_family"
    , "route_keys"
    , "selected"
    , "series"
    , "tab_id"
    , "toast_id"
    , "value"
    , "view"
    , "widget_id"
    , "width"
    , "height"
    , "x"
    , "y"
    ]


canonicalRouteKeyRequirements : List ( String, List String )
canonicalRouteKeyRequirements =
    [ ( "click", [ "action", "button_id", "widget_id", "id" ] )
    , ( "change", [ "input_id", "widget_id", "field", "action", "id" ] )
    , ( "submit", [ "form_id", "action", "id" ] )
    ]


canonicalWidgetEventRouteFamilies : List ( String, String )
canonicalWidgetEventRouteFamilies =
    [ ( "unified.action.requested", "click" )
    , ( "unified.button.clicked", "click" )
    , ( "unified.canvas.pointer.changed", "change" )
    , ( "unified.chart.point_hovered", "selection" )
    , ( "unified.chart.point_selected", "selection" )
    , ( "unified.command.executed", "click" )
    , ( "unified.element.blurred", "focus" )
    , ( "unified.element.focused", "focus" )
    , ( "unified.form.submitted", "submit" )
    , ( "unified.input.changed", "change" )
    , ( "unified.item.selected", "selection" )
    , ( "unified.item.toggled", "selection" )
    , ( "unified.link.clicked", "click" )
    , ( "unified.menu.action_selected", "click" )
    , ( "unified.overlay.closed", "click" )
    , ( "unified.overlay.confirmed", "click" )
    , ( "unified.scroll.changed", "change" )
    , ( "unified.split.collapse_changed", "change" )
    , ( "unified.split.resized", "change" )
    , ( "unified.tab.changed", "selection" )
    , ( "unified.tab.closed", "click" )
    , ( "unified.table.row_selected", "selection" )
    , ( "unified.table.sorted", "click" )
    , ( "unified.toast.cleared", "click" )
    , ( "unified.toast.dismissed", "click" )
    , ( "unified.tree.node_selected", "selection" )
    , ( "unified.tree.node_toggled", "selection" )
    , ( "unified.view.changed", "change" )
    , ( "unified.viewport.resized", "change" )
    ]


defaultWidgetEventType : String
defaultWidgetEventType =
    case canonicalWidgetEventTypes of
        firstType :: _ ->
            firstType

        [] ->
            "unified.button.clicked"


defaultWidgetEventRequiredAllOf : List String
defaultWidgetEventRequiredAllOf =
    [ "widget_id"
    , "action"
    ]


defaultWidgetEventRequiredAnyOf : List (List String)
defaultWidgetEventRequiredAnyOf =
    []


defaultWidgetEventRouteFamily : String
defaultWidgetEventRouteFamily =
    routeFamilyForEventType defaultWidgetEventType
        |> Maybe.withDefault "click"


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { connectionState = Connecting
            , runtimeContext =
                { correlationId = "corr-local-dev"
                , requestId = "req-local-dev"
                , topic = "webui:runtime:v1"
                , sessionId = Just "session-local-dev"
                , clientId = Just "client-local-dev"
                , userId = Nothing
                , traceId = Just "trace-local-dev"
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
        , ( "payload", Encode.object (runtimeContextFields runtimeContext) )
        ]


widgetEventCommand : Model -> Encode.Value
widgetEventCommand model =
    let
        cloudEvent =
            cloudEventEnvelope model
    in
    Encode.object
        [ ( "kind", Encode.string "ws_push" )
        , ( "event_name", Encode.string "runtime.event.send.v1" )
        , ( "payload"
          , Encode.object
                [ ( "event"
                  , cloudEvent
                  )
                ]
          )
        ]


cloudEventEnvelope : Model -> Encode.Value
cloudEventEnvelope model =
    Encode.object
        ([ ( "specversion", Encode.string "1.0" )
         , ( "id", Encode.string (nextEventId model) )
         , ( "source", Encode.string "web_ui/assets" )
         , ( "type", Encode.string defaultWidgetEventType )
         , ( "data", widgetEventData model )
         ]
            ++ runtimeContextFields model.runtimeContext
        )


widgetEventData : Model -> Encode.Value
widgetEventData model =
    Encode.object
        (requiredWidgetEventDataFields model
            ++ requiredWidgetEventAnyOfFields model
            ++ routeFamilyCompatibilityFields model
            ++ routeFamilyContinuityFields model
            ++ optionalWidgetEventDataFields model
        )


requiredWidgetEventDataFields : Model -> List ( String, Encode.Value )
requiredWidgetEventDataFields model =
    List.filterMap (widgetEventContractValue model) defaultWidgetEventRequiredAllOf


requiredWidgetEventAnyOfFields : Model -> List ( String, Encode.Value )
requiredWidgetEventAnyOfFields model =
    case defaultWidgetEventRequiredAnyOf of
        firstGroup :: _ ->
            case List.filterMap (widgetEventContractValue model) firstGroup of
                field :: _ ->
                    [ field ]

                [] ->
                    []

        [] ->
            []


optionalWidgetEventDataFields : Model -> List ( String, Encode.Value )
optionalWidgetEventDataFields model =
    [ ( "count", Encode.int model.count )
    , ( "input", Encode.string model.inputText )
    ]


routeFamilyCompatibilityFields : Model -> List ( String, Encode.Value )
routeFamilyCompatibilityFields model =
    routeFamilyRequirementKeys defaultWidgetEventRouteFamily
        |> List.filterMap (routeFamilyRequirementValue model)


routeFamilyRequirementValue : Model -> String -> Maybe ( String, Encode.Value )
routeFamilyRequirementValue model key =
    case routeKeyContractValue model key of
        Just field ->
            Just field

        Nothing ->
            widgetEventContractValue model key


routeFamilyRequirementKeys : String -> List String
routeFamilyRequirementKeys routeFamily =
    canonicalRouteKeyRequirements
        |> List.filter (\( family, _ ) -> family == routeFamily)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault []


routeFamilyForEventType : String -> Maybe String
routeFamilyForEventType eventType =
    canonicalWidgetEventRouteFamilies
        |> List.filter (\( eventName, _ ) -> eventName == eventType)
        |> List.head
        |> Maybe.map Tuple.second


routeFamilyContinuityFields : Model -> List ( String, Encode.Value )
routeFamilyContinuityFields model =
    [ ( "route_family", Encode.string defaultWidgetEventRouteFamily )
    , ( "route_keys", Encode.list Encode.string (declaredRouteKeys model) )
    ]


declaredRouteKeys : Model -> List String
declaredRouteKeys model =
    routeFamilyRequirementKeys defaultWidgetEventRouteFamily
        |> List.foldl (appendIfRouteKeyPopulated model) []
        |> List.reverse


appendIfRouteKeyPopulated : Model -> String -> List String -> List String
appendIfRouteKeyPopulated model key acc =
    if isRouteKeyPopulated model key then
        key :: acc

    else
        acc


isRouteKeyPopulated : Model -> String -> Bool
isRouteKeyPopulated model key =
    case widgetEventContractValue model key of
        Just _ ->
            True

        Nothing ->
            case routeKeyContractValue model key of
                Just _ ->
                    True

                Nothing ->
                    False


routeKeyContractValue : Model -> String -> Maybe ( String, Encode.Value )
routeKeyContractValue model key =
    case key of
        "button_id" ->
            Just ( key, Encode.string "elm-counter-increment-button" )

        "id" ->
            Just ( key, Encode.string ("elm-counter-route-" ++ String.fromInt model.count) )

        "input_id" ->
            Just ( key, Encode.string "elm-counter-input" )

        "field" ->
            Just ( key, Encode.string "input" )

        "form_id" ->
            Just ( key, Encode.string "elm-counter-form" )

        _ ->
            Nothing


widgetEventContractValue : Model -> String -> Maybe ( String, Encode.Value )
widgetEventContractValue model key =
    if List.member key canonicalWidgetEventPayloadKeys then
        case key of
            "widget_id" ->
                Just ( key, Encode.string "elm-counter" )

            "action" ->
                Just ( key, Encode.string "increment" )

            "button_id" ->
                Just ( key, Encode.string "elm-counter-increment-button" )

            "input_id" ->
                Just ( key, Encode.string "elm-counter-input" )

            "form_id" ->
                Just ( key, Encode.string "elm-counter-form" )

            "value" ->
                Just ( key, Encode.string model.inputText )

            _ ->
                Nothing

    else
        Nothing


nextEventId : Model -> String
nextEventId model =
    "elm-local-event-" ++ String.fromInt model.count


runtimeContextFields : RuntimeContext -> List ( String, Encode.Value )
runtimeContextFields runtimeContext =
    runtimeContextRequiredFields runtimeContext
        ++ runtimeContextOptionalFields runtimeContext


runtimeContextRequiredFields : RuntimeContext -> List ( String, Encode.Value )
runtimeContextRequiredFields runtimeContext =
    [ ( "correlation_id", Encode.string runtimeContext.correlationId )
    , ( "request_id", Encode.string runtimeContext.requestId )
    ]


runtimeContextOptionalFields : RuntimeContext -> List ( String, Encode.Value )
runtimeContextOptionalFields runtimeContext =
    optionalContextField "session_id" runtimeContext.sessionId
        ++ optionalContextField "client_id" runtimeContext.clientId
        ++ optionalContextField "user_id" runtimeContext.userId
        ++ optionalContextField "trace_id" runtimeContext.traceId


optionalContextField : String -> Maybe String -> List ( String, Encode.Value )
optionalContextField key maybeValue =
    case maybeValue of
        Just value ->
            [ ( key, Encode.string value ) ]

        Nothing ->
            []


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
