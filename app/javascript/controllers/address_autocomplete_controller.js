import { Controller } from "@hotwired/stimulus"
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"

export default class extends Controller {
  static values = { apiKey: String }
  static targets = ["address", "map", "error"]

  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "country,region,place,postcode,locality,neighborhood,address"
    })

    this.geocoder.addTo(this.mapTarget)

    // Restore previously selected address when form re-renders after a server error
    if (this.addressTarget.value) {
      this.geocoder.setInput(this.addressTarget.value)
    }

    this.geocoder.on("result", (event) => {
      this.addressTarget.value = event.result.place_name
      this.hideError()
      this.dispatch("place-changed")
    })

    this.geocoder.on("clear", () => {
      this.addressTarget.value = ""
      this.dispatch("place-changed")
    })
  }

  requirePlace(event) {
    if (!this.addressTarget.value.trim()) {
      event.preventDefault()
      this.showError()
      this.mapTarget.querySelector("input")?.focus()
    }
  }

  showError() {
    this.errorTarget.style.display = "block"
    this.mapTarget.querySelector("input")?.classList.add("is-invalid")
  }

  hideError() {
    this.errorTarget.style.display = "none"
    this.mapTarget.querySelector("input")?.classList.remove("is-invalid")
  }

  disconnect() {
    this.geocoder.onRemove()
  }
}
