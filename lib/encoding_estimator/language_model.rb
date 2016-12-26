require_relative 'distribution'

module EncodingEstimator

  # Class representing a language model. This can either be an internal
  # model (provided by the gem) or an external one (user defined model).
  class LanguageModel

    # Initialize a new object from a language file or an internal
    # language profile
    #
    # @param [String|Symbol] language If symbol given, interpreted as internal language identifier,
    #                                 otherwise interpreted as a path to a language model file
    def initialize( language )
      @language = language
    end

    # Check if the instance is a valid language model representation
    #
    # @return [Boolean] true, if the referenced model file exists
    def valid?
      if internal?
        @language.to_s.size == 2 and File.file? internal_path
      else
        File.file? external_path
      end
    end

    # Check if this instance represents an internal model file
    #
    # @return [Boolean] true, if the model referenced is an internal model
    def internal?
      @language.is_a? Symbol
    end

    # Check if this instance represents an external model file
    #
    # @return [Boolean] true, if the model referenced is an external file
    def external?
      !internal?
    end

    # Get the full (absolute) path to the language model file
    #
    # @return [String] Path to the language model
    def path
      @path ||= ( internal? ? internal_path : external_path )
    end

    # Load the distribution file into a distribution object
    #
    # @return [EncodingEstimator::Distribution] Object representing the language model
    def distribution
      @distribution ||= EncodingEstimator::Distribution.new( self )
    end

    private

    # Create the file path to the language statistics file
    #
    # @return [String] File path
    def internal_path
      File.expand_path( File.dirname( __FILE__ ) + "/lang/#{@language.to_s}.json" )
    end

    # Return the language file path
    #
    # @return [String] File path
    def external_path
      File.expand_path( @language )
    end
  end
end
