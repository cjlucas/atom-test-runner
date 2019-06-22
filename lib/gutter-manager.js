'use babel'

import GutterMarker from './gutter-marker.js'

var defaultGutterManager = null

export default class GutterManager {
  static start() {
    if (defaultGutterManager) {
      console.error('GutterManager has already started')
      return
    }

    defaultGutterManager = new GutterManager()
  }

  constructor() {
    atom.workspace.observeTextEditors(editor => {
      const gutter = editor.addGutter({
        name: 'atom-test-runner',
        visible: true,
        type: 'decorated'
      })

      const range = editor.getBuffer().rangeForRow(5)

      const marker = editor.markBufferRange(range)

      const markerItem = document.createElement('gutter-marker-item')
      markerItem.setAttribute('status', 'skip')

      gutter.decorateMarker(marker, {
        type: 'gutter',
        item: markerItem
      })
    })
  }
}
