import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="plyr"
export default class extends Controller {
  static values = {
    nextUrl: String
  }

  async connect() {
    // Dynamically import Plyr
    const Plyr = (await import("plyr")).default

    // Optimize video element for better S3 streaming/scrubbing
    this.element.setAttribute('preload', 'metadata') // Load metadata first for better scrubbing
    this.element.setAttribute('crossorigin', 'anonymous') // Enable CORS for S3

    // Initialize Plyr with enhanced scrubbing settings
    this.player = new Plyr(this.element, {
      controls: [
        'play-large',
        'play',
        'progress',
        'current-time',
        'duration',
        'mute',
        'volume',
        'settings',
        'pip',
        'fullscreen'
      ],
      settings: ['quality', 'speed'],
      speed: { selected: 1, options: [0.5, 0.75, 1, 1.25, 1.5, 2] },
      keyboard: {
        focused: true,
        global: true
      },
      tooltips: {
        controls: true,
        seek: true
      },
      seekTime: 5, // Seek by 5 seconds with arrow keys
      invertTime: false, // Show time remaining instead of elapsed
      displayDuration: true,
      hideControls: false // Always show controls for better scrubbing access
    })

    // Enhanced keyboard shortcuts for better scrubbing
    this.element.addEventListener('keydown', (e) => {
      if (!this.player) return

      switch(e.key) {
        case 'ArrowLeft':
          e.preventDefault()
          // Shift+Left for 30 sec back, Left for 5 sec back
          this.player.rewind(e.shiftKey ? 30 : 5)
          break
        case 'ArrowRight':
          e.preventDefault()
          // Shift+Right for 30 sec forward, Right for 5 sec forward
          this.player.forward(e.shiftKey ? 30 : 5)
          break
        case ',':
          e.preventDefault()
          // Frame-by-frame backward (1/30th of a second)
          this.player.currentTime = Math.max(0, this.player.currentTime - 0.033)
          break
        case '.':
          e.preventDefault()
          // Frame-by-frame forward (1/30th of a second)
          this.player.currentTime = Math.min(this.player.duration, this.player.currentTime + 0.033)
          break
        case 'Home':
          e.preventDefault()
          this.player.currentTime = 0
          break
        case 'End':
          e.preventDefault()
          this.player.currentTime = this.player.duration
          break
        case 'j':
          e.preventDefault()
          this.player.rewind(10)
          break
        case 'l':
          e.preventDefault()
          this.player.forward(10)
          break
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
          e.preventDefault()
          // Jump to percentage (0 = start, 9 = 90%, etc)
          const percentage = parseInt(e.key) / 10
          this.player.currentTime = this.player.duration * percentage
          break
      }
    })

    // Show current time tooltip while scrubbing
    this.enhanceProgressBar()

    // Handle video end - navigate to next lesson if available
    if (this.hasNextUrlValue) {
      this.player.on('ended', () => {
        window.location.href = this.nextUrlValue
      })
    }

    // Store player for cleanup
    this.element.plyrInstance = this.player
  }

  enhanceProgressBar() {
    // Add visual feedback for better scrubbing
    const progressBar = this.element.querySelector('.plyr__progress input[type="range"]')
    if (!progressBar) return

    // Show larger clickable area hint
    progressBar.style.cursor = 'pointer'

    // Add smooth scrubbing on mouse move
    let isScrubbing = false

    progressBar.addEventListener('mousedown', () => {
      isScrubbing = true
    })

    document.addEventListener('mouseup', () => {
      isScrubbing = false
    })

    progressBar.addEventListener('input', () => {
      if (isScrubbing && this.player) {
        // Smooth seeking while dragging
        this.player.currentTime = (progressBar.value / 100) * this.player.duration
      }
    })
  }

  disconnect() {
    if (this.player) {
      this.player.destroy()
    }
  }
}
