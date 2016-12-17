require_relative 'encoding_estimator/version'

require_relative 'encoding_estimator/builder/parallel_model_builder'
require_relative 'encoding_estimator/detector'

module EncodingEstimator

  # Convert a string to a UTF-8 string by performing the conversion that
  # is automatically detected by EncodingEstimator
  #
  # @param [String]        data            String to convert to UTF-8
  # @param [Array<Symbol>] languages       List of languages the data might originate from, two-letter-codes, e.g. [:de, :en]
  # @param [Array<String>] encodings       List of encodings to test, e.g. [ 'UTF-8', 'ISO-8859-1' ].
  #                                        The order defines the priority when choosing from encodings with same detection score
  # @param [Array<Symbol>] directions      Choose which directions (encoding to/decoding from an encoding to UTF-8) to test
  # @param [Boolean]       include_default Include "keep as is" conversion when testing, e.g. check if the string is
  #                                        already UTF-8 encoded
  #
  # @return [String] UTF-8 string
  def EncodingEstimator.ensure_utf8( data, config = {} )

    params = {
      languages:       [ :de, :en ],
      encodings:       %w(utf-8 iso-8859-1 windows-1251),
      directions:      [ Conversion::Directions::DECODE, Conversion::Directions::ENCODE ],
      include_default: true
    }.merge config

    EncodingEstimator.detect( data, params ).result.perform( data )
  end

  # Let the EncodingEstimator detect how the input string is encoded
  #
  # @param [String]        data            String to convert to UTF-8
  # @param [Array<Symbol>] languages       List of languages the data might originate from, two-letter-codes, e.g. [:de, :en]
  # @param [Array<String>] encodings       List of encodings to test, e.g. [ 'UTF-8', 'ISO-8859-1' ].
  #                                        The order defines the priority when choosing from encodings with same detection score
  # @param [Array<Symbol>] directions      Choose which directions (encoding to/decoding from an encoding to UTF-8) to test
  # @param [Boolean]       include_default Include "keep as is" conversion when testing, e.g. check if the string is
  #                                        already UTF-8 encoded
  #
  # @return [EncodingEstimator::Detection] Detection result with scores for all conversions
  def EncodingEstimator.detect( data, config )

    params = {
        languages:       [ :de, :en ],
        encodings:       %w(utf-8 iso-8859-1 windows-1251),
        directions:      [ Conversion::Directions::DECODE, Conversion::Directions::ENCODE ],
        include_default: true
    }.merge config

    Detector.new(
        Conversion.generate( params[ :encodings ], params[ :directions ], params[ :include_default ] ), params[ :languages ], 8
    ).detect data
  end
end