require_relative 'distribution'
require_relative 'conversion'
require_relative 'detection'

require_relative 'parallel_support'

module EncodingEstimator

  # Represent a function the maps a value between min and max to 0..1
  class RangeScale

    # Initialize a new object from the range minimum and maximum
    #
    # @param [Float] min The range's minimum
    # @param [Float] max The range's maximum
    def initialize( min, max )
      @min = min
      @max = max

      if max == min
        @min = min - 1.0
      end
    end

    # Map the given value to a range between 0 and 1 (min is 0, max is 1)
    #
    # @param [Float] value Value to map between 0 and 1
    #
    # @return [Float] The mapped value between 0 and 1
    def scale( value )
      ( value - @min ) / ( @max - @min )
    end
  end

  # Conversion Distribution Combination Representation
  class CDCombination
    attr_reader :conversion, :distribution

    # Initialize a new object from a conversion and a distribution
    #
    # @param [EncodingEstimator::Conversion]   conversion   Conversion to represent
    # @param [EncodingEstimator::Distribution] distribution Distribution to represent
    def initialize( conversion, distribution )
      @conversion   = conversion
      @distribution = distribution
    end
  end


  # Class to store a detection score of a single combination of a distribution and a conversion
  class SingleDetectionResult
    attr_reader :key, :score

    # Initialize a new object from a conversion identifier key and a score
    #
    # @param [String] key   Conversion identifier key
    # @param [Float]  score Scoring value for a combination of distribution and a conversion
    def initialize( key, score )
      @key   = key
      @score = score
    end
  end

  # Class to perform an encoding detection on strings
  class Detector
    attr_reader :conversions
    attr_reader :languages
    attr_reader :num_processes

    # Create a new instance with a given configuration consisting of a list of conversions, languages and the number
    # of processes.
    #
    # @param [Array<EncodingEstimator::Conversion>] conversions   Conversions to perform/test on the inputs.
    # @param [Array<Symbol>]                        languages     Languages to consider when evaluating the input. Array
    #                                                             of two-letter-codes
    # @param [Integer]                              num_processes Number of processes the detection will run on  -> true
    #                                                             multi-threading through the parallel gem
    def initialize( conversions, languages, num_processes = nil )
      @conversions   = conversions
      @languages     = languages
      @num_processes = num_processes

      @distributions = languages.map { |lang| Distribution.new( lang ) }
    end

    # Detect the encoding using the current configuration given an input string
    #
    # @param [String] str Input string the detection will be performed on
    #
    # @return [EncodingEstimator::Detection] Result of the detection process
    def detect( str )
      sums    = {}
      results = (num_processes.nil? or !EncodingEstimator::ParallelSupport.supported?) ?
                    detect_st( str, combinations ) : detect_mt( str, combinations )

      results.each do |result|
        sums[result.key] = sums.fetch(result.key, 0.0) + result.score
      end

      range = EncodingEstimator::RangeScale.new( sums.values.min, sums.values.max )
      EncodingEstimator::Detection.new( sums.map { |k,s| [ k, range.scale( s ) ] }.to_h, @conversions )
    end

    private

    # Compute the scores of all combinations of languages and conversions on a single thread.
    #
    # @param [String]      str    Input string to compute the encoding on
    # @param [Array<Hash>] matrix List of Conversion-Distribution-Combinations
    #
    # @return [Array<Hash>] Hash with the keys "key" and "score": key is the key of the conversion, score the result of
    #                       the evaluation for the input string
    def detect_st( str, matrix )
      matrix.map do |combination|
        EncodingEstimator::Detector.detect_single str, combination
      end
    end

    # Compute the scores of all combinations of languages and conversions on multiple processes. See num_processes.
    #
    # @param [String]      str    Input string to compute the encoding on
    # @param [Array<Hash>] matrix List of Conversion-Distribution-Combinations
    #
    # @return [Array<Hash>] Hash with the keys "key" and "score": key is the key of the conversion, score the result of
    #                       the evaluation for the input string
    def detect_mt( str, matrix )
      Parallel.map( matrix, in_processes: num_processes ) do |combination|
        EncodingEstimator::Detector.detect_single str, combination
      end
    end

    # Calculate the list of all combinations of languages and conversions
    #
    # @return [Array<EncodingEstimator::CDCombination>] Conversion-Distribution-Combinations of the current config
    def combinations
      @distributions.map {
          |dist| @conversions.map { |c| EncodingEstimator::CDCombination.new( c, dist ) }
      }.flatten
    end

    # Perform the evaluation of a Conversion-Distribution-Combination on an input string
    #
    # @param [String]                           str         Input to evaluate
    # @param [EncodingEstimator::CDCombination] combination Distribution/Conversion to evaluate on the input
    #
    # @return [EncodingEstimator::SingleDetectionResult] Result of the evaluation of the given combination on the input
    def self.detect_single( str, combination )
      EncodingEstimator::SingleDetectionResult.new(
          combination.conversion.key,
          combination.distribution.evaluate( combination.conversion.perform(str) )
      )
    end

  end
end