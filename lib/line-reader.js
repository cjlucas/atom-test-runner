'use babel'

import EventEmitter from 'events'

export default class LineReader extends EventEmitter {
  constructor(stream) {
    super()

    var chunks = []

    stream.on('data', data => {

      let idx
      do {
        idx = data.indexOf(0x0A)

        if (idx == -1) {
          chunks.push(data)
        } else {
          chunks.push(data.subarray(0, idx))

          this.emit('line', Buffer.concat(chunks))

          data = data.subarray(idx+1)
          chunks = []
        }
      } while (idx != -1)
    })

    stream.on('end', () => {
      let line = Buffer.concat(chunks)
      if (line.length > 0) {
        this.emit('line', line)
      }

      this.emit('end')
    })
  }
}
