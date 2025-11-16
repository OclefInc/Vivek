import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["row"]

    highlight(event) {
        // Remove highlight from all rows
        this.rowTargets.forEach(row => {
            row.classList.remove("bg-blue-100", "dark:bg-blue-900")
        })

        // Add highlight to clicked row
        const clickedRow = event.target.closest("tr")
        if (clickedRow) {
            clickedRow.classList.add("bg-blue-100", "dark:bg-blue-900")
        }
    }
}
