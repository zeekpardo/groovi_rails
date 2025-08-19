# frozen_string_literal: true

# Represents a playlist of schema-flexible items
class Playlist < ApplicationRecord
  include Trackable
  include Shortable

  acts_as_tenant :account
  has_prefix_id :playlist

  PLAYLIST_TYPES = ["sequential", "random"].freeze

  # Associations
  belongs_to :account
  belongs_to :qr_code
  belongs_to :created_by, class_name: "User"
  has_many :playlist_items, -> { order(:position) }, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :playlist_items, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :short_code, presence: true, uniqueness: true
  validates :playlist_type, inclusion: PLAYLIST_TYPES
  validates :current_position, presence: true, numericality: {greater_than_or_equal_to: 0}

  # Normalizations
  normalizes :short_code, with: ->(code) { code&.downcase&.strip }

  # Store JSON attributes
  store_accessor :settings, :auto_advance, :loop_playlist

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :generate_short_code, if: -> { short_code.blank? }
  before_create :set_defaults

  # Returns the current active item based on current_position
  # @return [PlaylistItem, nil] Current item or nil if empty
  def current_item
    return nil if playlist_items.empty?

    # Ensure position is within bounds
    valid_position = current_position.clamp(0, playlist_items.count - 1)
    playlist_items.offset(valid_position).first
  end

  # Advances to the next item in the playlist and updates the QR code redirect
  # @return [Boolean] True if advanced, false if at end
  def advance_position!
    return false if playlist_items.empty?

    advanced = if sequential?
      if current_position < playlist_items.count - 1
        increment!(:current_position)
        true
      elsif loop_playlist?
        update!(current_position: 0)
        true
      else
        false
      end
    else
      # Random selection
      update!(current_position: rand(playlist_items.count))
      true
    end

    # Update the QR code's shortened link to point to current item
    update_qr_redirect! if advanced

    advanced
  end

  # Updates the QR code's shortened link to point to the current playlist item
  # @return [void]
  def update_qr_redirect!
    current_playlist_item = current_item
    return unless current_playlist_item

    shortened_link = qr_code.linkable
    shortened_link.update!(
      schema_type: current_playlist_item.schema_type,
      target_value: current_playlist_item.target_value,
      message: current_playlist_item.message,
      subject: current_playlist_item.subject
    )
  end

  # Checks if playlist is sequential type
  # @return [Boolean] True if sequential
  def sequential?
    playlist_type == "sequential"
  end

  # Checks if playlist is random type
  # @return [Boolean] True if random
  def random?
    playlist_type == "random"
  end

  # Checks if playlist should loop
  # @return [Boolean] True if loop enabled
  def loop_playlist?
    settings["loop_playlist"].present?
  end

  # Gets the full URL for this playlist
  # @return [String] Full URL
  def full_url
    Rails.application.routes.url_helpers.playlist_url(short_code, host: Rails.application.config.action_mailer.default_url_options[:host])
  end

  # Returns a title for linking purposes
  # @return [String] QR code name
  def linkable_title
    qr_code_name
  end

  # Delegate name to the QR code
  # @return [String] QR code name
  def qr_code_name
    qr_code&.name || "Untitled Playlist"
  end

  # For backward compatibility and display purposes
  alias_method :name, :qr_code_name

  private

  # Generates a unique short code
  def generate_short_code
    loop do
      code = SecureRandom.alphanumeric(6).downcase
      if !self.class.exists?(short_code: code) && !ShortenedLink.exists?(short_code: code)
        self.short_code = code
        break
      end
    end
  end

  # Sets default values
  def set_defaults
    self.playlist_type ||= "sequential"
    self.current_position ||= 0
    self.active = true if active.nil?
    self.settings ||= {}
  end
end
