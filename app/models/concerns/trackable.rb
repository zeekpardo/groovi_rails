# frozen_string_literal: true

# Provides click tracking functionality for models
#
# @example Usage
#   class ShortenedLink < ApplicationRecord
#     include Trackable
#   end
#
module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :link_clicks, foreign_key: :shortened_link_id, dependent: :destroy

    # Track a click for this resource
    #
    # @param [Hash] click_data Information about the click
    # @option click_data [String] :ip_address The IP address of the visitor
    # @option click_data [String] :user_agent The user agent string
    # @option click_data [String] :referrer The referrer URL
    # @return [LinkClick] The created click record
    def track_click!(click_data = {})
      link_clicks.create!(
        clicked_at: Time.current,
        ip_address: click_data[:ip_address],
        user_agent: click_data[:user_agent],
        referrer: click_data[:referrer],
        metadata: click_data[:metadata] || {}
      )

      # Update click count
      increment!(:click_count)
    end
  end
end
