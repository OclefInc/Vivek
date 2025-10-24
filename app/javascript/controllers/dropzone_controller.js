import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import Dropzone from "dropzone"

Dropzone.autoDiscover = false

export default class extends Controller {
  static targets = ["input", "cameraButton"]
  static values = {
    captureMode: { type: String, default: "environment" } // "environment" for back camera, "user" for selfie
  }

  connect() {
    // console.log(Dropzone(this.element, { }))
    this.dropZone = createDropZone(this)
    this.hideFileInput()
    this.bindEvents()
    if (this.camera == 'true') {
      this.setupCameraButton()
    }
  }

  setupCameraButton() {
    // Create camera button if it doesn't exist
    if (!this.hasCameraButtonTarget) {
      const cameraButton = document.createElement("button")
      cameraButton.type = "button"
      cameraButton.className = "camera-capture-btn btn btn-outline-secondary mt-2 d-md-none"
      cameraButton.innerHTML = 'Take Photo'
      cameraButton.dataset.action = "click->dropzone--field#openCamera"
      cameraButton.dataset.dropzoneFieldTarget = "cameraButton"

      // Add it after the dropzone element
      this.element.appendChild(cameraButton)
    }

    // Create hidden file input for camera
    this.cameraInput = document.createElement("input")
    this.cameraInput.type = "file"
    this.cameraInput.accept = "image/*"
    this.cameraInput.capture = this.captureModeValue
    this.cameraInput.style.display = "none"
    this.cameraInput.addEventListener("change", this.handleCameraCapture.bind(this))
    this.element.appendChild(this.cameraInput)
  }

  // Method to open camera
  openCamera(event) {
    event.preventDefault()
    this.cameraInput.click()
  }

  // Handle captured photo
  handleCameraCapture(event) {
    const file = event.target.files[0]
    if (file) {
      // Add file to dropzone
      this.dropZone.addFile(file)
    }
  }

  // Private
  hideFileInput() {
    this.inputTarget.disabled = true
    this.inputTarget.style.display = "none"

    if (this.autoSubmit == 'true') {

      this.submitButton.style.display = "none"
    }

  }

  bindEvents() {
    this.dropZone.on("addedfile", (file) => {
      setTimeout(() => { file.accepted && createDirectUploadController(this, file).start() }, 500)
    })

    this.dropZone.on("removedfile", (file) => {
      file.controller && removeElement(file.controller.hiddenInput)
    })

    this.dropZone.on("canceled", (file) => {
      file.controller && file.controller.xhr.abort()
    })

    this.dropZone.on("processing", (file) => {
      this.submitButton.disabled = true
    })

    this.dropZone.on("queuecomplete", (file) => {

      if (this.autoSubmit == 'true') {

        if (this.turboSubmit == 'true') {
          Turbo.navigator.submitForm(this.form)
        } else {
          this.form.submit()
        }

      } else {
        this.submitButton.disabled = false
      }
    })
  }

  get headers() { return { "X-CSRF-Token": getMetaValue("csrf-token") } }

  get url() { return this.inputTarget.getAttribute("data-direct-upload-url") }

  get maxFiles() { return this.data.get("maxFiles") || 1 }

  get camera() { return this.inputTarget.getAttribute('data-camera') || 'false' }

  get autoSubmit() { return this.inputTarget.getAttribute('data-autosubmit') || 'true' }

  get turboSubmit() { return this.inputTarget.getAttribute('data-turbosubmit') || 'false' }

  get maxFileSize() { return this.element.dataset.dropzoneMaxFileSize || 5 }

  get acceptedFiles() { return this.element.dataset.dropzoneAcceptedFiles }

  get addRemoveLinks() { return this.data.get("addRemoveLinks") || true }

  get form() { return this.element.closest("form") }

  get submitButton() { return findElement(this.form, "input[type=submit], button[type=submit]") }

}

class DirectUploadController {
  constructor(source, file) {
    this.directUpload = createDirectUpload(file, source.url, this)
    this.source = source
    this.file = file
  }

  start() {
    this.file.controller = this
    this.hiddenInput = this.createHiddenInput()
    this.directUpload.create((error, attributes) => {
      if (error) {
        removeElement(this.hiddenInput)
        this.emitDropzoneError(error)
      } else {
        this.hiddenInput.value = attributes.signed_id
        this.emitDropzoneSuccess()
      }
    })
  }

