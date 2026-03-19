module WebUi.Elm.Runtime exposing (Model, Msg, init, update, view, subscriptions)

{-| Runtime module for web_ui Elm frontend.

This module provides the core runtime model, update loop, and
view rendering for the Elm application.

It renders foundational widgets based on the view state provided
by the server.

-}

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, id, style, type_)
import Json.Decode as Decode
import Json.Encode as Encode
import WebUi.Elm.Widgets.Foundational.Button
import WebUi.Elm.Widgets.Foundational.Content
import WebUi.Elm.Widgets.Foundational.Icon
import WebUi.Elm.Widgets.Foundational.Image
import WebUi.Elm.Widgets.Foundational.Label
import WebUi.Elm.Widgets.Foundational.Link
import WebUi.Elm.Widgets.Foundational.Separator
import WebUi.Elm.Widgets.Foundational.Spacer
import WebUi.Elm.Widgets.Foundational.Text



-- MODEL


type alias Model =
    { hydration : HydrationState
    , viewState : Maybe ViewState
    , ready : Bool
    , focus : Maybe String
    }


type alias HydrationState =
    { schema : Schema
    , version : String
    , checksum : String
    }


type alias Schema =
    Encode.Value


type alias ViewState =
    { root : WidgetData
    , widgets : Encode.Value
    , version : String
    }


type alias WidgetData =
    { id : String
    , type_ : String
    , props : Encode.Value
    , state : Encode.Value
    , slots : Encode.Value
    , styles : Encode.Value
    , events : Encode.Value
    }



-- INIT


init : Encode.Value -> ( Model, Cmd Msg )
init flags =
    case decodeHydration flags of
        Ok hydration ->
            ( { hydration = hydration
              , viewState = Nothing
              , ready = True
              , focus = Nothing
              }
            , Cmd.none
            )

        Err _ ->
            ( { hydration = emptyHydration()
              , viewState = Nothing
              , ready = False
              , focus = Nothing
              }
            , Cmd.none
            )



-- UPDATE


