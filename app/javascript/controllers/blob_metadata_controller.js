import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="blob-metadata"
export default class extends Controller {
  static targets = ["viewMode", "editMode", "editButton", "copyrightCheckbox", "purchaseUrlInput"]

  toggleEdit() {
    this.viewModeTarget.classList.add("hidden")
    this.editModeTarget.classList.remove("hidden")
    this.editButtonTarget.classList.add("hidden")
  }

  cancel() {
    this.viewModeTarget.classList.remove("hidden")
    this.editModeTarget.classList.add("hidden")
    this.editButtonTarget.classList.remove("hidden")
  }

  async save(event) {
    const button = event.currentTarget
    const sgid = button.dataset.blobSgid
    const isCopyrighted = this.copyrightCheckboxTarget.checked
    const purchaseUrl = this.purchaseUrlInputTarget.value.trim()

    // Validate: require purchase URL if copyrighted
    if (isCopyrighted && !purchaseUrl) {
      alert("Purchase link is required for copyrighted materials.")
      this.purchaseUrlInputTarget.focus()
      return
    }

    try {
      const response = await fetch('/attachments/update_metadata', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          sgid: sgid,
          copyrighted: isCopyrighted,
          purchase_url: purchaseUrl
        })
      })

      const data = await response.json()
      console.log("Server response:", data)

      if (response.ok) {
        console.log("Metadata updated successfully!")
        // Reload the page to show updated copyright info
        window.location.reload()
      } else {
        console.error("Failed to update metadata:", data)
        alert("Failed to update copyright information. Please try again.")
      }
    } catch (error) {
      console.error("Error updating metadata:", error)
      alert("An error occurred. Please try again.")
    }
  }
}
