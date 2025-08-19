# frozen_string_literal: true

# Service for building redirect URLs based on schema types
#
# @example Build URL redirect
#   url = SchemaHandlerService.build_redirect_url(shortened_link)
#
class SchemaHandlerService
  # Builds the appropriate redirect URL based on schema type
  #
  # @param [ShortenedLink] shortened_link The link to build URL for
  # @return [String] The redirect URL
  # @raise [ArgumentError] If schema type is unsupported
  def self.build_redirect_url(shortened_link)
    case shortened_link.schema_type
    when "url"
      build_url_redirect(shortened_link)
    when "sms"
      build_sms_redirect(shortened_link)
    when "phone"
      build_phone_redirect(shortened_link)
    when "email"
      build_email_redirect(shortened_link)
    when "whatsapp"
      build_whatsapp_redirect(shortened_link)
    else
      raise ArgumentError, "Unsupported schema type: #{shortened_link.schema_type}"
    end
  end

  # Checks if a schema type is supported
  #
  # @param [String] schema_type The schema type to check
  # @return [Boolean] True if supported
  def self.supported_schema?(schema_type)
    %w[url sms phone email whatsapp].include?(schema_type.to_s)
  end

  private

  # Builds URL redirect with UTM parameters if present
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] The URL with optional UTM parameters
  def self.build_url_redirect(link)
    url = link.target_value

    # Add UTM parameters if present
    if link.utm_source.present? || link.utm_medium.present? || link.utm_campaign.present?
      uri = URI.parse(url)
      params = URI.decode_www_form(uri.query || "")

      params << ["utm_source", link.utm_source] if link.utm_source.present?
      params << ["utm_medium", link.utm_medium] if link.utm_medium.present?
      params << ["utm_campaign", link.utm_campaign] if link.utm_campaign.present?
      params << ["utm_content", link.short_code] # Always add the short code as content

      uri.query = URI.encode_www_form(params)
      url = uri.to_s
    end

    url
  end

  # Builds SMS redirect URL
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] The SMS URL
  def self.build_sms_redirect(link)
    phone = link.target_value
    message = link.message || ""

    "sms:#{phone}?body=#{CGI.escape(message)}"
  end

  # Builds phone redirect URL
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] The phone URL
  def self.build_phone_redirect(link)
    "tel:#{link.target_value}"
  end

  # Builds email redirect URL
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] The email URL
  def self.build_email_redirect(link)
    email = link.target_value
    subject = link.subject || ""
    message = link.message || ""

    params = []
    params << "subject=#{CGI.escape(subject)}" if subject.present?
    params << "body=#{CGI.escape(message)}" if message.present?

    query = params.any? ? "?#{params.join("&")}" : ""
    "mailto:#{email}#{query}"
  end

  # Builds WhatsApp redirect URL
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] The WhatsApp URL
  def self.build_whatsapp_redirect(link)
    phone = link.target_value.gsub(/\D/, "") # Remove non-digits
    message = link.message || ""

    "https://wa.me/#{phone}?text=#{CGI.escape(message)}"
  end
end
