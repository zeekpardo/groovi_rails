# frozen_string_literal: true

# Represents an item within a playlist
class PlaylistItem < ApplicationRecord
  include SchemaSwitchable

  # Associations
  belongs_to :playlist


  # Validations
  validates :title, presence: true
  validates :target_value, presence: true
  validates :position, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :position, uniqueness: {scope: :playlist_id}

  # Normalizations
  normalizes :title, with: ->(title) { title&.strip }
  normalizes :target_value, with: ->(value) { value&.strip }

  # Store JSON attributes for schema-specific data
  store_accessor :metadata, :message, :subject

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }
  scope :by_schema, ->(type) { where(schema_type: type) }

  # Callbacks
  before_create :set_position, if: -> { position.blank? }
  after_destroy :reorder_positions

  # Increments the click count for this playlist item
  #
  # @return [void]
  def increment_clicks!
    increment!(:click_count)
  end

  # Builds the appropriate redirect URL based on schema type
  #
  # @return [String] Formatted URL for the schema type
  def build_redirect_url
    case schema_type.to_s
    when "url"
      target_value
    when "sms"
      "sms:#{target_value}?body=#{URI.encode_www_form_component(message || "")}"
    when "phone"
      "tel:#{target_value}"
    when "email"
      params = []
      params << "subject=#{URI.encode_www_form_component(subject)}" if subject.present?
      params << "body=#{URI.encode_www_form_component(message)}" if message.present?
      query = params.any? ? "?#{params.join("&")}" : ""
      "mailto:#{target_value}#{query}"
    when "whatsapp"
      encoded_message = URI.encode_www_form_component(message || "")
      "https://wa.me/#{target_value.gsub(/\D/, "")}?text=#{encoded_message}"
    else
      target_value
    end
  end

  # Returns a human-readable description of the target
  #
  # @return [String] Human-readable description with truncated details
  def target_description
    case schema_type.to_s
    when "url"
      target_value
    when "phone"
      target_value
    when "sms"
      "#{target_value} - #{message&.truncate(50)}"
    when "email"
      "#{target_value} - #{subject&.truncate(50)}"
    when "whatsapp"
      "#{target_value} - #{message&.truncate(50)}"
    else
      target_value
    end
  end

  private

  # Sets the position to the next available position in the playlist
  #
  # @return [void]
  def set_position
    max_position = playlist.playlist_items.maximum(:position) || -1
    self.position = max_position + 1
  end

  # Reorders positions after deletion to prevent gaps
  #
  # @return [void]
  def reorder_positions
    playlist.playlist_items.where("position > ?", position).update_all("position = position - 1")
  end
end
