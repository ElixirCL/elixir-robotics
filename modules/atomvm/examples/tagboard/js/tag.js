import { LitElement, css, html } from './lit-core.min.js';

export class Tag extends LitElement {
  static properties = {
    tag: {},
  }

  static styles = css`
    :host {
      color: blue;
      position: relative;
      width: 100%;
      flex-grow: 1;
    }

    p {
      padding: 0.5rem;
    }

    .author {
      color: black;
    }

    .date {
      position: absolute;
      top: 4px;
      left: 0;
      font-size: 0.6rem;
    }
  `

  constructor() {
    super()
    this.tag = {}
  }

  renderDate(timestamp) {
    const date = new Date(parseInt(timestamp))
    return html`<span class="date">${date.toLocaleString()}</span>`
  }

  render() {
    return html`<p>${this.renderDate(this.tag.timestamp)} <span class="author">${this.tag.author} > </span> ${this.tag.content}</p>`
  }
}
customElements.define('my-tag', Tag)
