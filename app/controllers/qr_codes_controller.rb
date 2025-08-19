# frozen_string_literal: true

# Controller for managing QR codes
class QrCodesController < ApplicationController
  before_action :authenticate_user!, except: [:preview]
  before_action :set_qr_code, only: [:show, :edit, :update, :destroy, :download]

  # GET /qr_codes
  def index
    @pagy, @qr_codes = pagy(
      current_account.qr_codes
        .includes(:linkable, images_attachments: :blob)
        .recent,
      limit: 9
    )
  end

  # GET /qr_codes/1
  def show
    @design_settings = @qr_code.design_settings_with_defaults
  end

  # GET /qr_codes/new
  def new
    @qr_code = current_account.qr_codes.build
    @shortened_links = current_account.shortened_links.active

    # Pre-populate from shortened link if provided
    if params[:shortened_link_id].present?
      @shortened_link = current_account.shortened_links.find(params[:shortened_link_id])
      @qr_code.linkable = @shortened_link
      @qr_code.name = @shortened_link.title
    end

    # Pre-populate from playlist if provided
    if params[:playlist_id].present?
      @playlist = current_account.playlists.find(params[:playlist_id])
      @qr_code.linkable = @playlist
      @qr_code.name = @playlist.name
    end
  end

  # GET /qr_codes/1/edit
  def edit
    @shortened_links = current_account.shortened_links.active
    @design_settings = @qr_code.design_settings_with_defaults
  end

  # POST /qr_codes
  def create
    # Debug: Log what we're receiving
    Rails.logger.debug "DEBUG: All params: #{params.to_unsafe_h}"
    Rails.logger.debug "DEBUG: shortened_link params: #{params[:shortened_link]&.to_unsafe_h}"
    
    # Always create a shortened link for the QR code
    @shortened_link = create_shortened_link_from_params
    return render_errors_for_shortened_link if @shortened_link.nil?

    @qr_code = current_account.qr_codes.build(qr_code_params)
    @qr_code.created_by = current_user
    @qr_code.linkable = @shortened_link

    respond_to do |format|
      if @qr_code.save
        format.html {
          redirect_to qr_code_path(@qr_code),
            notice: t(".created")
        }
        format.json { render :show, status: :created }
      else
        # If QR code save fails, destroy the shortened link
        @shortened_link.destroy if @shortened_link.persisted?
        @shortened_links = current_account.shortened_links.active
        @design_settings = @qr_code&.design_settings_with_defaults
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @qr_code.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /qr_codes/1
  def update
    # Always update the associated shortened link
    if @qr_code.linkable.is_a?(ShortenedLink)
      @shortened_link = @qr_code.linkable
      unless update_shortened_link_from_params(@shortened_link)
        return render_errors_for_shortened_link
      end
    end

    respond_to do |format|
      if @qr_code.update(qr_code_params)
        # Regenerate images if design settings changed
        if qr_code_params[:design_settings].present?
          QrCodeGeneratorJob.perform_later(@qr_code)
        end

        format.html {
          redirect_to qr_code_path(@qr_code),
            notice: t(".updated")
        }
        format.json { render :show, status: :ok }
      else
        @shortened_links = current_account.shortened_links.active
        @design_settings = @qr_code.design_settings_with_defaults
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @qr_code.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /qr_codes/1
  def destroy
    @qr_code.destroy!

    respond_to do |format|
      format.html {
        redirect_to qr_codes_path,
          notice: t(".deleted")
      }
      format.json { head :no_content }
    end
  end

  # GET /qr_codes/1/download
  def download
    format = params[:format] || "png"
    size = params[:size]&.to_i || 300

    # Find the appropriate attached image
    attachment = find_attachment_by_format_and_size(format, size)

    if attachment
      @qr_code.increment_downloads!

      respond_to do |f|
        f.html { redirect_to rails_blob_path(attachment, disposition: "attachment") }
        f.json { render json: {download_url: rails_blob_path(attachment)} }
      end
    else
      # Generate on demand if not found
      service = QrCodeGeneratorService.new(qr_code: @qr_code, format: format, size: size)
      image_data = service.generate

      @qr_code.increment_downloads!

      respond_to do |f|
        f.html do
          if format == "svg"
            send_data image_data,
              filename: "#{@qr_code.name.parameterize}.svg",
              type: "image/svg+xml",
              disposition: "attachment"
          else
            # Decode base64 for PNG
            binary_data = Base64.decode64(image_data.split(",").last)
            send_data binary_data,
              filename: "#{@qr_code.name.parameterize}.png",
              type: "image/png",
              disposition: "attachment"
          end
        end
        f.json { render json: {image_data: image_data} }
      end
    end
  end

  # POST /qr_codes/1/regenerate
  def regenerate
    @qr_code = current_account.qr_codes.find(params[:id])
    QrCodeGeneratorJob.perform_later(@qr_code)

    respond_to do |format|
      format.html {
        redirect_to qr_code_path(@qr_code),
          notice: t(".regenerating")
      }
      format.json { render json: {status: "regenerating"} }
    end
  end

  # GET /qr/preview
  def preview
    data = params[:data] || "https://example.com"

    service_options = {
      color: params[:foreground_color] || "#000000",
      fill: params[:background_color] || "#FFFFFF",
      module_size: (params[:module_size] || 6).to_i,
      png_size: (params[:size] || 300).to_i,
      dot_style: params[:dot_style] || "rounded",
      corner_style: params[:corner_style] || "rounded"
    }

    begin
      service = QrCodePreviewService.new(data: data, **service_options)
      svg_content = service.generate_svg

      respond_to do |format|
        format.json { render json: {svg: svg_content, success: true} }
        format.all { render plain: svg_content, content_type: "image/svg+xml" }
      end
    rescue => e
      Rails.logger.error "QR Code preview generation failed: #{e.message}"

      respond_to do |format|
        format.json { render json: {error: e.message, success: false}, status: :unprocessable_entity }
        format.all { render json: {error: e.message}, status: :unprocessable_entity }
      end
    end
  end

  private

  # Sets the QR code for member actions
  #
  # @return [void]
  def set_qr_code
    @qr_code = current_account.qr_codes.find(params[:id])
  end

  # Strong parameters for QR code creation/updates
  #
  # @return [ActionController::Parameters] Permitted parameters
  def qr_code_params
    params.expect(qr_code: [
      :name,
      design_settings: [
        :foreground_color, :background_color,
        :dot_style, :corner_style,
        :logo_url, :transparent_background,
        :error_correction_level, :margin
      ]
    ])
  end

  # Creates a new shortened link from form parameters
  #
  # @return [ShortenedLink, nil] Created shortened link or nil if failed
  def create_shortened_link_from_params
    link_params = shortened_link_params
    return nil if link_params.blank?

    # Auto-populate title from QR code name if not provided
    link_params[:title] = params[:qr_code][:name] if link_params[:title].blank?

    shortened_link = current_account.shortened_links.build(link_params)
    shortened_link.created_by = current_user

    # Custom slug is now handled through strong parameters and will be processed by the Shortable concern

    if shortened_link.save
      shortened_link
    else
      @shortened_link_errors = shortened_link.errors
      nil
    end
  end

  # Updates an existing shortened link from form parameters
  #
  # @param [ShortenedLink] shortened_link The link to update
  # @return [Boolean] True if successful
  def update_shortened_link_from_params(shortened_link)
    link_params = shortened_link_params
    return false if link_params.blank?

    # Auto-populate title from QR code name if not provided
    link_params[:title] = params[:qr_code][:name] if link_params[:title].blank?

    # Note: We don't update the custom_slug/short_code on updates to keep the permanent link
    if shortened_link.update(link_params)
      true
    else
      @shortened_link_errors = shortened_link.errors
      false
    end
  end

  # Renders errors for shortened link creation/update
  #
  # @return [void]
  def render_errors_for_shortened_link
    @shortened_links = current_account.shortened_links.active
    @design_settings = @qr_code&.design_settings_with_defaults
    
    # Ensure @qr_code is initialized for the form
    @qr_code ||= current_account.qr_codes.build(qr_code_params)

    respond_to do |format|
      format.html { render (@qr_code&.persisted? ? :edit : :new), status: :unprocessable_content }
      format.json { render json: @shortened_link_errors, status: :unprocessable_content }
    end
  end

  # Strong parameters for shortened link creation/updates
  #
  # @return [ActionController::Parameters] Permitted parameters
  def shortened_link_params
    return {} unless params[:shortened_link].present?

    schema_type = params[:shortened_link][:schema_type]
    base_params = params.expect(shortened_link: [:title, :schema_type, :target_value, :custom_slug])

    # Add metadata parameters based on schema type
    case schema_type
    when "sms", "whatsapp"
      if params[:shortened_link][:metadata].present?
        base_params[:message] = params[:shortened_link][:metadata][:message]
      end
    when "email"
      if params[:shortened_link][:metadata].present?
        base_params[:subject] = params[:shortened_link][:metadata][:subject]
        base_params[:message] = params[:shortened_link][:metadata][:message]
      end
    end

    base_params
  end

  # Finds attachment by format and size
  #
  # @param [String] format Image format
  # @param [Integer] size Image size
  # @return [ActiveStorage::Attachment, nil] Found attachment
  def find_attachment_by_format_and_size(format, size)
    filename_pattern = "#{@qr_code.name.parameterize}_#{size}.#{format}"
    @qr_code.images.find { |img| img.filename.to_s == filename_pattern }
  end
end
