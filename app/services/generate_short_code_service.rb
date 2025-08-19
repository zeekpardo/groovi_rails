# frozen_string_literal: true

# Service for generating unique short codes for links
#
# @example Generate with custom slug
#   service = GenerateShortCodeService.new(custom_slug: "summer-sale")
#   short_code = service.run
#
# @example Generate random code
#   service = GenerateShortCodeService.new
#   short_code = service.run
#
class GenerateShortCodeService
  MAX_RETRIES = 5
  CODE_LENGTH = 6
  EXCLUDED_WORDS = %w[admin api www app help support about contact privacy terms].freeze

  # Initialize the service
  #
  # @param [String, nil] custom_slug Optional custom slug
  def initialize(custom_slug: nil)
    @custom_slug = custom_slug&.downcase&.strip
  end

  # Generates a unique short code
  #
  # @return [String] The generated short code
  # @raise [ActiveRecord::RecordNotUnique] If unable to generate unique code
  def run
    if @custom_slug.present?
      validate_custom_slug!
      return @custom_slug if available?(@custom_slug)
      raise ActiveRecord::RecordNotUnique, "Custom slug '#{@custom_slug}' is already taken"
    end

    generate_random_code
  end

  private

  # Checks if a code is available
  #
  # @param [String] code The code to check
  # @return [Boolean] True if available
  def available?(code)
    return false if EXCLUDED_WORDS.include?(code.downcase)

    !ShortenedLink.exists?(short_code: code) &&
      !ShortenedLink.exists?(custom_slug: code)
  end

  # Generates a random unique code
  #
  # @return [String] The generated code
  def generate_random_code
    retries = 0

    loop do
      code = SecureRandom.alphanumeric(CODE_LENGTH).downcase
      # Ensure it starts with a letter (not a number)
      code = "a#{code[1..]}" if code[0].match?(/\d/)

      return code if available?(code)

      retries += 1
      raise ActiveRecord::RecordNotUnique, "Unable to generate unique code after #{MAX_RETRIES} attempts" if retries >= MAX_RETRIES
    end
  end

  # Validates the custom slug format
  #
  # @return [void]
  # @raise [ArgumentError] If slug format is invalid
  def validate_custom_slug!
    return if @custom_slug.blank?

    unless @custom_slug.match?(/\A[a-z0-9\-_]+\z/)
      raise ArgumentError, "Custom slug can only contain lowercase letters, numbers, hyphens, and underscores"
    end

    if @custom_slug.length < 2
      raise ArgumentError, "Custom slug must be at least 2 characters long"
    end

    if @custom_slug.length > 50
      raise ArgumentError, "Custom slug cannot be longer than 50 characters"
    end

    if EXCLUDED_WORDS.include?(@custom_slug)
      raise ArgumentError, "Custom slug '#{@custom_slug}' is not allowed"
    end
  end
end
