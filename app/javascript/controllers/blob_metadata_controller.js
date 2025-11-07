import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="blob-metadata"
export default class extends Controller {
  static targets = ["viewMode", "editMode", "editButton", "copyrightCheckbox", "purchaseUrlInput"]

  connect() {
    console.log("Blob metadata controller connected")
    console.log("Controller element:", this.element)
    console.log("Controller element HTML:", this.element.innerHTML.substring(0, 200))
    console.log("Controller element children:", this.element.children)
    console.log("Has viewMode target:", this.hasViewModeTarget)
    console.log("Has editMode target:", this.hasEditModeTarget)
    console.log("Has editButton target:", this.hasEditButtonTarget)

    // Try to find the targets manually
    const viewMode = this.element.querySelector('[data-blob-metadata-target="viewMode"]')
    const editMode = this.element.querySelector('[data-blob-metadata-target="editMode"]')
    const allTargets = this.element.querySelectorAll('[data-blob-metadata-target]')
    console.log("Manual viewMode find:", viewMode)
    console.log("Manual editMode find:", editMode)
    console.log("All targets found:", allTargets.length, allTargets)
  }

  toggleEdit() {
    console.log("toggleEdit called")
    console.log("viewModeTarget:", this.viewModeTarget)
    console.log("editModeTarget:", this.editModeTarget)
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
    const purchaseUrl = this.purchaseUrlInputTarget.value

    console.log("Saving blob metadata:", { sgid, isCopyrighted, purchaseUrl })

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
