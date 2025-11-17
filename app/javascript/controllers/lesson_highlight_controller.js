import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["row"]
    static values = { currentId: Number }

    connect() {
        this.highlightCurrentLesson()
    }

    highlightCurrentLesson() {
        if (!this.hasCurrentIdValue) return

        this.rowTargets.forEach(row => {
            const lessonId = parseInt(row.dataset.lessonId)

            if (lessonId === this.currentIdValue) {
                row.classList.add("bg-yellow-100", "dark:bg-blue-900/30")
            } else {
                row.classList.remove("bg-yellow-100", "dark:bg-blue-900/30")
            }
        })
    }
}
