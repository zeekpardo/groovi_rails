# frozen_string_literal: true

class RedirectController < ApplicationController
  # Skip authentication if it's defined (Devise may not be loaded yet)
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :set_current_request_details, raise: false

  # GET /:short_code
  def show
    @short_code = params.expect(:short_code)
    @shortened_link = find_shortened_link(@short_code)

    return render_not_found unless @shortened_link
    return render_expired if @shortened_link.expired?
    return render_inactive unless @shortened_link.active?

    # Check if this shortened link belongs to a QR code with a playlist
    qr_code = @shortened_link.qr_codes.first
    if qr_code&.has_playlist? && qr_code.playlist.settings["auto_advance"].present?
      # Auto-advance playlist position after this access
      qr_code.playlist.advance_position!
    end

    # Track the click
    track_click(@shortened_link)

    # Get the redirect URL based on schema type
    redirect_url = @shortened_link.redirect_url

    redirect_to redirect_url, allow_other_host: true
  end

  private

  # Finds a shortened link by short code
  #
  # @param [String] short_code The short code to search for
  # @return [ShortenedLink, nil] The found link or nil
  def find_shortened_link(short_code)
    ShortenedLink.find_by(short_code: short_code) ||
      ShortenedLink.find_by(custom_slug: short_code)
  end

  # Tracks a click for analytics
  #
  # @param [ShortenedLink] shortened_link The link being clicked
  # @return [void]
  def track_click(shortened_link)
    click_data = {
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      referrer: request.referrer,
      metadata: {
        session_id: session.id.to_s,
        timestamp: Time.current.to_i
      }
    }

    # Track synchronously for now (TODO: enable async when Redis is running)
    # For development, we'll track synchronously to avoid Redis dependency
    if Rails.env.development?
      ClickTrackerJob.new.perform(shortened_link, click_data)
    else
      # In production, use async job processing
      ClickTrackerJob.perform_later(shortened_link, click_data)
    end
  rescue => e
    # Log error but don't fail the redirect
    Rails.logger.error "Failed to track click: #{e.message}"
  end

  # Renders 404 for not found links
  #
  # @return [void]
  def render_not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "minimal" }
      format.json { render json: {error: "Link not found"}, status: :not_found }
    end
  end

  # Renders expired link page
  #
  # @return [void]
  def render_expired
    respond_to do |format|
      format.html { render "redirect/expired", status: :gone, layout: "minimal" }
      format.json { render json: {error: "Link has expired"}, status: :gone }
    end
  end

  # Renders inactive link page
  #
  # @return [void]
  def render_inactive
    respond_to do |format|
      format.html { render "redirect/inactive", status: :gone, layout: "minimal" }
      format.json { render json: {error: "Link is inactive"}, status: :gone }
    end
  end
end
