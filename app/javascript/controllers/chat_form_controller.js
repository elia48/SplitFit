import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { currentUser: Number }

  connect() {
    this.applyMessageStyles()
    this.scrollToBottom()
    this.observeMessages()
  }

  applyMessageStyles() {
    this.element.querySelectorAll(".chat-message").forEach(msg => this.styleMessage(msg))
  }

  styleMessage(msg) {
    const userId = parseInt(msg.dataset.messageUserId)
    const isOwn = userId === this.currentUserValue
    msg.classList.add(isOwn ? "chat-message--own" : "chat-message--other")
    const avatar = msg.querySelector("[data-avatar]")
    if (avatar) avatar.style.display = isOwn ? "none" : ""
    const authorWrap = msg.querySelector(".chat-message__author-wrap")
    if (authorWrap) authorWrap.style.display = isOwn ? "none" : ""
  }

  scrollToBottom() {
    const messages = this.element.querySelector("#messages")
    if (messages) messages.scrollTop = messages.scrollHeight
  }

  observeMessages() {
    const messages = this.element.querySelector("#messages")
    if (!messages) return
    const observer = new MutationObserver(mutations => {
      mutations.forEach(m => m.addedNodes.forEach(node => {
        if (node.nodeType === 1 && node.classList.contains("chat-message")) {
          this.styleMessage(node)
        }
      }))
      this.scrollToBottom()
    })
    observer.observe(messages, { childList: true })
  }
}
