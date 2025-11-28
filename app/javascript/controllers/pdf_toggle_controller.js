import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pdf-toggle"
export default class extends Controller {
    connect() {
        this.checkForPdfAttachments()
    }

    checkForPdfAttachments() {
        // Look for PDF viewer elements in the description
        const pdfViewers = this.element.querySelectorAll('[data-controller*="pdf-viewer"]')

        if (pdfViewers.length > 0) {
            // Create a "Show Music" button for each PDF
            pdfViewers.forEach(viewer => {
                // Check if button already exists for this viewer
                const existingButton = viewer.previousElementSibling?.classList.contains('pdf-show-button')
                if (existingButton) {
                    return
                }

                // Create the button container
                const buttonContainer = document.createElement('div')
                buttonContainer.className = 'text-center py-8 pdf-show-button'

                const button = document.createElement('button')
                button.className = 'text-blue-400 hover:text-blue-300 underline font-medium transition-colors'
                button.textContent = 'Show Music'
                button.addEventListener('click', () => this.togglePdf(viewer, buttonContainer))

                buttonContainer.appendChild(button)

                // Insert button before the viewer
                viewer.parentNode.insertBefore(buttonContainer, viewer)

                // Make sure admin-only elements are hidden initially by adding the class if not present
                const adminElements = viewer.querySelectorAll('.admin-only')
                adminElements.forEach(el => {
                    if (!el.classList.contains('admin-only')) {
                        el.classList.add('admin-only')
                    }
                })
            })
        }
    }

    togglePdf(viewer, buttonContainer) {
        // Toggle the button text
        const button = buttonContainer.querySelector('button')
        const isShowing = button.textContent === 'Hide Music'

        if (isShowing) {
            button.textContent = 'Show Music'
        } else {
            button.textContent = 'Hide Music'
        }

        // Toggle admin-only class on the viewer itself
        viewer.classList.toggle('admin-only')

        // Find the next siblings which are also admin-only
        let nextElement = viewer.nextElementSibling
        nextElement.classList.toggle('admin-only')

        // If showing for the first time, trigger PDF loading
        if (!isShowing) {
            const pdfController = this.application.getControllerForElementAndIdentifier(viewer, 'pdf-viewer')
            if (pdfController && typeof pdfController.initializePdf === 'function' && !pdfController.pdf) {
                pdfController.initializePdf()
            }
        }
    }
}
