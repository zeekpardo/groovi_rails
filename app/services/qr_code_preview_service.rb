# frozen_string_literal: true

class QrCodePreviewService
  attr_reader :data, :options

  def initialize(data:, **options)
    @data = data
    @options = default_options.merge(options)
  end

  def generate_svg
    qr = RQRCode::QRCode.new(data, qr_options)
    qr.as_svg(svg_options)
  end

  def generate_png
    qr = RQRCode::QRCode.new(data, qr_options)
    qr.as_png(png_options)
  end

  private

  def default_options
    {
      # QR Code generation options
      level: :m,          # 15% error correction
      size: nil,          # Auto-size based on data

      # SVG rendering options
      color: "#000000",
      fill: "#FFFFFF",
      module_size: 6,
      shape_rendering: "crispEdges",
      standalone: true,
      use_path: true,
      viewbox: true,
      offset: 0,          # No extra padding

      # PNG rendering options
      png_size: 300,
      border_modules: 4,

      # Design style options (for future enhancement)
      dot_style: "rounded",
      corner_style: "rounded"
    }
  end

  def qr_options
    {
      level: options[:level],
      size: options[:size]
    }.compact
  end

  def svg_options
    {
      color: normalize_color(options[:color]),
      fill: normalize_color(options[:fill]),
      module_size: options[:module_size],
      shape_rendering: options[:shape_rendering],
      standalone: options[:standalone],
      use_path: options[:use_path],
      viewbox: options[:viewbox],
      offset: options[:offset]
    }
  end

  def normalize_color(color)
    # Remove # from color codes as rqrcode adds it automatically
    return color unless color.is_a?(String) && color.start_with?("#")
    color.sub("#", "")
  end

  def png_options
    {
      size: options[:png_size],
      border_modules: options[:border_modules],
      fill: (options[:fill] == "#FFFFFF") ? "white" : options[:fill],
      color: (options[:color] == "#000000") ? "black" : options[:color]
    }
  end
end
