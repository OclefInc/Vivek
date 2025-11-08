import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="blob-metadata"
// Manages blob-level metadata (copyrighted, purchase_url) shared across all attachments
export default class extends Controller {
  static targets = ["viewMode", "editMode", "editButton", "copyrightCheckbox", "purchaseUrlInput"]

  toggleEdit() {
    this.viewModeTarget.classList.add("hidden")
    this.editModeTarget.classList.remove("hidden")
    this.editButtonTarget.classList.add("hidden")

    // Hide the pages button
    const pagesButton = this.element.querySelector('[data-attachment-pages-target="editButton"]')
    if (pagesButton) {
      pagesButton.classList.add("hidden")
    }
  }

  cancel() {
    this.viewModeTarget.classList.remove("hidden")
    this.editModeTarget.classList.add("hidden")
    this.editButtonTarget.classList.remove("hidden")

    // Show the pages button again
    const pagesButton = this.element.querySelector('[data-attachment-pages-target="editButton"]')
    if (pagesButton) {
      pagesButton.classList.remove("hidden")
    }
  }

  updateBanner(isCopyrighted, purchaseUrl) {
    // Find the copyright banner - it's a sibling of the controls container
    // Go up to find the parent that contains both the banner and controls
    let banner = this.element.previousElementSibling
    console.log('Checking previous sibling:', banner)

    // If previous sibling has data-copyright-banner, that's our banner
    if (banner && banner.hasAttribute('data-copyright-banner')) {
      console.log('Found banner as previous sibling')
    } else {
      // Otherwise search in document
      banner = document.querySelector('[data-copyright-banner]')
      console.log('Searched document for banner:', banner)
    }

    if (!banner) {
      console.error('Banner not found!')
      return
    }

    const innerDiv = banner.querySelector('.flex')
    console.log('Found inner div:', innerDiv)
    if (!innerDiv) {
      console.error('Inner div not found!')
      return
    }

    console.log('Updating banner - copyrighted:', isCopyrighted, 'purchaseUrl:', purchaseUrl)

    if (isCopyrighted) {
      // Show copyrighted material with purchase link
      innerDiv.innerHTML = `
        <p class="text-sm font-medium text-amber-800">Copyrighted Material</p>
        ${purchaseUrl ? `
          <p class="text-sm text-amber-700 mt-1">
            Purchase:
            <a href="${purchaseUrl}" target="_blank" rel="noopener noreferrer"
               class="text-blue-600 hover:text-blue-800 underline font-medium">Click Here</a>
          </p>
        ` : ''}
      `
    } else {
      // Show non-copyrighted material with download link
      // Find the pdf-viewer by going back through siblings
      let pdfViewerElement = this.element.previousElementSibling
      while (pdfViewerElement && !pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
        pdfViewerElement = pdfViewerElement.previousElementSibling
      }
      const blobUrl = pdfViewerElement?.dataset.pdfViewerUrlValue
      innerDiv.innerHTML = `
        <p class="text-sm font-medium text-amber-800">Non Copyrighted Material</p>
        <p class="text-sm text-amber-700 mt-1">
          Download:
          <a href="${blobUrl}?disposition=attachment" target="_blank" rel="noopener noreferrer"
             class="text-blue-600 hover:text-blue-800 underline font-medium">Click Here</a>
        </p>
      `
    }

    console.log('Banner updated, new HTML:', innerDiv.innerHTML)
  }  async updatePdfWatermark(isCopyrighted) {
    // Find the PDF viewer by going back through siblings
    let pdfViewerElement = this.element.previousElementSibling
    while (pdfViewerElement && !pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
      pdfViewerElement = pdfViewerElement.previousElementSibling
    }
    if (pdfViewerElement && pdfViewerElement.dataset.controller?.includes('pdf-viewer')) {
      const pdfViewer = this.application.getControllerForElementAndIdentifier(pdfViewerElement, "pdf-viewer")
      if (pdfViewer) {
        pdfViewer.copyrightedValue = isCopyrighted
        await pdfViewer.rerender()
      }
    }
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
      // Only save blob-level metadata (copyrighted and purchase_url)
      // Pages are handled by attachment-pages controller
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

        // Update the copyright banner
        this.updateBanner(isCopyrighted, purchaseUrl)

        // Update PDF viewer to show/hide watermark
        this.updatePdfWatermark(isCopyrighted)

        // Switch back to view mode
        this.cancel()
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
