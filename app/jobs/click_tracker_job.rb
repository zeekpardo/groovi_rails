# frozen_string_literal: true

# Job for tracking clicks on shortened links asynchronously
#
# @example Track a click
#   ClickTrackerJob.perform_later(shortened_link, click_data)
#
class ClickTrackerJob < ApplicationJob
  queue_as :default

  # Performs the click tracking
  #
  # @param [ShortenedLink] shortened_link The link that was clicked
  # @param [Hash] click_data Information about the click
  def perform(shortened_link, click_data)
    # Process click data and extract additional information
    processed_data = process_click_data(click_data)

    # Create the click record
    shortened_link.track_click!(processed_data)
  rescue => e
    Rails.logger.error "Failed to track click for link #{shortened_link.id}: #{e.message}"
    # Don't re-raise to avoid job failures for non-critical analytics
  end

  private

  # Processes raw click data to extract useful information
  #
  # @param [Hash] click_data Raw click data
  # @return [Hash] Processed click data
  def process_click_data(click_data)
    processed = click_data.dup

    # Parse user agent for device and browser info
    if click_data[:user_agent].present?
      device_info = parse_user_agent(click_data[:user_agent])
      processed.merge!(device_info)
    end

    # Extract location from IP (placeholder - would use real geolocation service)
    if click_data[:ip_address].present?
      location_info = extract_location(click_data[:ip_address])
      processed.merge!(location_info)
    end

    processed
  end

  # Parses user agent string for device and browser information
  #
  # @param [String] user_agent The user agent string
  # @return [Hash] Device and browser information
  def parse_user_agent(user_agent)
    device_type = case user_agent
    when /Mobile|Android|iPhone/i
      "mobile"
    when /iPad|Tablet/i
      "tablet"
    else
      "desktop"
    end

    browser = case user_agent
    when /Edge/i
      "Edge"
    when /Chrome/i
      "Chrome"
    when /Firefox/i
      "Firefox"
    when /Safari/i
      "Safari"
    else
      "Other"
    end

    {device_type: device_type, browser: browser}
  end

  # Extracts location information from IP address
  # In production, this would use a real geolocation service
  #
  # @param [String] ip_address The IP address
  # @return [Hash] Location information
  def extract_location(ip_address)
    # Placeholder implementation
    # In production, use MaxMind GeoIP2 or similar service

    return {country: "Unknown", city: "Unknown"} if ip_address.blank?

    # For development/testing, just return localhost info
    if ip_address == "127.0.0.1" || ip_address == "::1"
      {country: "Local", city: "Development"}
    else
      {country: "Unknown", city: "Unknown"}
    end
  end
end
