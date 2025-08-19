# frozen_string_literal: true

# Controller for managing playlists associated with QR codes
class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_qr_code
  before_action :set_playlist, only: [:show, :edit, :update, :destroy, :advance, :reset]

  # GET /qr_codes/:qr_code_id/playlist
  def show
    @playlist_items = @playlist.playlist_items.ordered.active
  end

  # GET /qr_codes/:qr_code_id/playlist/edit
  def edit
    @playlist_items = @playlist.playlist_items.ordered
  end

  # POST /qr_codes/:qr_code_id/playlist
  def create
    # Check if playlist already exists
    if @qr_code.has_playlist?
      redirect_to qr_code_playlist_path(@qr_code), notice: "Playlist already exists for this QR code."
      return
    end

    @playlist = current_account.playlists.build
    @playlist.qr_code = @qr_code
    @playlist.created_by = current_user

    # Set sensible defaults
    @playlist.playlist_type = "sequential"
    @playlist.settings = {"auto_advance" => false, "loop_playlist" => false}

    respond_to do |format|
      if @playlist.save
        format.html {
          redirect_to qr_code_playlist_path(@qr_code),
            notice: "Playlist created successfully! Add your first item to get started."
        }
        format.json { render :show, status: :created }
      else
        Rails.logger.error "Playlist creation failed: #{@playlist.errors.full_messages.join(', ')}"
        format.html {
          redirect_to qr_code_path(@qr_code),
            alert: "Failed to create playlist: #{@playlist.errors.full_messages.join(', ')}"
        }
        format.json { render json: @playlist.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /qr_codes/:qr_code_id/playlist
  def update
    respond_to do |format|
      if @playlist.update(playlist_params)
        # Update the QR code's redirect to reflect changes
        @playlist.update_qr_redirect!

        format.html {
          redirect_to qr_code_playlist_path(@qr_code),
            notice: "Playlist updated successfully"
        }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @playlist.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /qr_codes/:qr_code_id/playlist
  def destroy
    @playlist.destroy!

    respond_to do |format|
      format.html {
        redirect_to qr_code_path(@qr_code),
          notice: "Playlist deleted successfully"
      }
      format.json { head :no_content }
    end
  end

  # POST /qr_codes/:qr_code_id/playlist/advance
  def advance
    if @playlist.advance_position!
      @playlist.update_qr_redirect!

      render json: {
        success: true,
        current_position: @playlist.current_position,
        current_item: @playlist.current_item&.title
      }
    else
      render json: {
        success: false,
        message: "Cannot advance further"
      }
    end
  end

  # POST /qr_codes/:qr_code_id/playlist/reset
  def reset
    @playlist.update!(current_position: 0)
    @playlist.update_qr_redirect!

    render json: {
      success: true,
      current_position: @playlist.current_position,
      current_item: @playlist.current_item&.title
    }
  end

  private

  # Sets the QR code from the URL
  #
  # @return [void]
  def set_qr_code
    @qr_code = current_account.qr_codes.find(params[:qr_code_id])
  end

  # Sets the playlist for member actions
  #
  # @return [void]
  def set_playlist
    @playlist = @qr_code.playlist
    redirect_to qr_code_path(@qr_code), alert: "No playlist found for this QR code" unless @playlist
  end

  # Strong parameters for playlist updates
  #
  # @return [ActionController::Parameters] Permitted parameters
  def playlist_params
    params.expect(playlist: [
      :description, :playlist_type,
      settings: [:auto_advance, :loop_playlist],
      playlist_items_attributes: [
        :id, :title, :schema_type, :target_value, :position, :_destroy,
        metadata: [:message, :subject]
      ]
    ])
  end
end
