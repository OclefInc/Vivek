import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values = {
    url: String,
    field: String
  }

  edit() {
    this.displayTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  cancel() {
    this.inputTarget.value = this.displayTarget.textContent
    this.displayTarget.classList.remove("hidden")
    this.inputTarget.classList.add("hidden")
  }

  async save(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      await this.update()
    } else if (event.key === "Escape") {
      this.cancel()
    }
  }

  async update() {
    const value = this.inputTarget.value.trim()

    if (!value) {
      this.cancel()
      return
    }

    try {
      const formData = new FormData()
      formData.append("lesson[" + this.fieldValue + "]", value)
      formData.append("_method", "PATCH")

      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        this.displayTarget.textContent = value
        this.displayTarget.classList.remove("hidden")
        this.inputTarget.classList.add("hidden")
      } else {
        alert("Failed to update")
        this.cancel()
      }
    } catch (error) {
      console.error("Error:", error)
      alert("Failed to update")
      this.cancel()
    }
  }

  blur() {
    // Small delay to allow clicking cancel button
    setTimeout(() => this.update(), 200)
  }
}
