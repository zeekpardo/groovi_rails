import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="qr-form"
export default class extends Controller {
  static targets = [
    "schemaSelect",
    "urlFields", "urlInput",
    "phoneFields", "phoneInput", 
    "smsFields", "smsInput",
    "emailFields", "emailInput",
    "whatsappFields", "whatsappInput",
    "linkTitle"
  ]

  connect() {
    this.switchContentType()
  }

  switchContentType() {
    const selectedType = this.schemaSelectTarget.value

    // Hide all field groups and disable their inputs
    this.hideAllFields()

    // Show the selected field group and enable its inputs
    switch(selectedType) {
      case "url":
        this.urlFieldsTarget.style.display = "block"
        this.enableFieldGroup(this.urlFieldsTarget)
        break
      case "phone":
        this.phoneFieldsTarget.style.display = "block"
        this.enableFieldGroup(this.phoneFieldsTarget)
        break
      case "sms":
        this.smsFieldsTarget.style.display = "block"
        this.enableFieldGroup(this.smsFieldsTarget)
        break
      case "email":
        this.emailFieldsTarget.style.display = "block"
        this.enableFieldGroup(this.emailFieldsTarget)
        break
      case "whatsapp":
        this.whatsappFieldsTarget.style.display = "block"
        this.enableFieldGroup(this.whatsappFieldsTarget)
        break
    }
  }

  hideAllFields() {
    const fieldTargets = [
      this.urlFieldsTarget,
      this.phoneFieldsTarget,
      this.smsFieldsTarget,
      this.emailFieldsTarget,
      this.whatsappFieldsTarget
    ]

    fieldTargets.forEach(target => {
      if (target) {
        target.style.display = "none"
        this.disableFieldGroup(target)
      }
    })
  }

  enableFieldGroup(fieldGroup) {
    const inputs = fieldGroup.querySelectorAll('input, textarea, select')
    inputs.forEach(input => {
      input.disabled = false
    })
  }

  disableFieldGroup(fieldGroup) {
    const inputs = fieldGroup.querySelectorAll('input, textarea, select')
    inputs.forEach(input => {
      input.disabled = true
    })
  }


}
