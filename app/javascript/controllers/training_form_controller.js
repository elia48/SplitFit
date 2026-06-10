import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "field", "address"]

  connect() {
    this.check()
    this.element.addEventListener("input", () => this.check())
    this.element.addEventListener("change", () => this.check())
    this.element.addEventListener("address-autocomplete:place-changed", () => this.check())
  }

  check() {
    const fieldsOk = this.fieldTargets.every(f => f.value.trim() !== "")
    const addressOk = !this.hasAddressTarget || this.addressTarget.value.trim() !== ""
    this.submitTarget.disabled = !(fieldsOk && addressOk)
  }
}
