# frozen_string_literal: true

module ShortenedLinksHelper
  # Returns the appropriate CSS class for schema type pills
  #
  # @param [String] schema_type The schema type
  # @return [String] CSS class for the pill
  def schema_color(schema_type)
    case schema_type.to_s
    when "url"
      "pill-primary"
    when "phone"
      "pill-success"
    when "sms"
      "pill-info"
    when "email"
      "pill-warning"
    when "whatsapp"
      "pill-success"
    else
      "pill-secondary"
    end
  end

  # Returns formatted short URL with protocol
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] Full URL with protocol
  def formatted_short_url(link)
    return "" unless link&.short_code

    host = Rails.application.routes.default_url_options[:host] || "localhost:3000"
    protocol = Rails.env.production? ? "https" : "http"

    "#{protocol}://#{host}/#{link.short_code}"
  end

  # Returns schema type options for select dropdown
  #
  # @return [Array] Array of [label, value] pairs
  def schema_type_options
    [
      [t("shortened_links.form.schema_types.url"), "url"],
      [t("shortened_links.form.schema_types.phone"), "phone"],
      [t("shortened_links.form.schema_types.sms"), "sms"],
      [t("shortened_links.form.schema_types.email"), "email"],
      [t("shortened_links.form.schema_types.whatsapp"), "whatsapp"]
    ]
  end

  # Returns click stats summary for a link
  #
  # @param [ShortenedLink] link The shortened link
  # @param [Integer] days Number of days to analyze
  # @return [Hash] Stats hash with counts and percentages
  def link_stats_summary(link, days: 7)
    total = link.click_count
    recent = link.link_clicks.where(clicked_at: days.days.ago..Time.current).count

    {
      total: total,
      recent: recent,
      recent_percentage: (total > 0) ? ((recent.to_f / total) * 100).round(1) : 0
    }
  end

  # Returns formatted expiration status
  #
  # @param [ShortenedLink] link The shortened link
  # @return [String] Formatted expiration status
  def expiration_status(link)
    return "No expiration" unless link.expires_at

    if link.expired?
      "Expired #{time_ago_in_words(link.expires_at)} ago"
    else
      "Expires #{time_ago_in_words(link.expires_at)} from now"
    end
  end

  # Returns icon class for schema types
  #
  # @param [String] schema_type The schema type
  # @return [String] Icon class name
  def schema_icon(schema_type)
    case schema_type.to_s
    when "url"
      "fas fa-link"
    when "phone"
      "fas fa-phone"
    when "sms"
      "fas fa-sms"
    when "email"
      "fas fa-envelope"
    when "whatsapp"
      "fab fa-whatsapp"
    else
      "fas fa-question"
    end
  end
end
