port module Ports exposing (Test, testUpdate)


type alias Test =
    { name : String
    , suitePath : List String
    , location : ( Maybe String, Maybe Int )
    , status : String
    }


port testUpdate : (Test -> msg) -> Sub msg
