import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    nextUrl: String,
    nextName: String,
    nextDate: String
  }

  connect() {
    this.element.addEventListener('ended', this.handleVideoEnd.bind(this))
    this.countdownElement = null
    this.countdownInterval = null

    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.get('autoplay') === 'true') {
      this.element.play().catch(error => {
        console.log("Autoplay prevented:", error)
      })
    }
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

  visitNextUrl() {
    const url = new URL(this.nextUrlValue, window.location.origin)
    url.searchParams.set('autoplay', 'true')
    window.Turbo.visit(url.toString())
  }

  showCountdown() {
    // Find the background div (parent of the video)
    const backgroundDiv = this.element.parentElement

    // Ensure the background div has relative positioning
    if (window.getComputedStyle(backgroundDiv).position === 'static') {
      backgroundDiv.style.position = 'relative'
    }

    // Build the next lesson info HTML
    const nextLessonInfo = this.hasNextNameValue
      ? `<p class="text-gray-300 text-lg mb-2">Next Lesson</p>
         <p class="text-white text-2xl font-semibold mb-2">${this.nextNameValue}</p>
         ${this.hasNextDateValue ? `<p class="text-gray-300 text-lg mb-4">${this.nextDateValue}</p>` : ''}`
      : '<p class="text-white text-2xl mb-4">Next lesson starting in...</p>'

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
      <div class="text-center px-8">
        ${nextLessonInfo}
        <p class="text-white text-6xl font-bold countdown-number">10</p>
        <div class="mt-6 flex gap-4 justify-center">
          <button class="play-now-btn px-6 py-3 bg-green-600 hover:bg-green-500 text-white rounded-lg font-medium">
            Play Now
          </button>
          <button class="cancel-btn px-6 py-3 bg-red-600 hover:bg-red-500 text-white rounded-lg font-medium">
            Cancel
          </button>
        </div>
      </div>
    `

    // Add button events
    const playNowButton = this.countdownElement.querySelector('.play-now-btn')
    const cancelButton = this.countdownElement.querySelector('.cancel-btn')

    playNowButton.addEventListener('click', () => {
      this.clearCountdown()
      this.visitNextUrl()
    })

    cancelButton.addEventListener('click', () => this.clearCountdown())

    // Append to the background div to position it on top of the video
    backgroundDiv.appendChild(this.countdownElement)

    // Start countdown
    let count = 10
    const numberElement = this.countdownElement.querySelector('.countdown-number')

    this.countdownInterval = setInterval(() => {
      count--
      if (count > 0) {
        numberElement.textContent = count
      } else {
        this.clearCountdown()
        this.visitNextUrl()
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
