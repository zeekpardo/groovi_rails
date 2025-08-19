import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="schema-selector"
export default class extends Controller {
  static targets = [
    "dynamicFields", "schemaSelect",
    "urlField", "phoneField", "smsField", "smsMessage", 
    "emailField", "emailSubject", "emailMessage",
    "whatsappField", "whatsappMessage"
  ]

  connect() {
    this.updateFields()
  }

  // Updates form fields based on selected schema type
  updateFields(event) {
    const schemaType = event?.target?.value || this.schemaSelectTarget.value
    
    // Hide all schema-specific fields
    this.dynamicFieldsTarget.querySelectorAll("[data-schema]").forEach(field => {
      field.classList.add("hidden")
    })
    
    // Show relevant fields for the selected schema
    const relevantFields = this.dynamicFieldsTarget.querySelector(`[data-schema="${schemaType}"]`)
    if (relevantFields) {
      relevantFields.classList.remove("hidden")
    }
  }
}