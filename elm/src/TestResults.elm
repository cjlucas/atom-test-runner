module TestResults exposing
    ( Result(..)
    , TestResults
    , TestStatus(..)
    , add
    , empty
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
    { name : String
    , location : TestLocation
    , results : OrderedDict String Result
    }


type alias TestInternals =
    { name : String
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
    = TestResults (OrderedDict String Result)


empty =
    TestResults OrderedDict.empty


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
toList (TestResults testResults) =
    OrderedDict.values testResults


add : String -> List String -> TestLocation -> TestStatus -> TestResults -> TestResults
add name suitePath location testStatus (TestResults testResults) =
    let
        testInternals =
            { name = name
            , location = location
            , status = testStatus
            }
    in
    TestResults (addTest testInternals suitePath testResults)


addTest : TestInternals -> List String -> OrderedDict String Result -> OrderedDict String Result
addTest testInternals suitePath testResults =
    case suitePath of
        [] ->
            OrderedDict.insert testInternals.name (Test testInternals) testResults

        suiteName :: rest ->
            case OrderedDict.get suiteName testResults of
                Just (Test test_) ->
                    testResults

                Just (Suite suite) ->
                    let
                        results_ =
                            addTest testInternals rest suite.results

                        suite_ =
                            Suite { suite | results = results_ }
                    in
                    OrderedDict.insert suite.name suite_ testResults

                Nothing ->
                    let
                        suite =
                            Suite
                                { name = suiteName
                                , location = ( Nothing, Nothing )
                                , results = addTest testInternals rest OrderedDict.empty
                                }
                    in
                    OrderedDict.insert suiteName suite testResults
