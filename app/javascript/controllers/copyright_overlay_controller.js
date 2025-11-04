import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    copyrighted: Boolean
  }

  connect() {
    this.toggleOverlays()
    this.preventContextMenu()
  }

  toggleOverlays() {
    // Find all copyright overlays and blockers within this controller's scope
    const overlays = this.element.querySelectorAll('[data-copyright-overlay]')
    const blockers = this.element.querySelectorAll('[data-copyright-blocker]')
    const iframes = this.element.querySelectorAll('[data-copyright-iframe]')

    overlays.forEach(overlay => {
      if (this.copyrightedValue) {
        overlay.style.display = 'flex'
      } else {
        overlay.style.display = 'none'
      }
    })

    blockers.forEach(blocker => {
      if (this.copyrightedValue) {
        blocker.style.display = 'block'
      } else {
        blocker.style.display = 'none'
      }
    })

    iframes.forEach(iframe => {
      if (this.copyrightedValue) {
        iframe.style.pointerEvents = 'none'
      } else {
        iframe.style.pointerEvents = 'auto'
      }
    })
  }

  preventContextMenu() {
    if (this.copyrightedValue) {
      // Prevent right-click context menu on the entire description area
      this.element.addEventListener('contextmenu', (e) => {
        e.preventDefault()
        return false
      })
    }
  }
}
