# frozen_string_literal: true

# Provides schema type switching functionality for models
#
# @example Usage
#   class ShortenedLink < ApplicationRecord
#     include SchemaSwitchable
#   end
#
module SchemaSwitchable
  extend ActiveSupport::Concern

  included do
    enum :schema_type, {
      url: "url",
      phone: "phone", 
      sms: "sms",
      email: "email",
      whatsapp: "whatsapp"
    }, validate: true

    validates :target_value, presence: true
    validate :validate_target_value_format

    # Store JSON attributes in metadata
    store_accessor :metadata, :message, :subject

    # Normalizations
    normalizes :target_value, with: ->(value) { value&.strip }

    # Checks if this link requires additional metadata
    #
    # @return [Boolean] True if schema requires metadata
    def requires_metadata?
      sms? || email? || whatsapp?
    end

    # Gets the appropriate redirect URL based on schema type
    #
    # @return [String] The redirect URL
    def redirect_url
      SchemaHandlerService.build_redirect_url(self)
    end
  end

  private

  # Validates the target value format based on schema type
  #
  # @return [void]
  def validate_target_value_format
    case schema_type
    when "url"
      validate_url_format
    when "phone"
      validate_phone_format
    when "email"
      validate_email_format
    when "sms"
      validate_phone_format
    when "whatsapp"
      validate_phone_format
    end
  end

  # Validates URL format
  #
  # @return [void]
  def validate_url_format
    return if target_value.blank? # Skip validation if target_value is blank (handled by presence validation)
    
    uri = URI.parse(target_value)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:target_value, "must be a valid URL")
    end
  rescue URI::InvalidURIError
    errors.add(:target_value, "must be a valid URL")
  end

  # Validates phone number format
  #
  # @return [void]
  def validate_phone_format
    return if target_value.blank? # Skip validation if target_value is blank (handled by presence validation)
    
    unless target_value.match?(/\A\+?[1-9]\d{1,14}\z/)
      errors.add(:target_value, "must be a valid phone number")
    end
  end

  # Validates email format
  #
  # @return [void]
  def validate_email_format
    return if target_value.blank? # Skip validation if target_value is blank (handled by presence validation)
    
    unless target_value.match?(URI::MailTo::EMAIL_REGEXP)
      errors.add(:target_value, "must be a valid email address")
    end
  end
end
