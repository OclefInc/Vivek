import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "video",
        "playButton",
        "pauseButton",
        "progressContainer",
        "progressBar",
        "timeDisplay",
        "thumbnailTooltip",
        "thumbnailVideo",
        "controls"
    ]

    connect() {
        this.videoTarget.controls = false
        this.setupThumbnailVideo()
        this.videoTarget.addEventListener("timeupdate", this.updateProgress.bind(this))
        this.videoTarget.addEventListener("loadedmetadata", this.updateDuration.bind(this))
        this.videoTarget.addEventListener("play", this.updatePlayState.bind(this))
        this.videoTarget.addEventListener("pause", this.updatePlayState.bind(this))

        if (this.videoTarget.readyState >= 1) {
            this.updateDuration()
        }
    }

    disconnect() {
        this.videoTarget.removeEventListener("timeupdate", this.updateProgress.bind(this))
        this.videoTarget.removeEventListener("loadedmetadata", this.updateDuration.bind(this))
        this.videoTarget.removeEventListener("play", this.updatePlayState.bind(this))
        this.videoTarget.removeEventListener("pause", this.updatePlayState.bind(this))
    }

    setupThumbnailVideo() {
        if (this.hasThumbnailVideoTarget) {
            this.thumbnailVideoTarget.src = this.videoTarget.currentSrc || this.videoTarget.src
            this.thumbnailVideoTarget.load()
        }
    }

    togglePlay(event) {
        event.stopPropagation()
        if (this.videoTarget.paused) {
            this.videoTarget.play()
        } else {
            this.videoTarget.pause()
        }
    }

    updatePlayState() {
        if (this.videoTarget.paused) {
            this.playButtonTarget.classList.remove("hidden")
            this.pauseButtonTarget.classList.add("hidden")
        } else {
            this.playButtonTarget.classList.add("hidden")
            this.pauseButtonTarget.classList.remove("hidden")
        }
    }

    updateProgress() {
        const percent = (this.videoTarget.currentTime / this.videoTarget.duration) * 100
        this.progressBarTarget.style.width = `${percent}%`
        this.updateTimeDisplay()
    }

    updateDuration() {
        this.updateTimeDisplay()
    }

    updateTimeDisplay() {
        const current = this.formatTime(this.videoTarget.currentTime)
        const total = this.formatTime(this.videoTarget.duration || 0)
        this.timeDisplayTarget.textContent = `${current} / ${total}`
    }

    formatTime(seconds) {
        const h = Math.floor(seconds / 3600)
        const m = Math.floor((seconds % 3600) / 60)
        const s = Math.floor(seconds % 60)
        if (h > 0) {
            return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
        }
        return `${m}:${s.toString().padStart(2, '0')}`
    }

    seek(event) {
        const rect = this.progressContainerTarget.getBoundingClientRect()
        const pos = (event.clientX - rect.left) / rect.width
        this.videoTarget.currentTime = pos * this.videoTarget.duration
    }

    showThumbnail(event) {
        const rect = this.progressContainerTarget.getBoundingClientRect()
        const pos = (event.clientX - rect.left) / rect.width
        const time = pos * this.videoTarget.duration

        // Position tooltip
        const tooltipWidth = 128 // w-32 = 128px
        let left = event.clientX - rect.left - (tooltipWidth / 2)

        // Boundary checks
        if (left < 0) left = 0
        if (left + tooltipWidth > rect.width) left = rect.width - tooltipWidth

        this.thumbnailTooltipTarget.style.left = `${left}px`
        this.thumbnailTooltipTarget.classList.remove("hidden")

        // Update thumbnail video time
        if (this.hasThumbnailVideoTarget) {
            this.thumbnailVideoTarget.currentTime = time
        }
    }

    hideThumbnail() {
        this.thumbnailTooltipTarget.classList.add("hidden")
    }

    toggleFullscreen() {
        if (!document.fullscreenElement) {
            this.element.requestFullscreen().catch(err => {
                console.error(`Error attempting to enable fullscreen: ${err.message}`)
            })
        } else {
            document.exitFullscreen()
        }
    }
}
