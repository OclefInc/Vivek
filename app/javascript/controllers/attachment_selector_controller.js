import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attachment-selector"
export default class extends Controller {
  static targets = ["select", "editor"]

  connect() {
    console.log("Attachment selector controller connected!")
    console.log("Editor target:", this.hasEditorTarget)
    console.log("Select target:", this.hasSelectTarget)
  }

  insert(event) {
    console.log("Insert method called")
    const option = event.target.options[event.target.selectedIndex]
    const sgid = option.value
    console.log("SGID:", sgid)

    if (!sgid) return

    // Get the Trix editor element
    const trixEditor = this.editorTarget
    console.log("Trix editor:", trixEditor)

    // Get blob details from data attributes
    const filename = option.dataset.filename
    const contentType = option.dataset.contentType
    const byteSize = parseInt(option.dataset.byteSize)
    const url = option.dataset.url

    console.log("Blob details:", { filename, contentType, byteSize, url })

    // Create attachment with proper attributes
    // Note: Metadata (copyrighted, purchase_url, pages) is stored on the blob itself
    // and will be automatically available when the attachment is rendered
    // Add 'derived' attribute to indicate this attachment was reused, not uploaded
    // Add 'pages' attribute to specify which pages to show (per-attachment, not per-blob)
    const attachment = new Trix.Attachment({
      sgid: sgid,
      contentType: contentType,
      filename: filename,
      filesize: byteSize,
      href: url,
      url: url,
      derived: true,
      pages: "" // Empty string means show all pages; user can edit later
    })

    console.log("Attachment created:", attachment)

    // Insert the attachment at the current cursor position
    trixEditor.editor.insertAttachment(attachment)

    // Reset the select dropdown
    event.target.value = ""
  }
}