  // Private
  createHiddenInput() {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = this.source.inputTarget.name
    insertAfter(input, this.source.inputTarget)
    return input
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr)
    this.emitDropzoneUploading()
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr
    this.xhr.upload.addEventListener("progress", event => this.uploadRequestDidProgress(event))
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element
    const progress = event.loaded / event.total * 100
    findElement(this.file.previewTemplate, ".dz-upload").style.width = `${progress}%`
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING
    this.source.dropZone.emit("processing", this.file)
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR
    this.source.dropZone.emit("error", this.file, error)
    this.source.dropZone.emit("complete", this.file)
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS
    this.source.dropZone.emit("success", this.file)
    this.source.dropZone.emit("complete", this.file)
  }
}

// Top level...
function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file)
}

function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller)
}

function createDropZone(controller) {
  return new Dropzone(controller.element, {
    url: controller.url,
    headers: controller.headers,
    maxFiles: controller.maxFiles,
    maxFilesize: controller.maxFileSize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: controller.addRemoveLinks,
    autoQueue: false,
    // Add these camera capture options
    dictDefaultMessage: "Drop files here or click to upload<br>(or take a photo with camera)",
    clickable: true,
    // Add a camera button alongside file selection
    previewTemplate: controller.previewTemplate || getDefaultPreviewTemplate()
  })
}

// Add this helper function to get a template with camera button
function getDefaultPreviewTemplate() {
  return `
    <div class="dz-preview dz-file-preview">
      <div class="dz-image"><img data-dz-thumbnail /></div>
      <div class="dz-details">
        <div class="dz-size"><span data-dz-size></span></div>
        <div class="dz-filename"><span data-dz-name></span></div>
      </div>
      <div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div>
      <div class="dz-error-message"><span data-dz-errormessage></span></div>
      <div class="dz-success-mark"><svg width="54" height="54" viewBox="0 0 54 54" fill="white" xmlns="http://www.w3.org/2000/svg">
          <path d="M10.2071 29.7929L14.2929 25.7071C14.6834 25.3166 15.3166 25.3166 15.7071 25.7071L21.2929 31.2929C21.6834 31.6834 22.3166 31.6834 22.7071 31.2929L38.2929 15.7071C38.6834 15.3166 39.3166 15.3166 39.7071 15.7071L43.7929 19.7929C44.1834 20.1834 44.1834 20.8166 43.7929 21.2071L22.7071 42.2929C22.3166 42.6834 21.6834 42.6834 21.2929 42.2929L10.2071 31.2071C9.81658 30.8166 9.81658 30.1834 10.2071 29.7929Z"></path>
        </svg></div>
      <div class="dz-error-mark"><svg width="54" height="54" viewBox="0 0 54 54" fill="white" xmlns="http://www.w3.org/2000/svg">
          <path d="M26.2929 20.2929L19.2071 13.2071C18.8166 12.8166 18.1834 12.8166 17.7929 13.2071L13.2071 17.7929C12.8166 18.1834 12.8166 18.8166 13.2071 19.2071L20.2929 26.2929C20.6834 26.6834 20.6834 27.3166 20.2929 27.7071L13.2071 34.7929C12.8166 35.1834 12.8166 35.8166 13.2071 36.2071L17.7929 40.7929C18.1834 41.1834 18.8166 41.1834 19.2071 40.7929L26.2929 33.7071C26.6834 33.3166 27.3166 33.3166 27.7071 33.7071L34.7929 40.7929C35.1834 41.1834 35.8166 41.1834 36.2071 40.7929L40.7929 36.2071C41.1834 35.8166 41.1834 35.1834 40.7929 34.7929L33.7071 27.7071C33.3166 27.3166 33.3166 26.6834 33.7071 26.2929L40.7929 19.2071C41.1834 18.8166 41.1834 18.1834 40.7929 17.7929L36.2071 13.2071C35.8166 12.8166 35.1834 12.8166 34.7929 13.2071L27.7071 20.2929C27.3166 20.6834 26.6834 20.6834 26.2929 20.2929Z"></path>
        </svg></div>
    </div>
  `;
}