type Msg
    = NoOp
    | ReceiveServerUpdate String
    | SetFocus (Maybe String)
    | FocusWidget String
    | BlurWidget String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ReceiveServerUpdate json ->
            case Decode.decodeString viewStateDecoder json of
                Ok viewState ->
                    ( { model | viewState = Just viewState }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        SetFocus maybeId ->
            ( { model | focus = maybeId }
            , Cmd.none
            )

        FocusWidget widgetId ->
            ( { model | focus = Just widgetId }
            , Cmd.none
            )

        BlurWidget _widgetId ->
            ( { model | focus = Nothing }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    if model.ready then
        case model.viewState of
            Just viewState ->
                div
                    [ class "webui-runtime"
                    , id "webui-root"
                    ]
                    [ renderWidget viewState.root
                    ]

            Nothing ->
                div [ class "webui-runtime-loading" ]
                    [ text "Loading WebUi runtime..."
                    ]

    else
        div [ class "webui-runtime-error" ]
            [ text "Failed to initialize WebUi runtime"
            ]


renderWidget : WidgetData -> Html Msg
renderWidget widget =
    case widget.type_ of
        "text" ->
            case decodeTextProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Text.view props

                Nothing ->
                    text "[invalid text widget]"

        "label" ->
            case decodeLabelProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Label.view props

                Nothing ->
                    text "[invalid label widget]"

        "icon" ->
            case decodeIconProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Icon.view props

                Nothing ->
                    text "[invalid icon widget]"

        "image" ->
            case decodeImageProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Image.view props

                Nothing ->
                    text "[invalid image widget]"

        "button" ->
            case decodeButtonProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Button.view
                            { label = props.label
                            , onClick = Just (FocusWidget widget.id)
                            }

                Nothing ->
                    text "[invalid button widget]"

        "link" ->
            case decodeLinkProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Link.view props

                Nothing ->
                    text "[invalid link widget]"

        "separator" ->
            Html.map (\_ -> NoOp) <|
                WebUi.Elm.Widgets.Foundational.Separator.view {}

        "spacer" ->
            case decodeSpacerProps widget.props of
                Just props ->
                    Html.map (\_ -> NoOp) <|
                        WebUi.Elm.Widgets.Foundational.Spacer.view props

                Nothing ->
                    text "[invalid spacer widget]"

        "content" ->
            Html.map (\_ -> NoOp) <|
                WebUi.Elm.Widgets.Foundational.Content.view
                    { children = [ div [] [] ] }

        _ ->
            div [ class "webui-unknown-widget" ]
                [ text ("Unknown widget type: " ++ widget.type_)
                ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- DECODERS


decodeHydration : Encode.Value -> Result Decode.Error HydrationState
decodeHydration value =
    Decode.decodeValue hydrationDecoder value


hydrationDecoder : Decode.Decoder HydrationState
hydrationDecoder =
    Decode.map3 HydrationState
        (Decode.field "schema" Decode.value)
        (Decode.field "version" Decode.string)
        (Decode.field "checksum" Decode.string)


viewStateDecoder : Decode.Decoder ViewState
viewStateDecoder =
    Decode.map3 ViewState
        (Decode.field "root" widgetDataDecoder)
        (Decode.field "widgets" Decode.value)
        (Decode.field "version" Decode.string)


widgetDataDecoder : Decode.Decoder WidgetData
widgetDataDecoder =
    Decode.map7 WidgetData
        (Decode.field "id" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "props" Decode.value)
        (Decode.field "state" Decode.value)
        (Decode.field "slots" Decode.value)
        (Decode.field "styles" Decode.value)
        (Decode.field "events" Decode.value)


decodeTextProps : Encode.Value -> Maybe { value : String }
decodeTextProps value =
    Decode.decodeValue
        (Decode.map (\v -> { value = v })
            (Decode.field "value" Decode.string)
        )
        value
        |> Result.toMaybe


decodeLabelProps : Encode.Value -> Maybe { value : String, htmlFor : Maybe String }
decodeLabelProps value =
    Decode.decodeValue
        (Decode.map2 (\v h -> { value = v, htmlFor = h })
            (Decode.field "value" Decode.string)
            (Decode.maybe (Decode.field "html_for" Decode.string))
        )
        value
        |> Result.toMaybe


decodeIconProps : Encode.Value -> Maybe { name : String }
decodeIconProps value =
    Decode.decodeValue
        (Decode.map (\n -> { name = n })
            (Decode.field "name" Decode.string)
        )
        value
        |> Result.toMaybe


decodeImageProps : Encode.Value -> Maybe { source : String, altText : String }
decodeImageProps value =
    Decode.decodeValue
        (Decode.map2 (\s a -> { source = s, altText = a })
            (Decode.field "source" Decode.string)
            (Decode.field "alt_text" Decode.string)
        )
        value
        |> Result.toMaybe


decodeButtonProps : Encode.Value -> Maybe { label : String }
decodeButtonProps value =
    Decode.decodeValue
        (Decode.map (\l -> { label = l })
            (Decode.field "label" Decode.string)
        )
        value
        |> Result.toMaybe


decodeLinkProps : Encode.Value -> Maybe { label : String, target : String }
decodeLinkProps value =
    Decode.decodeValue
        (Decode.map2 (\l t -> { label = l, target = t })
            (Decode.field "label" Decode.string)
            (Decode.field "target" Decode.string)
        )
        value
        |> Result.toMaybe


decodeSpacerProps : Encode.Value -> Maybe { size : String }
decodeSpacerProps value =
    Decode.decodeValue
        (Decode.map (\s -> { size = s })
            (Decode.field "size" Decode.string)
        )
        value
        |> Result.toMaybe


emptyHydration : HydrationState
emptyHydration =
    { schema = Encode.null
    , version = "0.0.0"
    , checksum = ""
    }
