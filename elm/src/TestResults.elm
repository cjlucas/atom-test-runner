module TestResults exposing
    ( Result(..)
    , TestResults
    , TestStatus(..)
    , add
    , empty
    , id
    , results
    , status
    , testName
    , toList
    )

import OrderedDict exposing (OrderedDict)


type ID
    = ID String


type Result
    = Suite SuiteInternals
    | Test TestInternals


type alias TestLocation =
    ( Maybe String, Maybe Int )


type alias SuiteInternals =
    { id : Int
    , name : String
    , location : TestLocation
    , results : OrderedDict String Result
    }


type alias TestInternals =
    { id : Int
    , name : String
    , location : TestLocation
    , status : TestStatus
    }


type TestStatus
    = Passed
    | Failed
    | Errored
    | Pending
    | Skipped


type TestResults
    = TestResults TestResultsInternal


type alias TestResultsInternal =
    { nextResultId : Int
    , results : OrderedDict String Result
    }


empty =
    TestResults { nextResultId = 0, results = OrderedDict.empty }


status result =
    case result of
        Suite _ ->
            Failed

        Test test ->
            test.status


testName result =
    case result of
        Test test ->
            test.name

        Suite suite ->
            suite.name


results : Result -> List Result
results result =
    case result of
        Test _ ->
            []

        Suite suite ->
            OrderedDict.values suite.results


toList : TestResults -> List Result
toList (TestResults internal) =
    OrderedDict.values internal.results


add : String -> List String -> TestLocation -> TestStatus -> TestResults -> TestResults
add name suitePath location testStatus (TestResults internal) =
    let
        testInternals =
            { id = 0
            , name = name
            , location = location
            , status = testStatus
            }

        ( lastResultId, testResults ) =
            addTest
                testInternals
                internal.nextResultId
                suitePath
                internal.results
    in
    TestResults
        { internal
            | nextResultId = lastResultId + 1
            , results = testResults
        }


id : Result -> Int
id result =
    case result of
        Test internals ->
            internals.id

        Suite internals ->
            internals.id


addTest : TestInternals -> Int -> List String -> OrderedDict String Result -> ( Int, OrderedDict String Result )
addTest testInternals nextResultId suitePath testResults =
    case suitePath of
        [] ->
            let
                testInternals_ =
                    { testInternals | id = nextResultId }
            in
            ( nextResultId, OrderedDict.insert testInternals_.name (Test testInternals_) testResults )

        suiteName :: rest ->
            case OrderedDict.get suiteName testResults of
                Just (Test test_) ->
                    ( nextResultId - 1, testResults )

                Just (Suite suite) ->
                    let
                        ( lastResultId, results_ ) =
                            addTest testInternals nextResultId rest suite.results

                        suite_ =
                            Suite { suite | results = results_ }
                    in
                    ( lastResultId, OrderedDict.insert suite.name suite_ testResults )

                Nothing ->
                    let
                        ( lastResultId, results_ ) =
                            addTest testInternals (nextResultId + 1) rest OrderedDict.empty

                        suite =
                            Suite
                                { id = nextResultId
                                , name = suiteName
                                , location = ( Nothing, Nothing )
                                , results = results_
                                }
                    in
                    ( lastResultId, OrderedDict.insert suiteName suite testResults )
