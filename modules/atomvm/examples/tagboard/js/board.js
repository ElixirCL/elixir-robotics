import { LitElement, css, html } from './lit-core.min.js'
import "./tag.js"

export class TagBoard extends LitElement {
  static properties = {
    _username: { state: true },
    _tags: { state: true },
    _content: { state: true },
  }

  static styles = css`
    :host {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      justify-content: space-between;
      align-items: center;
      color: blue;
      border: 1px solid black;
    }

    .name-input-box {
      position: absolute;
      z-index: 10;

      padding: 2rem;
      border-radius: 0.5rem;
      background-color: white;
      box-shadow: 0 4px 8px rgba(0,0,0,0.2);
      max-width: 90%;
      width: 400px;
      text-align: center;
    }

    .name-input-box form {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      align-items: center;
    }

    .name-input-box input {
      padding: 0.5rem;
      border-radius: 0.25rem;
      border: 1px solid #ccc;
      width: 80%;
      max-width: 300px;
    }

    .name-input-box button {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 0.25rem;
      background-color: #007bff;
      color: white;
      cursor: pointer;
      font-size: 1rem;
    }

    .tags {
      display: flex;
      flex-direction: column;

      width: 36rem;
      height: 30rem;
      max-width: 100vw;
      max-height: 100vh;
      overflow-y: scroll;

      & > :not(:last-child) {
        border-bottom: 2px solid #000000;
      }
    }

    form {
      width: 100%;
      display: flex;
      gap: 0.5rem;
      padding-top: 0.5rem;
      padding-bottom: 0.5rem;
    }

    form input {
        flex-grow: 1;
    }
  `

  constructor() {
    super()
    this._username = ""
    this._content = ""

    this._tags = []

    this.fetchTags()
    setInterval(() => this.fetchTags(), 3000)
  }

  onNameSubmit(e) {
    e.preventDefault()
  }

  onNameInput(e) {
    this._username = e.target.value
  }

  async onTagSubmit(e) {
    e.preventDefault()

    const content = this._content
    this._content = ""

    let body = { author: this._username, content: content, timestamp: (new Date()).getTime().toString() }
    await fetch("/tags/create", { method: "POST", body: JSON.stringify(body) })

    setTimeout(() => this.fetchTags(), 500)
  }

  onTagInput(e) {
    this._content = e.target.value
  }

  render() {
    return html`
      ${(this._username == "") ? this.renderUsernameInput() : ""}

      <div class="tags">${this.renderTags(this._tags)}</div>
      <form @submit=${this.onTagSubmit}>
        <input placeholder="Mensaje" @input=${this.onTagInput} .value=${this._content} maxlength="70" />
        <button>Enviar</button>
      </form>
      `
  }

  async fetchTags() {
    try {
      const response = await fetch("/tags/get")

      const { tags: tags } = await response.json()

      this._tags = (tags == "" ? [] : tags)
    } catch (error) {
      console.error('Error fetching data:', error)
    }
  }

  renderTags(tags) {
    return tags.map((tag) => html`<my-tag .tag=${tag}  />`)
  }

  renderUsernameInput() {
    return html`
      <div class="name-input-box">
        <h2>Introduzca un nombre de usuario:</h2>
        <form @submit=${this.onNameSubmit}>
          <input @change=${this.onNameInput} .value=${this._username} placeholder="Nombre de usuario" />
          <button>Ok</button>
        </form>
      </div>
      `
  }
}


customElements.define('tag-board', TagBoard)
