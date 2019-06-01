module Atom.TextEditor exposing
    ( TextEditor
    , decode
    , id
    )

import Json.Decode as JD


id (TextEditor id_) =
    let
        (ID i) =
            id_
    in
    i


type ID
    = ID Int


type TextEditor
    = TextEditor ID


decodeID =
    JD.map ID JD.int


decoder =
    JD.map TextEditor (JD.field "id" decodeID)


decode : JD.Value -> Result JD.Error TextEditor
decode value =
    JD.decodeValue decoder value
