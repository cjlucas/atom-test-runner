module Atom.Workspace exposing
    ( addTextEditorGutter
    , didDestroyEditor
    , observeActiveTextEditor
    , observeGutters
    , observeTextEditors
    , onDidAddGutter
    , onDidRemoveGutter
    )

import Atom.Gutter as Gutter exposing (Gutter)
import Atom.Ports as Ports
import Atom.TextEditor as TextEditor exposing (TextEditor)
import Json.Decode as JD



-- EVENTS


observeTextEditors : (TextEditor -> msg) -> Sub msg
observeTextEditors msg =
    Ports.observeTextEditors (TextEditor.fromPrimative >> msg)


observeActiveTextEditor : (Maybe TextEditor -> msg) -> Sub msg
observeActiveTextEditor msg =
    let
        doit thing =
            case thing of
                Just primative ->
                    msg (Just (TextEditor.fromPrimative primative))

                Nothing ->
                    msg Nothing
    in
    Ports.observeActiveTextEditor doit


didDestroyEditor : (TextEditor -> msg) -> Sub msg
didDestroyEditor msg =
    Ports.didDestroyEditor (TextEditor.fromPrimative >> msg)


addTextEditorGutter : Gutter -> TextEditor -> Cmd msg
addTextEditorGutter gutter editor =
    Ports.addTextEditorGutter
        ( Gutter.toPrimative gutter
        , TextEditor.toPrimative editor
        )


observeGutters : (( Gutter, TextEditor ) -> msg) -> Sub msg
observeGutters msg =
    Ports.observeGutters
        (msg
            << Tuple.mapFirst Gutter.fromPrimative
            << Tuple.mapSecond TextEditor.fromPrimative
        )


onDidAddGutter : (( Gutter, TextEditor ) -> msg) -> Sub msg
onDidAddGutter msg =
    Ports.onDidAddGutter
        (msg
            << Tuple.mapFirst Gutter.fromPrimative
            << Tuple.mapSecond TextEditor.fromPrimative
        )


onDidRemoveGutter : (( Gutter, TextEditor ) -> msg) -> Sub msg
onDidRemoveGutter msg =
    Ports.onDidRemoveGutter
        (msg
            << Tuple.mapFirst Gutter.fromPrimative
            << Tuple.mapSecond TextEditor.fromPrimative
        )
