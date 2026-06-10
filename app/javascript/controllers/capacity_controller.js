import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["min", "max"]

  connect() {
    this.syncMax()
  }

  syncMax() {
    const minVal = parseInt(this.minTarget.value) || 2
    this.maxTarget.min = minVal
    if (parseInt(this.maxTarget.value) < minVal) {
      this.maxTarget.value = minVal
    }
  }

  validate(event) {
    const minVal = parseInt(this.minTarget.value) || 2
    const maxVal = parseInt(this.maxTarget.value)
    if (maxVal < minVal) {
      event.preventDefault()
      this.maxTarget.setCustomValidity(`Maximum must be at least ${minVal}`)
      this.maxTarget.reportValidity()
    } else {
      this.maxTarget.setCustomValidity("")
    }
  }
}
