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

  async toggleEdit() {
    if (this.hasEditFormTarget && this.hasEditButtonTarget) {
      const isEnteringEditMode = this.editFormTarget.classList.contains("hidden")

      this.editFormTarget.classList.toggle("hidden")
      this.editButtonTarget.classList.toggle("hidden")

      // Hide/show the copyright button
      const copyrightButton = this.element.querySelector('[data-blob-metadata-target="editButton"]')
      if (copyrightButton) {
        copyrightButton.classList.toggle("hidden")
      }

      // When entering edit mode, show all pages in PDF viewer
      if (isEnteringEditMode) {
        // Find the pdf-viewer (go back through siblings to find it)
        let pdfViewerElement = this.element.previousElementSibling
        while (pdfViewerElement && !pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
          pdfViewerElement = pdfViewerElement.previousElementSibling
        }
        if (pdfViewerElement && pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
          const pdfViewer = this.application.getControllerForElementAndIdentifier(pdfViewerElement, "pdf-viewer")
          if (pdfViewer) {
            // Store original pages value
            this.originalPages = pdfViewer.pagesValue
            // Set to empty to show all pages
            pdfViewer.pagesValue = ""
            await pdfViewer.rerender()
          }
        }
      }
    }
  }

  async cancel() {
    if (this.hasEditFormTarget && this.hasEditButtonTarget) {
      this.editFormTarget.classList.add("hidden")
      this.editButtonTarget.classList.remove("hidden")

      // Show the copyright button again
      const copyrightButton = this.element.querySelector('[data-blob-metadata-target="editButton"]')
      if (copyrightButton) {
        copyrightButton.classList.remove("hidden")
      }

      // Restore original pages when canceling
      if (this.originalPages !== undefined) {
        // Find the pdf-viewer (go back through siblings to find it)
        let pdfViewerElement = this.element.previousElementSibling
        while (pdfViewerElement && !pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
          pdfViewerElement = pdfViewerElement.previousElementSibling
        }
        if (pdfViewerElement && pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
          const pdfViewer = this.application.getControllerForElementAndIdentifier(pdfViewerElement, "pdf-viewer")
          if (pdfViewer) {
            pdfViewer.pagesValue = this.originalPages
            await pdfViewer.rerender()
            this.originalPages = undefined
          }
        }
      }
    }
  }

  async save() {
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


    // Update the data-pages attribute so it persists
    this.element.dataset.pages = pages
    const pagesDisplay = document.getElementById("pages-display")
    if (pagesDisplay) {
      pagesDisplay.textContent = pages || "All"
    }

    // Clear originalPages so cancel doesn't restore old value
    this.originalPages = undefined

    // Trigger the PDF viewer to re-render with new pages
    // Find the pdf-viewer by going back through previous siblings
    let pdfViewerElement = this.element.previousElementSibling
    while (pdfViewerElement && !pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
      pdfViewerElement = pdfViewerElement.previousElementSibling
    }
    console.log('Looking for pdf-viewer element:', pdfViewerElement)
    if (pdfViewerElement && pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
      const pdfViewer = this.application.getControllerForElementAndIdentifier(pdfViewerElement, "pdf-viewer")
      console.log('Found pdf-viewer controller:', pdfViewer)
      if (pdfViewer) {
        console.log('Updating pages from', pdfViewer.pagesValue, 'to', pages)
        pdfViewer.pagesValue = pages
        console.log('Calling rerender')
        await pdfViewer.rerender()
      }
    }

    // Hide edit mode (won't restore originalPages since we cleared it)
    if (this.hasEditFormTarget && this.hasEditButtonTarget) {
      this.editFormTarget.classList.add("hidden")
      this.editButtonTarget.classList.remove("hidden")

      // Show the copyright button again
      const copyrightButton = this.element.querySelector('[data-blob-metadata-target="editButton"]')
      if (copyrightButton) {
        copyrightButton.classList.remove("hidden")
      }
    }
  }

  async saveToDatabase(sgid, pages, recordType, recordId) {
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
      }
    } catch (error) {
      console.error("Error saving pages:", error)
    }
  }
}
