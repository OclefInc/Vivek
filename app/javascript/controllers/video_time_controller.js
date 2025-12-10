import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "startTime", "endTime", "startDisplay", "endDisplay", "form"]
  static values = { url: String, resource: String }

  toggleForm() {
    this.formTarget.classList.toggle("hidden")
  }

  async setStartTime() {
    const currentTime = Math.floor(this.videoTarget.currentTime)
    this.startTimeTarget.value = currentTime
    this.startDisplayTarget.textContent = this.formatTime(currentTime)
    await this.save('video_start_time', currentTime)
  }

  async setEndTime() {
    const currentTime = Math.floor(this.videoTarget.currentTime)
    this.endTimeTarget.value = currentTime
    this.endDisplayTarget.textContent = this.formatTime(currentTime)
    await this.save('video_end_time', currentTime)
  }

  async save(field, value) {
    try {
      const formData = new FormData()
      const resourceName = this.hasResourceValue ? this.resourceValue : 'lesson'
      formData.append(`${resourceName}[${field}]`, value)
      formData.append("_method", "PATCH")

      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        },
        body: formData
      })

      if (!response.ok) {
        alert("Failed to save time")
      }
    } catch (error) {
      console.error("Error:", error)
      alert("Failed to save time")
    }
  }

  formatTime(seconds) {
    const hrs = Math.floor(seconds / 3600)
    const mins = Math.floor((seconds % 3600) / 60)
    const secs = seconds % 60

    if (hrs > 0) {
      return `${hrs}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    } else {
      return `${mins}:${secs.toString().padStart(2, '0')}`
    }
  }
}
