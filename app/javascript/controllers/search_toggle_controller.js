import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input"]

    connect() {
        // Listen for turbo frame rendering to restore focus
        document.addEventListener("turbo:frame-render", this.restoreFocus.bind(this))
    }

    disconnect() {
        document.removeEventListener("turbo:frame-render", this.restoreFocus.bind(this))
    }

    restoreFocus(event) {
        // Only restore focus if this input was previously focused
        if (this.inputTarget === document.activeElement || this.wasFocused) {
            // Use requestAnimationFrame to ensure the DOM has updated
            requestAnimationFrame(() => {
                this.inputTarget.focus()
                // Restore cursor position to the end
                const length = this.inputTarget.value.length
                this.inputTarget.setSelectionRange(length, length)
            })
        }
    }

    // Track when input receives focus
    inputFocused() {
        this.wasFocused = true
    }

    // Track when input loses focus
    inputBlurred() {
        this.wasFocused = false
    }
}
