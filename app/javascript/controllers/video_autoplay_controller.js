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
    // Find the background div (parent of the video)
    const backgroundDiv = this.element.parentElement

    // Ensure the background div has relative positioning
    if (window.getComputedStyle(backgroundDiv).position === 'static') {
      backgroundDiv.style.position = 'relative'
    }

    // Create countdown overlay
    this.countdownElement = document.createElement('div')
    this.countdownElement.className = 'absolute inset-0 bg-black bg-opacity-75 flex items-center justify-center'
    // Add inline styles to ensure positioning works
    this.countdownElement.style.cssText = `
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: rgba(0, 0, 0, 0.75);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10;
    `
    this.countdownElement.innerHTML = `
      <div class="text-center">
        <p class="text-white text-2xl mb-4">Next lesson starting in...</p>
        <p class="text-white text-6xl font-bold countdown-number">5</p>
        <button class="mt-6 px-6 py-3 bg-red-600 hover:bg-red-500 text-white rounded-lg font-medium">
          Cancel
        </button>
      </div>
    `

    // Add cancel button event
    const cancelButton = this.countdownElement.querySelector('button')
    cancelButton.addEventListener('click', () => this.clearCountdown())

    // Append to the background div to position it on top of the video
    backgroundDiv.appendChild(this.countdownElement)

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
