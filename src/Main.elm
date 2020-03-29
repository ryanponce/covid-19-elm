module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, map3)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success WorldStats


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getWorldStats )



-- UPDATE


type Msg
    = GotWorldStats (Result Http.Error WorldStats)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWorldStats result ->
            case result of
                Ok worldStats ->
                    ( Success worldStats, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "COVID-19 World Stats" ]
        , viewWorldStats model
        ]


viewWorldStats : Model -> Html Msg
viewWorldStats model =
    case model of
        Failure ->
            div []
                [ text "Unable to load world stats."
                ]

        Loading ->
            text "Loading..."

        Success worldStats ->
            div []
                [ p [] [ text ("Confirmed: " ++ String.fromInt worldStats.confirmed) ]
                , p [] [ text ("Recovered: " ++ String.fromInt worldStats.recovered) ]
                , p [] [ text ("Deaths: " ++ String.fromInt worldStats.deaths) ]
                ]



-- HTTP


getWorldStats : Cmd Msg
getWorldStats =
    Http.get
        { url = "https://covid19.mathdro.id/api"
        , expect = Http.expectJson GotWorldStats worldStatsDecoder
        }


type alias WorldStats =
    { confirmed : Int
    , recovered : Int
    , deaths : Int
    }


confirmedDecoder : Decoder Int
confirmedDecoder =
    field "confirmed" (field "value" int)


recoveredDecoder : Decoder Int
recoveredDecoder =
    field "recovered" (field "value" int)


deathsDecoder : Decoder Int
deathsDecoder =
    field "deaths" (field "value" int)


worldStatsDecoder : Decoder WorldStats
worldStatsDecoder =
    map3 WorldStats confirmedDecoder recoveredDecoder deathsDecoder
