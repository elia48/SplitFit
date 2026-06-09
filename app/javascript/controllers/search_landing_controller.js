import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["location"]

  locate(event) {
    if (!navigator.geolocation) return

    const btn = event.currentTarget
    btn.classList.add("locating")

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        this.locationTarget.value = `${pos.coords.latitude},${pos.coords.longitude}`
        btn.classList.remove("locating")
        btn.innerHTML = '<i class="fa-solid fa-check"></i>'
      },
      () => {
        btn.classList.remove("locating")
      }
    )
  }
}
