import { Controller } from "@hotwired/stimulus"
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"

export default class extends Controller {
  static values = { apiKey: String }
  static targets = ["address", "map"]

  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "country,region,place,postcode,locality,neighborhood,address"
    })

    this.geocoder.addTo(this.mapTarget)

    this.geocoder.on("result", (event) => {
      this.addressTarget.value = event.result.place_name
    })

    this.geocoder.on("clear", () => {
      this.addressTarget.value = ""
    })
  }

  disconnect() {
    this.geocoder.onRemove()
  }
}
