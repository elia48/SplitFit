import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  }
  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12"
    })

    this.#addMarkersToMap()
    this.#fitMapToMarkers()
  }
  #addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup({
        anchor: "bottom",
        offset: [0, -10],
        maxWidth: "240px"
      }).setHTML(marker.info_window_html)

      // When the popup opens, pan the marker into the lower portion of the map
      // so the popup (which opens upward) stays fully inside the map container.
      popup.on("open", () => {
        const mapHeight = this.map.getContainer().offsetHeight
        this.map.easeTo({
          center: [marker.lng, marker.lat],
          offset: [0, Math.floor(mapHeight * 0.3)],
          duration: 250
        })
      })

      const mapMarker = new mapboxgl.Marker({ color: marker.is_own ? "white" : "#ff6428" })

      if (marker.is_own) {
        // Mapbox SVG has: body (white, already set), outline (g[opacity="0.25"]),
        // and inner dot (circle's parent g). Recolour the latter two to orange.
        const el = mapMarker.getElement()
        const outline = el.querySelector('g[opacity="0.25"]')
        if (outline) { outline.setAttribute("fill", "#ff6428"); outline.removeAttribute("opacity") }
        const dot = el.querySelector("circle")
        if (dot) dot.setAttribute("fill", "#ff6428")
      }

      mapMarker
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup)
        .addTo(this.map)
    })
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()

    this.markersValue.forEach((marker) => {
      bounds.extend([marker.lng, marker.lat])
    })

    this.map.fitBounds(bounds, {
      padding: 70,
      maxZoom: 15,
      duration: 0
    })
  }
}
