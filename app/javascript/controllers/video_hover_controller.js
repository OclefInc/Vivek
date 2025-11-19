import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["video", "videoContainer", "muteButton", "mutedIcon", "unmutedIcon", "progressBar", "progressContainer"]

    connect() {
        this.loaded = false
        this.playing = false
        this.isMobile = 'ontouchstart' in window
        // Hide video container initially
        if (this.hasVideoContainerTarget) {
            this.videoContainerTarget.style.opacity = '0'
        }

        // Only add mouse events on desktop
        if (!this.isMobile) {
            this.element.addEventListener('mouseenter', this.play.bind(this))
            this.element.addEventListener('mouseleave', this.pause.bind(this))
        }

        this.element.addEventListener('click', this.togglePlay.bind(this))
        this.videoTarget.addEventListener('timeupdate', this.updateProgress.bind(this))
    }

    disconnect() {
        if (!this.isMobile) {
            this.element.removeEventListener('mouseenter', this.play.bind(this))
            this.element.removeEventListener('mouseleave', this.pause.bind(this))
        }
        this.element.removeEventListener('click', this.togglePlay.bind(this))
        this.videoTarget.removeEventListener('timeupdate', this.updateProgress.bind(this))
    }

    play() {
        // Load video on first hover if not already loaded
        if (!this.loaded) {
            this.videoTarget.load()
            this.loaded = true
        }
        this.playing = true
        if (this.hasVideoContainerTarget) {
            this.videoContainerTarget.style.opacity = '1'
        }
        this.videoTarget.play()
    }

    pause() {
        this.playing = false
        if (this.hasVideoContainerTarget) {
            this.videoContainerTarget.style.opacity = '0'
        }
        this.videoTarget.pause()
        this.videoTarget.currentTime = 0
        this.progressBarTarget.style.width = '0%'
    }

    togglePlay(event) {
        // On desktop, don't interfere with hover - only work on mobile
        if (!this.isMobile) {
            return
        }

        // Prevent navigation when clicking video area
        event.preventDefault()
        event.stopPropagation()

        // Don't toggle if clicking mute button or progress bar
        if (event.target.closest('[data-action]')) {
            return
        }

        if (this.playing) {
            this.pause()
        } else {
            this.play()
        }
    }

    updateProgress() {
        const progress = (this.videoTarget.currentTime / this.videoTarget.duration) * 100
        this.progressBarTarget.style.width = `${progress}%`
    }

    seekVideo(event) {
        event.preventDefault()
        const rect = this.progressContainerTarget.getBoundingClientRect()
        const clickX = event.clientX - rect.left
        const percentage = clickX / rect.width
        const newTime = percentage * this.videoTarget.duration
        this.videoTarget.currentTime = newTime
    }

    toggleMute(event) {
        event.preventDefault()
        this.videoTarget.muted = !this.videoTarget.muted

        if (this.videoTarget.muted) {
            this.mutedIconTarget.classList.remove('hidden')
            this.unmutedIconTarget.classList.add('hidden')
        } else {
            this.mutedIconTarget.classList.add('hidden')
            this.unmutedIconTarget.classList.remove('hidden')
        }
    }
}