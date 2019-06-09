module Atom.TextEditor exposing
    ( Msg
    , PrimativeTextEditor
    , TextEditor
    , equal
    , fromPrimative
    , toPrimative
    )

import Atom.Gutter as Gutter exposing (Gutter)


type ID
    = ID Int


type TextEditor
    = TextEditor Internals


type alias PrimativeTextEditor =
    { id : Int
    }


fromPrimative primative =
    TextEditor { id = ID primative.id }


toPrimative editor =
    { id = rawId editor }


type alias Internals =
    { id : ID
    }



-- addGutter : Gutter -> TextEditor -> Cmd msg
-- addGutter gutter editor =
--     Ports.addTextEditorGutter ( Gutter.encode gutter, rawId editor )


rawId (TextEditor internals) =
    let
        (ID id_) =
            internals.id
    in
    id_


type Msg
    = GutterAdded Gutter
    | GutterRemoved Gutter


equal textEditorA textEditorB =
    rawId textEditorA == rawId textEditorB
