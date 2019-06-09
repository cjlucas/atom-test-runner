module TestGutterManager exposing (main)

import Atom.Gutter
import Atom.Ports
import Atom.TextEditor
import Atom.Workspace
import Json.Decode as JD
import Platform
import TestResults


type alias Gutter =
    { name : String }


type alias Marker =
    {}


type alias EditorInfo =
    { gutter : Maybe Gutter
    , markers : List Marker
    }


type alias Model =
    { testResults : TestResults.Model
    , editors : List ( Atom.TextEditor.TextEditor, EditorInfo )
    , activeEditor : Maybe Atom.TextEditor.TextEditor
    }


addEditor editor model =
    let
        editorInfo =
            { gutter = Nothing
            , markers = []
            }
    in
    { model | editors = ( editor, editorInfo ) :: model.editors }


updateEditorVisibility editor model =
    let
        mapper =
            \( e, editorInfo ) ->
                ( e, { editorInfo | active = Atom.TextEditor.equal editor e } )

        editors =
            List.map mapper model.editors
    in
    { model | editors = editors }


deleteEditor editor model =
    { model
        | editors =
            List.filter
                (not
                    << Atom.TextEditor.equal editor
                    << Tuple.first
                )
                model.editors
    }


type Msg
    = AddEditor Atom.TextEditor.TextEditor
    | EditorBecameActive (Maybe Atom.TextEditor.TextEditor)
    | EditorDestroyed Atom.TextEditor.TextEditor
    | AddGutter ( Atom.Gutter.Gutter, Atom.TextEditor.TextEditor )
    | GutterAdded ( Atom.Gutter.Gutter, Atom.TextEditor.TextEditor )
    | GutterRemoved ( Atom.Gutter.Gutter, Atom.TextEditor.TextEditor )


init : Int -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { testResults = TestResults.init
            , editors = []
            , activeEditor = Nothing
            }
    in
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        AddEditor editor ->
            let
                gutter =
                    Atom.Gutter.withName "fucker"
                        |> Atom.Gutter.setPriority 500

                cmd =
                    Atom.Workspace.addTextEditorGutter gutter editor
            in
            ( addEditor editor model, cmd )

        EditorBecameActive editor ->
            ( { model | activeEditor = editor }, Cmd.none )

        EditorDestroyed editor ->
            ( deleteEditor editor model, Cmd.none )

        AddGutter ( gutter, editor ) ->
            ( model, Cmd.none )

        GutterAdded ( gutter, editor ) ->
            ( model, Cmd.none )

        GutterRemoved ( gutter, editor ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Atom.Workspace.observeTextEditors AddEditor
        , Atom.Workspace.observeActiveTextEditor EditorBecameActive
        , Atom.Workspace.didDestroyEditor EditorDestroyed
        , Atom.Workspace.observeGutters AddGutter
        , Atom.Workspace.onDidAddGutter GutterAdded
        , Atom.Workspace.onDidRemoveGutter GutterRemoved
        ]


main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
