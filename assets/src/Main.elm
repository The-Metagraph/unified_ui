module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, input, p, span, text)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick)


type alias Model =
    { count : Int
    }


type Msg
    = Increment


init : () -> ( Model, Cmd Msg )
init _ =
    ( { count = 0 }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "min-h-screen p-8" ]
        [ div [ class "mx-auto max-w-3xl space-y-6" ]
            [ div [ class "hero rounded-box bg-base-100 shadow-xl" ]
                [ div [ class "hero-content text-center" ]
                    [ div [ class "max-w-xl space-y-4" ]
                        [ span [ class "badge badge-primary badge-outline" ] [ text "Elm + Tailwind + DaisyUI" ]
                        , h1 [ class "text-4xl font-bold" ] [ text "Web UI Starter" ]
                        , p [ class "text-base-content/70" ]
                            [ text "This Elm view uses DaisyUI component classes and Tailwind utilities." ]
                        ]
                    ]
                ]
            , div [ class "card bg-base-100 shadow-lg" ]
                [ div [ class "card-body gap-4" ]
                    [ div [ class "form-control" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Type here"
                            , class "input input-bordered w-full"
                            ]
                            []
                        ]
                    , div [ class "flex items-center gap-3" ]
                        [ button [ class "btn btn-primary", onClick Increment ] [ text "Click" ]
                        , span [ class "font-mono text-sm" ]
                            [ text ("count=" ++ String.fromInt model.count) ]
                        ]
                    ]
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
