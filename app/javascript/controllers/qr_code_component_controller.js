import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    data: String,
    foregroundColor: String,
    backgroundColor: String,
    size: Number,
    moduleSize: Number,
    showFallback: Boolean,
    dotStyle: String,
    cornerStyle: String
  }
  
  static targets = ["container", "loading", "display", "error"]

  connect() {
    this.generateQR()
  }

  // Public method to update QR code data
  updateData(newData) {
    this.dataValue = newData
    this.generateQR()
  }

  // Public method to update colors
  updateColors(foregroundColor, backgroundColor) {
    this.foregroundColorValue = foregroundColor || this.foregroundColorValue
    this.backgroundColorValue = backgroundColor || this.backgroundColorValue
    this.generateQR()
  }

  // Public method to update all design settings
  updateDesignSettings(settings) {
    if (settings.foregroundColor) this.foregroundColorValue = settings.foregroundColor
    if (settings.backgroundColor) this.backgroundColorValue = settings.backgroundColor
    if (settings.dotStyle) this.dotStyleValue = settings.dotStyle
    if (settings.cornerStyle) this.cornerStyleValue = settings.cornerStyle
    this.generateQR()
  }

  async generateQR() {
    try {
      this.showLoading()
      
      const data = this.dataValue
      if (!data) {
        throw new Error("No data provided for QR code")
      }
      
      const response = await this.fetchQRCode(data)
      
      if (response.success && response.svg) {
        this.displaySVG(response.svg)
      } else {
        throw new Error(response.error || "Failed to generate QR code")
      }
      
    } catch (error) {
      console.warn("QR generation failed:", error)
      this.showError()
    }
  }

  async fetchQRCode(data) {
    const url = new URL('/qr/preview', window.location.origin)
    url.searchParams.set('data', data)
    url.searchParams.set('foreground_color', this.foregroundColorValue)
    url.searchParams.set('background_color', this.backgroundColorValue)
    url.searchParams.set('size', this.sizeValue.toString())
    url.searchParams.set('module_size', this.moduleSizeValue.toString())
    url.searchParams.set('dot_style', this.dotStyleValue || 'rounded')
    url.searchParams.set('corner_style', this.cornerStyleValue || 'rounded')
    
    const response = await fetch(url, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    
    return await response.json()
  }

  displaySVG(svgContent) {
    this.displayTarget.innerHTML = svgContent
    this.showDisplay()
  }

  useFallback() {
    if (!this.showFallbackValue) {
      return
    }
    
    const data = encodeURIComponent(this.dataValue)
    const size = this.sizeValue
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=${data}`
    
    this.displayTarget.innerHTML = `
      <img src="${qrUrl}" 
           alt="QR Code" 
           class="qr-fallback"
           style="width: ${size}px; height: ${size}px;">
      <p class="text-xs text-gray-500 mt-2">Fallback QR Code</p>
    `
    
    this.showDisplay()
  }

  showLoading() {
    this.hideAll()
    this.loadingTarget.style.display = 'flex'
  }

  showDisplay() {
    this.hideAll()
    this.displayTarget.style.display = 'flex'
  }

  showError() {
    this.hideAll()
    this.errorTarget.style.display = 'flex'
  }

  hideAll() {
    this.loadingTarget.style.display = 'none'
    this.displayTarget.style.display = 'none'
    this.errorTarget.style.display = 'none'
  }
}