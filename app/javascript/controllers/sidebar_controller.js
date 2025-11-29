import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  toggle() {
    if (this.menuTarget.style.transform === "translateX(0px)") {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.style.transform = "translateX(0px)"
    this.overlayTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.style.transform = "translateX(100%)"
    this.overlayTarget.classList.add("hidden")
  }
}
