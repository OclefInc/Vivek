import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input", "form"]
  static values = {
    url: String,
    field: String
  }

  edit() {
    this.displayTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
    this.inputTarget.select()

    // For date inputs, automatically show the calendar picker after a small delay
    if (this.inputTarget.type === "date") {
      setTimeout(() => {
        this.inputTarget.showPicker()
      }, 10)
    }
  }

  cancel() {
    this.inputTarget.value = this.displayTarget.textContent
    this.displayTarget.classList.remove("hidden")
    this.inputTarget.classList.add("hidden")
  }

  async save(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.formTarget.requestSubmit()
    } else if (event.key === "Escape") {
      this.cancel()
    }
  }

  blur() {
    // Small delay to allow clicking cancel button
    setTimeout(() => this.formTarget.requestSubmit(), 100)
  }
}
