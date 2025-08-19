# frozen_string_literal: true

# Controller for managing playlist items within QR code playlists
class PlaylistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_qr_code
  before_action :set_playlist
  before_action :set_playlist_item, only: [:show, :edit, :update, :destroy]

  # GET /qr_codes/:qr_code_id/playlist/items
  def index
    @playlist_items = @playlist.playlist_items.ordered
  end

  # GET /qr_codes/:qr_code_id/playlist/items/1
  def show
  end

  # GET /qr_codes/:qr_code_id/playlist/items/new
  def new
    @playlist_item = @playlist.playlist_items.build
  end

  # GET /qr_codes/:qr_code_id/playlist/items/1/edit
  def edit
  end

  # POST /qr_codes/:qr_code_id/playlist/items
  def create
    service = CreatePlaylistItemService.new(
      playlist: @playlist,
      attributes: playlist_item_params
    )

    respond_to do |format|
      begin
        @playlist_item = service.run
        format.html {
          redirect_to qr_code_playlist_path(@qr_code),
            notice: "Playlist item created successfully"
        }
        format.json { render :show, status: :created }
      rescue ActiveRecord::RecordInvalid => e
        @playlist_item = e.record
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @playlist_item.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /qr_codes/:qr_code_id/playlist/items/1
  def update
    service = UpdatePlaylistItemService.new(
      playlist_item: @playlist_item,
      attributes: playlist_item_params
    )

    respond_to do |format|
      begin
        service.run
        format.html {
          redirect_to qr_code_playlist_path(@qr_code),
            notice: "Playlist item updated successfully"
        }
        format.json { render :show, status: :ok }
      rescue ActiveRecord::RecordInvalid => e
        @playlist_item = e.record
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @playlist_item.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /qr_codes/:qr_code_id/playlist/items/1
  def destroy
    was_current = @playlist.current_item == @playlist_item
    @playlist_item.destroy!

    # Update QR redirect if we deleted the current item
    @playlist.update_qr_redirect! if was_current

    respond_to do |format|
      format.html {
        redirect_to qr_code_playlist_path(@qr_code),
          notice: "Playlist item deleted successfully"
      }
      format.json { head :no_content }
    end
  end

  # POST /qr_codes/:qr_code_id/playlist/items/reorder
  def reorder
    items_params = params[:items]

    return head :bad_request unless items_params.is_a?(Array)

    ActiveRecord::Base.transaction do
      items_params.each_with_index do |item_data, index|
        item = @playlist.playlist_items.find(item_data[:id])
        item.update!(position: index)
      end
    end

    # Update QR redirect in case the current item position changed
    @playlist.update_qr_redirect!

    render json: {success: true}
  rescue ActiveRecord::RecordInvalid => e
    render json: {success: false, errors: e.message}, status: :unprocessable_content
  end

  private

  # Sets the QR code from the URL
  #
  # @return [void]
  def set_qr_code
    @qr_code = current_account.qr_codes.find(params[:qr_code_id])
  end

  # Sets the playlist from the QR code
  #
  # @return [void]
  def set_playlist
    @playlist = @qr_code.playlist
    redirect_to qr_code_path(@qr_code), alert: "No playlist found for this QR code" unless @playlist
  end

  # Sets the playlist item for member actions
  #
  # @return [void]
  def set_playlist_item
    @playlist_item = @playlist.playlist_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to qr_code_playlist_path(@qr_code), alert: "Playlist item not found"
  end

  # Strong parameters for playlist item creation/updates
  #
  # @return [ActionController::Parameters] Permitted parameters
  def playlist_item_params
    params.expect(playlist_item: [
      :title, :schema_type, :target_value, :position,
      metadata: [:message, :subject]
    ])
  end
end
