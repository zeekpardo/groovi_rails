module ApplicationHelper
  include Jumpstart::ApplicationHelper

  # Returns the appropriate pill color class for a schema type
  #
  # @param [String] schema_type The schema type
  # @return [String] CSS class for the pill color
  def schema_type_color(schema_type)
    case schema_type.to_s
    when "url"
      "pill-primary"
    when "phone"
      "pill-success"
    when "sms"
      "pill-accent"
    when "email"
      "pill-secondary"
    when "whatsapp"
      "pill-tertiary"
    when "playlist"
      "pill-accent"
    else
      "pill-secondary"
    end
  end
end
