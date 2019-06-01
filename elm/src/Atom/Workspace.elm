module Atom.Workspace exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    )

import Atom.Gutter as Gutter exposing (Gutter)
import Atom.Ports as Ports
import Atom.TextEditor as TextEditor exposing (TextEditor)
import Json.Decode as JD
import Platform


addGutter : Gutter -> TextEditor -> Cmd msg
addGutter gutter editor =
    Ports.addTextEditorGutter ( Gutter.encode gutter, TextEditor.id editor )



--- modal


type alias Model =
    { editors : List TextEditor
    , activeEditor : Maybe TextEditor
    }



--- INIT


init : ( Model, Cmd msg )
init =
    let
        model =
            { editors = []
            , activeEditor = Nothing
            }
    in
    ( model, Cmd.none )



--- UPDATE


type Msg
    = NewTextEditor TextEditor
    | NewActiveTextEditor (Maybe TextEditor)
    | TextEditorDestroyed TextEditor
    | NoOp


update msg model =
    case Debug.log "msg" msg of
        NewTextEditor editor ->
            let
                cmd =
                    addGutter (Gutter.withName "fucker") editor
            in
            ( { model | editors = editor :: model.editors }, cmd )

        NewActiveTextEditor maybeEditor ->
            ( { model | activeEditor = maybeEditor }, Cmd.none )

        TextEditorDestroyed editor ->
            let
                editors =
                    List.filter (\editor_ -> editor /= editor) model.editors
            in
            ( { model | editors = editors }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



--- SUBSCRIPTIONS


decodeTextEditor : (TextEditor -> Msg) -> JD.Value -> Msg
decodeTextEditor msg value =
    case TextEditor.decode value of
        Ok editor ->
            msg editor

        Err err ->
            NoOp


decodeActiveTextEditor value =
    case TextEditor.decode value of
        Ok editor ->
            NewActiveTextEditor (Just editor)

        Err err ->
            NewActiveTextEditor Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.observeTextEditors (decodeTextEditor NewTextEditor)
        , Ports.observeActiveTextEditor decodeActiveTextEditor
        , Ports.didDestroyEditor (decodeTextEditor TextEditorDestroyed)
        ]
