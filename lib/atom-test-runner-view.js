'use babel'

export default class AtomTestRunnerView {

  constructor(serializedState) {
    console.log('atom test runner view init')
    // Create root element
    this.element = document.createElement('div')
    this.element.setAttribute('class', 'fukyou')

    this.elm = document.createElement('div')
    this.element.appendChild(this.elm)
  }

  // Returns an object that can be retrieved when package is activated
  serialize() {}

  // Tear down any state and detach
  destroy() {
    console.log('in destroy')
    // this.element.remove()
  }

  getDefaultLocation() {
    return 'right'
  }

  getElement() {
    return this.element
  }

  getTitle() {
    return 'foo'
  }

  getURI() {
    return 'atom://atom-test-runner'
  }
}
