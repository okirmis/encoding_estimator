module EncodingEstimator

  # Class to represent the results of a detection process.
  class Detection

    # Initialize a new object from the evaluation scores and the conversions tested
    #
    # @param [Hash]                                 scores      Hash of scores mapping the conversion identifier key to
    #                                                           the score for that conversion
    # @param [Array<EncodingEstimator::Conversion>] conversions objects the scores table references
    def initialize( scores, conversions )
      @scores      = scores
      @conversions = conversions
    end

    # Get the most probable conversion
    #
    # @return [EncodingEstimator::Conversion] Most probable conversion
    def result
      @result ||= calculate_result
    end

    # Get the score of the most probable conversion (-> the highest score)
    #
    # @return [Float] Score of the most probable conversion
    def score
      @scores[ result.key ]
    end

    # Get all conversions and their scores
    #
    # @return [Array<Hash>] Array containing a hash for every conversion of the form
    #                       { conversion: EncodingEstimator::Conversion, score: Float }
    def results
      @results ||= @conversions.map { |c| { conversion: c, score: @scores[ c.key ].round( 2 ) } }
    end

    private
    # Find the most probable conversion
    #
    # @return [EncodingEstimator::Conversion] The most probable conversion
    def calculate_result
      max_conv = @conversions.first
      @conversions.each { |conv| max_conv = conv if @scores[conv.key] > @scores[max_conv.key] }

      max_conv
    end
  end
end
