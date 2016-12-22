module EncodingEstimator

  # Class that represents the conversion of a string to or from an other encoding
  class Conversion
    DEFAULT_TARGET_ENCODING = :'utf-8'

    # Ways of conversion: convert from an encoding to the target, to an encoding or don't change anything
    module Directions
      ENCODE = :enc
      DECODE = :dec
      KEEP   = :keep
    end

    attr_reader :direction
    attr_reader :encoding

    # Initialize a new conversion object from an encoding and tell it whether to convert from it or to it
    #
    # @param [String] encoding  Encoding to convert to/from
    # @param [Symbol] direction Whether to convert from that encoding or to it
    def initialize( encoding = DEFAULT_TARGET_ENCODING, direction = Directions::KEEP )
      @encoding  = encoding
      @direction = direction
    end

    # Perform the conversion with the current settings on a given string
    #
    # @param [String] data String to encode/decode
    # @return [String] The encoded/decoded string
    def perform( data )
      return encode( data, encoding ) if direction == Directions::ENCODE
      return decode( data, encoding ) if direction == Directions::DECODE
      data
    end

    def key
      @key ||= "#{direction}_#{encoding}"
    end

    private
    def encode( str, encoding )
      str.clone.force_encoding( DEFAULT_TARGET_ENCODING.to_s ).encode(
          encoding, invalid: :replace, undef: :replace, replace: ''
      )
    end

    def decode( str, encoding )
      str.clone.force_encoding( encoding ).encode(
          DEFAULT_TARGET_ENCODING.to_s, invalid: :replace, undef: :replace, replace: ''
      )
    end

    # Generate all
    def self.generate(
        encodings  = %w(utf-8 iso-8859-1 Windows-1251),
        directions = [ Directions::ENCODE, Directions::DECODE ],
        include_no_change = true
    )

      conversions = include_no_change ? [ Conversion.new ] : []

      encodings.each do |encoding|
        conversions = conversions + directions.map { |direction| Conversion.new( encoding, direction )  }
      end

      conversions
    end
  end
end