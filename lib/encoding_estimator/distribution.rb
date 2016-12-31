require 'json'

module EncodingEstimator
  class Distribution
    @@distributions = {}

    # Create a new distribution object for a given language
    #
    # @param [EncodingEstimator::LanguageModel] language Language to load the distribution for
    def initialize( language )

      @@distributions[ language.path ] ||= load_language language
      @distribution                      = @@distributions[ language.path ]
    end

    # Calculate the likelihood of a string for the given language
    #
    # @param [String] str     Data to calculate the likelihood for
    # @param [Float]  penalty Threshold which defines when chars are weighted negative (-> calc score - thresh)
    # @return [Float] Total likelihood
    def evaluate( str, penalty )
      dist = @distribution
      sum = 0.0
      str.each_char { |c| sum += dist.fetch( c, 0.0 ) - penalty }
      sum
    end


    private

    # Try to load the language from filesystem
    #
    # @param [EncodingEstimator::LanguageModel] language 2-letter-symbol indicating the language to load
    # @return [Hash] Hash representing the distribution for a language
    def load_language( language )
      return {} unless language.valid?

      begin
        distribution = JSON.parse(
            File.read( language.path, encoding: 'utf-8' )
        )
      rescue Exception
        distribution = {}
      end

      distribution
    end
  end
end
