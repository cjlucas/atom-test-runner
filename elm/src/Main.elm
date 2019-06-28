module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Element exposing (alignLeft, alignRight)
import Element.Events exposing (onClick)
import Element.Font as Font
import Html exposing (span, text)
import Html.Attributes exposing (class, style)
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
    { testResults : TestResults
    , testResultsViewState : Dict Int TestResultViewState
    }


type alias TestResultViewState =
    { collapsed : Bool
    }


defaultTestResultViewState =
    { collapsed = False }


testResultViewState id testResultsViewState =
    case Dict.get id testResultsViewState of
        Just viewState ->
            viewState

        Nothing ->
            defaultTestResultViewState


type Msg
    = InsertTest Ports.Test
    | TestResultClicked Int


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
    Debug.log "in init" ( { testResults = TestResults.empty, testResultsViewState = Dict.empty }, Cmd.none )


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
    case Debug.log "msg" msg of
        InsertTest portTest ->
            ( insertTest portTest model, Cmd.none )

        TestResultClicked id ->
            let
                viewState =
                    testResultViewState id model.testResultsViewState

                testResultsViewState =
                    Dict.insert id { viewState | collapsed = not viewState.collapsed } model.testResultsViewState
            in
            ( { model | testResultsViewState = testResultsViewState }, Cmd.none )


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


triangle collapsed =
    let
        icon_ =
            if collapsed then
                Element.htmlAttribute (class "icon icon-triangle-right")

            else
                Element.htmlAttribute (class "icon icon-triangle-down")
    in
    Element.el [ icon_, Font.color white ] Element.none


indent level =
    Element.paddingEach { edges | left = level * 15 }


viewTest indentLevel testResultsViewState testResult =
    let
        isCollapsed =
            testResultViewState (TestResults.id testResult) testResultsViewState
                |> .collapsed

        childResults =
            if isCollapsed then
                []

            else
                List.concatMap
                    (viewTest (indentLevel + 1) testResultsViewState)
                    (TestResults.results testResult)

        dropdownTriangle =
            if TestResults.results testResult |> List.isEmpty then
                Element.el [ Element.width (Element.px 20) ] Element.none

            else
                triangle isCollapsed
    in
    Element.row
        [ indent indentLevel
        , onClick (TestResultClicked (TestResults.id testResult))
        , Element.width Element.fill
        , Element.htmlAttribute (style "cursor" "pointer")
        ]
        [ Element.row [ Element.width Element.fill ]
            [ Element.row [ alignLeft ]
                [ dropdownTriangle
                , Element.text (TestResults.testName testResult)
                ]
            , Element.el [ alignRight ] (icon (TestResults.status testResult))
            ]
        ]
        :: childResults


white =
    Element.rgb255 255 255 255


view : Model -> Html.Html Msg
view model =
    Element.layout [ Element.explain Debug.todo ] <|
        Element.column [ Font.color white, Element.width Element.fill ] <|
            List.concatMap (viewTest 0 model.testResultsViewState) (TestResults.toList model.testResults)


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.testUpdate InsertTest
