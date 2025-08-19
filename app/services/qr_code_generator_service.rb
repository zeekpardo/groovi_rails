# frozen_string_literal: true

# Service for generating QR code images with custom styling
#
# @example Generate QR code for a shortened link
#   service = QrCodeGeneratorService.new(
#     qr_code: qr_code,
#     format: 'png',
#     size: 300
#   )
#   image_data = service.generate
#
class QrCodeGeneratorService
  require "mini_magick"

  # Initialize the service
  #
  # @param [QrCode] qr_code The QR code record
  # @param [String] format Image format (png, svg)
  # @param [Integer] size Image size in pixels
  def initialize(qr_code:, format: "png", size: 300)
    @qr_code = qr_code
    @format = format.to_s.downcase
    @size = size.to_i
  end

  # Generates QR code image
  #
  # @return [String] Base64 encoded image data or SVG string
  def generate
    case @format
    when "png"
      generate_png
    when "svg"
      generate_svg
    else
      raise ArgumentError, "Unsupported format: #{@format}"
    end
  end

  # Generates and attaches QR code images to the record
  #
  # @return [void]
  def generate_and_attach!
    # Generate PNG versions
    %w[png svg].each do |format|
      [150, 300, 600].each do |size|
        service = self.class.new(qr_code: @qr_code, format: format, size: size)
        image_data = service.generate

        filename = "#{@qr_code.name.parameterize}_#{size}.#{format}"

        if format == "svg"
          @qr_code.images.attach(
            io: StringIO.new(image_data),
            filename: filename,
            content_type: "image/svg+xml"
          )
        else
          @qr_code.images.attach(
            io: StringIO.new(Base64.decode64(image_data.split(",").last)),
            filename: filename,
            content_type: "image/png"
          )
        end
      end
    end
  end

  private

  # Generates PNG format QR code using RQRCode
  #
  # @return [String] Base64 encoded PNG data
  def generate_png
    require "rqrcode"

    qr = RQRCode::QRCode.new(@qr_code.target_url, level: error_correction_level)

    # Generate PNG using ChunkyPNG
    png = qr.as_png(
      resize_gte_to: false,
      resize_exactly_to: @size,
      fill: "white",
      color: @qr_code.foreground_color || "#000000",
      size: @size,
      border_modules: margin,
      module_px_size: calculate_module_size
    )

    # Convert to base64
    "data:image/png;base64,#{Base64.strict_encode64(png.to_s)}"
  end

  # Generates SVG format QR code
  #
  # @return [String] SVG string
  def generate_svg
    require "rqrcode"

    qr = RQRCode::QRCode.new(@qr_code.target_url, level: error_correction_level)

    # Generate SVG with custom styling
    svg = qr.as_svg(
      offset: margin,
      color: @qr_code.foreground_color || "#000000",
      shape_rendering: "crispEdges",
      module_size: calculate_module_size,
      standalone: true,
      svg_attributes: {
        width: @size,
        height: @size,
        style: background_style
      }
    )

    # Apply custom styling if needed
    apply_svg_styling(svg)
  end

  # Calculates module size based on total size
  #
  # @return [Integer] Module size in pixels
  def calculate_module_size
    base_modules = 21 # Base QR code is 21x21 modules
    available_size = @size - (margin * 2)
    (available_size / base_modules).floor
  end

  # Gets margin from design settings
  #
  # @return [Integer] Margin in pixels
  def margin
    (@qr_code.design_settings_with_defaults["margin"] || 4).to_i
  end

  # Gets error correction level
  #
  # @return [Symbol] Error correction level
  def error_correction_level
    level = @qr_code.design_settings_with_defaults["error_correction_level"] || "M"
    case level.upcase
    when "L" then :low
    when "M" then :medium
    when "Q" then :quartile
    when "H" then :high
    else :medium
    end
  end

  # Gets background style for SVG
  #
  # @return [String] CSS background style
  def background_style
    bg_color = @qr_code.design_settings_with_defaults["background_color"]
    transparent = @qr_code.design_settings_with_defaults["transparent_background"]

    if transparent == true || transparent == "true"
      "background: transparent;"
    else
      "background: #{bg_color || "#FFFFFF"};"
    end
  end

  # Applies custom styling to SVG
  #
  # @param [String] svg SVG content
  # @return [String] Modified SVG content
  def apply_svg_styling(svg)
    # Apply dot style modifications
    dot_style = @qr_code.design_settings_with_defaults["dot_style"]
    @qr_code.design_settings_with_defaults["corner_style"]

    case dot_style
    when "rounded"
      svg = svg.gsub("<rect", '<rect rx="1" ry="1"')
    when "dots"
      # Convert rectangles to circles
      module_size = calculate_module_size
      radius = module_size / 2
      svg = svg.gsub(/<rect[^>]*width="(\d+)"[^>]*height="(\d+)"[^>]*x="(\d+)"[^>]*y="(\d+)"[^>]*\/>/) do |match|
        x, y = $3.to_i, $4.to_i
        cx, cy = x + radius, y + radius
        "<circle cx=\"#{cx}\" cy=\"#{cy}\" r=\"#{radius}\" fill=\"currentColor\"/>"
      end
    end

    svg
  end
end
