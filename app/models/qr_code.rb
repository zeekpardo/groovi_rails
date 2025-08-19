# frozen_string_literal: true

# Represents a QR code with customizable design and polymorphic association
#
# @example Creating a QR code for a shortened link
#   qr_code = account.qr_codes.create!(
#     name: "My Campaign QR",
#     linkable: shortened_link,
#     design_settings: {
#       foreground_color: "#000000",
#       background_color: "#FFFFFF",
#       dot_style: "rounded"
#     }
#   )
#
class QrCode < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :qr

  # Available schema types for QR content
  SCHEMA_TYPES = [
    {value: "url", label: "website", icon: "globe"},
    {value: "phone", label: "phone", icon: "phone"},
    {value: "sms", label: "sms", icon: "message-square"},
    {value: "email", label: "email", icon: "mail"},
    {value: "whatsapp", label: "whatsapp", icon: "message-circle"}
  ].freeze

  # Associations
  belongs_to :account
  belongs_to :linkable, polymorphic: true
  belongs_to :created_by, class_name: "User", optional: true
  has_one :playlist, dependent: :destroy

  # Active Storage for QR code images
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [150, 150]
    attachable.variant :medium, resize_to_limit: [300, 300]
    attachable.variant :large, resize_to_limit: [600, 600]
  end

  # Validations
  validates :name, presence: true
  validates :short_url, presence: true, uniqueness: true
  validates :download_count, numericality: {greater_than_or_equal_to: 0}
  validates :scan_count, numericality: {greater_than_or_equal_to: 0}

  # Store JSON attributes for design settings
  store_accessor :design_settings,
    :foreground_color, :background_color,
    :dot_style, :corner_style,
    :logo_url, :transparent_background,
    :error_correction_level, :margin

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(scan_count: :desc, download_count: :desc) }
  scope :by_type, ->(type) { joins(:linkable).where(linkable_type: type) }

  # Callbacks
  before_validation :set_short_url, on: :create
  # after_create :generate_qr_images # Disabled for now - requires Redis/Sidekiq

  # Gets the target URL for the QR code
  #
  # @return [String] The short URL that the QR code contains
  def target_url
    host = Rails.application.routes.default_url_options[:host] || "localhost:3000"
    protocol = Rails.env.production? ? "https" : "http"
    "#{protocol}://#{host}/#{short_url_code}"
  end

  # Gets just the short code from the URL
  #
  # @return [String] The short code portion
  def short_url_code
    return linkable.short_code if linkable.respond_to?(:short_code)

    # Extract from full short_url if needed
    short_url.split("/").last
  end

  # Gets the linkable resource's title for display
  #
  # @return [String] Display title
  def linkable_title
    linkable.title.present? ? linkable.title : name
  end

  # Gets the schema type from the linkable resource
  #
  # @return [String] Schema type (url, phone, sms, etc.)
  def schema_type
    linkable.schema_type
  end

  # Checks if this QR code has a playlist
  #
  # @return [Boolean] True if playlist exists
  def has_playlist?
    playlist.present?
  end

  # Increments the download count
  #
  # @return [void]
  def increment_downloads!
    increment!(:download_count)
  end

  # Increments the scan count (called from redirect controller)
  #
  # @return [void]
  def increment_scans!
    increment!(:scan_count)
  end

  # Gets default design settings
  #
  # @return [Hash] Default design configuration
  def self.default_design_settings
    {
      foreground_color: "#000000",
      background_color: "#FFFFFF",
      dot_style: "rounded",
      corner_style: "rounded",
      transparent_background: false,
      error_correction_level: "M",
      margin: 4
    }
  end

  # Applies default design settings if none provided
  #
  # @return [Hash] Design settings with defaults applied
  def design_settings_with_defaults
    self.class.default_design_settings.merge(design_settings || {})
  end

  private

  # Sets the short URL from the linkable resource
  #
  # @return [void]
  def set_short_url
    return if short_url.present?

    self.short_url = if linkable.respond_to?(:short_code)
      linkable.short_code
    else
      # Generate a unique short code if linkable doesn't have one
      GenerateShortCodeService.new.run
    end
  end

  # Generates QR code images in different formats
  #
  # @return [void]
  def generate_qr_images
    QrCodeGeneratorJob.perform_later(self)
  end
end
