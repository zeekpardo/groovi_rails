# frozen_string_literal: true

# Represents a click on a shortened link for analytics
#
# @example Creating a click record
#   click = link.link_clicks.create!(
#     clicked_at: Time.current,
#     ip_address: "127.0.0.1",
#     user_agent: "Mozilla/5.0..."
#   )
#
class LinkClick < ApplicationRecord
  # Associations
  belongs_to :shortened_link, counter_cache: :click_count

  # Validations
  validates :clicked_at, presence: true
  validates :ip_address, presence: true

  # Store JSON attributes
  store_accessor :metadata, :session_id, :campaign_source, :utm_params

  # Scopes
  scope :recent, ->(days = 7) { where(clicked_at: days.days.ago..Time.current) }
  scope :by_country, ->(country) { where(country: country) }
  scope :by_device, ->(device) { where(device_type: device) }
  scope :today, -> { where(clicked_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(clicked_at: 1.week.ago..Time.current) }
  scope :this_month, -> { where(clicked_at: 1.month.ago..Time.current) }

  # Before callbacks
  before_create :parse_user_agent
  before_create :extract_location_info

  # Gets the account this click belongs to through the shortened link
  #
  # @return [Account] The associated account
  def account
    shortened_link.account
  end

  # Checks if this click is from a unique visitor (based on IP)
  #
  # @return [Boolean] True if first click from this IP for this link
  def unique_visitor?
    shortened_link.link_clicks.where(ip_address: ip_address).where.not(id: id).empty?
  end

  # Gets the time zone adjusted clicked_at time
  #
  # @param [String] timezone The timezone to convert to
  # @return [Time] The time in the specified timezone
  def clicked_at_in_timezone(timezone = "UTC")
    clicked_at.in_time_zone(timezone)
  end

  private

  # Parses user agent string to extract device and browser info
  #
  # @return [void]
  def parse_user_agent
    return unless user_agent.present?

    # Simple user agent parsing - could use a gem like 'user_agent' for more accuracy
    self.device_type = case user_agent
    when /Mobile|Android|iPhone|iPad/i
      "mobile"
    when /Tablet/i
      "tablet"
    else
      "desktop"
    end

    self.browser = case user_agent
    when /Chrome/i
      "Chrome"
    when /Firefox/i
      "Firefox"
    when /Safari/i
      "Safari"
    when /Edge/i
      "Edge"
    else
      "Other"
    end
  end

  # Extracts location information from IP address
  # This would typically use a service like MaxMind GeoIP
  #
  # @return [void]
  def extract_location_info
    return unless ip_address.present?

    # Placeholder for geolocation service
    # In production, you'd use something like:
    # GeolocationJob.perform_later(self)

    # For now, just set defaults
    self.country ||= "Unknown"
    self.city ||= "Unknown"
  end
end
