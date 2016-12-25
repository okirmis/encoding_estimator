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

    # Get the internal name (unique key) for this conversion. Useful when storing/referencing conversions
    # in hashes.
    #
    # @return [String] Unique key of this conversion
    def key
      @key ||= "#{direction}_#{encoding}"
    end

    # Generate all conversions of for given encodings and directions. Note: this will produce
    # #encodings * #directions conversions if default is not included and #encoding * #directions + 1
    # if the default is included.
    #
    # @param [Array<String>] encodings   Names of the encodings to generate conversions for
    # @param [Array<Symbol>] directions  Directions describing which conversions (encode/decode/keep) to include
    # @param [Boolean] include_no_change Include the default conversion (keep UTF-8) in the list
    # @return [Array<Conversion>]        List of conversions generated from the encodings and directions
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

    private

    # Encode a given string from the default (UTF-8) to a given encoding.
    #
    # @param [String] str      String to encode
    # @param [String] encoding Name of the encoding used to encode the string
    # @return [String] The encoded string
    def encode( str, encoding )
      str.clone.force_encoding( DEFAULT_TARGET_ENCODING.to_s ).encode(
          encoding, invalid: :replace, undef: :replace, replace: ''
      )
    end

    # Decode a given string from a given encoding to the default (UTF-8).
    #
    # @param [String] str      String to decode
    # @param [String] encoding Name of the encoding used to decode the string
    # @return [String] The decoded string
    def decode( str, encoding )
      str.clone.force_encoding( encoding ).encode(
          DEFAULT_TARGET_ENCODING.to_s, invalid: :replace, undef: :replace, replace: ''
      )
    end
  end
end