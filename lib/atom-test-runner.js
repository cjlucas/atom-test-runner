'use babel';

import AtomTestRunnerView from './atom-test-runner-view';
import { CompositeDisposable } from 'atom';

// import TreeSitter from 'tree-sitter'
// import TreeSitterElm from 'tree-sitter-elm'

import ChildProcess from 'child_process'

const TestGutterManager = require('../elm/src/TestGutterManager.elm').Elm.TestGutterManager

console.log(TestGutterManager);

var testRunnerPackage;

function findEditor(editorId) {
  const editors = atom.workspace.getTextEditors()
  for (let i = 0; i < editors.length; i++) {
    if (editors[i].id === editorId) {
      return editors[i]
    }
  }

  return null
}

export function initialize(state) {
  const app = TestGutterManager.init({flags: 0})
  console.log(app);

  atom.workspace.observeTextEditors(editor => {
    app.ports.observeTextEditors.send(editor)

    editor.onDidDestroy(() => app.ports.didDestroyEditor.send(editor))
    editor.observeGutters(gutter => app.ports.observeGutters.send([gutter, editor]))
    editor.onDidAddGutter(gutter => app.ports.onDidAddGutter.send([gutter, editor]))
    // editor.onDidRemoveGutter(gutter => app.ports.onDidRemoveGutter.send([gutter, editor]))
  })
  atom.workspace.observeActiveTextEditor(editor => {
    // This port accepts a Maybe type because editor can be undefined
    // when switching to a non-editor pane (such as a preference pane).
    // Elm however, doesn't treat undefined as null, so we need to convert
    // it ourselves.
    editor = editor || null;
    app.ports.observeActiveTextEditor.send(editor)
  })

  app.ports.addTextEditorGutter.subscribe(([gutter, editor]) => {
    console.log('in addTextEditorGutter port');
    console.log(gutter);
    console.log(editor);
    console.log(`Adding gutter to editor with id: ${editor.id}`);
    let textEditor = findEditor(editor.id)

    if (!textEditor) {
      console.error(`Could not find TextEditor with ID: ${editor.id}`);
      return
    }

    console.log(textEditor);
    textEditor.addGutter(gutter)
  })

  testRunnerPackage = new TestRunnerPackage()
}

class Suite {
  setTest(test) {
    this.test = test
  }
}

class Describe {
  constructor(name) {
    this.name = name
  }
}

class Test {
  constructor(name) {
    this.name = name
  }
}

class Skip {
  constructor(name) {
    this.name = name
  }

  setTest(test) {
    this.test = test
  }
}

class TestRunnerPackage {
  constructor() {
    atom.commands.add('atom-workspace', {
      'atom-test-runner:foo': () => this.doit()
    })

    this._setupEventHandlers()
  }

  _setupEventHandlers() {
    atom.workspace.observeTextEditors(editor => {
      const gutter = editor.addGutter({
        name: 'test-runner',
        type: 'decorated'
      })

      const range = new Range([10, 0], [10, 5])
      const marker = editor.markBufferRange(range, {
        invalidate: 'never'
      })

      gutter.decorateMarker(marker, {
        style: 'background-color: red;'
      })
    });
  }

  doit() {
    // const params = [
    //   '--report',
    //   'json',
    //   atom.workspace.getActiveTextEditor().getPath()
    // ]
    // const raw = ChildProcess.spawnSync('elm-test', params).stdout.toString()
    //
    // const arrayifiedRaw = `[${raw.trim().split('\n').join(',')}]`
    //
    // console.log(raw);
    // console.log(arrayifiedRaw);
    // console.log(JSON.parse(arrayifiedRaw));

    console.log('doit!');

    const parser = new TreeSitter()
    parser.setLanguage(TreeSitterElm)
    const text = atom.workspace.getActiveTextEditor().getBuffer().cachedText
    const tree = parser.parse(text)

    const walkNode = (node, context) => {
      if (node.type === 'function_call_expr') {
        const interestingFunction =
          node.childCount >= 2 &&
          node.child(0).type === 'value_expr' &&
          node.child(1).type === 'string_constant_expr'

        if (interestingFunction) {
          const funcName = node.child(0).text
          const testName = node.child(1).child(1).text
          const child = {
            funcName: funcName,
            testName: testName,
            lineNumber: node.startPosition.row,
            children: []
          }

          context.children.push(child)
          context = child

          console.log(`funcName: ${funcName} testName: ${testName}`)
        }
      }

      for (let i = 0; i < node.childCount; i++) {
        walkNode(node.child(i), context)
      }

      return context
    }

    const start = new Date();
    const context = walkNode(tree.rootNode, { children: [] })
    console.log(new Date() - start);
    console.log(context);
  }
}

// export default {
//   atomTestRunnerView: null,
//   modalPanel: null,
//   subscriptions: null,
//
//   initialize(state) {
//     console.log(atom.workspace);
//     console.log('intiialize');
//     console.log(state);
//
//     const app = Elm.Main.init({
//       flags: 5
//     });
//
//     app.ports.addTextEditorGutter.subscribe(([gutter, editorID]) => {
//       atom.workspace.getTextEditors().forEach(editor => {
//         if (editor.id == editorID) {
//           editor.addGutter(gutter)
//           return
//         }
//       })
//     })
//
//     atom.workspace.observeTextEditors(editor => {
//       app.ports.observeTextEditors.send(editor)
//
//       editor.onDidDestroy(() => app.ports.didDestroyEditor.send(editor))
//
//       editor.observeGutters(gutter => {
//         console.log(`observeGutters ${editor.id} ${gutter.name}`);
//         app.ports.observeGutters.send({editor, gutter})
//       })
//     })
//
//     atom.workspace.observeActiveTextEditor(app.ports.observeActiveTextEditor.send);
//   },
//
//   activate(state) {
//     console.log('activate!');
//     this.atomTestRunnerView = new AtomTestRunnerView(state.atomTestRunnerViewState);
//     this.modalPanel = atom.workspace.addModalPanel({
//       item: this.atomTestRunnerView.getElement(),
//       visible: false
//     });
//
//     // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
//     this.subscriptions = new CompositeDisposable();
//
//     // Register command that toggles this view
//     this.subscriptions.add(atom.commands.add('atom-workspace', {
//       'atom-test-runner:toggle': () => this.toggle()
//     }));
//   },
//
//   deactivate() {
//     this.modalPanel.destroy();
//     this.subscriptions.dispose();
//     this.atomTestRunnerView.destroy();
//   },
//
//   serialize() {
//     return {
//       atomTestRunnerViewState: this.atomTestRunnerView.serialize()
//     };
//   },
//
//   toggle() {
//     console.log('AtomTestRunner was toggled!');
//     return (
//       this.modalPanel.isVisible() ?
//       this.modalPanel.hide() :
//       this.modalPanel.show()
//     );
//   }
// };
