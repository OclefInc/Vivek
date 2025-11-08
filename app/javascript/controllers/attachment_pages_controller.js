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

      // When entering edit mode, show all pages in PDF viewer
      if (isEnteringEditMode) {
        const pdfViewerElement = this.element.nextElementSibling
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

      // Restore original pages when canceling
      if (this.originalPages !== undefined) {
        const pdfViewerElement = this.element.nextElementSibling
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

    // Save to database
    if (sgid) {
      this.saveToDatabase(sgid, pages)
    }

    // Update the data-pages attribute so it persists
    this.element.dataset.pages = pages

    // Clear originalPages so cancel doesn't restore old value
    this.originalPages = undefined

    // Trigger the PDF viewer to re-render with new pages
    // The pdf-viewer is the next sibling element after attachment-pages
    const pdfViewerElement = this.element.nextElementSibling
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
    }
  }

  async saveToDatabase(sgid, pages) {
    try {
      const response = await fetch('/attachments/update_pages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          sgid: sgid,
          pages: pages
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
