import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="searchable-select"
export default class extends Controller {
  static values = {
    placeholder: String,
    create: { type: Boolean, default: true },
    wrapperClass: String,
    controlClass: String,
    dropdownClass: String
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
    // Store the original classes from the select element
    const originalClasses = this.element.className
    const isMultiple = this.element.hasAttribute('multiple')

    const options = {
      create: this.createValue,
      sortField: {
        field: "text",
        direction: "asc"
      },
      placeholder: this.placeholderValue || "Select or type to create...",
      maxOptions: null,
      createOnBlur: true,
      createFilter: function(input) {
        return input.length >= 1;
      },
      onItemAdd: () => {
        // Only move to next field for single-select dropdowns
        if (!isMultiple) {
          // Use setTimeout to allow Tom Select to finish processing
          setTimeout(() => {
            this.moveToNextField()
          }, 10)
        }
      }
    }

    // Add custom classes if provided via data attributes
    if (this.hasWrapperClassValue) {
      options.wrapperClass = this.wrapperClassValue
    }
    if (this.hasControlClassValue) {
      options.controlClass = this.controlClassValue
    }
    if (this.hasDropdownClassValue) {
      options.dropdownClass = this.dropdownClassValue
    }

    this.tomSelect = new TomSelect(this.element, options)

    // Apply the original classes to the wrapper element
    if (originalClasses && !this.hasWrapperClassValue) {
      this.tomSelect.wrapper.className = `ts-wrapper ${originalClasses} single`
    }

    // Apply original classes to the control input
    if (originalClasses && !this.hasControlClassValue) {
      const control = this.tomSelect.control
      control.className = `ts-control ${originalClasses}`
    }
  }

  moveToNextField() {
    // Blur the current Tom Select control
    this.tomSelect.blur()

    // Small delay to ensure blur completes
    setTimeout(() => {
      // Find all focusable elements in the form, excluding Tom Select internal inputs
      const form = this.element.closest('form')
      const allElements = form.querySelectorAll(
        'select, input[type="file"], textarea:not([disabled]), trix-editor'
      )

      // Find the current element (the original select)
      const focusableArray = Array.from(allElements)
      const currentIndex = focusableArray.indexOf(this.element)

      // Focus the next element
      if (currentIndex >= 0 && currentIndex < focusableArray.length - 1) {
        const nextElement = focusableArray[currentIndex + 1]

        // Check if next element is a select with Tom Select
        if (nextElement.tagName === 'SELECT' && nextElement.tomselect) {
          nextElement.tomselect.focus()
        } else if (nextElement.tagName === 'TRIX-EDITOR') {
          nextElement.focus()
        } else {
          nextElement.focus()
        }
      }
    }, 100)
  }
}
