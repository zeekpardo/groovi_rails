// Handles dynamic form fields based on schema type selection
// Example usage:
// <div data-controller="url-shortener">
//   <select data-action="change->url-shortener#updateFields">
//   <div data-url-shortener-target="dynamicFields">

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define targets for dynamic content
  static targets = ["dynamicFields"]
  
  // Define value properties with defaults
  static values = {
    currentSchema: { type: String, default: "url" }
  }
  
  // Initialize controller
  connect() {
    // Set initial schema based on selected value or default
    const schemaSelect = this.element.querySelector('select[name*="schema_type"]')
    if (schemaSelect) {
      this.currentSchemaValue = schemaSelect.value || "url"
    }
    this.updateFields()
  }
  
  // Updates form fields based on selected schema type
  updateFields(event) {
    const schemaType = event?.target?.value || this.currentSchemaValue
    
    // Hide all schema-specific field groups
    this.dynamicFieldsTarget.querySelectorAll("[data-schema]").forEach(fieldGroup => {
      fieldGroup.classList.add("hidden")
      
      // Disable inputs in hidden groups to prevent validation issues
      const inputs = fieldGroup.querySelectorAll("input, textarea, select")
      inputs.forEach(input => {
        if (input.dataset.schema !== schemaType) {
          input.disabled = true
        }
      })
    })
    
    // Show and enable relevant field group
    const activeFieldGroup = this.dynamicFieldsTarget.querySelector(`[data-schema="${schemaType}"]`)
    if (activeFieldGroup) {
      activeFieldGroup.classList.remove("hidden")
      
      // Enable inputs in active group
      const inputs = activeFieldGroup.querySelectorAll("input, textarea, select")
      inputs.forEach(input => {
        input.disabled = false
      })
    }
    
    // Update current schema value
    this.currentSchemaValue = schemaType
    
    // Update placeholder and labels based on schema type
    this.updatePlaceholders(schemaType)
  }
  
  // Updates placeholders and help text based on schema type
  updatePlaceholders(schemaType) {
    const targetInput = this.element.querySelector(`[data-schema="${schemaType}"] input[data-schema="${schemaType}"]`)
    if (!targetInput) return
    
    // Update placeholders based on schema type
    const placeholders = {
      url: "https://example.com",
      phone: "+1234567890", 
      sms: "+1234567890",
      email: "contact@example.com",
      whatsapp: "1234567890"
    }
    
    if (placeholders[schemaType]) {
      targetInput.placeholder = placeholders[schemaType]
    }
    
    // Focus the main input field for better UX
    targetInput.focus()
  }
  
  // Handle schema type changes
  currentSchemaValueChanged() {
    this.updateFields()
  }
}