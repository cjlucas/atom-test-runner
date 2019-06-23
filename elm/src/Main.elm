module Main exposing (main)

import Browser
import Element
import Element.Font as Font
import Html exposing (span, text)
import Html.Attributes exposing (class)
import Ports
import TestResults exposing (TestResults)


type alias Flags =
    {}


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--- MODEL


type alias Model =
    { testResults : TestResults }


type Msg
    = InsertTest Ports.Test


mockTests =
    TestResults.empty
        |> TestResults.add "should increment the total"
            [ "Order", "#add_total" ]
            ( Nothing, Just 10 )
            TestResults.Failed
        |> TestResults.add "should return true"
            [ "Order", "#add_total" ]
            ( Nothing, Just 15 )
            TestResults.Passed


init flags =
    Debug.log "in init" ( { testResults = TestResults.empty }, Cmd.none )


insertTest : Ports.Test -> Model -> Model
insertTest portTest model =
    let
        status =
            case portTest.status of
                "pass" ->
                    TestResults.Passed

                "fail" ->
                    TestResults.Failed

                _ ->
                    TestResults.Pending
    in
    { model
        | testResults =
            TestResults.add portTest.name
                portTest.suitePath
                portTest.location
                status
                model.testResults
    }


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        InsertTest portTest ->
            ( insertTest portTest model, Cmd.none )


edges =
    { top = 0
    , left = 0
    , right = 0
    , bottom = 0
    }


icon status =
    let
        color =
            case status of
                TestResults.Passed ->
                    Element.rgb255 0 255 0

                TestResults.Failed ->
                    Element.rgb255 255 0 0

                TestResults.Skipped ->
                    Element.rgb255 0 0 255

                TestResults.Errored ->
                    Element.rgb255 200 200 200

                TestResults.Pending ->
                    Element.rgb255 100 100 100
    in
    Element.el
        [ Element.htmlAttribute (class "icon icon-x")
        , Font.color color
        ]
        Element.none


indent level =
    Element.paddingEach { edges | left = level * 20 }


viewTopLevelTest =
    viewTest 0


viewTest level testResult =
    Element.row [ indent level ]
        [ icon (TestResults.status testResult)
        , Element.text (TestResults.testName testResult)
        ]
        :: List.concatMap (viewTest (level + 1)) (TestResults.results testResult)


white =
    Element.rgb255 255 255 255


view : Model -> Html.Html Msg
view model =
    Element.layout [ Element.explain Debug.todo ] <|
        Element.column [ Font.color white ] <|
            List.concatMap (viewTest 0) (TestResults.toList model.testResults)


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.testUpdate InsertTest
