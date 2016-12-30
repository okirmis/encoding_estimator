require_relative 'encoding_estimator/version'

require_relative 'encoding_estimator/builder/parallel_model_builder'
require_relative 'encoding_estimator/detector'
require_relative 'encoding_estimator/language_model'

module EncodingEstimator

  # Convert a string to a UTF-8 string by performing the conversion that
  # is automatically detected by EncodingEstimator
  #
  # @param [String]               data            String to convert to UTF-8
  # @param [Array<Symbol|String>] languages       List of languages the data might originate from, two-letter-codes, e.g. [:de, :en]
  # @param [Array<String>]        encodings       List of encodings to test, e.g. [ 'UTF-8', 'ISO-8859-1' ].
  #                                               The order defines the priority when choosing from encodings with same detection score
  # @param [Array<Symbol>]        operations      Choose which operations (encoding to/decoding from an encoding to UTF-8) to test
  # @param [Float]                penalty         Penalty threshold to define when chars are weighted negative
  # @param [Integer]              num_cores       Number of threads to use for detection. Use "nil" to use single threaded implementation
  # @param [Boolean]              include_default Include "keep as is" conversion when testing, e.g. check if the string is
  #                                               already UTF-8 encoded
  #
  # @return [String] UTF-8 string
  def EncodingEstimator.ensure_utf8( data, config = {} )

    params = {
      languages:        [ :de, :en ],
      encodings:        %w(iso-8859-1 utf-16le windows-1251),
      operations:       [Conversion::Operation::DECODE],
      include_default:  true,
      penalty:          0.01,
      num_cores:        nil
    }.merge config

    EncodingEstimator.detect( data, params ).result.perform( data )
  end

  # Let the EncodingEstimator detect how the input string is encoded
  #
  # @param [String]        data            String to convert to UTF-8
  # @param [Array<Symbol>] languages       List of languages the data might originate from, two-letter-codes, e.g. [:de, :en]
  # @param [Array<String>] encodings       List of encodings to test, e.g. [ 'UTF-8', 'ISO-8859-1' ].
  #                                        The order defines the priority when choosing from encodings with same detection score
  # @param [Array<Symbol>] operations      Choose which operations (encoding to/decoding from an encoding to UTF-8) to test
  # @param [Float]         penalty         Penalty threshold to define when chars are weighted negative
  # @param [Integer]       num_cores       Number of threads to use for detection. Use "nil" to use single threaded implementation
  # @param [Boolean]       include_default Include "keep as is" conversion when testing, e.g. check if the string is
  #                                        already UTF-8 encoded
  #
  # @return [EncodingEstimator::Detection] Detection result with scores for all conversions
  def EncodingEstimator.detect( data, config )
    params = {
        languages:       [ :de, :en ],
        encodings:       %w(iso-8859-1 utf-16le windows-1251),
        operations:      [Conversion::Operation::DECODE],
        include_default: true,
        penalty:         0.01,
        num_cores:       nil
    }.merge config

    Detector.new(
        Conversion.generate( params[ :encodings ], params[ :operations ], params[ :include_default ] ),
        params[ :languages ].map { |l| EncodingEstimator::LanguageModel.new( l ) }, params[ :penalty ], params[:num_cores]
    ).detect data
  end
end
