# frozen_string_literal: true

# Service for creating playlist items with proper positioning and validation
#
# @example
#   service = CreatePlaylistItemService.new(playlist: @playlist, attributes: item_params)
#   playlist_item = service.run
class CreatePlaylistItemService
  # Initialize the service with playlist and item attributes
  #
  # @param [Playlist] playlist The playlist to add the item to
  # @param [Hash] attributes The playlist item attributes
  def initialize(playlist:, attributes:)
    @playlist = playlist
    @attributes = attributes
  end

  # Creates the playlist item with proper positioning
  #
  # @return [PlaylistItem] The created playlist item
  # @raise [ActiveRecord::RecordInvalid] If validation fails
  def run
    PlaylistItem.transaction do
      @playlist_item = @playlist.playlist_items.build(@attributes)
      
      # Set position if not provided
      @playlist_item.position = next_position if @playlist_item.position.blank?
      
      @playlist_item.save!
      
      # Update playlist redirect if this is the first item
      update_playlist_redirect_if_needed
      
      @playlist_item
    end
  end

  private

  # Gets the next available position in the playlist
  #
  # @return [Integer] Next position number
  def next_position
    (@playlist.playlist_items.maximum(:position) || -1) + 1
  end

  # Updates the playlist's QR redirect if this is the first item or current item
  #
  # @return [void]
  def update_playlist_redirect_if_needed
    if @playlist.current_item == @playlist_item
      @playlist.update_qr_redirect!
    end
  end
end