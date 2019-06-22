module TestResultsTests exposing (testNew)

import Expect exposing (Expectation)
import Test exposing (..)
import TestResults


testNew =
    test "doit" <|
        \_ ->
            let
                actual =
                    TestResults.empty
                        |> TestResults.add "test1" [] ( Nothing, Nothing ) TestResults.Passed
            in
            Expect.pass
