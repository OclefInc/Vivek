import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "preview", "modal", "canvas", "existingAvatar", "existingContainer", "cropXField", "cropYField", "cropWidthField", "cropHeightField"]
    static values = {
        aspectRatio: { type: Number, default: 1 }
    }

    connect() {
        this.isDragging = false
        this.isResizing = false
        this.resizeCorner = null
        this.startX = 0
        this.startY = 0
        this.cropX = 0
        this.cropY = 0
        this.cropSize = 200
        this.scale = 1
        this.image = null
        this.isEditingExisting = false
    } openCropper(event) {
        const file = event.target.files[0]
        if (!file) return

        this.isEditingExisting = false
        const reader = new FileReader()
        reader.onload = (e) => {
            this.image = new Image()
            this.image.onload = () => {
                this.showModal()
                this.drawImage()
            }
            this.image.src = e.target.result
        }
        reader.readAsDataURL(file)
    }

    editExisting(event) {
        event.preventDefault()
        if (!this.hasExistingAvatarTarget) return

        this.isEditingExisting = true
        this.image = new Image()
        this.image.crossOrigin = "anonymous"
        this.image.onload = () => {
            this.showModal()
            this.drawImage()
        }
        // Use the original image URL from data attribute
        const originalUrl = this.existingAvatarTarget.dataset.originalUrl
        this.image.src = originalUrl || this.existingAvatarTarget.src
    }

    showModal() {
        this.modalTarget.classList.remove("hidden")
        document.body.style.overflow = "hidden"
    }

    hideModal() {
        this.modalTarget.classList.add("hidden")
        document.body.style.overflow = ""
    }

    drawImage() {
        const canvas = this.canvasTarget
        const ctx = canvas.getContext("2d")

        // Set canvas size
        const maxWidth = 600
        const maxHeight = 600
        let width = this.image.width
        let height = this.image.height

        if (width > maxWidth || height > maxHeight) {
            const ratio = Math.min(maxWidth / width, maxHeight / height)
            width = width * ratio
            height = height * ratio
        }

        canvas.width = width
        canvas.height = height
        this.scale = width / this.image.width

        // Draw image
        ctx.drawImage(this.image, 0, 0, width, height)

        // Initialize crop area
        const existingX = parseFloat(this.cropXFieldTarget.value)
        const existingY = parseFloat(this.cropYFieldTarget.value)
        const existingWidth = parseFloat(this.cropWidthFieldTarget.value)

        if (this.isEditingExisting && !isNaN(existingX) && !isNaN(existingY) && !isNaN(existingWidth)) {
            this.cropX = existingX * this.scale
            this.cropY = existingY * this.scale
            this.cropSize = existingWidth * this.scale
        } else {
            // Initialize crop area in center
            this.cropSize = Math.min(width, height) * 0.7
            this.cropX = (width - this.cropSize) / 2
            this.cropY = (height - this.cropSize) / 2
        }

        this.drawCropArea()
    }

    drawCropArea() {
        const canvas = this.canvasTarget
        const ctx = canvas.getContext("2d")

        // Redraw image
        ctx.drawImage(this.image, 0, 0, canvas.width, canvas.height)

        // Draw overlay
        ctx.fillStyle = "rgba(0, 0, 0, 0.5)"
        ctx.fillRect(0, 0, canvas.width, canvas.height)

        // Clear crop area
        ctx.clearRect(this.cropX, this.cropY, this.cropSize, this.cropSize)
        ctx.drawImage(
            this.image,
            this.cropX / this.scale,
            this.cropY / this.scale,
            this.cropSize / this.scale,
            this.cropSize / this.scale,
            this.cropX,
            this.cropY,
            this.cropSize,
            this.cropSize
        )

        // Draw border
        ctx.strokeStyle = "#14b8a6"
        ctx.lineWidth = 2
        ctx.strokeRect(this.cropX, this.cropY, this.cropSize, this.cropSize)

        // Draw corners
        this.drawCorner(ctx, this.cropX, this.cropY)
        this.drawCorner(ctx, this.cropX + this.cropSize, this.cropY)
        this.drawCorner(ctx, this.cropX, this.cropY + this.cropSize)
        this.drawCorner(ctx, this.cropX + this.cropSize, this.cropY + this.cropSize)
    }

    drawCorner(ctx, x, y) {
        ctx.fillStyle = "#14b8a6"
        ctx.fillRect(x - 4, y - 4, 8, 8)
    }

    startDrag(event) {
        const rect = this.canvasTarget.getBoundingClientRect()
        const x = event.clientX - rect.left
        const y = event.clientY - rect.top

        const handleSize = 12

        // Check if clicking on a corner handle
        const corners = [
            { name: 'tl', x: this.cropX, y: this.cropY },
            { name: 'tr', x: this.cropX + this.cropSize, y: this.cropY },
            { name: 'bl', x: this.cropX, y: this.cropY + this.cropSize },
            { name: 'br', x: this.cropX + this.cropSize, y: this.cropY + this.cropSize }
        ]

        for (const corner of corners) {
            if (Math.abs(x - corner.x) <= handleSize && Math.abs(y - corner.y) <= handleSize) {
                this.isResizing = true
                this.resizeCorner = corner.name
                this.startX = x
                this.startY = y
                this.startCropX = this.cropX
                this.startCropY = this.cropY
                this.startCropSize = this.cropSize
                return
            }
        }

        // Check if click is inside crop area for dragging
        if (x >= this.cropX && x <= this.cropX + this.cropSize &&
            y >= this.cropY && y <= this.cropY + this.cropSize) {
            this.isDragging = true
            this.startX = x - this.cropX
            this.startY = y - this.cropY
        }
    }

    drag(event) {
        if (!this.isDragging && !this.isResizing) return

        const rect = this.canvasTarget.getBoundingClientRect()
        const x = event.clientX - rect.left
        const y = event.clientY - rect.top

        if (this.isResizing) {
            const deltaX = x - this.startX
            const deltaY = y - this.startY
            const maxSize = Math.min(this.canvasTarget.width, this.canvasTarget.height)

            // Use the larger delta to maintain square aspect ratio
            let delta = Math.max(Math.abs(deltaX), Math.abs(deltaY))
            if (deltaX < 0 || deltaY < 0) {
                delta = -delta
            }

            let newSize = this.startCropSize
            let newX = this.startCropX
            let newY = this.startCropY

            switch (this.resizeCorner) {
                case 'tl': // Top-left: move top-left, keep bottom-right fixed
                    newSize = this.startCropSize - delta
                    newX = this.startCropX + delta
                    newY = this.startCropY + delta
                    break
                case 'tr': // Top-right: move top-right, keep bottom-left fixed
                    newSize = this.startCropSize + delta
                    newY = this.startCropY - delta
                    break
                case 'bl': // Bottom-left: move bottom-left, keep top-right fixed
                    newSize = this.startCropSize + delta
                    newX = this.startCropX - delta
                    break
                case 'br': // Bottom-right: move bottom-right, keep top-left fixed
                    newSize = this.startCropSize + delta
                    break
            }

            // Enforce minimum and maximum size
            if (newSize >= 100 && newSize <= maxSize) {
                // Ensure crop stays within bounds
                newX = Math.max(0, Math.min(newX, this.canvasTarget.width - newSize))
                newY = Math.max(0, Math.min(newY, this.canvasTarget.height - newSize))

                if (newX >= 0 && newY >= 0 &&
                    newX + newSize <= this.canvasTarget.width &&
                    newY + newSize <= this.canvasTarget.height) {
                    this.cropSize = newSize
                    this.cropX = newX
                    this.cropY = newY
                }
            }
        } else if (this.isDragging) {
            this.cropX = Math.max(0, Math.min(x - this.startX, this.canvasTarget.width - this.cropSize))
            this.cropY = Math.max(0, Math.min(y - this.startY, this.canvasTarget.height - this.cropSize))
        }

        this.drawCropArea()
    }

    stopDrag() {
        this.isDragging = false
        this.isResizing = false
        this.resizeCorner = null
    }

    zoom(event) {
        const delta = event.deltaY > 0 ? -10 : 10
        const newSize = this.cropSize + delta
        const maxSize = Math.min(this.canvasTarget.width, this.canvasTarget.height)

        if (newSize >= 100 && newSize <= maxSize) {
            // Adjust position to keep centered
            this.cropX += (this.cropSize - newSize) / 2
            this.cropY += (this.cropSize - newSize) / 2
            this.cropSize = newSize

            // Ensure within bounds
            this.cropX = Math.max(0, Math.min(this.cropX, this.canvasTarget.width - this.cropSize))
            this.cropY = Math.max(0, Math.min(this.cropY, this.canvasTarget.height - this.cropSize))

            this.drawCropArea()
        }

        event.preventDefault()
    }

    async applyCrop() {
        // Calculate crop coordinates relative to original image dimensions
        const cropX = Math.round(this.cropX / this.scale)
        const cropY = Math.round(this.cropY / this.scale)
        const cropSize = Math.round(this.cropSize / this.scale)

        // Store crop coordinates in hidden fields
        this.cropXFieldTarget.value = cropX
        this.cropYFieldTarget.value = cropY
        this.cropWidthFieldTarget.value = cropSize
        this.cropHeightFieldTarget.value = cropSize

        // Create a preview canvas to show the cropped result
        const previewCanvas = document.createElement("canvas")
        const previewCtx = previewCanvas.getContext("2d")
        previewCanvas.width = 128
        previewCanvas.height = 128

        // Draw cropped portion as preview
        previewCtx.drawImage(
            this.image,
            cropX,
            cropY,
            cropSize,
            cropSize,
            0,
            0,
            128,
            128
        )

        // Show preview
        this.previewTarget.src = previewCanvas.toDataURL("image/jpeg", 0.9)
        this.previewTarget.classList.remove("hidden")

        // Hide existing avatar container if present
        if (this.hasExistingContainerTarget) {
            this.existingContainerTarget.classList.add("hidden")
        }

        this.hideModal()
    }

    cancel() {
        this.inputTarget.value = ""
        this.hideModal()
    }
}
