import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  connect() {
    if (this.menuTarget.classList.contains("left-0")) {
      this.closedTransform = "translateX(-100%)"
    } else {
      this.closedTransform = "translateX(100%)"
    }
  }

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
    this.menuTarget.style.transform = this.closedTransform
    this.overlayTarget.classList.add("hidden")
  }
}
