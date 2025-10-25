import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    nextUrl: String
  }

  connect() {
    this.element.addEventListener('ended', this.handleVideoEnd.bind(this))
    this.countdownElement = null
    this.countdownInterval = null
  }

  disconnect() {
    this.element.removeEventListener('ended', this.handleVideoEnd.bind(this))
    this.clearCountdown()
  }

  handleVideoEnd() {
    if (this.hasNextUrlValue && this.nextUrlValue) {
      this.showCountdown()
    }
  }

  showCountdown() {
    // Create countdown overlay
    this.countdownElement = document.createElement('div')
    this.countdownElement.className = 'fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50'
    this.countdownElement.innerHTML = `
      <div class="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75 z-10">
      <div class="text-center">
        <p class="text-white text-2xl mb-4">Next lesson starting in...</p>
        <p class="text-white text-6xl font-bold countdown-number">5</p>
        <button class="mt-6 px-6 py-3 bg-red-600 hover:bg-red-500 text-white rounded-lg font-medium">
          Cancel
        </button>
      </div>
    </div>
    `
    // mmove countdownElement to be a sibling of the video element
    // this.element.parentNode.insertBefore(this.countdownElement, this.element.nextSibling)
    // Add cancel button event
    const cancelButton = this.countdownElement.querySelector('button')
    cancelButton.addEventListener('click', () => this.clearCountdown())

    this.element.parentNode.parentNode.insertBefore(this.countdownElement, this.element.parentNode.parentNode.firstChild)

    // Start countdown
    let count = 5
    const numberElement = this.countdownElement.querySelector('.countdown-number')

    this.countdownInterval = setInterval(() => {
      count--
      if (count > 0) {
        numberElement.textContent = count
      } else {
        this.clearCountdown()
        window.Turbo.visit(this.nextUrlValue)
      }
    }, 1000)
  }

  clearCountdown() {
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval)
      this.countdownInterval = null
    }
    if (this.countdownElement) {
      this.countdownElement.remove()
      this.countdownElement = null
    }
  }
}
