import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
    static values = {
        placeholder: String,
        teacherId: Number,
        endpoint: String
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
            create: false,
            sortField: {
                field: "text",
                direction: "asc"
            },
            placeholder: this.placeholderValue || "Select one or more...",
            maxOptions: null,
            plugins: ['remove_button'],
            closeAfterSelect: false,
            optgroups: [],
            optgroupField: 'optgroup',
            labelField: 'text',
            valueField: 'value',
            searchField: ['text'],
            selectOnTab: true,
            hideSelected: true,
            allowEmptyOption: false
        }

        // Only load from server if teacherId is provided
        if (this.hasTeacherIdValue && this.teacherIdValue) {
            // Determine endpoint based on the endpoint value or default to chapters
            const endpoint = this.hasEndpointValue ? this.endpointValue : 'chapters'

            options.load = (query, callback) => {
                const url = `/admin/teachers/${this.teacherIdValue}/${endpoint}?q=${encodeURIComponent(query)}`

                fetch(url)
                    .then(response => response.json())
                    .then(json => {
                        // If optgroups exist, use them (for chapters)
                        if (json.optgroups && json.optgroups.length > 0) {
                            this.tomSelect.clearOptionGroups()
                            json.optgroups.forEach(optgroup => {
                                this.tomSelect.addOptionGroup(optgroup.value, optgroup)
                            })
                        }

                        // Return filtered options
                        callback(json.options)
                    })
                    .catch(() => {
                        callback()
                    })
            }
        }

        this.tomSelect = new TomSelect(this.element, options)

        // Don't override the wrapper classes, just add to them
        if (originalClasses) {
            const wrapperClasses = this.tomSelect.wrapper.className.split(' ')
            const originalClassArray = originalClasses.split(' ')

            // Add original classes that aren't already present
            originalClassArray.forEach(cls => {
                if (!wrapperClasses.includes(cls)) {
                    this.tomSelect.wrapper.classList.add(cls)
                }
            })
        }

        // Trigger initial load after TomSelect is initialized
        if (this.hasTeacherIdValue && this.teacherIdValue) {
            this.tomSelect.load('')
        }
    }
}
