class QrCodeComponent < JumpstartComponent
  renders_one :loading_state
  renders_one :error_state

  def initialize(
    data:,
    size: 300,
    foreground_color: "#000000",
    background_color: "#FFFFFF",
    module_size: 6,
    dot_style: "rounded",
    corner_style: "rounded",
    show_fallback: true,
    container_class: nil,
    **options
  )
    @data = data
    @size = size
    @foreground_color = foreground_color
    @background_color = background_color
    @module_size = module_size
    @dot_style = dot_style
    @corner_style = corner_style
    @show_fallback = show_fallback
    @container_class = container_class
    @options = options
  end

  attr_reader :data

  attr_reader :size

  attr_reader :foreground_color

  attr_reader :background_color

  attr_reader :module_size

  attr_reader :dot_style

  attr_reader :corner_style

  def show_fallback?
    @show_fallback
  end

  def container_class
    return @container_class if @container_class.present?
    "qr-code-component"
  end

  def controller_options
    {
      data: data,
      foreground_color: foreground_color,
      background_color: background_color,
      size: size,
      module_size: module_size,
      show_fallback: show_fallback?
    }
  end

  def data_attributes
    {
      controller: "qr-code-component",
      qr_code_component_data_value: data,
      qr_code_component_foreground_color_value: foreground_color,
      qr_code_component_background_color_value: background_color,
      qr_code_component_size_value: size,
      qr_code_component_module_size_value: module_size,
      qr_code_component_dot_style_value: dot_style,
      qr_code_component_corner_style_value: corner_style,
      qr_code_component_show_fallback_value: show_fallback?
    }
  end
end
