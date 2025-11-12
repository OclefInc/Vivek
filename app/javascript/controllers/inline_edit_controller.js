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
      await this.update()
    } else if (event.key === "Escape") {
      this.cancel()
    }
  }

  submitInputAsForm() {
  // Create a form element
  const form = document.createElement("form");
  form.action = this.urlValue;
  form.method = "POST";

  // Add CSRF token
  const csrf = document.querySelector('meta[name="csrf-token"]');
  if (csrf) {
    const csrfInput = document.createElement("input");
    csrfInput.type = "hidden";
    csrfInput.name = "authenticity_token";
    csrfInput.value = csrf.content;
    form.appendChild(csrfInput);
  }

  // Clone the input target and append to form
  const inputClone = this.inputTarget.cloneNode(true);
  inputClone.name = `lesson[${this.fieldValue}]`;
  form.appendChild(inputClone);

  // Optionally add _method for PATCH
  const methodInput = document.createElement("input");
  methodInput.type = "hidden";
  methodInput.name = "_method";
  methodInput.value = "PATCH";
  form.appendChild(methodInput);

  // Append form to body, submit, and remove after
  document.body.appendChild(form);
  form.submit();
  document.body.removeChild(form);
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

      // Use Turbo Stream for date field to update multiple elements
      const acceptHeader = this.fieldValue === "date"
        ? "text/vnd.turbo-stream.html"
        : "application/json"

      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": acceptHeader
        },
        body: formData
      })

      if (response.ok) {
        if (this.fieldValue === "date") {
          // Let Turbo handle the stream response
          const text = await response.text()
          Turbo.renderStreamMessage(text)
        } else {
          this.displayTarget.textContent = value
          this.displayTarget.classList.remove("hidden")
          this.inputTarget.classList.add("hidden")
        }
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
