port module Main exposing (..)

import Browser
import Html exposing (Html, text, pre)
import Html.Events exposing (onClick)
import Http
import Json.Encode as JE


-- PORTS


port audio : (String -> msg) -> Sub msg


port toot : String -> Cmd msg



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
    | Success String
    | Initial


init : () -> ( Model, Cmd Msg )
init _ =
    ( Initial
    , Cmd.none
    )



-- UPDATE


type Msg
    = GotText (Result Http.Error String)
    | ProcessAudio String
    | SendAudio


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotText result ->
            case result of
                Ok fullText ->
                    ( Success fullText, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        ProcessAudio string ->
            ( Initial, Cmd.none )

        SendAudio ->
            ( Initial, toot "butt" )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ audio ProcessAudio
        ]



-- VIEW


buttons : Html Msg
buttons =
    Html.button [ onClick SendAudio ] [ text "toot?" ]


view : Model -> Html Msg
view model =
    case model of
        Initial ->
            buttons

        Failure ->
            text "I was unable to load your book."

        Loading ->
            text "Loading..."

        Success fullText ->
            pre [] [ text fullText ]
