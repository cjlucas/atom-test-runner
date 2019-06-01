module Atom.TextEditor exposing
    ( TextEditor
    , addGutter
    , decode
    )

import Atom.Gutter as Gutter exposing (Gutter)
import Atom.Ports as Ports
import Json.Decode as JD


type ID
    = ID Int


type TextEditor
    = TextEditor Internals


type alias Internals =
    { id : ID
    }


decodeID =
    JD.map ID JD.int


decoder =
    JD.map Internals (JD.field "id" decodeID)
        |> JD.map TextEditor


decode : JD.Value -> Result JD.Error TextEditor
decode value =
    JD.decodeValue decoder value


addGutter : Gutter -> TextEditor -> Cmd msg
addGutter gutter editor =
    Ports.addTextEditorGutter ( Gutter.encode gutter, rawId editor )


rawId (TextEditor internals) =
    let
        (ID id_) =
            internals.id
    in
    id_
