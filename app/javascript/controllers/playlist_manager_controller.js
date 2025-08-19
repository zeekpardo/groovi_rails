import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playlist-manager"
export default class extends Controller {
  static targets = ["itemsList", "playlistItem", "resetBtn", "advanceBtn"]
  static values = { 
    qrCodeId: Number,
    playlistId: Number 
  }

  connect() {
    this.setupDragAndDrop()
  }

  // Sets up drag and drop functionality for playlist items
  setupDragAndDrop() {
    this.playlistItemTargets.forEach((item) => {
      item.addEventListener("dragstart", this.handleDragStart.bind(this))
      item.addEventListener("dragend", this.handleDragEnd.bind(this))
    })

    this.itemsListTarget.addEventListener("dragover", this.handleDragOver.bind(this))
    this.itemsListTarget.addEventListener("drop", this.handleDrop.bind(this))
  }

  handleDragStart(event) {
    this.draggedItem = event.target
    event.target.style.opacity = "0.5"
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/html", event.target.outerHTML)
  }

  handleDragEnd(event) {
    event.target.style.opacity = "1"
    this.draggedItem = null
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    
    const afterElement = this.getDragAfterElement(event.clientY)
    const draggedElement = this.draggedItem
    
    if (afterElement == null) {
      this.itemsListTarget.appendChild(draggedElement)
    } else {
      this.itemsListTarget.insertBefore(draggedElement, afterElement)
    }
  }

  handleDrop(event) {
    event.preventDefault()
    this.reorderItems()
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.itemsListTarget.querySelectorAll('[data-playlist-manager-target="playlistItem"]:not([style*="opacity: 0.5"])')]
    
    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2
      
      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  // Sends the new order to the server
  reorderItems() {
    const items = []
    this.playlistItemTargets.forEach((item, index) => {
      items.push({
        id: parseInt(item.dataset.itemId),
        position: index
      })
    })

    fetch(`/qr/${this.qrCodeIdValue}/playlist/items/reorder`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ items: items })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showSuccessMessage("Items reordered successfully")
      } else {
        this.showErrorMessage("Failed to reorder items")
        location.reload() // Reload to reset the order
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showErrorMessage("Failed to reorder items")
      location.reload()
    })
  }

  // Advances the playlist to the next item
  advancePlaylist() {
    fetch(`/qr/${this.qrCodeIdValue}/playlist/advance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        location.reload() // Reload to show the new active item
      } else {
        this.showErrorMessage("Cannot advance further")
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showErrorMessage("Failed to advance playlist")
    })
  }

  // Resets the playlist to the beginning
  resetPlaylist() {
    if (!confirm("Are you sure you want to start the playlist over from the beginning?")) {
      return
    }
    
    fetch(`/qr/${this.qrCodeIdValue}/playlist/reset`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        location.reload()
      } else {
        this.showErrorMessage("Failed to reset playlist")
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showErrorMessage("Failed to reset playlist")
    })
  }

  // Toggles archived items visibility
  toggleArchived() {
    // This would show/hide archived items
    console.log("Toggle archived items")
  }

  // Shows a success message to the user
  showSuccessMessage(message) {
    // You could implement a toast notification system here
    console.log("Success:", message)
  }

  // Shows an error message to the user
  showErrorMessage(message) {
    // You could implement a toast notification system here
    console.error("Error:", message)
    alert(message) // Simple fallback
  }
}