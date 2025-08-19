import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "urlFields", "phoneFields", "smsFields", "emailFields", "whatsappFields", 
    "qrPreview", "playlistFields", "shortenedLinkFields"
  ]

  connect() {
    // Determine the initial schema type from the form or default to URL
    const initialSchema = this.getInitialSchemaType()
    
    // Show the appropriate fields
    this.showFields(initialSchema)
  }

  getInitialSchemaType() {
    // Look for a checked schema type radio button
    const checkedRadio = this.element.querySelector('input[name*="schema_type"]:checked')
    if (checkedRadio) {
      return checkedRadio.value
    }
    
    // Look for the currently active schema button
    const activeButton = this.element.querySelector('[data-schema-type].btn-primary')
    if (activeButton) {
      return activeButton.dataset.schemaType
    }
    
    // Default to URL
    return "url"
  }

  switchLinkableType(event) {
    const linkableType = event.currentTarget.dataset.linkableType
    
    // Update button states for linkable type buttons
    this.updateLinkableTypeButtonStates(event.currentTarget)
    
    // Update the hidden radio button for form submission
    const radioButton = document.getElementById(`linkable_type_${linkableType}`)
    if (radioButton) {
      radioButton.checked = true
    }
    
    // Show/hide appropriate sections
    this.showLinkableTypeFields(linkableType)
    
    this.updatePreview()
  }

  switchSchema(event) {
    const schemaType = event.currentTarget.dataset.schemaType
    
    // Update button states
    this.updateSchemaButtonStates(event.currentTarget)
    
    // Update the hidden radio button for form submission
    const radioButton = this.element.querySelector(`input[name*="schema_type"][value="${schemaType}"]`)
    if (radioButton) {
      radioButton.checked = true
    }
    
    // Show appropriate fields
    this.showFields(schemaType)
    
    // Note: No QR update needed - content type doesn't affect permalink
  }

  updateLinkableTypeButtonStates(activeButton) {
    // Remove active state from all linkable type buttons
    const buttons = this.element.querySelectorAll('[data-linkable-type]')
    buttons.forEach(button => {
      button.classList.remove('btn-primary')
      button.classList.add('btn-secondary')
    })
    
    // Add active state to clicked button
    activeButton.classList.remove('btn-secondary')
    activeButton.classList.add('btn-primary')
  }

  updateSchemaButtonStates(activeButton) {
    // Remove active state from all schema buttons
    const buttons = this.element.querySelectorAll('[data-schema-type]')
    buttons.forEach(button => {
      button.classList.remove('btn-primary')
      button.classList.add('btn-secondary')
    })
    
    // Add active state to clicked button
    activeButton.classList.remove('btn-secondary')
    activeButton.classList.add('btn-primary')
  }

  showLinkableTypeFields(linkableType) {
    if (linkableType === "playlist") {
      // Show playlist selection, hide shortened link fields
      if (this.hasPlaylistFieldsTarget) {
        this.playlistFieldsTarget.style.display = 'block'
      }
      if (this.hasShortenedLinkFieldsTarget) {
        this.shortenedLinkFieldsTarget.style.display = 'none'
      }
    } else {
      // Show shortened link fields, hide playlist selection
      if (this.hasPlaylistFieldsTarget) {
        this.playlistFieldsTarget.style.display = 'none'
      }
      if (this.hasShortenedLinkFieldsTarget) {
        this.shortenedLinkFieldsTarget.style.display = 'block'
      }
    }
  }

  showFields(schemaType) {
    // Hide all field groups
    this.hideAllFields()
    
    // Show the appropriate field group
    const targetName = `${schemaType}FieldsTarget`
    if (this[targetName]) {
      this[targetName].style.display = 'block'
    }
    
    // Update required attributes
    this.updateRequiredAttributes(schemaType)
  }

  hideAllFields() {
    const fieldTargets = ['urlFields', 'phoneFields', 'smsFields', 'emailFields', 'whatsappFields']
    fieldTargets.forEach(targetName => {
      const target = this[`${targetName}Target`]
      if (target) {
        target.style.display = 'none'
      }
    })
  }

  updateRequiredAttributes(activeSchemaType) {
    // Remove required from all fields first
    const allFields = this.element.querySelectorAll('input[required], textarea[required], select[required]')
    allFields.forEach(field => {
      field.removeAttribute('required')
    })

    // Add required to fields in the active schema
    const activeTarget = this[`${activeSchemaType}FieldsTarget`]
    if (activeTarget) {
      const activeFields = activeTarget.querySelectorAll('input[type="url"], input[type="tel"], input[type="email"], textarea')
      activeFields.forEach(field => {
        // Only add required to main fields, not optional ones like message fields
        if (this.shouldBeRequired(field, activeSchemaType)) {
          field.setAttribute('required', 'required')
        }
      })
    }
  }

  shouldBeRequired(field, schemaType) {
    const fieldName = field.name
    
    // Main target fields are always required
    if (fieldName.includes('[target_value]')) {
      return true
    }
    
    // Optional fields (messages, subjects) are not required
    return false
  }

  updateQRPreview() {
    // Find the QR code component and trigger an update
    const qrComponent = this.element.querySelector('[data-controller*="qr-code-component"]')
    if (qrComponent) {
      const qrController = this.application.getControllerForElementAndIdentifier(qrComponent, 'qr-code-component')
      if (qrController) {
        const newData = this.getCurrentSchemaData()
        const designSettings = {
          foregroundColor: this.getForegroundColor(),
          backgroundColor: this.getBackgroundColor(),
          dotStyle: this.getDotStyle(),
          cornerStyle: this.getCornerStyle()
        }
        
        // Update data and all design settings
        qrController.updateData(newData)
        qrController.updateDesignSettings(designSettings)
      }
    }
  }

  getForegroundColor() {
    const input = document.querySelector('[name="qr_code[design_settings][foreground_color]"]')
    return input?.value || "#000000"
  }

  getBackgroundColor() {
    const input = document.querySelector('[name="qr_code[design_settings][background_color]"]')
    return input?.value || "#FFFFFF"
  }

  getDotStyle() {
    const input = document.querySelector('[name="qr_code[design_settings][dot_style]"]')
    return input?.value || "rounded"
  }

  getCornerStyle() {
    const input = document.querySelector('[name="qr_code[design_settings][corner_style]"]')
    return input?.value || "rounded"
  }

  getCurrentSchemaData() {
    // The QR code should always point to the shortened link URL, regardless of schema type
    // This creates a permanent link that redirects to the actual target
    
    const customSlug = this.element.querySelector('[name="shortened_link[custom_slug]"]')?.value
    const baseUrl = window.location.origin
    
    if (customSlug && customSlug.trim()) {
      // Use custom slug if provided
      return `${baseUrl}/${customSlug.trim()}`
    } else {
      // Generate preview URL with placeholder short code for new QR codes
      return `${baseUrl}/abc123`
    }
  }

  // Method called when input fields change
  updatePreview() {
    this.updateQRPreview()
  }
}