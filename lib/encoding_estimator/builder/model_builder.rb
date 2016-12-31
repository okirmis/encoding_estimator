require 'htmlentities'

module EncodingEstimator

  # Class which allows building language models (character count statistics) from a single file
  class ModelBuilder
    attr_reader   :filename

    # Create a new object for a given file
    #
    # @param [String] filename Path to the file to learn statistics from
    def initialize( filename )
      @filename = filename
    end

    # Count all characters in the file
    #
    # @return [Hash] Hash mapping each character found in the file to the number of occurrences
    def execute
      content = load_content

      stats = {}
      content.each_char { |c| stats[c] = stats.fetch(c, 0) + 1 }

      stats
    end

    # Combine multiple character count statistics to one single table. Also, characters
    # occurring less often then a threshold are ignored. The final table is scaled
    # linear (and mapped to a score of 1 to 10)
    #
    # @param [Array<Hash>] stats_collection   Array of character count statistics as returned by ModelBuilder.encode
    # @param [Float]       min_char_threshold Threshold used to decide, which characters to include
    #                                         (include a char if count/max_count >= threshold)
    # @return [Hash] Character count statistics, in linear scale, score from 1 to 10
    def self.join_and_postprocess( stats_collection, min_char_threshold = 0.0001 )
      stats     = {}
      log_stats = {}

      # Join all stats
      stats_collection.each do |stat|
        stat.each { |char, count| stats[char] = stats.fetch(char, 0) + count }
      end

      max_count = stats.values.max
      stats.each do |char, count|
        next if count < max_count * min_char_threshold

        log_stats[ char ] = ( 10.0 * count / max_count ).round( 6 )
      end

      log_stats
    end

    private

    # Load the content from the file specified in the constructor. HTML entities are decoded because of large
    # collections of natural language from the internet are used (e.g. Wikipedia).
    #
    # @return [String] Content of the file without whitespaces
    def load_content
      raw       = File.read( @filename, encoding: 'utf-8' ).encode('UTF-16be', invalid: :replace, replace: '').encode('UTF-8')
      decoder   = HTMLEntities.new
      plaintext = decoder.decode raw

      plaintext.gsub! /\s/, ''
      plaintext
    end
  end
end
