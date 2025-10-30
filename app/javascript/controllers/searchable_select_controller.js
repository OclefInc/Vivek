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
}
