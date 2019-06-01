module Main exposing (main)

import Atom.Workspace
import Platform



--- modal


type alias Model =
    { workspace : Atom.Workspace.Model }


main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



--- INIT


init : Int -> ( Model, Cmd msg )
init flags =
    let
        ( workspace, cmd ) =
            Atom.Workspace.init
    in
    ( { workspace = workspace }, cmd )



--- UPDATE


type Msg
    = AtomWorkspaceMsg Atom.Workspace.Msg


update msg model =
    case msg of
        AtomWorkspaceMsg workspaceMsg ->
            let
                ( workspace, workspaceCmd ) =
                    Atom.Workspace.update workspaceMsg model.workspace
            in
            ( { workspace = workspace }, Cmd.map AtomWorkspaceMsg workspaceCmd )



--- SUBSCRIPTIONS


subscriptions model =
    Sub.map AtomWorkspaceMsg (Atom.Workspace.subscriptions model.workspace)
