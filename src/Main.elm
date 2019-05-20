port module Main exposing (..)

import Browser
import Html exposing (Html, text, pre)
import Html.Events exposing (onClick)
import Http
import Json.Encode as JE
import Random


-- PORTS


port audio : (String -> msg) -> Sub msg


port sendAudio : Int -> Cmd msg


port changeGain : Float -> Cmd msg



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
    | Playing TonePair


type alias TonePair =
    { left : Int
    , right : Int
    }


type TonePos
    = Left
    | Right


init : () -> ( Model, Cmd Msg )
init _ =
    ( Initial
    , Cmd.none
    )



-- UPDATE


type Msg
    = GotText (Result Http.Error String)
    | ProcessAudio String
    | SendAudio Int
    | ChangeGain Float
    | GenerateRandomNumber Int
    | UpdateRandomNumber TonePos Int


generateRandomNumber : TonePos -> Int -> Cmd Msg
generateRandomNumber tonePos i =
    Random.generate (UpdateRandomNumber tonePos) (Random.int 1 i)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateRandomNumber i ->
            ( Initial
            , Cmd.batch
                [ generateRandomNumber Left 10
                , generateRandomNumber Right 10
                ]
            )

        UpdateRandomNumber Left f ->
            case model of
                Playing tonePair ->
                    ( Playing (TonePair f tonePair.right)
                    , SendAudio (f * 100)
                    )

                _ ->
                    ( Playing (TonePair f 1)
                    , SendAudio (f * 100)
                    )

        UpdateRandomNumber Right t ->
            case model of
                Playing tonePair ->
                    ( Playing (TonePair tonePair.left t), Cmd.none )

                _ ->
                    ( Playing (TonePair 1 t), Cmd.none )

        GotText result ->
            case result of
                Ok fullText ->
                    ( Success fullText, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        ProcessAudio string ->
            ( Initial, Cmd.none )

        SendAudio f ->
            ( Initial, sendAudio f )

        ChangeGain v ->
            ( Initial, changeGain v )


tonePosToString tonePos =
    case tonePos of
        Left ->
            "left"

        _ ->
            "right"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ audio ProcessAudio
        ]



-- VIEW


buttons : Html Msg
buttons =
    Html.div []
        [ Html.button [ onClick (SendAudio 3) ] [ text "tone 1" ]
        , Html.button [ onClick (SendAudio 4) ] [ text "tone 2" ]
        , Html.button [ onClick (ChangeGain 0.8) ] [ text "loud" ]
        , Html.button [ onClick (ChangeGain 0.1) ] [ text "soft" ]
        , Html.button [ onClick (GenerateRandomNumber 12) ] [ text "next" ]
        ]


view : Model -> Html Msg
view model =
    case model of
        Initial ->
            buttons

        Playing tonePair ->
            Html.div []
                [ buttons
                , Html.div [] [ tonePair.left |> String.fromInt |> text ]
                , Html.div [] [ tonePair.right |> String.fromInt |> text ]
                ]

        Failure ->
            text "I was unable to load your book."

        Loading ->
            text "Loading..."

        Success fullText ->
            pre [] [ text fullText ]
