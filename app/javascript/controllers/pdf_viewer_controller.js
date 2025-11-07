import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pdf-viewer"
export default class extends Controller {
  static values = {
    url: String,
    copyrighted: Boolean,
    pages: String
  }

  async connect() {
    // Access PDF.js library from global scope
    const pdfjsLib = window.pdfjsLib

    if (!pdfjsLib) {
      console.error('PDF.js library not loaded')
      this.element.innerHTML = '<p class="text-red-600 p-4">PDF viewer not available. Please refresh the page.</p>'
      return
    }

    // Set worker path
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/build/pdf.worker.min.js'

    try {
      // Load the PDF document - PDF.js expects an object with url property
      const loadingTask = pdfjsLib.getDocument({ url: this.urlValue })
      this.pdf = await loadingTask.promise

      // Render all pages initially
      await this.renderPages()
    } catch (error) {
      console.error('Error loading PDF:', error)
      this.element.innerHTML = '<p class="text-red-600 p-4">Error loading PDF. Please try again.</p>'
    }
  }

  async renderPages(container = null) {
    // Find the container if not provided
    if (!container) {
      container = this.element.querySelector('.bg-gray-50, .dark\\:bg-gray-900')
      if (!container) {
        container = this.element
      }
    }

    const pageInput = this.pagesValue ? this.pagesValue.trim() : ''
    const pagesToRender = this.parsePageInput(pageInput, this.pdf.numPages)

    for (const pageNum of pagesToRender) {
      await this.renderPage(this.pdf, pageNum, container)
    }
  }

  parsePageInput(input, totalPages) {
    // If empty, return all pages
    if (!input) {
      return Array.from({ length: totalPages }, (_, i) => i + 1)
    }

    const pages = new Set()
    const parts = input.split(',')

    for (const part of parts) {
      const trimmed = part.trim()

      // Check for range (e.g., "2-9")
      if (trimmed.includes('-')) {
        const [start, end] = trimmed.split('-').map(n => parseInt(n.trim()))
        if (!isNaN(start) && !isNaN(end)) {
          for (let i = start; i <= end && i <= totalPages; i++) {
            if (i > 0) pages.add(i)
          }
        }
      } else {
        // Single page number
        const pageNum = parseInt(trimmed)
        if (!isNaN(pageNum) && pageNum > 0 && pageNum <= totalPages) {
          pages.add(pageNum)
        }
      }
    }

    return Array.from(pages).sort((a, b) => a - b)
  }

  async renderPage(pdf, pageNum, container) {
    const page = await pdf.getPage(pageNum)
    const viewport = page.getViewport({ scale: 1.5 })

    // Create canvas for this page
    const canvas = document.createElement('canvas')
    canvas.className = 'border-b border-gray-200 dark:border-gray-700 w-full'
    canvas.dataset.pageNumber = pageNum
    const context = canvas.getContext('2d')

    canvas.height = viewport.height
    canvas.width = viewport.width

    // Add canvas to container
    container.appendChild(canvas)

    // Render PDF page into canvas context
    const renderContext = {
      canvasContext: context,
      viewport: viewport
    }

    await page.render(renderContext).promise

    // Add watermark if copyrighted
    if (this.copyrightedValue) {
      this.addWatermark(context, canvas.width, canvas.height)
    }
  }

  addWatermark(context, width, height) {
    // Save the current context state
    context.save()

    // Set watermark style
    context.font = 'bold 60px Arial'
    context.fillStyle = 'rgba(255, 165, 0, 0.3)' // Orange with transparency
    context.textAlign = 'center'
    context.textBaseline = 'middle'

    // Rotate and position the watermark
    context.translate(width / 2, height / 2)
    context.rotate(-45 * Math.PI / 180)

    // Draw the watermark text
    context.fillText('COPYRIGHTED', 0, 0)

    // Restore the context state
    context.restore()
  }
}
