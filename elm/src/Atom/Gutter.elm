module Atom.Gutter exposing
    ( Gutter
    , PrimativeGutter
    , fromPrimative
    , setPriority
    , setVisiblity
    , toPrimative
    , withName
    )

import Json.Decode as JD
import Json.Encode as JE


type Gutter
    = Gutter PrimativeGutter


type alias PrimativeGutter =
    { name : String
    , priority : Maybe Int
    , visible : Maybe Bool
    }


fromPrimative primative =
    Gutter primative


toPrimative (Gutter primative) =
    primative


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
