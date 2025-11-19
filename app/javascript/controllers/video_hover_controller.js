import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["video", "muteButton", "mutedIcon", "unmutedIcon"]

    connect() {
        this.loaded = false
        this.videoTarget.addEventListener('mouseenter', this.play.bind(this))
        this.videoTarget.addEventListener('mouseleave', this.pause.bind(this))
    }

    disconnect() {
        this.videoTarget.removeEventListener('mouseenter', this.play.bind(this))
        this.videoTarget.removeEventListener('mouseleave', this.pause.bind(this))
    }

    play() {
        // Load video on first hover if not already loaded
        if (!this.loaded) {
            this.videoTarget.load()
            this.loaded = true
        }
        this.videoTarget.play()
    }

    pause() {
        this.videoTarget.pause()
        this.videoTarget.currentTime = 0
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
