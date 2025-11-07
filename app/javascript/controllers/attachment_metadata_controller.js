import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attachment-metadata"
export default class extends Controller {
  static targets = ["editor", "modal", "copyrightCheckbox", "purchaseUrl", "blobId"]

  connect() {
    // Listen for trix-attachment-add events
    if (this.hasEditorTarget) {
      this.editorTarget.addEventListener("trix-attachment-add", this.handleAttachmentAdd.bind(this))
    }
  }

  disconnect() {
    if (this.hasEditorTarget) {
      this.editorTarget.removeEventListener("trix-attachment-add", this.handleAttachmentAdd.bind(this))
    }
  }

  handleAttachmentAdd(event) {
    const attachment = event.attachment

    // Only handle new file uploads (not existing attachments being inserted)
    if (attachment.file) {
      // Store the attachment to update later
      this.currentAttachment = attachment

      // Wait for the upload to complete before showing modal
      // Listen for trix-attachment-upload event
      const uploadCompleteHandler = (uploadEvent) => {
        if (uploadEvent.attachment === attachment) {
          this.editorTarget.removeEventListener("trix-attachment-upload", uploadCompleteHandler)

          // Show modal after upload completes
          setTimeout(() => {
            this.showModal()
          }, 100)
        }
      }

      this.editorTarget.addEventListener("trix-attachment-upload", uploadCompleteHandler)
    }
  }

  showModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
    }
  }

  hideModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
    }
  }

  save(event) {
    event.preventDefault()

    const isCopyrighted = this.hasCopyrightCheckboxTarget && this.copyrightCheckboxTarget.checked
    const purchaseUrl = this.hasPurchaseUrlTarget ? this.purchaseUrlTarget.value.trim() : ""

    // Validate: require purchase URL if copyrighted
    if (isCopyrighted && !purchaseUrl) {
      alert("Purchase link is required for copyrighted materials.")
      if (this.hasPurchaseUrlTarget) {
        this.purchaseUrlTarget.focus()
      }
      return
    }

    // Get the blob signed ID from the attachment
    if (this.currentAttachment) {
      // Try different ways to get the SGID
      let sgid = null

      // Method 1: Check attachment attributes
      if (this.currentAttachment.attachment && this.currentAttachment.attachment.sgid) {
        sgid = this.currentAttachment.attachment.sgid
      }
      // Method 2: Check attributes.values
      else if (this.currentAttachment.attachment?.attributes?.values?.sgid) {
        sgid = this.currentAttachment.attachment.attributes.values.sgid
      }
      // Method 3: Direct sgid property
      else if (this.currentAttachment.sgid) {
        sgid = this.currentAttachment.sgid
      }

      if (sgid) {
        // Send metadata to server
        this.updateBlobMetadata(sgid, isCopyrighted, purchaseUrl)
      }
    }

    this.hideModal()
    this.reset()
  }

  cancel(event) {
    event.preventDefault()
    this.hideModal()
    this.reset()
  }

  reset() {
    if (this.hasCopyrightCheckboxTarget) {
      this.copyrightCheckboxTarget.checked = false
    }
    if (this.hasPurchaseUrlTarget) {
      this.purchaseUrlTarget.value = ""
    }
    this.currentAttachment = null
  }

  async updateBlobMetadata(sgid, copyrighted, purchaseUrl) {
    try {
      const response = await fetch('/attachments/update_metadata', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          sgid: sgid,
          copyrighted: copyrighted,
          purchase_url: purchaseUrl
        })
      })

      const data = await response.json()

      if (!response.ok) {
        console.error("Failed to update metadata:", data)
      }
    } catch (error) {
      console.error("Error updating metadata:", error)
    }
  }
}