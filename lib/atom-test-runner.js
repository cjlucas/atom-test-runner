'use babel';

import AtomTestRunnerView from './atom-test-runner-view';
import { CompositeDisposable } from 'atom';

import { Elm } from '../elm/src/Main.elm'

export default {
  atomTestRunnerView: null,
  modalPanel: null,
  subscriptions: null,

  initialize(state) {
    console.log(atom.workspace);
    console.log('intiialize');
    console.log(state);

    const app = Elm.Main.init({
      flags: 5
    });

    app.ports.addTextEditorGutter.subscribe(([gutter, editorID]) => {
      atom.workspace.getTextEditors().forEach(editor => {
        if (editor.id == editorID) {
          editor.addGutter(gutter)
          return
        }
      })
    })

    atom.workspace.observeTextEditors(editor => {
      editor.onDidDestroy(() => app.ports.didDestroyEditor.send(editor))

      app.ports.observeTextEditors.send(editor)
    })

    atom.workspace.observeActiveTextEditor(app.ports.observeActiveTextEditor.send);
  },

  activate(state) {
    console.log('activate!');
    this.atomTestRunnerView = new AtomTestRunnerView(state.atomTestRunnerViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.atomTestRunnerView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'atom-test-runner:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.atomTestRunnerView.destroy();
  },

  serialize() {
    return {
      atomTestRunnerViewState: this.atomTestRunnerView.serialize()
    };
  },

  toggle() {
    console.log('AtomTestRunner was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }
};
