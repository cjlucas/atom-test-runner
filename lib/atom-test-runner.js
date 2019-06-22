'use babel'

import AtomTestRunnerView from './atom-test-runner-view'

import GutterManager from './gutter-manager'

import LineReader from './line-reader'

import ChildProcess from 'child_process'

import { Elm } from '../elm/src/Main.elm'

export var elmApp

export var x = 5

export function initialize() {
  console.log('initialize!')
  // GutterManager.start()

  const view = new AtomTestRunnerView()
  console.log('init view')
  console.log(view)

  x = 10

  elmApp = Elm.Main.init({
    node: view.elm
  })

  console.log(elmApp)

  atom.workspace.addOpener(uri => {
    if (uri === 'atom://atom-test-runner') {
      return view
    }
  })

  atom.workspace.toggle('atom://atom-test-runner')

  atom.commands.add('atom-workspace', {
    'atom-test-runner:toggle': () => atom.workspace.toggle('atom://atom-test-runner')
  })

  const childProcess = ChildProcess.spawn('elm-test', ['--report=json', '--fuzz=1'], {cwd: '/Users/chris/repos/test-elm'})

  const r = new LineReader(childProcess.stdout)

  r.on('line', line => {
    console.log('on line')
    line = line.toString()

    let result = JSON.parse(line)
    console.log(result)

    if (result.event != 'testCompleted') {
      return
    }

    let testName = result.labels.pop()
    let suitePath = result.labels

    elmApp.ports.testUpdate.send({
      name: testName,
      suitePath: suitePath,
      location: [null, null],
      status: result.status
    })
  })

  r.on('end', () => { console.log('on end') })
}
