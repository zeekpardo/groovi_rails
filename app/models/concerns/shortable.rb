# frozen_string_literal: true

# Provides short code generation functionality for models
#
# @example Usage
#   class ShortenedLink < ApplicationRecord
#     include Shortable
#   end
#
module Shortable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_short_code, on: :create

    validates :short_code, presence: true, uniqueness: true

    # Generates the full shortened URL
    #
    # @return [String] The complete shortened URL
    def full_url
      "#{Rails.application.routes.default_url_options[:host] || "http://localhost:3000"}/#{short_code}"
    end

    # Checks if this resource uses a custom slug
    #
    # @return [Boolean] True if using custom slug
    def custom_slug?
      custom_slug.present?
    end
  end

  private

  # Generates a unique short code if not already present
  #
  # @return [void]
  def generate_short_code
    return if short_code.present?

    service = GenerateShortCodeService.new(custom_slug: custom_slug)
    self.short_code = service.run
  end
end
