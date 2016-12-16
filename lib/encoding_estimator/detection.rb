module EncodingEstimator
  class Detection

    def initialize( scores, conversions )
      @scores      = scores
      @conversions = conversions
    end

    # @return [EncodingEstimator::Conversion]
    def result
      @result ||= calculate_result
    end

    def score
      @scores[ result.key ]
    end

    def results
      @results ||= @conversions.map { |c| { conversion: c, score: @scores[ c.key ].round( 2 ) } }
    end

    private
    def calculate_result
      max_conv = @conversions.first
      @conversions.each { |conv| max_conv = conv if @scores[conv.key] > @scores[max_conv.key] }

      max_conv
    end
  end
end
