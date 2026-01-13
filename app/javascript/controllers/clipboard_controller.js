import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        content: String,
        success: { type: String, default: "Copied!" }
    }

    connect() {
        this.originalText = this.element.innerText.trim() // store original on connect

        // If we are dealing with an icon + text structure, we might need a more robust way to handle innerHTML restoration
        // For now, assuming simple text button or handling restoration manually
        this.originalHTML = this.element.innerHTML
    }

    copy(event) {
        event.preventDefault()

        const content = this.contentValue

        if (!content) return

        navigator.clipboard.writeText(content).then(() => {
            // Visual feedback
            this.element.innerText = this.successValue
            this.element.classList.add("text-green-600", "dark:text-green-500", "font-medium")

            setTimeout(() => {
                this.element.innerHTML = this.originalHTML
                this.element.classList.remove("text-green-600", "dark:text-green-500", "font-medium")
            }, 2000)
        })
    }
}
