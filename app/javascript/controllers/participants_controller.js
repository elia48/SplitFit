import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "chevron"]

  toggle() {
    const isOpen = this.listTarget.classList.toggle("participants-list--open")
    this.chevronTarget.classList.toggle("participants-chevron--rotated", isOpen)
  }
}
