import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attachment-pages"
// Manages the pages-to-display attribute for individual PDF attachments
export default class extends Controller {
  static targets = ["editButton", "pagesInput", "editForm"]

  connect() {
    // Populate the input field from the action-text-attachment element
    if (this.hasPagesInputTarget) {
      this.pagesInputTarget.value = this.element.dataset.pages || ""
    }
  }

  toggleEdit() {
    if (this.hasEditFormTarget && this.hasEditButtonTarget) {
      this.editFormTarget.classList.toggle("hidden")
      this.editButtonTarget.classList.toggle("hidden")
    }
  }

  cancel() {
    if (this.hasEditFormTarget && this.hasEditButtonTarget) {
      this.editFormTarget.classList.add("hidden")
      this.editButtonTarget.classList.remove("hidden")
    }
  }

  save() {
    if (!this.hasPagesInputTarget) {
      return
    }

    const pages = this.pagesInputTarget.value.trim()

    // Get SGID from the controller element
    const sgid = this.element.dataset.blobSgid

    // Extract record type and ID from the nearest turbo-frame
    const turboFrame = this.element.closest('turbo-frame')
    let recordType = null
    let recordId = null

    if (turboFrame && turboFrame.id) {
      // Parse the turbo-frame id to extract record type and ID
      // e.g., "lesson_67_description" -> recordType: "Lesson", recordId: 67
      const match = turboFrame.id.match(/^(\w+)_(\d+)/)
      if (match) {
        recordType = match[1].charAt(0).toUpperCase() + match[1].slice(1) // Capitalize
        recordId = match[2]
      }
    }

    // Save to database
    if (sgid && recordType && recordId) {
      this.saveToDatabase(sgid, pages, recordType, recordId)
    }

    // Trigger the PDF viewer to re-render with new pages
    const pdfViewerElement = this.element.parentElement.querySelector('[data-controller*="pdf-viewer"]')
    if (pdfViewerElement) {
      const pdfViewer = this.application.getControllerForElementAndIdentifier(pdfViewerElement, "pdf-viewer")
      if (pdfViewer) {
        pdfViewer.pagesValue = pages
        pdfViewer.renderPages()
      }
    }

    // Hide edit mode
    this.cancel()
  }  async saveToDatabase(sgid, pages, recordType, recordId) {
    try {
      const response = await fetch('/attachments/update_pages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          sgid: sgid,
          pages: pages,
          record_type: recordType,
          record_id: recordId
        })
      })

      const data = await response.json()

      if (!response.ok) {
        console.error("Failed to save pages:", data)
      } else {
        console.log("Pages saved successfully to database")
        // Reload the page to show updated pdf rendering
        window.location.reload()
      }
    } catch (error) {
      console.error("Error saving pages:", error)
    }
  }
}
