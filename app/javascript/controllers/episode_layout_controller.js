import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["videoDescription", "episodeTable"]

    connect() {
        this.updateTableHeight()
        // Update on window resize
        this.resizeObserver = new ResizeObserver(() => this.updateTableHeight())
        this.resizeObserver.observe(this.videoDescriptionTarget)
    }

    disconnect() {
        if (this.resizeObserver) {
            this.resizeObserver.disconnect()
        }
    }

    updateTableHeight() {
        const innerDiv = this.videoDescriptionTarget.querySelector('#' + this.videoDescriptionTarget.querySelector('[id]').id)
        const videoDescriptionHeight = innerDiv ? innerDiv.offsetHeight : this.videoDescriptionTarget.offsetHeight
        this.episodeTableTarget.style.maxHeight = `${videoDescriptionHeight}px`
    }
}
