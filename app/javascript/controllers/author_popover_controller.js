import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.menuTarget.style.display = "none"
  }

  toggle(event) {
    event.stopPropagation()
    document.querySelectorAll("[data-author-popover-target='menu']").forEach(el => {
      if (el !== this.menuTarget) el.style.display = "none"
    })
    this.menuTarget.style.display =
      this.menuTarget.style.display === "none" ? "flex" : "none"
  }

  hide() {
    this.menuTarget.style.display = "none"
  }
}
