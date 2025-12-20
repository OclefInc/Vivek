import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "overlay"]

  connect() {
    this.videoTarget.addEventListener('play', this.handlePlay.bind(this))
  }

  handlePlay() {
    // Hide the overlay when video starts playing
    this.overlayTarget.classList.add('hidden')
  }

  hideOverlay() {
    // Hide the overlay when clicked (for YouTube iframes)
    this.overlayTarget.classList.add('hidden')
  }
}
