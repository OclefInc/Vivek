import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "urlField"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (this.checkboxTarget.checked) {
      this.urlFieldTarget.classList.remove("hidden")
    } else {
      this.urlFieldTarget.classList.add("hidden")
    }
  }
}
