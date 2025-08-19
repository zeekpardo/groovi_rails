# frozen_string_literal: true

# Represents a shortened link with flexible schema types
#
# @example Creating a URL shortener
#   link = account.shortened_links.create!(
#     title: "My Website",
#     schema_type: :url,
#     target_value: "https://example.com"
#   )
#
# @example Creating a phone link
#   link = account.shortened_links.create!(
#     title: "Call Us",
#     schema_type: :phone,
#     target_value: "+1234567890"
#   )
#
class ShortenedLink < ApplicationRecord
  include Trackable
  include Shortable
  include SchemaSwitchable

  acts_as_tenant :account
  has_prefix_id :link

  SCHEMA_TYPES = [:url, :sms, :phone, :email, :whatsapp].freeze

  # Associations
  belongs_to :account
  belongs_to :created_by, class_name: "User", optional: true
  has_many :qr_codes, as: :linkable, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :short_code, presence: true, uniqueness: true
  validates :custom_slug, uniqueness: true, allow_blank: true
  validates :click_count, numericality: {greater_than_or_equal_to: 0}

  # Normalizations
  normalizes :short_code, with: ->(code) { code&.downcase&.strip }
  normalizes :custom_slug, with: ->(slug) { slug&.downcase&.strip }

  # Store JSON attributes
  store_accessor :metadata, :message, :subject
  store_accessor :settings, :utm_source, :utm_medium, :utm_campaign

  # Default attributes
  attribute :active, default: true
  attribute :click_count, default: 0

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_schema, ->(type) { where(schema_type: type) }
  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :not_expired, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(click_count: :desc) }

  # Checks if link has expired
  #
  # @return [Boolean] True if the link has expired
  def expired?
    expires_at.present? && expires_at < Time.current
  end

  # Checks if link is accessible (active and not expired)
  #
  # @return [Boolean] True if the link can be accessed
  def accessible?
    active? && !expired?
  end

  # Gets the display name for the schema type
  #
  # @return [String] Human readable schema type
  def schema_display_name
    schema_type.humanize
  end

  # Gets recent click statistics
  #
  # @param [Integer] days Number of days to look back
  # @return [Hash] Statistics hash
  def click_stats(days: 7)
    recent_clicks = link_clicks.where(clicked_at: days.days.ago..Time.current)

    {
      total_clicks: click_count,
      recent_clicks: recent_clicks.count,
      unique_ips: recent_clicks.distinct.count(:ip_address),
      top_countries: recent_clicks.group(:country).count.first(5),
      top_devices: recent_clicks.group(:device_type).count.first(5)
    }
  end
end
