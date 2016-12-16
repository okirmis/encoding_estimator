module EncodingEstimator
  class Conversion
    DEFAULT_TARGET_ENCODING = :'utf-8'

    module Directions
      ENCODE = :enc
      DECODE = :dec
      KEEP   = :nochange
    end

    attr_reader :direction
    attr_reader :encoding

    def initialize( encoding = DEFAULT_TARGET_ENCODING, direction = Directions::KEEP )
      @encoding  = encoding
      @direction = direction
    end

    def perform( data )
      return encode( data, encoding ) if direction == Directions::ENCODE
      return decode( data, encoding ) if direction == Directions::DECODE
      data
    end

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
  end
end