'use babel'

export default class GutterMarker extends HTMLElement {
  constructor() {
    super()
  }

  connectedCallback() {
    console.log('connectedCallback')

    const wrapper = document.createElement('div')
    wrapper.setAttribute('class', this._classList())

    this.appendChild(wrapper)
  }

  _classList() {
    return [
      'atom-test-runner-circle',
      `atom-test-runner-status-${this.getAttribute('status')}`
    ].join(' ')
  }
}

console.log('registering')
console.log(GutterMarker)
customElements.define('gutter-marker-item', GutterMarker)
