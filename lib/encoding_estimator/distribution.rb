require 'json'

module EncodingEstimator
  class Distribution
    @@distributions = {}

    # Create a new distribution object for a given language
    #
    # @param [Symbol|String] language Language to load the distribution for
    def initialize( language )
      language = sanitize_language language

      @@distributions[ language ] ||= load_language language
      @distribution                 = @@distributions[ language ]
    end

    # Calculate the likelihood of a string for the given language
    #
    # @param [String] str Data to calculate the likelihood for
    # @return [Float]     Total likelihood
    def evaluate( str )
      dist = @distribution
      sum = 0.0
      str.each_char { |c| sum += dist.fetch( c, 0 ) }
      sum
    end


    private

    # Try to load the language from filesystem
    #
    # @param [Symbol] language 2-letter-symbol indicating the language to load
    # @return [Hash]           Hash representing the distribution for a language
    def load_language( language )
      begin
        distribution = JSON.parse(
            File.read( filepath( language ) )
        )
      rescue Exception
        distribution = {}
      end

      distribution
    end

    # Create the file path to the language statistics file
    #
    # @param [Symbol] language Sanitized language symbol (2-letter-symbol)
    # @return [String]         File path
    def filepath( language )
      File.expand_path( File.dirname( __FILE__ ) + "/lang/#{language.to_s}.json" )
    end

    # Ensure that the language is a two letter symbol
    #
    # @param [Symbol|String] language Symbol or string representing a language
    # @return [Symbol]                2-letter-symbol
    def sanitize_language( language )
      language.to_s[0..1].to_sym
    end
  end
end
