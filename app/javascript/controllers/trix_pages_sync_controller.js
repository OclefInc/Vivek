import { Controller } from "@hotwired/stimulus"

// Syncs pages data between stored action-text-attachment elements and Trix editor
export default class extends Controller {
  static targets = ["editor"]

  connect() {
    // Listen to trix-before-initialize to modify the hidden input BEFORE Trix reads it
    this.editorTarget.addEventListener('trix-before-initialize', this.syncPagesToTrix.bind(this))
  }

  syncPagesToTrix() {
    // Find the hidden input element
    const hiddenInput = this.editorTarget.previousElementSibling
    if (!hiddenInput || hiddenInput.type !== 'hidden') return

    // Decode the HTML-encoded value
    const textarea = document.createElement('textarea')
    textarea.innerHTML = hiddenInput.value
    const decodedHTML = textarea.value

    // Parse to extract pages data from action-text-attachment elements
    const parser = new DOMParser()
    const doc = parser.parseFromString(decodedHTML, 'text/html')
    const pagesMap = new Map()

    // Build a map of SGID -> pages from stored action-text-attachment elements
    doc.querySelectorAll('action-text-attachment').forEach(el => {
      const sgid = el.getAttribute('sgid')
      const pages = el.getAttribute('data-pages')
      if (sgid && pages) {
        pagesMap.set(sgid, pages)
      }
    })

    // If no pages data found, nothing to sync
    if (pagesMap.size === 0) return

    // Now find figure elements and update their data-trix-attachment JSON
    let modified = false

    doc.querySelectorAll('figure[data-trix-attachment]').forEach(figure => {
      try {
        // Parse the existing attachment JSON
        const attachmentJSON = figure.getAttribute('data-trix-attachment')
        const attachment = JSON.parse(attachmentJSON)

        // Check if we have pages data for this SGID
        if (attachment.sgid && pagesMap.has(attachment.sgid)) {
          // Update the pages in the JSON
          attachment.pages = pagesMap.get(attachment.sgid)

          // Write back the updated JSON to the figure element
          figure.setAttribute('data-trix-attachment', JSON.stringify(attachment))
          modified = true
        }
      } catch (e) {
        console.error('Error parsing trix attachment JSON:', e)
      }
    })

    // If we modified anything, update the hidden input with the new HTML
    if (modified) {
      const updatedHTML = doc.body.innerHTML
      hiddenInput.value = updatedHTML
    }
  }
}
