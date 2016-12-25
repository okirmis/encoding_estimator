module EncodingEstimator

  # Class that represents the conversion of a string to or from an other encoding
  class Conversion
    DEFAULT_TARGET_ENCODING = :'utf-8'

    # Ways of conversion: convert from an encoding to the target, to an encoding or don't change anything
    module Operation
      ENCODE = :enc
      DECODE = :dec
      KEEP   = :keep
    end

    attr_reader :operation
    attr_reader :encoding

    # Initialize a new conversion object from an encoding and tell it whether to convert from it or to it
    #
    # @param [String] encoding  Encoding to convert to/from
    # @param [Symbol] operation Whether to convert from that encoding or to it
    def initialize( encoding = DEFAULT_TARGET_ENCODING, operation = Operation::KEEP )
      @encoding  = encoding
      @operation = operation
    end

    # Check if two conversions are representing the same operation.
    #
    # @param [EncodingEstimator::Conversion] other Conversion to compare this instance to
    # @return [Boolean] True if equal, false if not
    def equals?( other )

      # Not the same encoding? Cannot be equal
      return false if other.encoding.to_s != self.encoding.to_s

      # If the default and the target encoding is the same, the operation doesn't matter
      # as the conversion does nothing at all
      return true if self.encoding.to_s == DEFAULT_TARGET_ENCODING.to_s

      # Not the default encoding, so check if the operation is the same
      self.operation == other.operation
    end

    # Perform the conversion with the current settings on a given string
    #
    # @param [String] data String to encode/decode
    # @return [String] The encoded/decoded string
    def perform( data )
      return encode( data, encoding ) if operation == Operation::ENCODE
      return decode( data, encoding ) if operation == Operation::DECODE
      data
    end

    # Get the internal name (unique key) for this conversion. Useful when storing/referencing conversions
    # in hashes.
    #
    # @return [String] Unique key of this conversion
    def key
      @key ||= "#{operation}_#{encoding}"
    end

    # Generate all conversions of for given encodings and operations. Note: this will produce
    # #encodings * #operations conversions if default is not included and #encoding * #operations + 1
    # if the default is included.
    #
    # @param [Array<String>] encodings   Names of the encodings to generate conversions for
    # @param [Array<Symbol>] operations  Operations describing which conversions (encode/decode/keep) to include
    # @param [Boolean] include_no_change Include the default conversion (keep UTF-8) in the list
    # @return [Array<Conversion>]        List of conversions generated from the encodings and operations
    def self.generate(
        encodings  = %w(utf-8 iso-8859-1 Windows-1251),
        operations = [Operation::ENCODE, Operation::DECODE ],
        include_no_change = true
    )

      conversions = include_no_change ? [ Conversion.new ] : []

      encodings.each do |encoding|
        conversions = conversions + operations.map { |operation| Conversion.new( encoding, operation )  }
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
      ).force_encoding( DEFAULT_TARGET_ENCODING.to_s )
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