import { Controller } from "@hotwired/stimulus"
import { RetellWebClient } from "retell-client-js-sdk"

export default class extends Controller {
    static targets = [
      "card",
      "startBtn",
      "stopBtn",
      "status",
      "transcript",
      "workoutType",
      "place",
      "placeDisplay",
      "date",
      "duration",
      "description",
      "price",
      "minPeople",
      "maxPeople"
    ]

  connect() {
    this.callId = null
    this.client = new RetellWebClient()
    this.transcript = []

    this.client.on("call_started", () => {
      this.setStatus("In call")
      this.setState("active")
    })

    this.client.on("call_ended", () => {
        this.onCallEnded()
    })

    this.client.on("update", (update) => {
      this.onUpdate(update)
    })

    this.client.on("error", (error) => {
      console.error(error)
      this.setStatus(`Error: ${error.message}`)
      this.setState("error")
      this.startBtnTarget.disabled = false
      this.stopBtnTarget.disabled = true
    })
  }

  async startCall() {
    this.setStatus("Connecting...")
    this.setState("connecting")
    this.startBtnTarget.disabled = true
    this.stopBtnTarget.disabled = true
    this.transcript = []
    this.transcriptTarget.value = ""

    try {
      const response = await fetch("/retell/web_call", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        }
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Failed to create Retell call")
      }
        this.callId = data.call_id

      await this.client.startCall({
        accessToken: data.access_token
      })

      this.stopBtnTarget.disabled = false
    } catch (error) {
      console.error(error)
      this.setStatus(`Error: ${error.message}`)
      this.startBtnTarget.disabled = false
      this.stopBtnTarget.disabled = true
    }
  }

  stopCall() {
    this.client.stopCall()
    this.setStatus("Stopping...")
    this.stopBtnTarget.disabled = true
  }

  onUpdate(update) {
    if (!update.transcript) return

    this.transcript = update.transcript

    this.transcriptTarget.value = update.transcript
      .map((line) => `${line.role}: ${line.content}`)
      .join("\n")

    this.transcriptTarget.scrollTop = this.transcriptTarget.scrollHeight
  }

  async fetchCallDataWithRetry() {
    const maxAttempts = 8
    const delayMs = 2000
  
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      this.setStatus(`Reading training data... attempt ${attempt}/${maxAttempts}`)
  
      const response = await fetch("/retell/call_data", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          call_id: this.callId
        })
      })
  
      const data = await this.parseResponse(response)
  
    //   console.log(`Retell call data attempt ${attempt}:`, data)
  
      if (!response.ok) {
        throw new Error(data.error || "Failed to retrieve Retell call data")
      }
  
      if (this.callDataReady(data)) {
        return data
      }
  
      await this.sleep(delayMs)
    }
  
    throw new Error("Training data is not ready yet. Try again in a few seconds.")
}
  
  callDataReady(data) {
    return data.variables
  }
  
  sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms))
    }

    fillForm(variables) {
    if (!variables) return
    
    const location = variables.location || ""
    
    this.workoutTypeTarget.value = variables.workout_type || ""
    if (this.hasPlaceDisplayTarget) {
      this.placeDisplayTarget.value = location
    }
    this.placeDisplayTarget.value = location
    this.dateTarget.value = variables.date_time || ""
    this.durationTarget.value = variables.duration_minutes || ""
    this.descriptionTarget.value = variables.description || ""
    this.priceTarget.value = variables.price_euros || ""
    this.minPeopleTarget.value = variables.min_participants || ""
    this.maxPeopleTarget.value = variables.max_participants || ""
    
    this.dispatchInputEvents()
    this.dispatchPlaceChanged()
}

dispatchPlaceChanged() {
  this.placeTarget.dispatchEvent(
    new CustomEvent("address-autocomplete:place-changed", { bubbles: true })
  )
}

dispatchInputEvents() {
  const targets = [
    this.workoutTypeTarget,
    this.placeTarget,
    this.dateTarget,
    this.durationTarget,
    this.descriptionTarget,
    this.priceTarget,
    this.minPeopleTarget,
    this.maxPeopleTarget
  ]

  if (this.hasPlaceDisplayTarget) {
    targets.push(this.placeDisplayTarget)
  }

  targets.forEach((target) => {
    target.dispatchEvent(new Event("input", { bubbles: true }))
    target.dispatchEvent(new Event("change", { bubbles: true }))
  })
}

async parseResponse(response) {
    const contentType = response.headers.get("content-type")
  
    if (contentType && contentType.includes("application/json")) {
        return await response.json()
    }
  
    return { error: await response.text() }
}

  setStatus(text) {
    this.statusTarget.textContent = text
  }

  
  async onCallEnded() {
    this.setStatus("Call ended. Reading training data...")
    this.startBtnTarget.disabled = false
    this.stopBtnTarget.disabled = true
  
    if (!this.callId) {
      this.setStatus("Call ended, but call ID is missing")
      return
    }
  
    try {
        const data = await this.fetchCallDataWithRetry()
        
        // console.log("Retell call data:", data)
        
        this.fillForm(data.variables)

        this.setStatus("Training form filled")
        this.setState("done")

    } catch (error) {
        console.error(error)
        this.setStatus(`Error: ${error.message}`)
        this.setState("error")
    }
  }

  setState(state) {
    if (this.hasCardTarget) {
      this.cardTarget.dataset.voiceState = state
    }
  }
}
}