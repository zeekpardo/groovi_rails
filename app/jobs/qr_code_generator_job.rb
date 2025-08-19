# frozen_string_literal: true

# Background job for generating QR code images
class QrCodeGeneratorJob < ApplicationJob
  queue_as :default

  # Generates QR code images for a given QR code record
  #
  # @param [QrCode] qr_code The QR code record
  # @return [void]
  def perform(qr_code)
    service = QrCodeGeneratorService.new(qr_code: qr_code)
    service.generate_and_attach!
  rescue => e
    Rails.logger.error "Failed to generate QR code images for QR Code #{qr_code.id}: #{e.message}"
    raise e
  end
end
