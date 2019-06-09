module TestResults exposing
    ( Model
    , Msg
    , OutMsg(..)
    , getTests
    , init
    , subscriptions
    , update
    )


type ID
    = ID String


type TestRepresentable
    = TestContainer TestContainerInternals
    | Test TestInternals


type alias TestContainerInternals =
    { id : ID
    , name : String
    , lineNumber : Maybe Int
    , tests : List TestRepresentable
    }


type alias TestInternals =
    { id : ID
    , name : String
    , lineNumber : Maybe Int
    , status : TestStatus
    }


type TestStatus
    = Passed
    | Failed
    | Errored
    | Pending
    | Skipped


type alias Model =
    { tests : List TestRepresentable }


type Msg
    = AddTest TestRepresentable
    | UpdateTestStatus ID TestStatus


type OutMsg
    = None


getTests : Model -> List TestRepresentable
getTests model =
    model.tests


init : Model
init =
    { tests = [] }


updateTestStatus : Model -> String -> TestStatus -> Model
updateTestStatus model string status =
    { tests = [] }


update : Model -> Msg -> ( Model, Cmd Msg, Maybe OutMsg )
update model msg =
    ( model, Cmd.none, Nothing )


subscriptions : Sub Msg
subscriptions =
    Sub.none
