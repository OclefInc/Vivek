import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pdf-viewer"
export default class extends Controller {
  static values = {
    url: String,
    copyrighted: Boolean
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
      const pdf = await loadingTask.promise

      // Render all pages
      for (let pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
        await this.renderPage(pdf, pageNum)
      }
    } catch (error) {
      console.error('Error loading PDF:', error)
      this.element.innerHTML = '<p class="text-red-600 p-4">Error loading PDF. Please try again.</p>'
    }
  }

  async renderPage(pdf, pageNum) {
    const page = await pdf.getPage(pageNum)
    const viewport = page.getViewport({ scale: 1.5 })

    // Create canvas for this page
    const canvas = document.createElement('canvas')
    canvas.className = 'border-b border-gray-200 dark:border-gray-700 w-full'
    const context = canvas.getContext('2d')

    canvas.height = viewport.height
    canvas.width = viewport.width

    // Add canvas to container
    this.element.appendChild(canvas)

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
