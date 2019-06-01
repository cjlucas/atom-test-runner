port module Atom.Ports exposing
    ( addTextEditorGutter
    , didDestroyEditor
    , observeActiveTextEditor
    , observeTextEditors
    )

import Json.Decode
import Json.Encode


port observeTextEditors : (Json.Decode.Value -> msg) -> Sub msg


port observeActiveTextEditor : (Json.Decode.Value -> msg) -> Sub msg



--- TextEditor Commands


port addTextEditorGutter : ( String, Int ) -> Cmd msg



--- TextEditor Events


port didDestroyEditor : (Json.Decode.Value -> msg) -> Sub msg
