import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
    static values = {
        placeholder: String
    }

    connect() {
        this.initTomSelect()
    }

    disconnect() {
        if (this.tomSelect) {
            this.tomSelect.destroy()
        }
    }

    initTomSelect() {
        const originalClasses = this.element.className

        const options = {
            create: false, // Don't allow custom input
            sortField: {
                field: "text",
                direction: "asc"
            },
            placeholder: this.placeholderValue || "Select one or more...",
            maxOptions: null,
            plugins: ['remove_button'], // Add x button to remove selected items
            closeAfterSelect: false // Keep dropdown open for multiple selections
        }

        this.tomSelect = new TomSelect(this.element, options)

        // Apply the original classes to the wrapper element
        if (originalClasses) {
            this.tomSelect.wrapper.className = `ts-wrapper ${originalClasses} multi plugin-remove_button`
        }

        // Apply original classes to the control input
        if (originalClasses) {
            const control = this.tomSelect.control
            control.className = `ts-control ${originalClasses}`
        }
    }
}
