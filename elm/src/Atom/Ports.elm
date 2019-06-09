port module Atom.Ports exposing
    ( addTextEditorGutter
    , didDestroyEditor
    , foo
    , observeActiveTextEditor
    , observeGutters
    , observeTextEditors
    , onDidAddGutter
    , onDidRemoveGutter
    )

import Atom.Gutter exposing (PrimativeGutter)
import Atom.Range exposing (PrimativeRange)
import Atom.TextEditor exposing (PrimativeTextEditor)
import Json.Decode
import Json.Encode


port observeTextEditors : (PrimativeTextEditor -> msg) -> Sub msg


port observeActiveTextEditor : (Maybe PrimativeTextEditor -> msg) -> Sub msg



--- TextEditor Commands


port addTextEditorGutter : ( PrimativeGutter, PrimativeTextEditor ) -> Cmd msg


port addMarker : PrimativeRange -> ( PrimativeRange, PrimativeMarker )



--- TextEditor Events


port foo : (String -> msg) -> Sub msg


port didDestroyEditor : (PrimativeTextEditor -> msg) -> Sub msg


port observeGutters : (( PrimativeGutter, PrimativeTextEditor ) -> msg) -> Sub msg


port onDidAddGutter : (( PrimativeGutter, PrimativeTextEditor ) -> msg) -> Sub msg


port onDidRemoveGutter : (( PrimativeGutter, PrimativeTextEditor ) -> msg) -> Sub msg
