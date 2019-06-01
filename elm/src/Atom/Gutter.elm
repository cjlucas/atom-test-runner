module Atom.Gutter exposing
    ( Gutter
    , encode
    , setPriority
    , setVisiblity
    , withName
    )

import Json.Encode as JE


type Gutter
    = Gutter Internals


type alias Internals =
    { name : String
    , priority : Maybe Int
    , visible : Maybe Bool
    }


encode (Gutter internals) =
    let
        encoder =
            JE.object [ ( "name", JE.string internals.name ) ]
    in
    JE.encode 0 encoder


withName name =
    Gutter
        { name = name
        , priority = Nothing
        , visible = Nothing
        }


setPriority priority (Gutter internals) =
    Gutter { internals | priority = Just priority }


setVisiblity visibility (Gutter internals) =
    Gutter { internals | visible = Just visibility }
