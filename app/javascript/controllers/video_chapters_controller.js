// app/javascript/controllers/video_chapters_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chaptersList", "nameInput", "startTimeInput"]
  static values = { url: String, startTime: Number, endTime: Number }

  connect() {
    // Find the video element by ID
    this.video = document.getElementById('lesson-video')

    if (this.video) {
      this.video.addEventListener("timeupdate", () => this.updateCurrentChapter())

      this.updateCurrentChapter()
    } else {
      console.error("Video element not found!")
    }
  }

  disconnect() {
    if (this.video) {
      this.video.removeEventListener("timeupdate", () => this.updateCurrentChapter())
    }
  }

  addChapterWithTime(event) {
    if (this.video) {
      const currentTime = Math.floor(this.video.currentTime)
      const url = new URL(event.currentTarget.href)
      url.searchParams.set('start_time', currentTime)
      event.currentTarget.href = url.toString()
    }
  }

  setCurrentTime(event) {
    event.preventDefault()
    const startTime = parseFloat(event.currentTarget.dataset.startTime)
    if (this.video) {
      this.video.currentTime = startTime
      this.video.play()
    }
    // Manually trigger highlight update
    this.updateCurrentChapter()
  }

  captureCurrentTime(event) {
    event.preventDefault()
    if (this.video && this.hasStartTimeInputTarget) {
      this.startTimeInputTarget.value = Math.floor(this.video.currentTime)
    }
  }

  updateCurrentChapter() {
    if (!this.video || !this.hasChaptersListTarget) return

    const currentTime = this.video.currentTime
    const chapterItems = this.chaptersListTarget.querySelectorAll("[data-chapter-item]")

    chapterItems.forEach(item => {
      const startTime = parseFloat(item.dataset.startTime)

      // Check if next sibling is tutorials div
      const tutorialsDiv = item.nextElementSibling?.hasAttribute('data-chapter-tutorials')
        ? item.nextElementSibling
        : null

      // Skip the tutorials div when looking for next chapter
      let actualNextItem = item.nextElementSibling
      while (actualNextItem && actualNextItem.hasAttribute('data-chapter-tutorials')) {
        actualNextItem = actualNextItem.nextElementSibling
      }

      const endTime = actualNextItem ? parseFloat(actualNextItem.dataset.startTime) : Infinity

      if (currentTime >= startTime && currentTime < endTime) {
        item.classList.add("bg-blue-900", "text-white")
        // Show tutorials for highlighted chapter
        if (tutorialsDiv) {
          tutorialsDiv.classList.remove("hidden")
        }
      } else {
        item.classList.remove("bg-blue-900", "text-white")
        // Hide tutorials for non-highlighted chapters
        if (tutorialsDiv) {
          tutorialsDiv.classList.add("hidden")
        }
      }
    })
  }

  async deleteChapter(event) {
    event.preventDefault()
    const chapterId = event.currentTarget.dataset.chapterId
    const lessonId = event.currentTarget.dataset.lessonId

    if (!confirm("Are you sure you want to delete this chapter?")) return

    try {
      const response = await fetch(`/admin/lessons/${lessonId}/chapters/${chapterId}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const turboStream = await response.text()
        Turbo.renderStreamMessage(turboStream)
      }
    } catch (error) {
      console.error("Error deleting chapter:", error)
    }
  }
}