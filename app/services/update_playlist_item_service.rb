# frozen_string_literal: true

# Service for updating playlist items with proper redirect handling
#
# @example
#   service = UpdatePlaylistItemService.new(playlist_item: @item, attributes: item_params)
#   updated_item = service.run
class UpdatePlaylistItemService
  # Initialize the service with playlist item and attributes
  #
  # @param [PlaylistItem] playlist_item The playlist item to update
  # @param [Hash] attributes The updated attributes
  def initialize(playlist_item:, attributes:)
    @playlist_item = playlist_item
    @attributes = attributes
    @playlist = playlist_item.playlist
  end

  # Updates the playlist item and handles redirect updates
  #
  # @return [PlaylistItem] The updated playlist item
  # @raise [ActiveRecord::RecordInvalid] If validation fails
  def run
    PlaylistItem.transaction do
      was_current_item = @playlist.current_item == @playlist_item
      
      @playlist_item.update!(@attributes)
      
      # Update playlist redirect if this was or is the current item
      update_playlist_redirect_if_needed(was_current_item)
      
      @playlist_item
    end
  end

  private

  # Updates the playlist's QR redirect if needed
  #
  # @param [Boolean] was_current_item Whether this item was the current item before update
  # @return [void]
  def update_playlist_redirect_if_needed(was_current_item)
    if was_current_item || @playlist.current_item == @playlist_item
      @playlist.update_qr_redirect!
    end
  end
end