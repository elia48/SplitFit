import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, title: String, text: String }
  static targets = ["dropdown"]

  share(event) {
    event.stopPropagation()
    this.dropdownTarget.classList.toggle("share-dropdown--open")
  }

  async native(event) {
    event.stopPropagation()
    if (!navigator.share) return
    try {
      await navigator.share({
        title: this.titleValue,
        text: this.textValue,
        url: this.urlValue
      })
    } catch {}
    this.dropdownTarget.classList.remove("share-dropdown--open")
  }

  closeDropdown(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.remove("share-dropdown--open")
    }
  }

  whatsapp() {
    const text = encodeURIComponent(`${this.textValue} ${this.urlValue}`)
    window.open(`https://wa.me/?text=${text}`, "_blank")
  }

  twitter() {
    const url  = encodeURIComponent(this.urlValue)
    const text = encodeURIComponent(this.textValue)
    window.open(`https://twitter.com/intent/tweet?url=${url}&text=${text}`, "_blank")
  }

  facebook() {
    const url = encodeURIComponent(this.urlValue)
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${url}`, "_blank")
  }
}
